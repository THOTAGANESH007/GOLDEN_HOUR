import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:golden_hour/core/constants/app_constants.dart';
import 'package:golden_hour/features/profile/data/profile_models.dart';
import 'package:golden_hour/features/profile/data/profile_repository.dart';
import 'package:golden_hour/features/profile/domain/profile_provider.dart';
import 'package:golden_hour/features/profile/domain/profile_state.dart';
import 'package:golden_hour/features/qr/data/qr_models.dart';
import 'package:golden_hour/features/qr/data/qr_repository.dart';
import 'package:golden_hour/features/qr/domain/qr_provider.dart';
import 'package:golden_hour/features/qr/domain/qr_state.dart';
import 'package:golden_hour/features/qr/presentation/qr_display_screen.dart';
import 'package:golden_hour/features/qr/presentation/qr_share_screen.dart';
import 'package:qr_flutter/qr_flutter.dart';

class MockQRNotifier extends QRNotifier {
  MockQRNotifier(QRState initialState) : super(_FakeQRRepository()) {
    state = initialState;
  }

  @override
  Future<void> loadQr() async {}
}

class _FakeQRRepository implements QRRepository {
  @override
  String buildResponderUrl(String uid) {
    return '${AppConstants.defaultResponderWebUrl}/$uid';
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockProfileNotifierForQR extends ProfileNotifier {
  MockProfileNotifierForQR(ProfileState initialState)
      : super(_FakeProfileRepositoryForQR()) {
    state = initialState;
  }

  @override
  Future<void> loadProfileData() async {}
}

class _FakeProfileRepositoryForQR implements ProfileRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('Module 3 — QR Code Models & Serialization', () {
    test('QRData serializes and deserializes correctly', () {
      final json = {
        'qr_uid': 'ABCD1234',
        'qr_url': 'https://goldenhr.pages.dev/p/ABCD1234',
        'message': 'QR code generated successfully',
      };

      final data = QRData.fromJson(json);
      expect(data.qrUid, 'ABCD1234');
      expect(data.qrUrl, 'https://goldenhr.pages.dev/p/ABCD1234');
      expect(data.message, 'QR code generated successfully');

      final serialized = data.toJson();
      expect(serialized['qr_uid'], 'ABCD1234');
      expect(serialized['qr_url'], 'https://goldenhr.pages.dev/p/ABCD1234');
    });

    test('buildResponderUrl generates proper Cloudflare responder link', () {
      final repo = _FakeQRRepository();
      expect(
        repo.buildResponderUrl('XYZ98765'),
        'https://goldenhr.pages.dev/p/XYZ98765',
      );
    });
  });

  group('Module 3 — QR Display Screen Presentation', () {
    testWidgets('QRDisplayScreen renders QR image, blood group, and UID',
        (tester) async {
      const mockProfile = PatientProfile(
        id: 'p-1',
        userId: 'u-1',
        fullName: 'Vikram Singh',
        bloodGroup: 'AB+',
        qrIsActive: true,
      );

      const mockQRState = QRState(
        qrUid: 'VKRM1234',
        qrUrl: 'https://goldenhr.pages.dev/p/VKRM1234',
        isOffline: false,
      );

      final router = GoRouter(
        initialLocation: '/qr',
        routes: [
          GoRoute(
            path: '/qr',
            builder: (_, __) => const QRDisplayScreen(),
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            profileNotifierProvider.overrideWith(
              (ref) => MockProfileNotifierForQR(
                const ProfileState(profile: mockProfile),
              ),
            ),
            qrNotifierProvider.overrideWith(
              (ref) => MockQRNotifier(mockQRState),
            ),
          ],
          child: MaterialApp.router(
            routerConfig: router,
          ),
        ),
      );

      expect(find.text('Emergency QR Code'), findsOneWidget);
      expect(find.text('GOLDEN HOUR EMERGENCY ID'), findsOneWidget);
      expect(find.text('BLOOD GROUP'), findsOneWidget);
      expect(find.text('AB+'), findsOneWidget);
      expect(find.text('Vikram Singh'), findsOneWidget);
      expect(find.text('UID: VKRM1234'), findsOneWidget);
      expect(find.byType(QrImageView), findsOneWidget);
      expect(find.text('Share / Save'), findsOneWidget);
      expect(find.text('Preview Page'), findsOneWidget);
      expect(find.text('Regenerate QR Code'), findsOneWidget);
    });

    testWidgets('QRDisplayScreen shows offline banner when cached offline',
        (tester) async {
      const mockQRState = QRState(
        qrUid: 'OFFLINE1',
        qrUrl: 'https://goldenhr.pages.dev/p/OFFLINE1',
        isOffline: true,
      );

      final router = GoRouter(
        initialLocation: '/qr',
        routes: [
          GoRoute(
            path: '/qr',
            builder: (_, __) => const QRDisplayScreen(),
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            profileNotifierProvider.overrideWith(
              (ref) => MockProfileNotifierForQR(const ProfileState()),
            ),
            qrNotifierProvider.overrideWith(
              (ref) => MockQRNotifier(mockQRState),
            ),
          ],
          child: MaterialApp.router(
            routerConfig: router,
          ),
        ),
      );

      expect(find.textContaining('Viewing offline cached QR code'), findsOneWidget);
    });
  });

  group('Module 3 — QR Share Screen Presentation', () {
    testWidgets('QRShareScreen renders printable card with export buttons',
        (tester) async {
      const mockProfile = PatientProfile(
        id: 'p-1',
        userId: 'u-1',
        fullName: 'Ananya Roy',
        bloodGroup: 'O-',
      );

      const mockQRState = QRState(
        qrUid: 'ANNY5678',
        qrUrl: 'https://goldenhr.pages.dev/p/ANNY5678',
      );

      final router = GoRouter(
        initialLocation: '/qr/share',
        routes: [
          GoRoute(
            path: '/qr/share',
            builder: (_, __) => const QRShareScreen(),
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            profileNotifierProvider.overrideWith(
              (ref) => MockProfileNotifierForQR(
                const ProfileState(profile: mockProfile),
              ),
            ),
            qrNotifierProvider.overrideWith(
              (ref) => MockQRNotifier(mockQRState),
            ),
          ],
          child: MaterialApp.router(
            routerConfig: router,
          ),
        ),
      );

      expect(find.text('Share Emergency QR'), findsOneWidget);
      expect(find.text('GOLDEN HOUR'), findsOneWidget);
      expect(find.text('EMERGENCY MEDICAL ID'), findsOneWidget);
      expect(find.text('O-'), findsOneWidget);
      expect(find.text('Ananya Roy'), findsOneWidget);
      expect(find.text('Save QR Card to Gallery (PNG)'), findsOneWidget);
      expect(find.text('Share QR Image to Family / Doctor'), findsOneWidget);
      expect(find.text('Copy & Share Public Link'), findsOneWidget);
    });
  });
}
