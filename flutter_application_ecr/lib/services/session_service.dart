import 'package:shared_preferences/shared_preferences.dart';

class SessionService {
  static const _keyToken = 'auth_token';
  static const _keyUserId = 'user_id';
  static const _keyNombre = 'user_nombre';
  static const _keyEmail = 'user_email';
  static const _keyRol = 'user_rol';
  static const _keyTipoDocumento = 'user_tipo_documento';
  static const _keyNumeroDocumento = 'user_numero_documento';
  static const _keyFechaNacimiento = 'user_fecha_nacimiento';
  static const _keyDireccion = 'user_direccion';
  static const _keyTelefono = 'user_telefono';
  static const _keyEsMenor14 = 'user_es_menor_14';
  static const _keyRefreshToken = 'refresh_token';
  static const _keyTokenExpiresAt = 'token_expires_at';

  static Future<void> saveSession({
    required String token,
    required String userId,
    required String nombre,
    required String email,
    required String rol,
    String tipoDocumento = '',
    String numeroDocumento = '',
    String fechaNacimiento = '',
    String direccion = '',
    String telefono = '',
    bool esMenor14 = false,
    String refreshToken = '',
    String tokenExpiresAt = '',
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyToken, token);
    await prefs.setString(_keyUserId, userId);
    await prefs.setString(_keyNombre, nombre);
    await prefs.setString(_keyEmail, email);
    await prefs.setString(_keyRol, rol);
    await prefs.setString(_keyTipoDocumento, tipoDocumento);
    await prefs.setString(_keyNumeroDocumento, numeroDocumento);
    await prefs.setString(_keyFechaNacimiento, fechaNacimiento);
    await prefs.setString(_keyDireccion, direccion);
    await prefs.setString(_keyTelefono, telefono);
    await prefs.setBool(_keyEsMenor14, esMenor14);
    await prefs.setString(_keyRefreshToken, refreshToken);
    await prefs.setString(_keyTokenExpiresAt, tokenExpiresAt);
  }

  static Future<void> updateTokens({
    required String token,
    required String tokenExpiresAt,
    required String refreshToken,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyToken, token);
    await prefs.setString(_keyTokenExpiresAt, tokenExpiresAt);
    await prefs.setString(_keyRefreshToken, refreshToken);
  }

  static Future<Map<String, dynamic>?> getSession() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_keyToken);
    if (token == null || token.isEmpty) return null;
    return {
      'token': token,
      'userId': prefs.getString(_keyUserId) ?? '',
      'nombre': prefs.getString(_keyNombre) ?? '',
      'email': prefs.getString(_keyEmail) ?? '',
      'rol': prefs.getString(_keyRol) ?? '',
      'tipoDocumento': prefs.getString(_keyTipoDocumento) ?? '',
      'numeroDocumento': prefs.getString(_keyNumeroDocumento) ?? '',
      'fechaNacimiento': prefs.getString(_keyFechaNacimiento) ?? '',
      'direccion': prefs.getString(_keyDireccion) ?? '',
      'telefono': prefs.getString(_keyTelefono) ?? '',
      'esMenor14': prefs.getBool(_keyEsMenor14) ?? false,
      'refreshToken': prefs.getString(_keyRefreshToken) ?? '',
      'tokenExpiresAt': prefs.getString(_keyTokenExpiresAt) ?? '',
    };
  }

  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyToken);
    await prefs.remove(_keyUserId);
    await prefs.remove(_keyNombre);
    await prefs.remove(_keyEmail);
    await prefs.remove(_keyRol);
    await prefs.remove(_keyTipoDocumento);
    await prefs.remove(_keyNumeroDocumento);
    await prefs.remove(_keyFechaNacimiento);
    await prefs.remove(_keyDireccion);
    await prefs.remove(_keyTelefono);
    await prefs.remove(_keyEsMenor14);
    await prefs.remove(_keyRefreshToken);
    await prefs.remove(_keyTokenExpiresAt);
  }

  static Future<bool> hasActiveSession() async {
    final session = await getSession();
    return session != null;
  }
}
