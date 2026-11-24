import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_hour/core/localization/locale_provider.dart';
import 'package:golden_hour/core/services/analytics_service.dart';
import 'package:golden_hour/core/services/secure_storage_service.dart';
import 'package:golden_hour/core/theme/theme_customizer.dart';
import 'package:golden_hour/core/theme/theme_provider.dart';

class _FakeSecureStorageService implements SecureStorageService {
  final Map<String, String> _data = {};

  @override
  Future<String?> getThemeMode() async => _data['theme_mode'];

  @override
  Future<void> saveThemeMode(String mode) async {
    _data['theme_mode'] = mode;
  }

  @override
  Future<String?> getAccentColor() async => _data['accent_color'];

  @override
  Future<void> saveAccentColor(String colorId) async {
    _data['accent_color'] = colorId;
  }

  @override
  Future<String?> getLocale() async => _data['locale'];

  @override
  Future<void> saveLocale(String localeCode) async {
    _data['locale'] = localeCode;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AnalyticsService Unit Tests', () {
    late AnalyticsService analytics;

    setUp(() {
      analytics = AnalyticsService();
      analytics.clearLoggedEvents();
    });

    test('logGuideViewed records valid event structure', () async {
      await analytics.logGuideViewed(
        guideId: 'cpr_adult',
        category: 'Cardiac',
        title: 'Adult CPR Protocol',
      );

      expect(analytics.loggedEvents.length, 1);
      final event = analytics.loggedEvents.first;
      expect(event['name'], 'guide_viewed');
      expect(event['parameters']['guide_id'], 'cpr_adult');
      expect(event['parameters']['category'], 'Cardiac');
      expect(event['parameters']['title'], 'Adult CPR Protocol');
    });

    test('logContactBroadcast records group broadcast parameters', () async {
      await analytics.logContactBroadcast(
        groupId: 'grp-work-1',
        contactCount: 4,
        urgency: 'critical',
      );

      expect(analytics.loggedEvents.length, 1);
      final event = analytics.loggedEvents.first;
      expect(event['name'], 'contact_broadcast');
      expect(event['parameters']['group_id'], 'grp-work-1');
      expect(event['parameters']['contact_count'], 4);
      expect(event['parameters']['urgency'], 'critical');
    });

    test('logSosTriggered records channel and source', () async {
      await analytics.logSosTriggered(
        channel: 'statutory_dialer_112',
        source: 'floating_sos_action',
        hasLocation: true,
      );

      expect(analytics.loggedEvents.length, 1);
      final event = analytics.loggedEvents.first;
      expect(event['name'], 'sos_triggered');
      expect(event['parameters']['channel'], 'statutory_dialer_112');
      expect(event['parameters']['source'], 'floating_sos_action');
      expect(event['parameters']['has_location'], isTrue);
    });

    test('logThemeChanged logs theme mode and accent color', () async {
      await analytics.logThemeChanged(
        themeMode: 'dark',
        accentColor: 'crimson',
      );

      expect(analytics.loggedEvents.length, 1);
      final event = analytics.loggedEvents.first;
      expect(event['name'], 'theme_changed');
      expect(event['parameters']['theme_mode'], 'dark');
      expect(event['parameters']['accent_color'], 'crimson');
    });

    test('logQrShared logs sharing method and image attachment', () async {
      await analytics.logQrShared(
        shareMethod: 'image_xfile',
        hasQrImage: true,
      );

      expect(analytics.loggedEvents.length, 1);
      final event = analytics.loggedEvents.first;
      expect(event['name'], 'qr_shared');
      expect(event['parameters']['share_method'], 'image_xfile');
      expect(event['parameters']['has_qr_image'], isTrue);
    });

    test('logLanguageChanged logs selected locale code', () async {
      await analytics.logLanguageChanged(languageCode: 'hi');

      expect(analytics.loggedEvents.length, 1);
      final event = analytics.loggedEvents.first;
      expect(event['name'], 'language_changed');
      expect(event['parameters']['language_code'], 'hi');
    });

    test('logScreenView logs screen name and optional screen class', () async {
      await analytics.logScreenView(
        screenName: 'ProfileHomeScreen',
        screenClass: 'ProfileHomeScreen',
      );

      expect(analytics.loggedEvents.length, 1);
      final event = analytics.loggedEvents.first;
      expect(event['name'], 'screen_view');
      expect(event['parameters']['screen_name'], 'ProfileHomeScreen');
      expect(event['parameters']['screen_class'], 'ProfileHomeScreen');
    });

    test('gracefully handles setUserId when Firebase is uninitialized', () async {
      expect(() => analytics.setUserId('user-123'), returnsNormally);
    });
  });

  group('Analytics Integration with Core Notifiers', () {
    late AnalyticsService analytics;
    late _FakeSecureStorageService storage;

    setUp(() {
      analytics = AnalyticsService();
      analytics.clearLoggedEvents();
      storage = _FakeSecureStorageService();
    });

    test('ThemeModeNotifier triggers theme_changed event on mode switch', () async {
      final notifier = ThemeModeNotifier(storage, analytics: analytics);

      await notifier.setThemeMode(ThemeMode.dark);
      expect(notifier.state, ThemeMode.dark);

      expect(analytics.loggedEvents.length, 1);
      final event = analytics.loggedEvents.first;
      expect(event['name'], 'theme_changed');
      expect(event['parameters']['theme_mode'], 'dark');
    });

    test('AccentColorNotifier triggers theme_changed event on palette switch', () async {
      final notifier = AccentColorNotifier(storage, analytics: analytics);
      final amberOption = ThemeCustomizer.fromId('amber');

      await notifier.setAccentColor(amberOption);
      expect(notifier.state, amberOption.color);

      expect(analytics.loggedEvents.length, 1);
      final event = analytics.loggedEvents.first;
      expect(event['name'], 'theme_changed');
      expect(event['parameters']['accent_color'], 'amber');
    });

    test('LocaleNotifier triggers language_changed event on locale switch', () async {
      final notifier = LocaleNotifier(storage, analytics: analytics);

      await notifier.setLocale('es');
      expect(notifier.state, const Locale('es'));

      expect(analytics.loggedEvents.length, 1);
      final event = analytics.loggedEvents.first;
      expect(event['name'], 'language_changed');
      expect(event['parameters']['language_code'], 'es');
    });
  });
}
