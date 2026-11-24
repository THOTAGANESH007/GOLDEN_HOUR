import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_hour/core/theme/app_theme.dart';
import 'package:golden_hour/features/profile/data/profile_models.dart';
import 'package:golden_hour/features/profile/data/profile_repository.dart';
import 'package:golden_hour/features/profile/domain/profile_provider.dart';
import 'package:golden_hour/features/profile/domain/profile_state.dart';
import 'package:golden_hour/features/profile/presentation/contact_group_screen.dart';
import 'package:golden_hour/features/profile/presentation/widgets/quick_dial_button.dart';

class MockProfileNotifier extends ProfileNotifier {
  final ProfileState initialState;
  MockProfileNotifier(this.initialState)
      : super(_FakeProfileRepository()) {
    state = initialState;
  }

  @override
  Future<void> fetchContactGroups() async {}
}

class _FakeProfileRepository implements ProfileRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Contact Groups & Quick Dial — Data Models Unit Tests', () {
    test('EmergencyContact supports groupId and groupName', () {
      const contact = EmergencyContact(
        id: 'c-1',
        name: 'Priya Sharma',
        relation: 'Spouse',
        phone: '+919876543210',
        groupId: 'g-1',
        groupName: 'Family',
      );

      final json = contact.toJson();
      expect(json['group_id'], 'g-1');
      expect(json['group_name'], 'Family');

      final restored = EmergencyContact.fromJson(json);
      expect(restored.groupId, 'g-1');
      expect(restored.groupName, 'Family');

      final updated = contact.copyWith(groupName: 'Immediate Family');
      expect(updated.groupName, 'Immediate Family');
      expect(updated.groupId, 'g-1');
    });

    test('ContactGroup serializes and deserializes correctly', () {
      const contact = EmergencyContact(
        id: 'c-1',
        name: 'Rohan Sharma',
        relation: 'Brother',
        phone: '+919876543211',
      );

      final group = ContactGroup(
        id: 'g-100',
        userId: 'u-1',
        name: 'Family',
        description: 'Immediate family',
        contactCount: 1,
        contacts: const [contact],
        createdAt: DateTime(2026, 11, 24),
      );

      final json = group.toJson();
      expect(json['id'], 'g-100');
      expect(json['name'], 'Family');
      expect(json['contact_count'], 1);
      expect((json['contacts'] as List).length, 1);

      final restored = ContactGroup.fromJson(json);
      expect(restored.id, 'g-100');
      expect(restored.name, 'Family');
      expect(restored.contacts.first.name, 'Rohan Sharma');
    });

    test('BroadcastResult parses counts and broadcastId', () {
      final json = {
        'broadcast_id': 'bcast_abc123',
        'group_id': 'g-1',
        'group_name': 'Family',
        'total_contacts': 3,
        'whatsapp_sent_count': 3,
        'fcm_sent_count': 2,
        'sent_at': '2026-11-24T10:00:00.000Z',
      };

      final res = BroadcastResult.fromJson(json);
      expect(res.broadcastId, 'bcast_abc123');
      expect(res.groupName, 'Family');
      expect(res.totalContacts, 3);
      expect(res.whatsappSentCount, 3);
      expect(res.fcmSentCount, 2);
    });
  });

  group('QuickDialButton Widget Tests', () {
    testWidgets('Renders Speed Dial 112 when primaryContact is null', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(
            body: QuickDialButton(primaryContact: null),
          ),
        ),
      );

      expect(find.text('Speed Dial 112 (Helpline)'), findsOneWidget);
      expect(find.text('No emergency contact set yet'), findsOneWidget);
      expect(find.text('Dial 112'), findsOneWidget);
    });

    testWidgets('Renders primary contact details and Call Now button', (tester) async {
      const contact = EmergencyContact(
        id: 'c-1',
        name: 'Aarav Patel',
        relation: 'Father',
        phone: '+919988776655',
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(
            body: QuickDialButton(primaryContact: contact),
          ),
        ),
      );

      expect(find.text('Aarav Patel'), findsOneWidget);
      expect(find.text('FATHER'), findsOneWidget);
      expect(find.textContaining('+919988776655'), findsOneWidget);
      expect(find.text('Call Now'), findsOneWidget);
    });
  });

  group('ContactGroupScreen Widget Tests', () {
    testWidgets('Renders empty state when user has no groups', (tester) async {
      const state = ProfileState(
        contactGroups: [],
        contacts: [],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            profileNotifierProvider.overrideWith((ref) => MockProfileNotifier(state)),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const ContactGroupScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Safety Contact Groups'), findsOneWidget);
      expect(find.text('Instant Emergency Alert'), findsOneWidget);
      expect(find.text('No Contact Groups Created'), findsOneWidget);
      expect(find.text('Create First Group'), findsOneWidget);
    });

    testWidgets('Renders group cards with member chips and broadcast action', (tester) async {
      const contact = EmergencyContact(
        id: 'c-1',
        name: 'Kavita Roy',
        relation: 'Sister',
        phone: '+919112233445',
      );

      const group = ContactGroup(
        id: 'g-1',
        userId: 'u-1',
        name: 'Home & Family',
        description: 'Family emergency circle',
        contactCount: 1,
        contacts: [contact],
      );

      const state = ProfileState(
        contactGroups: [group],
        contacts: [contact],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            profileNotifierProvider.overrideWith((ref) => MockProfileNotifier(state)),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const ContactGroupScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Home & Family'), findsOneWidget);
      expect(find.text('Family emergency circle'), findsOneWidget);
      expect(find.text('Kavita Roy (Sister)'), findsOneWidget);
      expect(find.text('Members (1)'), findsOneWidget);
      expect(find.text('Broadcast'), findsWidgets);
    });
  });
}

