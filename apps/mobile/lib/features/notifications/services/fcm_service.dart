import 'dart:developer' as developer;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../data/notification_repository.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp();
    }
  } catch (_) {}
  developer.log(
    'Handling background emergency notification: ${message.messageId} - ${message.notification?.title}',
    name: 'FCMBackground',
  );
}

class FCMService {
  final NotificationRepository? _repository;
  bool _isInitialized = false;

  FCMService([this._repository]);

  bool get isInitialized => _isInitialized;

  Future<void> initialize({
    Function(RemoteMessage)? onForegroundMessage,
  }) async {
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp();
      }

      final messaging = FirebaseMessaging.instance;

      // 1. Request notification permissions (critical for iOS & Android 13+)
      final settings = await messaging.requestPermission(
        alert: true,
        announcement: true,
        badge: true,
        carPlay: false,
        criticalAlert: true,
        provisional: false,
        sound: true,
      );

      developer.log(
        'FCM Permission authorization status: ${settings.authorizationStatus}',
        name: 'FCMService',
      );

      // 2. Set background message handler
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      // 3. Obtain initial FCM token and register with backend
      final token = await messaging.getToken();
      if (token != null && token.isNotEmpty) {
        developer.log('Device FCM Token obtained: ${token.substring(0, 12)}...',
            name: 'FCMService');
        if (_repository != null) {
          await _repository.registerFcmToken(token);
        }
      }

      // 4. Listen to token refresh
      messaging.onTokenRefresh.listen((newToken) async {
        developer.log('FCM Token refreshed: ${newToken.substring(0, 12)}...',
            name: 'FCMService');
        if (_repository != null) {
          try {
            await _repository.registerFcmToken(newToken);
          } catch (e) {
            developer.log('Failed to register refreshed FCM token: $e',
                name: 'FCMService');
          }
        }
      });

      // 5. Handle foreground notifications
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        developer.log(
          'Emergency notification received in foreground: ${message.notification?.title} - ${message.notification?.body}',
          name: 'FCMService',
        );
        if (onForegroundMessage != null) {
          onForegroundMessage(message);
        }
      });

      _isInitialized = true;
    } catch (e) {
      // In simulator/test or environments without Google Services JSON, log gracefully
      developer.log('FCM initialization skipped or failed: $e',
          name: 'FCMService');
    }
  }

  Future<String?> getToken() async {
    try {
      return await FirebaseMessaging.instance.getToken();
    } catch (e) {
      return null;
    }
  }
}
