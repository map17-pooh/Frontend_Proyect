import 'package:flutter/material.dart';
import 'router/app_router.dart';
import 'services/activity_service.dart';
import 'services/notification_service.dart';
import 'services/session_service.dart';
import 'widgets/offline_banner.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.initialize();

  // Si hay sesión activa al arrancar, reanudar tracking de actividad
  final hasSession = await SessionService.hasActiveSession();
  if (hasSession) {
    ActivityService.instance.start();
  }

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'PreventApp',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF00A99D),
          secondary: Color(0xFF00A99D),
        ),
        iconTheme: const IconThemeData(
          color: Color(0xFF00A99D),
          size: 24,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
          ),
        ),
      ),
      routerConfig: appRouter,
      builder: (context, child) {
        return Listener(
          behavior: HitTestBehavior.translucent,
          onPointerDown: (_) => ActivityService.instance.recordActivity(),
          onPointerMove: (_) => ActivityService.instance.recordActivity(),
          child: OfflineBanner(child: child ?? const SizedBox()),
        );
      },
    );
  }
}