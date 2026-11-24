import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_hour/core/constants/app_constants.dart';
import 'package:golden_hour/core/services/secure_storage_service.dart';
import 'package:golden_hour/features/auth/presentation/phone_input_screen.dart';
import 'package:golden_hour/features/offline_guides/data/guide_repository.dart';
import 'package:golden_hour/features/offline_guides/domain/guide_provider.dart';
import 'package:golden_hour/features/offline_guides/presentation/guides_screen.dart';
import 'package:golden_hour/features/profile/data/profile_models.dart';
import 'package:golden_hour/features/profile/data/profile_repository.dart';
import 'package:golden_hour/features/profile/domain/profile_provider.dart';
import 'package:golden_hour/features/profile/domain/profile_state.dart';
import 'package:golden_hour/features/profile/presentation/profile_home_screen.dart';
import 'package:golden_hour/features/qr/data/qr_repository.dart';
import 'package:golden_hour/features/qr/domain/qr_provider.dart';
import 'package:golden_hour/features/qr/domain/qr_state.dart';
import 'package:golden_hour/features/qr/presentation/qr_display_screen.dart';

class _FakeAssetBundle extends CachingAssetBundle {
  final Map<String, String> _assets;

  _FakeAssetBundle(this._assets);

  @override
  Future<String> loadString(String key, {bool cache = true}) async {
    if (_assets.containsKey(key)) {
      return _assets[key]!;
    }
    return '# Guide Content\n\nEmergency safety instructions.';
  }

  @override
  Future<ByteData> load(String key) async {
    final str = await loadString(key);
    final list = Uint8List.fromList(str.codeUnits);
    return ByteData.view(list.buffer);
  }
}

class _E2EStorageService extends SecureStorageService {
  final Map<String, String> _storage = {
    AppConstants.keyOnboardingCompleted: 'true',
    AppConstants.keyAccessToken: 'mock-jwt-access-token',
    AppConstants.keyUserPhone: '+919876543210',
    AppConstants.keyUserId: 'user-e2e-123',
  };

  @override
  Future<bool> isOnboardingCompleted() async => true;

  @override
  Future<bool> hasValidToken() async => true;

  @override
  Future<String?> getAccessToken() async => _storage[AppConstants.keyAccessToken];

  @override
  Future<String?> getUserPhone() async => _storage[AppConstants.keyUserPhone];

  @override
  Future<String?> getUserId() async => _storage[AppConstants.keyUserId];
}

class _E2EProfileNotifier extends ProfileNotifier {
  _E2EProfileNotifier() : super(_FakeProfileRepo()) {
    state = const ProfileState(
      isLoading: false,
      profile: PatientProfile(
        id: 'profile-e2e-123',
        userId: 'user-e2e-123',
        qrUid: 'GH-SAFE-2026',
        qrIsActive: true,
        fullName: 'Vikram Malhotra',
        bloodGroup: 'O+',
        allergies: ['Penicillin'],
        chronicConditions: ['Hypertension'],
        medications: [],
        wizardCompleted: true,
      ),
      completion: ProfileCompletion(
        score: 100,
        missing: [],
      ),
      contacts: [
        EmergencyContact(
          id: 'contact-1',
          name: 'Sunita Malhotra',
          phone: '+919811122233',
          relation: 'Spouse',
        ),
      ],
    );
  }

  @override
  Future<void> loadProfileData() async {}
}

class _E2EQRNotifier extends QRNotifier {
  _E2EQRNotifier() : super(_FakeQRRepo()) {
    state = const QRState(
      qrUid: 'GH-SAFE-2026',
      qrUrl: 'https://emergency.goldenhour.app/p/GH-SAFE-2026',
      isOffline: false,
    );
  }

  @override
  Future<void> loadQr() async {}
}

class _FakeProfileRepo implements ProfileRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeQRRepo implements QRRepository {
  @override
  String buildResponderUrl(String uid) => '${AppConstants.defaultResponderWebUrl}/$uid';

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final mockBundle = _FakeAssetBundle({
    'assets/guides/cpr_guidance.md':
        '# Cardiopulmonary Resuscitation (CPR)\n\n> EMERGENCY NOTICE: Call 112 immediately.',
    'assets/guides/severe_bleeding.md':
        '# Severe Bleeding\n\nApply direct pressure.',
  });

  group('Golden Hour End-to-End (E2E) Flow Integration Test Suite', () {
    testWidgets('E2E Stage 1: Phone Authentication & DPDPA 2023 Consent Verification',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final storage = _E2EStorageService();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            secureStorageServiceProvider.overrideWithValue(storage),
          ],
          child: const MaterialApp(
            home: PhoneInputScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Welcome to Golden Hour'), findsOneWidget);
      expect(find.text('+91'), findsOneWidget);
      expect(find.textContaining('DPDPA 2023'), findsWidgets);
      expect(find.text('Get Verification Code'), findsOneWidget);
    });

    testWidgets('E2E Stage 2: Profile Dashboard & Emergency Readiness Checklist',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final storage = _E2EStorageService();
      final profileNotifier = _E2EProfileNotifier();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            secureStorageServiceProvider.overrideWithValue(storage),
            profileNotifierProvider.overrideWith((ref) => profileNotifier),
          ],
          child: const MaterialApp(
            home: ProfileHomeScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Vikram Malhotra'), findsWidgets);
      expect(find.text('100%'), findsOneWidget);
      expect(find.text('View Emergency QR Code'), findsOneWidget);
      expect(find.text('Critical Emergency Summary'), findsOneWidget);
    });

    testWidgets('E2E Stage 3: Universal Emergency QR Code Generation & Action Triggers',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final profileNotifier = _E2EProfileNotifier();
      final qrNotifier = _E2EQRNotifier();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            profileNotifierProvider.overrideWith((ref) => profileNotifier),
            qrNotifierProvider.overrideWith((ref) => qrNotifier),
          ],
          child: const MaterialApp(
            home: QRDisplayScreen(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('Emergency QR Code'), findsOneWidget);
      expect(find.text('GOLDEN HOUR EMERGENCY ID'), findsOneWidget);
      expect(find.text('O+'), findsWidgets);
      expect(find.textContaining('GH-SAFE-2026'), findsWidgets);
      expect(find.text('Share / Save'), findsOneWidget);
      expect(find.text('Preview Page'), findsOneWidget);
    });

    testWidgets('E2E Stage 4: Offline Guides Access & Category Filtering',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final guideRepo = GuideRepository(bundle: mockBundle);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            guideRepositoryProvider.overrideWithValue(guideRepo),
          ],
          child: const MaterialApp(
            home: GuidesScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Emergency Safety Guides'), findsOneWidget);
      expect(find.text('100% Offline'), findsOneWidget);
      expect(find.text('Cardiopulmonary Resuscitation (CPR)'), findsOneWidget);
    });
  });
}
