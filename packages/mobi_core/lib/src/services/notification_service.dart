import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

class NotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final Logger _logger = Logger();

  Future<void> initialize() async {
    // Request permission
    await requestPermission();

    // Get FCM token
    final token = await getToken();
    if (token != null) {
      _logger.i('FCM Token: $token');
    }

    // Listen to token refresh
    _fcm.onTokenRefresh.listen((newToken) {
      _logger.i('FCM Token refreshed: $newToken');
      // TODO: Send new token to backend
    });

    // Setup message handlers
    setupMessageHandlers();
  }

  Future<NotificationSettings> requestPermission() async {
    return await _fcm.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
  }

  Future<String?> getToken() async {
    try {
      return await _fcm.getToken();
    } catch (e) {
      _logger.e('Error getting FCM token: $e');
      return null;
    }
  }

  void setupMessageHandlers() {
    // Foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _logger.i('Foreground message received: ${message.messageId}');
      _handleMessage(message);
    });

    // Background messages (when app is in background but not terminated)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _logger.i('Message opened app: ${message.messageId}');
      _handleMessage(message);
    });

    // Check if app was opened from a terminated state
    _fcm.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        _logger.i('App opened from terminated state: ${message.messageId}');
        _handleMessage(message);
      }
    });
  }

  void _handleMessage(RemoteMessage message) {
    _logger.i('Handling message: ${message.data}');

    if (message.notification != null) {
      _logger.i('Notification title: ${message.notification?.title}');
      _logger.i('Notification body: ${message.notification?.body}');
    }

    // Handle different notification types based on data
    final data = message.data;
    final type = data['type'];

    switch (type) {
      case 'ride_accepted':
        _handleRideAccepted(data);
        break;
      case 'ride_started':
        _handleRideStarted(data);
        break;
      case 'ride_completed':
        _handleRideCompleted(data);
        break;
      case 'driver_arrived':
        _handleDriverArrived(data);
        break;
      case 'payment_processed':
        _handlePaymentProcessed(data);
        break;
      default:
        _logger.w('Unknown notification type: $type');
    }
  }

  void _handleRideAccepted(Map<String, dynamic> data) {
    // TODO: Navigate to ride tracking screen or show notification
    _logger.i('Ride accepted: ${data['ride_id']}');
  }

  void _handleRideStarted(Map<String, dynamic> data) {
    // TODO: Navigate to active ride screen
    _logger.i('Ride started: ${data['ride_id']}');
  }

  void _handleRideCompleted(Map<String, dynamic> data) {
    // TODO: Navigate to ride summary screen
    _logger.i('Ride completed: ${data['ride_id']}');
  }

  void _handleDriverArrived(Map<String, dynamic> data) {
    // TODO: Show driver arrived notification
    _logger.i('Driver arrived: ${data['ride_id']}');
  }

  void _handlePaymentProcessed(Map<String, dynamic> data) {
    // TODO: Show payment confirmation
    _logger.i('Payment processed: ${data['payment_id']}');
  }

  Future<void> subscribeToTopic(String topic) async {
    try {
      await _fcm.subscribeToTopic(topic);
      _logger.i('Subscribed to topic: $topic');
    } catch (e) {
      _logger.e('Error subscribing to topic: $e');
    }
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _fcm.unsubscribeFromTopic(topic);
      _logger.i('Unsubscribed from topic: $topic');
    } catch (e) {
      _logger.e('Error unsubscribing from topic: $e');
    }
  }

  Future<void> deleteToken() async {
    try {
      await _fcm.deleteToken();
      _logger.i('FCM token deleted');
    } catch (e) {
      _logger.e('Error deleting FCM token: $e');
    }
  }
}

// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  final logger = Logger();
  logger.i('Background message: ${message.messageId}');
}
