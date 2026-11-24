import 'dart:developer' as developer;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/notification_models.dart';
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

final fcmServiceProvider = Provider<FCMService>((ref) {
  final repo = ref.watch(notificationRepositoryProvider);
  return FCMService(repo);
});

class FCMService {
  final NotificationRepository? _repository;
  bool _isInitialized = false;

  FCMService([this._repository]);

  bool get isInitialized => _isInitialized;

  /// Parse RemoteMessage into structured NotificationPayload supporting data-only packets
  NotificationPayload parseMessage(RemoteMessage message) {
    return NotificationPayload.fromDataMap(
      notificationTitle: message.notification?.title,
      notificationBody: message.notification?.body,
      data: message.data,
    );
  }

  /// Track notification opened analytics event
  void logNotificationOpened(NotificationPayload payload) {
    developer.log(
      'analytics_event=notification_opened category=${payload.category} title=${payload.title} scan_id=${payload.scanId}',
      name: 'FCMAnalytics',
    );
  }

  Future<void> initialize({
    Function(RemoteMessage)? onForegroundMessage,
    Function(RemoteMessage)? onNotificationClick,
    Function(NotificationPayload)? onPayloadAction,
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
          try {
            await _repository.registerFcmToken(token);
          } catch (e) {
            developer.log('Initial FCM token registration deferred: $e',
                name: 'FCMService');
          }
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

      // 6. Handle notification click when app is opened from background
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        final payload = parseMessage(message);
        logNotificationOpened(payload);
        developer.log(
          'Emergency notification clicked: ${message.data}',
          name: 'FCMService',
        );
        if (onNotificationClick != null) {
          onNotificationClick(message);
        }
        if (onPayloadAction != null) {
          onPayloadAction(payload);
        }
      });

      // 7. Check if app was launched from terminated state via notification click
      final initialMessage = await messaging.getInitialMessage();
      if (initialMessage != null) {
        final payload = parseMessage(initialMessage);
        logNotificationOpened(payload);
        developer.log(
          'App opened via notification click from terminated state: ${initialMessage.data}',
          name: 'FCMService',
        );
        if (onNotificationClick != null) {
          onNotificationClick(initialMessage);
        }
        if (onPayloadAction != null) {
          onPayloadAction(payload);
        }
      }

      _isInitialized = true;
    } catch (e) {
      developer.log('FCM initialization skipped or failed: $e',
          name: 'FCMService');
    }
  }

  Future<void> syncTokenWithBackend() async {
    try {
      final messaging = FirebaseMessaging.instance;
      final token = await messaging.getToken();
      if (token != null && token.isNotEmpty && _repository != null) {
        await _repository.registerFcmToken(token);
        developer.log('FCM token synchronized with backend successfully',
            name: 'FCMService');
      }
    } catch (e) {
      developer.log('Failed to sync FCM token with backend: $e',
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

