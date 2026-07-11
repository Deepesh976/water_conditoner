import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin
  _localNotifications =
  FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    // Android notification settings
    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings settings =
    InitializationSettings(
      android: androidSettings,
    );

    await _localNotifications.initialize(settings);

    // Foreground notifications
    FirebaseMessaging.onMessage.listen(
          (RemoteMessage message) async {
        print(
            "Notification Received: ${message.notification?.title}");

        const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'water_conditioner_channel',
          'Water Conditioner Alerts',
          importance: Importance.max,
          priority: Priority.high,
        );

        const NotificationDetails details =
        NotificationDetails(
          android: androidDetails,
        );

        await _localNotifications.show(
          0,
          message.notification?.title ?? "Alert",
          message.notification?.body ?? "",
          details,
        );
      },
    );

    // App opened from notification
    FirebaseMessaging.onMessageOpenedApp.listen(
          (RemoteMessage message) {
        print(
            "Notification clicked: ${message.data}");
      },
    );
  }
}