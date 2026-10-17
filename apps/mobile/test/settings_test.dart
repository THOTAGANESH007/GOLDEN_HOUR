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
          child: const MaterialApp(
            home: SettingsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Account Card
      expect(find.text('Settings & Privacy'), findsOneWidget);
      expect(find.text('Arjun Reddy'), findsOneWidget);
      expect(find.text('+919876543210'), findsOneWidget);
      expect(find.text('DPDPA Verified Account'), findsOneWidget);

      // QR Controls
      expect(find.text('EMERGENCY QR CONTROLS'), findsOneWidget);
      expect(find.text('Emergency QR Code Active'), findsOneWidget);
      expect(find.text('Per-Field Privacy Toggles'), findsOneWidget);

      // Alerts & Incidents
      expect(find.text('ALERTS & INCIDENT AUDIT'), findsOneWidget);
      expect(find.text('Scan History & GPS Audit'), findsOneWidget);
      expect(find.text('Notifications & Channel Test'), findsOneWidget);

      // Legal & Compliance
      expect(find.text('LEGAL & COMPLIANCE (INDIA DPDPA)'), findsOneWidget);
      expect(find.text('DPDPA 2023 Privacy Policy'), findsOneWidget);
      expect(find.text('Medical Responder Disclaimer'), findsOneWidget);
      expect(find.text('Terms of Service'), findsOneWidget);

      // Danger Zone
      expect(find.text('ACCOUNT ACTIONS'), findsOneWidget);
      expect(find.text('Log Out'), findsOneWidget);
      expect(find.text('Delete Account'), findsOneWidget);

      // Footer
      expect(find.text('Golden Hour — Every Second Counts'), findsOneWidget);
      expect(find.textContaining('App Version 1.0.0'), findsOneWidget);
    });

    testWidgets('Tapping Medical Responder Disclaimer opens modal sheet',
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
          child: const MaterialApp(
            home: SettingsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final disclaimerTile = find.text('Medical Responder Disclaimer');
      expect(disclaimerTile, findsOneWidget);

      await tester.scrollUntilVisible(disclaimerTile, 150);
      await tester.tap(disclaimerTile);
      await tester.pumpAndSettle();

      expect(find.textContaining('IMPORTANT MEDICAL TRIAGE ADVISORY:'), findsOneWidget);
      expect(find.textContaining('Good Samaritan Guidelines'), findsOneWidget);
      expect(find.text('Understood'), findsOneWidget);

      await tester.tap(find.text('Understood'));
      await tester.pumpAndSettle();
      expect(find.textContaining('IMPORTANT MEDICAL TRIAGE ADVISORY:'), findsNothing);
    });
  });
}
