import 'dart:async';
import 'api_service.dart';
import 'session_service.dart';
import '../router/auth_notifier.dart';

class ActivityService {
  // ── Configuración ── ajusta estos valores desde un solo lugar ──────────────
  static const Duration inactivityTimeout = Duration(minutes: 30);
  static const Duration tokenRefreshThreshold = Duration(minutes: 2);
  static const Duration _checkInterval = Duration(minutes: 1);
  // ──────────────────────────────────────────────────────────────────────────

  static final ActivityService instance = ActivityService._();
  ActivityService._();

  Timer? _timer;
  DateTime _lastActivity = DateTime.now();
  bool _isRefreshing = false;
  bool _isRunning = false;

  void start() {
    if (_isRunning) return;
    _isRunning = true;
    _lastActivity = DateTime.now();
    _timer = Timer.periodic(_checkInterval, (_) => _tick());
  }

  void stop() {
    _isRunning = false;
    _timer?.cancel();
    _timer = null;
  }

  void recordActivity() {
    _lastActivity = DateTime.now();
    _tryRefreshToken();
  }

  Future<void> _tick() async {
    final inactiveFor = DateTime.now().difference(_lastActivity);
    if (inactiveFor >= inactivityTimeout) {
      await _expireSession();
    } else {
      await _tryRefreshToken();
    }
  }

  Future<void> _tryRefreshToken() async {
    if (_isRefreshing) return;

    final session = await SessionService.getSession();
    if (session == null) return;

    final expiresAtStr = session['tokenExpiresAt'] as String? ?? '';
    if (expiresAtStr.isEmpty) return;

    final expiresAt = DateTime.tryParse(expiresAtStr);
    if (expiresAt == null) return;

    final timeUntilExpiry = expiresAt.toLocal().difference(DateTime.now());
    if (timeUntilExpiry > tokenRefreshThreshold) return;

    final refreshToken = session['refreshToken'] as String? ?? '';
    if (refreshToken.isEmpty) return;

    _isRefreshing = true;
    try {
      final result = await ApiService.refreshAccessToken(refreshToken);
      await SessionService.updateTokens(
        token: result['auth_token'] as String,
        tokenExpiresAt: result['auth_token_expires_at'] as String,
        refreshToken: result['refresh_token'] as String,
      );
    } on ApiException {
      // Refresh token expirado — cerrar sesión
      await _expireSession();
    } catch (_) {
      // Error de red — ignorar, se reintenta en el próximo tick
    } finally {
      _isRefreshing = false;
    }
  }

  Future<void> _expireSession() async {
    stop();
    await SessionService.clearSession();
    AuthNotifier.instance.notifySessionExpired();
  }
}
