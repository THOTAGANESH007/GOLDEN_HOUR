import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_hour/core/services/secure_storage_service.dart';
import 'package:golden_hour/core/theme/app_colors.dart';
import 'package:golden_hour/core/theme/app_theme.dart';
import 'package:golden_hour/core/theme/theme_customizer.dart';
import 'package:golden_hour/core/theme/theme_provider.dart';
import 'package:golden_hour/features/auth/data/auth_repository.dart';
import 'package:golden_hour/features/auth/domain/auth_provider.dart';
import 'package:golden_hour/features/auth/domain/auth_state.dart';
import 'package:golden_hour/features/profile/data/profile_models.dart';
import 'package:golden_hour/features/profile/data/profile_repository.dart';
import 'package:golden_hour/features/profile/domain/profile_provider.dart';
import 'package:golden_hour/features/profile/domain/profile_state.dart';
import 'package:golden_hour/features/settings/presentation/settings_screen.dart';

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
  Future<void> saveThemeMode(String mode) async {
    _data['app_theme_mode'] = mode;
  }

  @override
  Future<String?> getAccentColor() async => _data['app_accent_color'];

  @override
  Future<void> saveAccentColor(String hexOrId) async {
    _data['app_accent_color'] = hexOrId;
  }
}

void main() {
  group('Theme Customizer & Palette Tests', () {
    test('Accent palette contains 8 options and valid defaults', () {
      expect(ThemeCustomizer.accentOptions.length, 8);
      expect(ThemeCustomizer.defaultAccent.id, 'crimson');
      expect(ThemeCustomizer.defaultAccent.color, AppColors.primary);

      final amber = ThemeCustomizer.fromId('amber');
      expect(amber.name, 'Amber Rescue');
      expect(amber.color, const Color(0xFFDD6B20));

      final unknown = ThemeCustomizer.fromId('nonexistent');
      expect(unknown.id, 'crimson');

      final fromColor = ThemeCustomizer.fromColor(const Color(0xFF3182CE));
      expect(fromColor.id, 'cobalt');
      expect(fromColor.name, 'Ocean Safety');
    });

    test('ThemeModeNotifier transitions and persists properly', () async {
      final fakeStorage = FakeSecureStorageService();
      final notifier = ThemeModeNotifier(fakeStorage);

      expect(notifier.state, ThemeMode.system);

      await notifier.setThemeMode(ThemeMode.dark);
      expect(notifier.state, ThemeMode.dark);
      expect(await fakeStorage.getThemeMode(), 'dark');

      await notifier.setThemeMode(ThemeMode.light);
      expect(notifier.state, ThemeMode.light);
      expect(await fakeStorage.getThemeMode(), 'light');

      await notifier.setThemeMode(ThemeMode.system);
      expect(notifier.state, ThemeMode.system);
      expect(await fakeStorage.getThemeMode(), 'system');
    });

    test('AccentColorNotifier loads, updates, and persists accent colors', () async {
      final fakeStorage = FakeSecureStorageService();
      final notifier = AccentColorNotifier(fakeStorage);

      expect(notifier.state, AppColors.primary);

      final cobalt = ThemeCustomizer.fromId('cobalt');
      await notifier.setAccentColor(cobalt);
      expect(notifier.state, cobalt.color);
      expect(await fakeStorage.getAccentColor(), 'cobalt');

      await notifier.setAccentColorById('emerald');
      expect(notifier.state, const Color(0xFF38A169));
      expect(await fakeStorage.getAccentColor(), 'emerald');
    });

    test('AppTheme.buildLightTheme and buildDarkTheme apply dynamic accent colors', () {
      const customAccent = Color(0xFF805AD5); // Royal Amethyst

      final light = AppTheme.buildLightTheme(customAccent);
      expect(light.brightness, Brightness.light);
      expect(light.colorScheme.primary, customAccent);
      expect(light.primaryColor, customAccent);
      expect(light.floatingActionButtonTheme.backgroundColor, customAccent);

      final dark = AppTheme.buildDarkTheme(customAccent);
      expect(dark.brightness, Brightness.dark);
      expect(dark.colorScheme.primary, customAccent);
      expect(dark.primaryColor, customAccent);

      // Verify static getters default to crimson
      expect(AppTheme.lightTheme.colorScheme.primary, AppColors.primary);
      expect(AppTheme.darkTheme.colorScheme.primary, AppColors.primary);
    });
  });

  group('Theme Settings UI Tests', () {
    testWidgets('Renders Appearance & Theme section with Dark Mode toggle and Color Picker',
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
          fullName: 'Arjun Reddy',
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
            home: SettingsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Theme Header and elements
      expect(find.text('APPEARANCE & THEME'), findsOneWidget);
      expect(find.text('Theme Mode'), findsOneWidget);
      expect(find.text('Accent Color'), findsOneWidget);

      // Theme Mode Segmented Chips
      expect(find.text('System'), findsOneWidget);
      expect(find.text('Light'), findsOneWidget);
      expect(find.text('Dark'), findsOneWidget);

      // Tap Dark mode
      await tester.tap(find.text('Dark'));
      await tester.pumpAndSettle();
      expect(await fakeStorage.getThemeMode(), 'dark');

      // Tap Light mode
      await tester.tap(find.text('Light'));
      await tester.pumpAndSettle();
      expect(await fakeStorage.getThemeMode(), 'light');

      // Verify accent color chips
      final amberChip = find.byKey(const ValueKey('accent_color_amber'));
      expect(amberChip, findsOneWidget);

      await tester.tap(amberChip);
      await tester.pumpAndSettle();
      expect(await fakeStorage.getAccentColor(), 'amber');
      expect(find.text('Amber Rescue'), findsOneWidget);
    });
  });
}

