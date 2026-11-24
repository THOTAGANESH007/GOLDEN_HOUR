import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:golden_hour/features/profile/data/profile_models.dart';
import 'package:golden_hour/features/profile/data/profile_repository.dart';
import 'package:golden_hour/features/profile/domain/profile_provider.dart';
import 'package:golden_hour/features/profile/domain/profile_state.dart';
import 'package:golden_hour/features/profile/presentation/edit_profile_screen.dart';

class MockProfileNotifier extends ProfileNotifier {
  bool updateProfileCalled = false;
  Map<String, dynamic>? lastUpdatePayload;

  MockProfileNotifier(ProfileState initialState)
      : super(_FakeProfileRepository()) {
    state = initialState;
  }

  @override
  Future<void> loadProfileData() async {}

  @override
  Future<bool> updateProfile(Map<String, dynamic> payload) async {
    updateProfileCalled = true;
    lastUpdatePayload = payload;
    return true;
  }
}

class _FakeProfileRepository implements ProfileRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const sampleProfile = PatientProfile(
    id: 'test-profile-123',
    userId: 'test-user-456',
    qrUid: 'QR123456',
    qrIsActive: true,
    fullName: 'Ananya Verma',
    dateOfBirth: '1998-04-12',
    gender: 'Female',
    bloodGroup: 'B+',
    allergies: ['Penicillin'],
    chronicConditions: ['None'],
    medications: [],
    pastSurgeries: [],
    implants: [],
    isOrganDonor: true,
    wizardCompleted: true,
  );

  Widget buildTestApp({required MockProfileNotifier notifier}) {
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (_, __) => const EditProfileScreen(),
        ),
      ],
    );

    return ProviderScope(
      overrides: [
        profileNotifierProvider.overrideWith((ref) => notifier),
      ],
      child: MaterialApp.router(
        routerConfig: router,
      ),
    );
  }

  group('EditProfileScreen Widget Tests', () {
    testWidgets('populates existing profile data into form fields',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final mockNotifier = MockProfileNotifier(
        const ProfileState(
          isLoading: false,
          profile: sampleProfile,
        ),
      );

      await tester.pumpWidget(buildTestApp(notifier: mockNotifier));
      await tester.pumpAndSettle();

      expect(find.text('Edit Emergency Profile'), findsOneWidget);
      expect(find.text('Ananya Verma'), findsOneWidget);
      expect(find.text('B+'), findsWidgets);
      expect(find.text('Female'), findsWidgets);
    });

    testWidgets('allows editing full name and saving changes',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final mockNotifier = MockProfileNotifier(
        const ProfileState(
          isLoading: false,
          profile: sampleProfile,
        ),
      );

      await tester.pumpWidget(buildTestApp(notifier: mockNotifier));
      await tester.pumpAndSettle();

      final nameField = find.widgetWithText(TextFormField, 'Ananya Verma');
      expect(nameField, findsOneWidget);

      await tester.enterText(nameField, 'Ananya Sharma');
      await tester.pumpAndSettle();

      final saveButton = find.widgetWithText(TextButton, 'Save');
      expect(saveButton, findsOneWidget);

      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      expect(mockNotifier.updateProfileCalled, isTrue);
      expect(mockNotifier.lastUpdatePayload?['full_name'], 'Ananya Sharma');
    });

    testWidgets('validates full name cannot be cleared to empty',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final mockNotifier = MockProfileNotifier(
        const ProfileState(
          isLoading: false,
          profile: sampleProfile,
        ),
      );

      await tester.pumpWidget(buildTestApp(notifier: mockNotifier));
      await tester.pumpAndSettle();

      final nameField = find.widgetWithText(TextFormField, 'Ananya Verma');
      await tester.enterText(nameField, '');
      await tester.pumpAndSettle();

      final saveButton = find.widgetWithText(TextButton, 'Save');
      expect(saveButton, findsOneWidget);

      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      expect(find.text('Full name is required'), findsOneWidget);
      expect(mockNotifier.updateProfileCalled, isFalse);
    });
  });
}
