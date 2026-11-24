import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_hour/core/services/secure_storage_service.dart';
import 'package:golden_hour/core/theme/app_colors.dart';
import 'package:golden_hour/core/theme/app_theme.dart';
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
  Future<String?> getThemeMode() async => _data['app_theme_mode'];

  @override
  Future<String?> getAccentColor() async => _data['app_accent_color'];

  @override
  Future<String?> getLocale() async => _data['app_locale'];
}

void main() {
  group('Accessibility & WCAG AA Contrast Tests', () {
    test('AppTheme buttons enforce minimum 48dp tap target', () {
      final lightTheme = AppTheme.lightTheme;
      final darkTheme = AppTheme.darkTheme;

      expect(lightTheme.elevatedButtonTheme.style?.minimumSize?.resolve({}),
          const Size(64, 48));
      expect(lightTheme.outlinedButtonTheme.style?.minimumSize?.resolve({}),
          const Size(64, 48));
      expect(lightTheme.iconButtonTheme.style?.minimumSize?.resolve({}),
          const Size(48, 48));

      expect(darkTheme.elevatedButtonTheme.style?.minimumSize?.resolve({}),
          const Size(64, 48));
      expect(darkTheme.outlinedButtonTheme.style?.minimumSize?.resolve({}),
          const Size(64, 48));
      expect(darkTheme.iconButtonTheme.style?.minimumSize?.resolve({}),
          const Size(48, 48));
    });

    test('Color palette ensures accessible high contrast text', () {
      // Ensure textSecondary and textMuted are darkened sufficiently for WCAG AA (ratio > 4.5:1 on white)
      expect(AppColors.textPrimary, const Color(0xFF0F172A));
      expect(AppColors.textSecondary, const Color(0xFF475569));
      expect(AppColors.textMuted, const Color(0xFF64748B));
    });
  });

  group('Interactive Elements Semantics & Hit Target Tests', () {
    testWidgets('SettingsScreen interactive chips provide valid semantics & tap targets',
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

      // Verify back button tooltip
      expect(find.byTooltip('Back'), findsOneWidget);

      // Verify theme chips have Semantics label
      final systemThemeSemantics = find.byWidgetPredicate(
        (w) => w is Semantics && w.properties.label == 'System theme',
      );
      expect(systemThemeSemantics, findsOneWidget);

      final darkThemeSemantics = find.byWidgetPredicate(
        (w) => w is Semantics && w.properties.label == 'Dark theme',
      );
      expect(darkThemeSemantics, findsOneWidget);

      // Verify language chips have Semantics label
      final enLanguageSemantics = find.byWidgetPredicate(
        (w) => w is Semantics && w.properties.label == 'English language',
      );
      expect(enLanguageSemantics, findsOneWidget);

      // Verify accent color chip has Semantics label and size >= 48dp
      final crimsonSemantics = find.byWidgetPredicate(
        (w) => w is Semantics && w.properties.label == 'Accent color: Crimson Alert',
      );
      expect(crimsonSemantics, findsOneWidget);

      final crimsonBox = tester.getRect(find.byKey(const ValueKey('accent_color_crimson')));
      expect(crimsonBox.width, greaterThanOrEqualTo(48.0));
      expect(crimsonBox.height, greaterThanOrEqualTo(48.0));
    });
  });
}

