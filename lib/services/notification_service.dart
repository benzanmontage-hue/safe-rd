import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../core/constants.dart';

/// Push notification service using Firebase Cloud Messaging.
/// Sends alerts for new incidents and SOS confirmations.
class NotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _local = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  /// User's FCM token for server-side targeting
  String? fcmToken;

  /// Stream of incoming messages
  Stream<RemoteMessage> get onMessage => FirebaseMessaging.onMessage;

  /// Stream of notification taps (when user opens app from notification)
  Stream<RemoteMessage> get onMessageOpened =>
      FirebaseMessaging.onMessageOpenedApp;

  Future<void> init() async {
    if (_initialized) return;

    // Request permissions
    await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Get FCM token
    fcmToken = await _fcm.getToken();
    _fcm.onTokenRefresh.listen((token) => fcmToken = token);

    // Subscribe to incident alerts topic
    await _fcm.subscribeToTopic(AppConstants.notificationsTopic);

    // Local notification setup (Android)
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    await _local.initialize(
      const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
    );

    // Handle foreground messages with local notification
    FirebaseMessaging.onMessage.listen(_showLocalNotification);

    _initialized = true;
  }

  /// Show a local notification (when app is in foreground)
  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    await _local.show(
      message.hashCode,
      notification.title ?? 'SafeRD Alert',
      notification.body ?? 'Nueva alerta de seguridad',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'incident_alerts',
          'Incident Alerts',
          channelDescription: 'Alertas de incidentes cercanos',
          importance: Importance.high,
          priority: Priority.high,
          color: Color(0xFFFF6A00),
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: message.data['incidentId'],
    );
  }

  /// Show a local incident alert
  Future<void> showIncidentAlert(String type, String location, double distanceKm) async {
    await _local.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      '$type cerca de ti',
      '$location a ${distanceKm.toStringAsFixed(1)} km',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'incident_alerts',
          'Incident Alerts',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
    );
  }

  Future<void> dispose() async {
    await _fcm.unsubscribeFromTopic(AppConstants.notificationsTopic);
    await _local.cancelAll();
  }
}
