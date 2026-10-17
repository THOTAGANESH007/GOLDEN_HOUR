import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:golden_hour/core/constants/app_constants.dart';
import 'package:golden_hour/core/services/secure_storage_service.dart';
import 'package:golden_hour/features/auth/presentation/phone_input_screen.dart';
import 'package:golden_hour/features/auth/presentation/splash_screen.dart';
import 'package:golden_hour/features/auth/presentation/otp_verify_screen.dart';
import 'package:flutter/material.dart';

class FakeSecureStorageService extends SecureStorageService {
  final Map<String, String> _data = {};

  @override
  Future<String?> getAccessToken() async => _data[AppConstants.keyAccessToken];

  @override
  Future<String?> getRefreshToken() async => _data[AppConstants.keyRefreshToken];

  @override
  Future<void> saveTokens({required String accessToken, required String refreshToken}) async {
    _data[AppConstants.keyAccessToken] = accessToken;
    _data[AppConstants.keyRefreshToken] = refreshToken;
  }

  @override
  Future<bool> hasValidToken() async => _data.containsKey(AppConstants.keyAccessToken);

  @override
  Future<void> clearAll() async => _data.clear();
}

void main() {
  testWidgets('SplashScreen renders branding and routes to login', (WidgetTester tester) async {
    final router = GoRouter(
      initialLocation: '/splash',
      routes: [
        GoRoute(
          path: '/splash',
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const Scaffold(body: Text('Login Screen')),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          secureStorageServiceProvider.overrideWithValue(FakeSecureStorageService()),
        ],
        child: MaterialApp.router(
          routerConfig: router,
        ),
      ),
    );

    expect(find.text('GOLDEN HOUR'), findsOneWidget);
    expect(find.text('Universal Emergency Medical ID'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 2000));
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('Login Screen'), findsOneWidget);
  });

  testWidgets('PhoneInputScreen renders mobile field and DPDPA consent', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          secureStorageServiceProvider.overrideWithValue(FakeSecureStorageService()),
        ],
        child: const MaterialApp(
          home: PhoneInputScreen(),
        ),
      ),
    );

    expect(find.text('Welcome to Golden Hour'), findsOneWidget);
    expect(find.text('+91'), findsOneWidget);
    expect(find.text('Get Verification Code'), findsOneWidget);
    expect(find.byType(Checkbox), findsOneWidget);
  });

  testWidgets('OtpVerifyScreen renders 6 OTP boxes and verify button', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          secureStorageServiceProvider.overrideWithValue(FakeSecureStorageService()),
        ],
        child: const MaterialApp(
          home: OtpVerifyScreen(),
        ),
      ),
    );

    expect(find.text('Enter Verification Code'), findsOneWidget);
    expect(find.text('Verify & Proceed'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(6));
  });
}
