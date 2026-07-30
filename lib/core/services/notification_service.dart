import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin
  _localNotifications =
  FlutterLocalNotificationsPlugin();

  static const String _channelId = "water_conditioner_channel";
  static const String _groupKey = "water_conditioner_group";
  static const int _summaryId = 0;

  static Future<void> initialize() async {
    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
    );

    await _localNotifications.initialize(settings);

    FirebaseMessaging.onMessage.listen(
          (RemoteMessage message) async {

        print("Notification Data: ${message.data}");
        print("Notification Title: ${message.notification?.title}");

        // Ignore Channel Recovered notifications
        if (message.data["type"] == "CHANNEL_RECOVERED") {
          print("CHANNEL_RECOVERED notification ignored");
          return;
        }

        // Individual notification
        const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          _channelId,
          'Water Conditioner Alerts',
          importance: Importance.max,
          priority: Priority.high,
          groupKey: _groupKey,
          playSound: true,
          enableVibration: true,
        );

        const NotificationDetails details =
        NotificationDetails(android: androidDetails);

        await _localNotifications.show(
          DateTime.now().millisecondsSinceEpoch.remainder(100000),
          message.notification?.title ?? "Alert",
          message.notification?.body ?? "",
          details,
        );

        // Group summary notification
        const AndroidNotificationDetails summaryDetails =
        AndroidNotificationDetails(
          _channelId,
          'Water Conditioner Alerts',
          importance: Importance.max,
          priority: Priority.high,
          groupKey: _groupKey,
          setAsGroupSummary: true,
        );

        await _localNotifications.show(
          _summaryId,
          "Water Conditioner",
          "Tap to view notifications",
          const NotificationDetails(
            android: summaryDetails,
          ),
        );
      },
    );

    FirebaseMessaging.onMessageOpenedApp.listen(
          (RemoteMessage message) {
        print("Notification clicked: ${message.data}");
      },
    );
  }
}