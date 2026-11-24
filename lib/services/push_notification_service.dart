import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class PushNotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  static int _nextNotificationId = 0;

  // 1. Inicializar el plugin de notificaciones (se llama en el main.dart)
  static Future<void> initNotification() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await _notificationsPlugin.initialize(initializationSettings);
  }

  // 2. Función helper reutilizable para mandar la notificación real
  static Future<void> showNotification({
    required String title,
    required String body,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'te_ayudo_channel_id', // ID del canal
          'Te Ayudo Notificaciones', // Nombre del canal
          channelDescription: 'Canal principal para alertas de la app',
          importance: Importance.max,
          priority: Priority.high,
          ticker: 'ticker',
        );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    // Muestra la notificación en la barra de estado del celular
    await _notificationsPlugin.show(
      _nextNotificationId++,
      title,
      body,
      notificationDetails,
    );
  }

  static Future<void> showPaymentNotifications({
    required String serviceType,
    required double workerAmount,
    required double totalAmount,
  }) async {
    await Future.wait([
      showNotification(
        title: 'Pago realizado',
        body:
            'Se confirmó el pago simulado de '
            '\$${totalAmount.toStringAsFixed(2)} MXN para $serviceType.',
      ),
      showNotification(
        title: 'Pago obtenido',
        body:
            'Se registró el pago simulado de '
            '\$${workerAmount.toStringAsFixed(2)} MXN por $serviceType.',
      ),
    ]);
  }
}
