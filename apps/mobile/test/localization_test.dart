import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_hour/core/localization/locale_provider.dart';
import 'package:golden_hour/core/services/secure_storage_service.dart';
import 'package:golden_hour/features/auth/data/auth_repository.dart';
import 'package:golden_hour/features/auth/domain/auth_provider.dart';
import 'package:golden_hour/features/auth/domain/auth_state.dart';
import 'package:golden_hour/features/profile/data/profile_models.dart';
import 'package:golden_hour/features/profile/data/profile_repository.dart';
import 'package:golden_hour/features/profile/domain/profile_provider.dart';
import 'package:golden_hour/features/profile/domain/profile_state.dart';
import 'package:golden_hour/features/settings/presentation/settings_screen.dart';
import 'package:golden_hour/l10n/app_localizations.dart';

class _FakeAuthRepository implements AuthRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeProfileRepository implements ProfileRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockAuthNotifier extends AuthNotifier {
  MockAuthNotifier(AuthState initialState) : super(_FakeAuthRepository()) {
    state = initialState;
  }
}

class MockProfileNotifier extends ProfileNotifier {
  MockProfileNotifier(ProfileState initialState)
      : super(_FakeProfileRepository()) {
    state = initialState;
  }
}

class FakeSecureStorageService extends SecureStorageService {
  final Map<String, String> _data = {};

  @override
  Future<String?> getLocale() async => _data['app_locale'];

  @override
  Future<void> saveLocale(String languageCode) async {
    _data['app_locale'] = languageCode;
  }
}

void main() {
  group('ARB Key Parity & Completeness', () {
    test('All ARB files exist and contain identical translation keys', () {
      final enFile = File('lib/l10n/app_en.arb');
      final hiFile = File('lib/l10n/app_hi.arb');
      final esFile = File('lib/l10n/app_es.arb');

      expect(enFile.existsSync(), isTrue);
      expect(hiFile.existsSync(), isTrue);
      expect(esFile.existsSync(), isTrue);

      final enMap = jsonDecode(enFile.readAsStringSync()) as Map<String, dynamic>;
      final hiMap = jsonDecode(hiFile.readAsStringSync()) as Map<String, dynamic>;
      final esMap = jsonDecode(esFile.readAsStringSync()) as Map<String, dynamic>;

      final enKeys = enMap.keys.where((k) => !k.startsWith('@')).toSet();
      final hiKeys = hiMap.keys.where((k) => !k.startsWith('@')).toSet();
      final esKeys = esMap.keys.where((k) => !k.startsWith('@')).toSet();

      expect(enKeys.isNotEmpty, isTrue);
      expect(hiKeys, equals(enKeys),
          reason: 'Hindi translations must match all English keys');
      expect(esKeys, equals(enKeys),
          reason: 'Spanish translations must match all English keys');
    });
  });

  group('Locale Notifier & AppLocales Unit Tests', () {
    test('AppLocales lists English, Hindi, and Spanish', () {
      expect(AppLocales.supportedLanguages.length, 3);
      expect(AppLocales.defaultLocale, const Locale('en'));

      final hi = AppLocales.fromCode('hi');
      expect(hi.code, 'hi');
      expect(hi.nativeName, 'हिन्दी');
      expect(hi.flag, '🇮🇳');

      final es = AppLocales.fromCode('es');
      expect(es.code, 'es');
      expect(es.nativeName, 'Español');
      expect(es.flag, '🇪🇸');

      final unknown = AppLocales.fromCode('de');
      expect(unknown.code, 'en');
    });

    test('LocaleNotifier switches locale and persists to storage', () async {
      final fakeStorage = FakeSecureStorageService();
      final notifier = LocaleNotifier(fakeStorage);

      expect(notifier.state, const Locale('en'));

      await notifier.setLocale('hi');
      expect(notifier.state, const Locale('hi'));
      expect(await fakeStorage.getLocale(), 'hi');

      await notifier.setLocale('es');
      expect(notifier.state, const Locale('es'));
      expect(await fakeStorage.getLocale(), 'es');

      await notifier.setLocale('en');
      expect(notifier.state, const Locale('en'));
      expect(await fakeStorage.getLocale(), 'en');
    });

    test('AppLocalizations loads valid localized content for each locale', () async {
      final en = await AppLocalizations.delegate.load(const Locale('en'));
      expect(en.appTitle, 'Golden Hour');
      expect(en.emergencySos, 'Emergency SOS');
      expect(en.language, 'Language');

      final hi = await AppLocalizations.delegate.load(const Locale('hi'));
      expect(hi.appTitle, 'गोल्डन ऑवर');
      expect(hi.emergencySos, 'आपातकालीन एसओएस');
      expect(hi.language, 'भाषा');

      final es = await AppLocalizations.delegate.load(const Locale('es'));
      expect(es.appTitle, 'Golden Hour');
      expect(es.emergencySos, 'SOS de emergencia');
      expect(es.language, 'Idioma');
    });
  });

  group('Language Selection Widget Tests', () {
    testWidgets('SettingsScreen renders language selector and switches locale',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final fakeStorage = FakeSecureStorageService();
      const authState = AuthState(
        status: AuthStatus.authenticated,
        phone: '+919876543210',
        userId: 'user-77',
      );
      const profileState = ProfileState(
        profile: PatientProfile(
          id: 'p-1',
          userId: 'user-77',
          fullName: 'Ganesh Thota',
          bloodGroup: 'O+',
          qrIsActive: true,
        ),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            secureStorageServiceProvider.overrideWithValue(fakeStorage),
            authNotifierProvider
                .overrideWith((ref) => MockAuthNotifier(authState)),
            profileNotifierProvider
                .overrideWith((ref) => MockProfileNotifier(profileState)),
          ],
          child: const MaterialApp(
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            home: SettingsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Language Section exists
      expect(find.text('Language'), findsOneWidget);
      expect(find.byKey(const ValueKey('language_en')), findsOneWidget);
      expect(find.byKey(const ValueKey('language_hi')), findsOneWidget);
      expect(find.byKey(const ValueKey('language_es')), findsOneWidget);
      expect(find.text('हिन्दी'), findsOneWidget);
      expect(find.text('Español'), findsOneWidget);

      // Tap Hindi option
      final hiChip = find.byKey(const ValueKey('language_hi'));
      expect(hiChip, findsOneWidget);
      await tester.tap(hiChip);
      await tester.pumpAndSettle();

      expect(await fakeStorage.getLocale(), 'hi');

      // Tap Spanish option
      final esChip = find.byKey(const ValueKey('language_es'));
      expect(esChip, findsOneWidget);
      await tester.tap(esChip);
      await tester.pumpAndSettle();

      expect(await fakeStorage.getLocale(), 'es');
    });
  });
}
