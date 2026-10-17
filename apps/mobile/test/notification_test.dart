import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:golden_hour/features/notifications/data/notification_models.dart';
import 'package:golden_hour/features/notifications/data/notification_repository.dart';
import 'package:golden_hour/features/notifications/domain/notification_provider.dart';
import 'package:golden_hour/features/notifications/domain/notification_state.dart';
import 'package:golden_hour/features/notifications/presentation/notifications_screen.dart';

class MockNotificationNotifier extends NotificationNotifier {
  MockNotificationNotifier(NotificationState initialState)
      : super(_FakeNotificationRepository()) {
    state = initialState;
  }

  @override
  Future<void> loadHistory({int page = 1}) async {}
}

class _FakeNotificationRepository implements NotificationRepository {
  @override
  Future<TestNotificationResponse> sendTestNotification() async {
    return const TestNotificationResponse(
      smsSent: true,
      whatsappSent: true,
      message: 'Test notification dispatched',
    );
  }

  @override
  Future<void> markFalseAlarm(String scanId) async {}

  @override
  Future<ScanHistoryResponse> getHistory({int page = 1, int pageSize = 20}) async {
    return const ScanHistoryResponse(items: [], total: 0, page: 1, pageSize: 20);
  }

  @override
  Future<void> registerFcmToken(String fcmToken) async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('Module 4 — Notification Models & Serialization', () {
    test('ScanEventItem deserializes and serializes properly', () {
      final json = {
        'id': 'scan-123',
        'qr_uid': 'QRTEST01',
        'responder_name': 'Paramedic Anita',
        'responder_hospital': 'City Trauma Center',
        'latitude': 12.9716,
        'longitude': 77.5946,
        'location_area': 'MG Road, Bangalore',
        'google_maps_url': 'https://maps.google.com/?q=12.9716,77.5946',
        'sms_sent': true,
        'whatsapp_sent': true,
        'fcm_sent': true,
        'is_false_alarm': false,
        'scanned_at': '2026-10-17T14:30:00Z',
      };

      final item = ScanEventItem.fromJson(json);
      expect(item.id, 'scan-123');
      expect(item.responderName, 'Paramedic Anita');
      expect(item.responderHospital, 'City Trauma Center');
      expect(item.smsSent, true);
      expect(item.whatsappSent, true);
      expect(item.fcmSent, true);
      expect(item.isFalseAlarm, false);

      final copy = item.copyWith(isFalseAlarm: true);
      expect(copy.isFalseAlarm, true);
      expect(copy.id, item.id);
    });

    test('TestNotificationResponse deserializes properly', () {
      final json = {
        'sms_sent': true,
        'whatsapp_sent': false,
        'message': 'Fast2SMS delivered successfully',
      };

      final response = TestNotificationResponse.fromJson(json);
      expect(response.smsSent, true);
      expect(response.whatsappSent, false);
      expect(response.message, 'Fast2SMS delivered successfully');
    });
  });

  group('Module 4 — Notifications Screen Presentation', () {
    testWidgets('NotificationsScreen renders test button and empty state',
        (tester) async {
      const mockState = NotificationState(
        events: [],
        isLoading: false,
      );

      final router = GoRouter(
        initialLocation: '/notifications',
        routes: [
          GoRoute(
            path: '/notifications',
            builder: (_, __) => const NotificationsScreen(),
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            notificationNotifierProvider
                .overrideWith((ref) => MockNotificationNotifier(mockState)),
          ],
          child: MaterialApp.router(
            routerConfig: router,
          ),
        ),
      );

      expect(find.text('Notifications & Alerts'), findsOneWidget);
      expect(find.text('Instant Emergency Alerting'), findsOneWidget);
      expect(find.text('Test Emergency Channels'), findsOneWidget);
      expect(find.text('Send Test Notification'), findsOneWidget);
      expect(find.text('No Emergency Scans Recorded'), findsOneWidget);
    });

    testWidgets('NotificationsScreen renders scan event cards with channel badges',
        (tester) async {
      final scanEvent = ScanEventItem(
        id: 'evt-1',
        qrUid: 'QRTEST01',
        responderName: 'Dr. Vikram',
        responderHospital: 'Apollo Hospital',
        smsSent: true,
        whatsappSent: true,
        fcmSent: true,
        isFalseAlarm: false,
        scannedAt: DateTime(2026, 10, 17, 10, 30),
      );

      final mockState = NotificationState(
        events: [scanEvent],
        totalEvents: 1,
        isLoading: false,
      );

      final router = GoRouter(
        initialLocation: '/notifications',
        routes: [
          GoRoute(
            path: '/notifications',
            builder: (_, __) => const NotificationsScreen(),
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            notificationNotifierProvider
                .overrideWith((ref) => MockNotificationNotifier(mockState)),
          ],
          child: MaterialApp.router(
            routerConfig: router,
          ),
        ),
      );

      expect(find.text('Emergency QR Scanned'), findsOneWidget);
      expect(find.textContaining('Dr. Vikram'), findsOneWidget);
      expect(find.textContaining('Apollo Hospital'), findsOneWidget);
      expect(find.text('SMS'), findsOneWidget);
      expect(find.text('WhatsApp'), findsOneWidget);
      expect(find.text('FCM Push'), findsOneWidget);
      expect(find.text('False Alarm?'), findsOneWidget);
    });
  });
}
