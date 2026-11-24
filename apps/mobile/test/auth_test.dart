import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:golden_hour/features/auth/domain/auth_provider.dart';
import 'package:golden_hour/features/auth/domain/auth_state.dart';
import 'package:golden_hour/features/auth/data/auth_repository.dart';
import 'package:golden_hour/features/auth/presentation/phone_input_screen.dart';
import 'package:golden_hour/features/auth/presentation/otp_verify_screen.dart';

class MockAuthNotifier extends AuthNotifier {
  bool sendOtpCalled = false;
  bool verifyOtpCalled = false;
  String? lastSentPhone;
  String? lastVerifiedOtp;

  MockAuthNotifier([AuthState initialState = const AuthState()])
      : super(_FakeAuthRepository()) {
    state = initialState;
  }

  @override
  Future<bool> sendOtp({required String phone, required bool consentGiven}) async {
    sendOtpCalled = true;
    lastSentPhone = phone;
    state = state.copyWith(phone: phone, status: AuthStatus.otpSent, resendCountdown: 30);
    return true;
  }

  @override
  Future<bool> verifyOtp(String otp) async {
    verifyOtpCalled = true;
    lastVerifiedOtp = otp;
    state = state.copyWith(status: AuthStatus.authenticated);
    return true;
  }
}

class _FakeAuthRepository implements AuthRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget buildTestApp({required Widget home, required MockAuthNotifier notifier}) {
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(path: '/', builder: (_, __) => home),
        GoRoute(path: '/verify-otp', builder: (_, __) => const Scaffold(body: Text('Verify Screen'))),
        GoRoute(path: '/home', builder: (_, __) => const Scaffold(body: Text('Home Screen'))),
      ],
    );

    return ProviderScope(
      overrides: [
        authNotifierProvider.overrideWith((ref) => notifier),
      ],
      child: MaterialApp.router(
        routerConfig: router,
      ),
    );
  }

  group('PhoneInputScreen Widget Tests', () {
    testWidgets('renders phone input, India prefix, consent checkbox, and submit button',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final mockNotifier = MockAuthNotifier();
      await tester.pumpWidget(buildTestApp(home: const PhoneInputScreen(), notifier: mockNotifier));
      await tester.pumpAndSettle();

      expect(find.text('Welcome to Golden Hour'), findsOneWidget);
      expect(find.text('+91'), findsOneWidget);
      expect(find.byType(TextFormField), findsOneWidget);
      expect(find.textContaining('DPDPA 2023'), findsWidgets);
      expect(find.text('Get Verification Code'), findsOneWidget);
    });

    testWidgets('shows validation error when submitting incomplete phone number',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final mockNotifier = MockAuthNotifier();
      await tester.pumpWidget(buildTestApp(home: const PhoneInputScreen(), notifier: mockNotifier));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField), '98765');
      await tester.tap(find.text('Get Verification Code'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter a valid 10-digit mobile number'), findsOneWidget);
      expect(mockNotifier.sendOtpCalled, isFalse);
    });

    testWidgets('shows error snackbar if DPDPA consent is not checked',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final mockNotifier = MockAuthNotifier();
      await tester.pumpWidget(buildTestApp(home: const PhoneInputScreen(), notifier: mockNotifier));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField), '9876543210');
      await tester.tap(find.text('Get Verification Code'));
      await tester.pumpAndSettle();

      expect(find.textContaining('DPDPA 2023 privacy consent'), findsOneWidget);
      expect(mockNotifier.sendOtpCalled, isFalse);
    });

    testWidgets('successfully triggers sendOtp when valid phone and consent are provided',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final mockNotifier = MockAuthNotifier();
      await tester.pumpWidget(buildTestApp(home: const PhoneInputScreen(), notifier: mockNotifier));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField), '9876543210');

      final checkbox = find.byType(Checkbox);
      await tester.tap(checkbox);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Get Verification Code'));
      await tester.pumpAndSettle();

      expect(mockNotifier.sendOtpCalled, isTrue);
      expect(mockNotifier.lastSentPhone, '+919876543210');
    });
  });

  group('OtpVerifyScreen Widget Tests', () {
    testWidgets('renders title, 6 OTP digit inputs, and verify button',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final mockNotifier = MockAuthNotifier(
        const AuthState(phone: '+919876543210', resendCountdown: 25),
      );

      await tester.pumpWidget(buildTestApp(home: const OtpVerifyScreen(), notifier: mockNotifier));
      await tester.pumpAndSettle();

      expect(find.text('Enter Verification Code'), findsOneWidget);
      expect(find.textContaining('+919876543210'), findsOneWidget);

      final textFields = find.byType(TextField);
      expect(textFields, findsNWidgets(6));
      expect(find.text('Verify & Proceed'), findsOneWidget);
      expect(find.textContaining('25s'), findsOneWidget);
    });

    testWidgets('shows warning snackbar when verifying with less than 6 digits',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final mockNotifier = MockAuthNotifier(
        const AuthState(phone: '+919876543210'),
      );

      await tester.pumpWidget(buildTestApp(home: const OtpVerifyScreen(), notifier: mockNotifier));
      await tester.pumpAndSettle();

      final textFields = find.byType(TextField);
      await tester.enterText(textFields.at(0), '1');
      await tester.enterText(textFields.at(1), '2');
      await tester.enterText(textFields.at(2), '3');
      await tester.pumpAndSettle();

      await tester.tap(find.text('Verify & Proceed'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter all 6 digits of the OTP.'), findsOneWidget);
      expect(mockNotifier.verifyOtpCalled, isFalse);
    });

    testWidgets('submits 6-digit OTP and navigates to home when all fields are populated',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final mockNotifier = MockAuthNotifier(
        const AuthState(phone: '+919876543210'),
      );

      await tester.pumpWidget(buildTestApp(home: const OtpVerifyScreen(), notifier: mockNotifier));
      await tester.pumpAndSettle();

      final textFields = find.byType(TextField);
      for (int i = 0; i < 6; i++) {
        await tester.enterText(textFields.at(i), '${i + 1}');
      }
      await tester.pumpAndSettle();

      expect(mockNotifier.verifyOtpCalled, isTrue);
      expect(mockNotifier.lastVerifiedOtp, '123456');
      expect(find.text('Home Screen'), findsOneWidget);
    });
  });
}
