import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    await _plugin.initialize(settings);
  }

  static Future<void> mostrarNotificacion({
    required int id,
    required String titulo,
    required String cuerpo,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'preventapp_channel',
      'PreventApp',
      channelDescription: 'Notificaciones de PreventApp',
      importance: Importance.high,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    await _plugin.show(id, titulo, cuerpo, details, payload: payload);
  }

  static Future<void> notificarAsesoriaAgendada(String fecha, String hora) async {
    await mostrarNotificacion(
      id: 1,
      titulo: 'Asesoría Agendada',
      cuerpo: 'Tu asesoría ha sido programada para el $fecha a las $hora.',
    );
  }

  static Future<void> notificarRecordatorio(String mensaje) async {
    await mostrarNotificacion(
      id: 2,
      titulo: 'Recordatorio PreventApp',
      cuerpo: mensaje,
    );
  }

  static Future<void> notificarFormularioGuardado(String nombre) async {
    await mostrarNotificacion(
      id: 3,
      titulo: 'Formulario guardado',
      cuerpo: '$nombre ha sido guardado automáticamente.',
    );
  }
}
