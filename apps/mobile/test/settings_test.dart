import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_hour/features/auth/data/auth_repository.dart';
import 'package:golden_hour/features/auth/domain/auth_provider.dart';
import 'package:golden_hour/features/auth/domain/auth_state.dart';
import 'package:golden_hour/features/profile/data/profile_models.dart';
import 'package:golden_hour/features/profile/data/profile_repository.dart';
import 'package:golden_hour/features/profile/domain/profile_provider.dart';
import 'package:golden_hour/features/profile/domain/profile_state.dart';
import 'package:golden_hour/core/theme/app_theme.dart';
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

  @override
  Future<void> logout() async {}

  @override
  Future<bool> deleteAccount() async => true;
}

class MockProfileNotifier extends ProfileNotifier {
  MockProfileNotifier(ProfileState initialState)
      : super(_FakeProfileRepository()) {
    state = initialState;
  }

  @override
  Future<void> loadProfileData() async {}

  @override
  Future<bool> toggleQrActive(bool isActive) async => true;
}

void main() {
  group('Module 7 — Settings Screen Tests', () {
    testWidgets('SettingsScreen renders account, QR toggle, legal, and danger zone',
        (tester) async {
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
          qrUid: 'ARJUN108',
        ),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authNotifierProvider
                .overrideWith((ref) => MockAuthNotifier(authState)),
            profileNotifierProvider
                .overrideWith((ref) => MockProfileNotifier(profileState)),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const SettingsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Account Card
      expect(find.text('Settings & Privacy'), findsOneWidget);
      expect(find.text('Arjun Reddy'), findsOneWidget);
      expect(find.text('+919876543210'), findsOneWidget);
      expect(find.text('DPDPA Verified Account'), findsOneWidget);

      // Legal & Compliance
      expect(find.text('LEGAL & COMPLIANCE (INDIA DPDPA)'), findsOneWidget);
      expect(find.text('DPDPA 2023 Privacy Policy'), findsOneWidget);
      expect(find.text('Emergency Responder Disclaimer'), findsOneWidget);
      expect(find.text('Terms of Service'), findsOneWidget);

      // Emergency Safety Protocols
      expect(find.text('EMERGENCY SAFETY PROTOCOLS'), findsOneWidget);
      expect(find.text('Offline Emergency Safety Guides'), findsOneWidget);
      expect(find.text('Safety Contact Groups'), findsOneWidget);

      // Appearance & Theme
      expect(find.text('APPEARANCE & THEME'), findsOneWidget);
      expect(find.text('Theme Mode'), findsOneWidget);
      expect(find.text('Accent Color'), findsOneWidget);

      // Danger Zone
      expect(find.text('ACCOUNT ACTIONS'), findsOneWidget);
      expect(find.text('Log Out'), findsOneWidget);
      expect(find.text('Delete Account'), findsOneWidget);

      // Footer
      expect(find.text('Golden Hour — Every Second Counts'), findsOneWidget);
      expect(find.textContaining('App Version 1.0.0'), findsOneWidget);
    });

    testWidgets('Tapping Emergency Responder Disclaimer opens modal sheet',
        (tester) async {
      const authState = AuthState(
        status: AuthStatus.authenticated,
        phone: '+919876543210',
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
            authNotifierProvider
                .overrideWith((ref) => MockAuthNotifier(authState)),
            profileNotifierProvider
                .overrideWith((ref) => MockProfileNotifier(profileState)),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const SettingsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final disclaimerTile = find.text('Emergency Responder Disclaimer');
      expect(disclaimerTile, findsOneWidget);

      await tester.scrollUntilVisible(
        disclaimerTile,
        150,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(disclaimerTile);
      await tester.pumpAndSettle();

      expect(find.textContaining('IMPORTANT EMERGENCY ADVISORY:'), findsOneWidget);
      expect(find.textContaining('Good Samaritan Guidelines'), findsOneWidget);
      expect(find.text('Understood'), findsOneWidget);

      await tester.tap(find.text('Understood'));
      await tester.pumpAndSettle();
      expect(find.textContaining('IMPORTANT EMERGENCY ADVISORY:'), findsNothing);
    });
  });
}
