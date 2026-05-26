import 'package:go_router/go_router.dart';
import '../menu_inicio.dart';
import '../login_usuario_externo.dart';
import '../login_interno_admin.dart';
import '../perfil_usuario_externo.dart';
import '../perfil_interno_admin.dart';
import '../modulo_educativo.dart';
import '../formulario_caracterizacion.dart';
import '../historial_clinico.dart';
import '../agendar_asesoria.dart';
import '../reportes_dashboard.dart';
import '../gestion_usuarios.dart';
import '../registro_usuario_externo.dart';
import '../registro_interno_admin.dart';
import '../services/session_service.dart';
import 'auth_notifier.dart';

class AppRoutes {
  static const menu = '/';
  static const loginExterno = '/login/externo';
  static const loginInterno = '/login/interno';
  static const perfilExterno = '/perfil/externo';
  static const perfilInterno = '/perfil/interno';
  static const moduloEducativo = '/modulo-educativo';
  static const caracterizacion = '/caracterizacion';
  static const historialClinico = '/historial-clinico';
  static const agendarAsesoria = '/agendar-asesoria';
  static const reportes = '/reportes';
  static const gestionUsuarios = '/gestion-usuarios';
  static const registroExterno = '/registro/externo';
  static const registroInterno = '/registro/interno';
}

final appRouter = GoRouter(
  initialLocation: AppRoutes.menu,
  refreshListenable: AuthNotifier.instance,
  redirect: (context, state) async {
    final isAuthRoute = state.matchedLocation == AppRoutes.loginExterno ||
        state.matchedLocation == AppRoutes.loginInterno ||
        state.matchedLocation == AppRoutes.menu ||
        state.matchedLocation == AppRoutes.registroExterno ||
        state.matchedLocation == AppRoutes.registroInterno ||
        state.matchedLocation == AppRoutes.moduloEducativo;
    if (isAuthRoute) return null;

    final hasSession = await SessionService.hasActiveSession();
    if (!hasSession) return AppRoutes.menu;
    return null;
  },
  routes: [
    GoRoute(
      path: AppRoutes.menu,
      builder: (context, state) => const MenuInicio(),
    ),
    GoRoute(
      path: AppRoutes.loginExterno,
      builder: (context, state) => const LoginUsuarioExterno(),
    ),
    GoRoute(
      path: AppRoutes.loginInterno,
      builder: (context, state) => const LoginInternoAdmin(),
    ),
    GoRoute(
      path: AppRoutes.registroExterno,
      builder: (context, state) => const RegistroUsuarioExterno(),
    ),
    GoRoute(
      path: AppRoutes.registroInterno,
      builder: (context, state) => const RegistroInternoAdmin(),
    ),
    GoRoute(
      path: AppRoutes.moduloEducativo,
      builder: (context, state) => const ModuloEducativo(),
    ),
    GoRoute(
      path: AppRoutes.perfilExterno,
      builder: (context, state) {
        final perfilData = state.extra as Map<String, dynamic>? ?? {};
        return PerfilUsuarioExterno(perfilData: perfilData);
      },
    ),
    GoRoute(
      path: AppRoutes.perfilInterno,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>? ?? {};
        return PerfilInternoAdmin(
          perfilData: extra['perfilData'] as Map<String, dynamic>? ?? {},
          rol: extra['rol'] as String? ?? 'Interno',
        );
      },
    ),
    GoRoute(
      path: AppRoutes.caracterizacion,
      builder: (context, state) => const FormularioCaracterizacion(),
    ),
    GoRoute(
      path: AppRoutes.historialClinico,
      builder: (context, state) => const HistorialClinico(),
    ),
    GoRoute(
      path: AppRoutes.agendarAsesoria,
      builder: (context, state) => const AgendarAsesoria(),
    ),
    GoRoute(
      path: AppRoutes.reportes,
      builder: (context, state) {
        final rol = state.extra as String? ?? 'Interno';
        return ReportesDashboard(rol: rol);
      },
    ),
    GoRoute(
      path: AppRoutes.gestionUsuarios,
      builder: (context, state) {
        final rol = state.extra as String? ?? 'Interno';
        return GestionUsuarios(rol: rol);
      },
    ),
  ],
);
