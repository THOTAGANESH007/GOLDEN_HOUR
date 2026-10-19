import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:golden_hour/core/theme/app_theme.dart';
import 'package:golden_hour/features/profile/data/profile_models.dart';
import 'package:golden_hour/features/profile/data/profile_repository.dart';
import 'package:golden_hour/features/profile/domain/profile_provider.dart';
import 'package:golden_hour/features/profile/domain/profile_state.dart';
import 'package:golden_hour/features/profile/presentation/privacy_settings_screen.dart';
import 'package:golden_hour/features/profile/presentation/profile_home_screen.dart';
import 'package:golden_hour/features/profile/presentation/wizard/step1_blood_group.dart';
import 'package:golden_hour/features/profile/presentation/wizard/step2_allergies.dart';
import 'package:golden_hour/features/profile/presentation/wizard/step3_conditions.dart';
import 'package:golden_hour/features/profile/presentation/wizard/step4_medications.dart';
import 'package:golden_hour/features/profile/presentation/wizard/step5_contacts.dart';

class MockProfileNotifier extends ProfileNotifier {
  MockProfileNotifier(ProfileState initialState)
      : super(_FakeProfileRepository()) {
    state = initialState;
  }

  @override
  Future<void> loadProfileData() async {}
}

class _FakeProfileRepository implements ProfileRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('Module 2 — Profile Models & Serialization', () {
    test('PatientProfile serializes and deserializes correctly', () {
      final json = {
        'id': 'test-profile-123',
        'user_id': 'test-user-456',
        'qr_uid': 'QR123456',
        'qr_is_active': true,
        'full_name': 'Rahul Sharma',
        'date_of_birth': '1990-05-15',
        'gender': 'Male',
        'blood_group': 'O+',
        'allergies': ['Penicillin', 'Peanuts'],
        'chronic_conditions': ['Asthma'],
        'medications': [
          {'name': 'Albuterol', 'dosage': '2 puffs', 'frequency': 'As needed'}
        ],
        'is_organ_donor': true,
        'show_name': true,
        'show_dob': true,
        'show_photo': false,
        'wizard_completed': true,
      };

      final profile = PatientProfile.fromJson(json);
      expect(profile.id, 'test-profile-123');
      expect(profile.fullName, 'Rahul Sharma');
      expect(profile.bloodGroup, 'O+');
      expect(profile.allergies.length, 2);
      expect(profile.medications.first.name, 'Albuterol');
      expect(profile.isOrganDonor, true);

      final updateMap = profile.toUpdateJson();
      expect(updateMap['full_name'], 'Rahul Sharma');
      expect(updateMap['blood_group'], 'O+');
      expect(updateMap['is_organ_donor'], true);
    });

    test('EmergencyContact serializes and deserializes correctly', () {
      final json = {
        'id': 'contact-1',
        'name': 'Priya Sharma',
        'relation': 'Spouse',
        'phone': '+919876543210',
        'whatsapp_enabled': true,
        'notify_on_scan': true,
        'sort_order': 0,
      };

      final contact = EmergencyContact.fromJson(json);
      expect(contact.name, 'Priya Sharma');
      expect(contact.relation, 'Spouse');
      expect(contact.phone, '+919876543210');
      expect(contact.whatsappEnabled, true);

      final contactJson = contact.toJson();
      expect(contactJson['name'], 'Priya Sharma');
      expect(contactJson['phone'], '+919876543210');
    });

    test('ProfileCompletion parses score and missing fields', () {
      final json = {
        'score': 75,
        'missing': ['medications', 'doctor_name'],
      };

      final completion = ProfileCompletion.fromJson(json);
      expect(completion.score, 75);
      expect(completion.missing, ['medications', 'doctor_name']);
    });
  });

  group('Module 2 — Profile Wizard Steps', () {
    testWidgets('Step 1 renders blood groups and triggers callback',
        (tester) async {
      String? selected;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: Step1BloodGroup(
              selectedBloodGroup: 'O+',
              onSelected: (val) => selected = val,
            ),
          ),
        ),
      );

      expect(find.text('Select Blood Group'), findsOneWidget);
      expect(find.text('O+'), findsOneWidget);
      expect(find.text('A+'), findsOneWidget);

      await tester.tap(find.text('A+'));
      await tester.pump();
      expect(selected, 'A+');
    });

    testWidgets('Step 2 renders allergies and allows adding custom',
        (tester) async {
      List<String> currentAllergies = ['Penicillin'];

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: Step2Allergies(
              selectedAllergies: currentAllergies,
              onChanged: (val) => currentAllergies = val,
            ),
          ),
        ),
      );

      expect(find.text('Allergies & Reactions'), findsOneWidget);
      expect(find.text('Penicillin'), findsWidgets);

      // Enter custom allergy
      await tester.enterText(find.byType(TextField), 'Latex');
      await tester.tap(find.text('Add'));
      await tester.pump();

      expect(currentAllergies.contains('Latex'), isTrue);
    });

    testWidgets('Step 3 renders conditions and handles selection',
        (tester) async {
      List<String> currentConditions = [];

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: Step3Conditions(
              selectedConditions: currentConditions,
              onChanged: (val) => currentConditions = val,
            ),
          ),
        ),
      );

      expect(find.text('Chronic Conditions'), findsOneWidget);
      expect(find.text('Hypertension'), findsOneWidget);

      await tester.tap(find.text('Hypertension'));
      await tester.pump();
      expect(currentConditions.contains('Hypertension'), isTrue);
    });

    testWidgets('Step 4 adds new medication to list', (tester) async {
      List<MedicationItem> currentMeds = [];

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: Step4Medications(
              medications: currentMeds,
              onChanged: (val) => currentMeds = val,
            ),
          ),
        ),
      );

      expect(find.text('Current Medications'), findsOneWidget);

      await tester.enterText(
          find.widgetWithText(TextField, 'Medication Name'), 'Metformin');
      await tester.enterText(
          find.widgetWithText(TextField, 'Dosage'), '500mg');
      await tester.tap(find.text('Add Medication to List'));
      await tester.pump();

      expect(currentMeds.length, 1);
      expect(currentMeds.first.name, 'Metformin');
      expect(currentMeds.first.dosage, '500mg');
    });

    testWidgets('Step 5 adds emergency contact', (tester) async {
      List<EmergencyContact> contacts = [];

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: Step5Contacts(
              contacts: contacts,
              onChanged: (val) => contacts = val,
            ),
          ),
        ),
      );

      expect(find.text('Emergency Contacts'), findsOneWidget);

      await tester.enterText(
          find.widgetWithText(TextField, 'Contact Name'), 'Anil Kumar');
      await tester.enterText(
          find.widgetWithText(TextField, 'Phone Number'), '9876543210');
      await tester.tap(find.text('Add Contact to Profile'));
      await tester.pump();

      expect(contacts.length, 1);
      expect(contacts.first.name, 'Anil Kumar');
      expect(contacts.first.phone, '+919876543210');
    });
  });

  group('Module 2 — Profile Screens Presentation', () {
    testWidgets('PrivacySettingsScreen renders DPDPA toggles', (tester) async {
      const mockState = ProfileState(
        profile: PatientProfile(
          id: 'test-profile-1',
          userId: 'test-user-1',
          showName: true,
          showDob: false,
          showPhoto: false,
        ),
      );

      final router = GoRouter(
        initialLocation: '/privacy',
        routes: [
          GoRoute(
            path: '/privacy',
            builder: (_, __) => const PrivacySettingsScreen(),
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            profileNotifierProvider
                .overrideWith((ref) => MockProfileNotifier(mockState)),
          ],
          child: MaterialApp.router(
            routerConfig: router,
          ),
        ),
      );

      expect(find.text('Privacy & Visibility Controls'), findsOneWidget);
      expect(find.text('Show Full Legal Name'), findsOneWidget);
      expect(find.text('DPDPA 2023 Compliant'), findsOneWidget);
    });

    testWidgets('ProfileHomeScreen renders summary card, score, and actions',
        (tester) async {
      const mockProfile = PatientProfile(
        id: 'test-1',
        userId: 'user-1',
        fullName: 'Dr. Ramesh Rao',
        bloodGroup: 'B+',
        gender: 'Male',
        allergies: ['Penicillin'],
        chronicConditions: ['Hypertension'],
        medications: [
          MedicationItem(name: 'Amlodipine', dosage: '5mg', frequency: 'Daily')
        ],
        wizardCompleted: true,
      );

      const mockState = ProfileState(
        profile: mockProfile,
        completion: ProfileCompletion(score: 90, missing: []),
        contacts: [
          EmergencyContact(
            name: 'Sunita Rao',
            relation: 'Spouse',
            phone: '+919876500000',
          ),
        ],
      );

      final router = GoRouter(
        initialLocation: '/home',
        routes: [
          GoRoute(
            path: '/home',
            builder: (_, __) => const ProfileHomeScreen(),
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            profileNotifierProvider
                .overrideWith((ref) => MockProfileNotifier(mockState)),
          ],
          child: MaterialApp.router(
            routerConfig: router,
          ),
        ),
      );

      expect(find.text('Dr. Ramesh Rao'), findsOneWidget);
      expect(find.text('B+'), findsOneWidget);
      expect(find.text('Profile Readiness Score'), findsOneWidget);
      expect(find.text('90%'), findsOneWidget);
      expect(find.text('Edit Profile'), findsOneWidget);
      expect(find.text('Profile Wizard'), findsOneWidget);
      expect(find.text('Sunita Rao'), findsOneWidget);
    });
  });
}
