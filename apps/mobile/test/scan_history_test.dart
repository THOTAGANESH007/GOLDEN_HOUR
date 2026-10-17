import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_hour/features/scan_history/data/scan_models.dart';
import 'package:golden_hour/features/scan_history/data/scan_repository.dart';
import 'package:golden_hour/features/scan_history/domain/scan_history_provider.dart';
import 'package:golden_hour/features/scan_history/domain/scan_history_state.dart';
import 'package:golden_hour/features/scan_history/presentation/scan_detail_screen.dart';
import 'package:golden_hour/features/scan_history/presentation/scan_history_screen.dart';

class MockScanHistoryNotifier extends ScanHistoryNotifier {
  MockScanHistoryNotifier(ScanHistoryState initialState)
      : super(_FakeScanRepository()) {
    state = initialState;
  }

  @override
  Future<void> loadInitial() async {}

  @override
  Future<void> loadNextPage() async {}

  @override
  Future<void> refresh() async {}

  @override
  Future<ScanHistoryItem?> loadDetail(String scanId) async => null;
}

class _FakeScanRepository implements ScanRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('Module 6 — Scan History Models & State', () {
    test('ScanHistoryItem deserializes and computes properties correctly', () {
      final now = DateTime.now();
      final item = ScanHistoryItem(
        id: 'scan-1',
        qrUid: 'EMERG123',
        responderName: 'Dr. Ramesh Kumar',
        responderHospital: 'Apollo Emergency Trauma Care',
        latitude: 17.3850,
        longitude: 78.4867,
        locationArea: 'Banjara Hills, Hyderabad',
        googleMapsUrl: 'https://maps.google.com/?q=17.385,78.4867',
        deviceType: 'Mobile Safari (iOS 18)',
        smsSent: true,
        whatsappSent: true,
        fcmSent: true,
        emailSent: false,
        notificationSuppressed: false,
        isFalseAlarm: false,
        scannedAt: now.subtract(const Duration(minutes: 5)),
      );

      expect(item.id, 'scan-1');
      expect(item.qrUid, 'EMERG123');
      expect(item.displayResponder,
          'Dr. Ramesh Kumar • Apollo Emergency Trauma Care');
      expect(item.displayLocation, 'Banjara Hills, Hyderabad');
      expect(item.resolvedMapsUrl, 'https://maps.google.com/?q=17.385,78.4867');
      expect(item.relativeTime, '5m ago');
      // 5 minutes > 60 seconds, so false alarm is unlocked
      expect(item.isFalseAlarmAvailable, isTrue);
      expect(item.secondsUntilFalseAlarmAvailable, 0);

      final json = item.toJson();
      final restored = ScanHistoryItem.fromJson(json);
      expect(restored.id, item.id);
      expect(restored.responderName, item.responderName);
      expect(restored.smsSent, isTrue);
    });

    test('ScanHistoryItem cooldown calculation for recent scan (< 60s)', () {
      final recentScan = ScanHistoryItem(
        id: 'scan-recent',
        qrUid: 'FAST999',
        scannedAt: DateTime.now().subtract(const Duration(seconds: 15)),
      );

      expect(recentScan.isFalseAlarmAvailable, isFalse);
      expect(
          recentScan.secondsUntilFalseAlarmAvailable, inInclusiveRange(40, 50));
    });

    test('ScanHistoryListResponse parses items and checks hasMore', () {
      final json = {
        'total': 45,
        'page': 1,
        'page_size': 20,
        'items': [
          {
            'id': 'scan-1',
            'qr_uid': 'EMERG123',
            'scanned_at': DateTime.now().toIso8601String(),
            'sms_sent': true,
            'whatsapp_sent': true,
            'fcm_sent': true,
          }
        ]
      };

      final response = ScanHistoryListResponse.fromJson(json);
      expect(response.total, 45);
      expect(response.page, 1);
      expect(response.pageSize, 20);
      expect(response.hasMore, isTrue);
      expect(response.items.length, 1);
    });

    test('ScanHistoryState correctly computes active and false alarm counts',
        () {
      final now = DateTime.now();
      final state = ScanHistoryState(
        items: [
          ScanHistoryItem(
            id: '1',
            qrUid: 'U1',
            scannedAt: now,
            isFalseAlarm: false,
          ),
          ScanHistoryItem(
            id: '2',
            qrUid: 'U2',
            scannedAt: now,
            isFalseAlarm: true,
          ),
          ScanHistoryItem(
            id: '3',
            qrUid: 'U3',
            scannedAt: now,
            isFalseAlarm: false,
          ),
        ],
      );

      expect(state.activeScanCount, 2);
      expect(state.falseAlarmCount, 1);
    });
  });

  group('Module 6 — Scan History Presentation Screens', () {
    testWidgets('ScanHistoryScreen renders header, metrics, and empty state',
        (tester) async {
      const mockState = ScanHistoryState(
        items: [],
        isLoading: false,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            scanHistoryNotifierProvider.overrideWith(
              (ref) => MockScanHistoryNotifier(mockState),
            ),
          ],
          child: const MaterialApp(
            home: ScanHistoryScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Emergency Scan History'), findsOneWidget);
      expect(find.text('Responder Scan Audit'), findsOneWidget);
      expect(find.text('Total Scans'), findsOneWidget);
      expect(find.text('Emergencies'), findsOneWidget);
      expect(find.text('False Alarms'), findsOneWidget);
      expect(find.text('No Emergency Scans Yet'), findsOneWidget);
      expect(find.text('View My Emergency QR'), findsOneWidget);
    });

    testWidgets('ScanHistoryScreen renders scan items and channel badges',
        (tester) async {
      final scanItem = ScanHistoryItem(
        id: 'scan-item-1',
        qrUid: 'EMERG100',
        responderName: 'Paramedic Priya',
        responderHospital: 'Apollo ER',
        locationArea: 'Banjara Hills',
        deviceType: 'iPhone 15',
        smsSent: true,
        whatsappSent: true,
        fcmSent: true,
        isFalseAlarm: false,
        scannedAt: DateTime.now().subtract(const Duration(minutes: 10)),
      );

      final mockState = ScanHistoryState(
        items: [scanItem],
        totalCount: 1,
        isLoading: false,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            scanHistoryNotifierProvider.overrideWith(
              (ref) => MockScanHistoryNotifier(mockState),
            ),
          ],
          child: const MaterialApp(
            home: ScanHistoryScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Banjara Hills'), findsOneWidget);
      expect(find.text('Paramedic Priya • Apollo ER'), findsOneWidget);
      expect(find.text('SMS'), findsOneWidget);
      expect(find.text('WhatsApp'), findsOneWidget);
      expect(find.text('FCM Push'), findsOneWidget);
      expect(find.text('Details'), findsOneWidget);
    });

    testWidgets(
        'ScanDetailScreen renders full audit info and false alarm action',
        (tester) async {
      final pastScan = ScanHistoryItem(
        id: 'scan-detail-1',
        qrUid: 'GOLDEN99',
        responderName: 'Paramedic Priya Sharma',
        responderHospital: 'GVK EMRI 108 Ambulance',
        latitude: 17.4485,
        longitude: 78.3742,
        locationArea: 'Hitec City, Hyderabad',
        googleMapsUrl: 'https://maps.google.com/?q=17.4485,78.3742',
        deviceType: 'Chrome on Pixel 8 Pro',
        smsSent: true,
        whatsappSent: true,
        fcmSent: true,
        emailSent: false,
        notificationSuppressed: false,
        isFalseAlarm: false,
        scannedAt: DateTime.now().subtract(const Duration(minutes: 10)),
      );

      final mockState = ScanHistoryState(
        selectedEvent: pastScan,
        isLoadingDetail: false,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            scanHistoryNotifierProvider.overrideWith(
              (ref) => MockScanHistoryNotifier(mockState),
            ),
          ],
          child: MaterialApp(
            home: ScanDetailScreen(
              scanId: pastScan.id,
              initialEvent: pastScan,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Scan Event Details'), findsOneWidget);
      expect(find.text('Emergency QR Scan Event'), findsOneWidget);
      expect(find.text('QR UID: GOLDEN99'), findsOneWidget);
      expect(find.text('Paramedic Priya Sharma'), findsOneWidget);
      expect(find.text('GVK EMRI 108 Ambulance'), findsOneWidget);
      expect(find.text('Hitec City, Hyderabad'), findsOneWidget);
      expect(find.text('Open in Google Maps'), findsOneWidget);
      expect(find.text('Emergency Alert Broadcasts'), findsOneWidget);
      expect(find.text('Mark as False Alarm'), findsOneWidget);
    });
  });
}
