import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Centralized service for Google Analytics / Firebase Analytics tracking.
/// Designed defensively so tests and environments without active Firebase
/// configurations continue executing seamlessly while preserving in-memory event logs.
class AnalyticsService {
  final FirebaseAnalytics? _analytics;
  final List<Map<String, dynamic>> _inMemoryEvents = [];

  AnalyticsService({FirebaseAnalytics? analytics}) : _analytics = analytics;

  /// Returns an unmodifiable view of logged events for unit/widget testing and audit.
  List<Map<String, dynamic>> get loggedEvents =>
      List.unmodifiable(_inMemoryEvents);

  /// Clears in-memory history (useful in test teardown).
  void clearLoggedEvents() => _inMemoryEvents.clear();

  FirebaseAnalytics? get _instance {
    if (_analytics != null) return _analytics;
    try {
      return FirebaseAnalytics.instance;
    } catch (_) {
      // Firebase not initialized in headless or unit test mode
      return null;
    }
  }

  /// Core event logger.
  Future<void> logEvent(String name, [Map<String, Object>? parameters]) async {
    _inMemoryEvents.add({
      'name': name,
      'parameters': parameters ?? {},
      'timestamp': DateTime.now().toIso8601String(),
    });

    if (kDebugMode) {
      debugPrint('[Analytics] Event: $name, Params: $parameters');
    }

    try {
      final instance = _instance;
      if (instance != null) {
        await instance.logEvent(name: name, parameters: parameters);
      }
    } catch (e) {
      debugPrint('[Analytics] Could not dispatch to Firebase: $e');
    }
  }

  /// Triggered when an emergency response guide is opened.
  Future<void> logGuideViewed({
    required String guideId,
    required String category,
    String? title,
  }) async {
    await logEvent('guide_viewed', {
      'guide_id': guideId,
      'category': category,
      if (title != null) 'title': title,
    });
  }

  /// Triggered when an ICE contact group alert broadcast is dispatched.
  Future<void> logContactBroadcast({
    String? groupId,
    required int contactCount,
    String urgency = 'high',
  }) async {
    await logEvent('contact_broadcast', {
      if (groupId != null) 'group_id': groupId,
      'contact_count': contactCount,
      'urgency': urgency,
    });
  }

  /// Triggered when emergency SOS or statutory helpline dialer is launched.
  Future<void> logSosTriggered({
    required String channel,
    String source = 'app_sos_button',
    bool hasLocation = false,
  }) async {
    await logEvent('sos_triggered', {
      'channel': channel,
      'source': source,
      'has_location': hasLocation,
    });
  }

  /// Triggered when user alters theme mode or accent palette.
  Future<void> logThemeChanged({
    required String themeMode,
    required String accentColor,
  }) async {
    await logEvent('theme_changed', {
      'theme_mode': themeMode,
      'accent_color': accentColor,
    });
  }

  /// Triggered when emergency QR image or secure link is shared.
  Future<void> logQrShared({
    required String shareMethod,
    bool hasQrImage = true,
  }) async {
    await logEvent('qr_shared', {
      'share_method': shareMethod,
      'has_qr_image': hasQrImage,
    });
  }

  /// Triggered when user changes the application display language.
  Future<void> logLanguageChanged({
    required String languageCode,
  }) async {
    await logEvent('language_changed', {
      'language_code': languageCode,
    });
  }

  /// Triggered when viewing a major navigation screen.
  Future<void> logScreenView({
    required String screenName,
    String? screenClass,
  }) async {
    _inMemoryEvents.add({
      'name': 'screen_view',
      'parameters': {
        'screen_name': screenName,
        if (screenClass != null) 'screen_class': screenClass,
      },
      'timestamp': DateTime.now().toIso8601String(),
    });

    try {
      final instance = _instance;
      if (instance != null) {
        await instance.logScreenView(
          screenName: screenName,
          screenClass: screenClass,
        );
      }
    } catch (_) {}
  }

  /// Set the active user ID for analytics tracking.
  Future<void> setUserId(String? userId) async {
    try {
      final instance = _instance;
      if (instance != null) {
        await instance.setUserId(id: userId);
      }
    } catch (_) {}
  }
}

/// Global provider for [AnalyticsService].
final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  return AnalyticsService();
});
