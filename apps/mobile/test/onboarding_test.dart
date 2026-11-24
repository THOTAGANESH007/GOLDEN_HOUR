import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:golden_hour/core/constants/app_constants.dart';
import 'package:golden_hour/core/services/secure_storage_service.dart';
import 'package:golden_hour/features/auth/presentation/splash_screen.dart';
import 'package:golden_hour/features/onboarding/presentation/onboarding_screen.dart';

class FakeSecureStorageService extends SecureStorageService {
  final Map<String, String> _data = {};

  @override
  Future<bool> isOnboardingCompleted() async {
    return _data[AppConstants.keyOnboardingCompleted] == 'true';
  }

  @override
  Future<void> setOnboardingCompleted(bool completed) async {
    _data[AppConstants.keyOnboardingCompleted] = completed ? 'true' : 'false';
  }

  @override
  Future<bool> hasValidToken() async => false;
}

void main() {
  group('Onboarding Flow Tests', () {
    testWidgets('OnboardingScreen renders first slide and navigation controls',
        (tester) async {
      final fakeStorage = FakeSecureStorageService();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            secureStorageServiceProvider.overrideWithValue(fakeStorage),
          ],
          child: const MaterialApp(
            home: OnboardingScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Header branding
      expect(find.text('GOLDEN HOUR'), findsOneWidget);
      expect(find.text('Skip'), findsOneWidget);

      // Slide 1 Content
      expect(find.text('INSTANT IDENTIFICATION'), findsOneWidget);
      expect(find.text('Universal Emergency Safety QR'), findsOneWidget);
      expect(find.text('Continue'), findsOneWidget);
    });

    testWidgets('Tapping Continue advances through slides to Get Started',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final fakeStorage = FakeSecureStorageService();
      bool navigatedToLogin = false;

      final router = GoRouter(
        initialLocation: '/onboarding',
        routes: [
          GoRoute(
            path: '/onboarding',
            builder: (_, __) => const OnboardingScreen(),
          ),
          GoRoute(
            path: '/login',
            builder: (_, __) {
              navigatedToLogin = true;
              return const Scaffold(body: Text('Login Screen'));
            },
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            secureStorageServiceProvider.overrideWithValue(fakeStorage),
          ],
          child: MaterialApp.router(
            routerConfig: router,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Slide 1 -> Slide 2
      await tester.tap(find.byKey(const ValueKey('onboarding_action_button')));
      await tester.pumpAndSettle();
      expect(find.text('Automated Family Alerts'), findsOneWidget);
      expect(find.text('ZERO-DELAY NOTIFICATIONS'), findsOneWidget);

      // Slide 2 -> Slide 3
      await tester.tap(find.byKey(const ValueKey('onboarding_action_button')));
      await tester.pumpAndSettle();
      expect(find.text('Offline Emergency Safety Guides'), findsOneWidget);
      expect(find.text('OFFLINE READINESS'), findsOneWidget);

      // Slide 3 -> Slide 4 (Final Slide)
      await tester.tap(find.byKey(const ValueKey('onboarding_action_button')));
      await tester.pumpAndSettle();
      expect(find.text('Privacy-First & DPDPA 2023 Compliant'), findsOneWidget);
      expect(find.text('LEGAL & ENCRYPTED'), findsOneWidget);
      expect(find.text('Get Started'), findsOneWidget);
      expect(find.text('Skip'), findsNothing);

      // Tap Get Started
      await tester.tap(find.byKey(const ValueKey('onboarding_action_button')));
      await tester.pumpAndSettle();

      expect(await fakeStorage.isOnboardingCompleted(), isTrue);
      expect(navigatedToLogin, isTrue);
    });

    testWidgets('Tapping Skip immediately persists completion and routes to login',
        (tester) async {
      final fakeStorage = FakeSecureStorageService();
      bool navigatedToLogin = false;

      final router = GoRouter(
        initialLocation: '/onboarding',
        routes: [
          GoRoute(
            path: '/onboarding',
            builder: (_, __) => const OnboardingScreen(),
          ),
          GoRoute(
            path: '/login',
            builder: (_, __) {
              navigatedToLogin = true;
              return const Scaffold(body: Text('Login Screen'));
            },
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            secureStorageServiceProvider.overrideWithValue(fakeStorage),
          ],
          child: MaterialApp.router(
            routerConfig: router,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Skip'), findsOneWidget);
      await tester.tap(find.text('Skip'));
      await tester.pumpAndSettle();

      expect(await fakeStorage.isOnboardingCompleted(), isTrue);
      expect(navigatedToLogin, isTrue);
    });

    testWidgets('SplashScreen routes to /onboarding when not completed',
        (tester) async {
      final fakeStorage = FakeSecureStorageService();
      bool reachedOnboarding = false;

      final router = GoRouter(
        initialLocation: '/splash',
        routes: [
          GoRoute(
            path: '/splash',
            builder: (_, __) => const SplashScreen(),
          ),
          GoRoute(
            path: '/onboarding',
            builder: (_, __) {
              reachedOnboarding = true;
              return const Scaffold(body: Text('Onboarding View'));
            },
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            secureStorageServiceProvider.overrideWithValue(fakeStorage),
          ],
          child: MaterialApp.router(
            routerConfig: router,
          ),
        ),
      );

      expect(find.text('GOLDEN HOUR'), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 2000));
      await tester.pump(const Duration(milliseconds: 200));

      expect(reachedOnboarding, isTrue);
      expect(find.text('Onboarding View'), findsOneWidget);
    });
  });
}

