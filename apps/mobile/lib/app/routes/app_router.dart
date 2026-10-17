import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/otp_verify_screen.dart';
import '../../features/auth/presentation/phone_input_screen.dart';
import '../../features/auth/presentation/splash_screen.dart';
import '../../features/documents/presentation/documents_screen.dart';
import '../../features/notifications/presentation/notifications_screen.dart';
import '../../features/profile/presentation/edit_profile_screen.dart';
import '../../features/profile/presentation/privacy_settings_screen.dart';
import '../../features/profile/presentation/profile_home_screen.dart';
import '../../features/profile/presentation/wizard/profile_wizard_screen.dart';
import '../../features/qr/presentation/qr_display_screen.dart';
import '../../features/qr/presentation/qr_preview_webview.dart';
import '../../features/qr/presentation/qr_share_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const PhoneInputScreen(),
      ),
      GoRoute(
        path: '/verify-otp',
        builder: (context, state) => const OtpVerifyScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const ProfileHomeScreen(),
      ),
      GoRoute(
        path: '/profile/wizard',
        builder: (context, state) => const ProfileWizardScreen(),
      ),
      GoRoute(
        path: '/profile/edit',
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: '/profile/privacy',
        builder: (context, state) => const PrivacySettingsScreen(),
      ),
      GoRoute(
        path: '/qr',
        builder: (context, state) => const QRDisplayScreen(),
      ),
      GoRoute(
        path: '/qr/share',
        builder: (context, state) => const QRShareScreen(),
      ),
      GoRoute(
        path: '/qr/preview',
        builder: (context, state) => QRPreviewWebview(
          initialUid: state.uri.queryParameters['uid'],
        ),
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: '/documents',
        builder: (context, state) => const DocumentsScreen(),
      ),
    ],
  );
});
