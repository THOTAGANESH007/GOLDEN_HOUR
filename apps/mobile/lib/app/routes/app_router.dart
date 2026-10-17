import 'package:flutter/material.dart';
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
import '../../features/scan_history/presentation/scan_detail_screen.dart';
import '../../features/scan_history/presentation/scan_history_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';

CustomTransitionPage<void> _buildSmoothTransition({
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 250),
    reverseTransitionDuration: const Duration(milliseconds: 200),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final fade = CurvedAnimation(parent: animation, curve: Curves.easeInOut);
      final slide = Tween<Offset>(
        begin: const Offset(0.04, 0),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
      );
      return FadeTransition(
        opacity: fade,
        child: SlideTransition(position: slide, child: child),
      );
    },
  );
}

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        pageBuilder: (context, state) => _buildSmoothTransition(
          state: state,
          child: const SplashScreen(),
        ),
      ),
      GoRoute(
        path: '/login',
        pageBuilder: (context, state) => _buildSmoothTransition(
          state: state,
          child: const PhoneInputScreen(),
        ),
      ),
      GoRoute(
        path: '/verify-otp',
        pageBuilder: (context, state) => _buildSmoothTransition(
          state: state,
          child: const OtpVerifyScreen(),
        ),
      ),
      GoRoute(
        path: '/home',
        pageBuilder: (context, state) => _buildSmoothTransition(
          state: state,
          child: const ProfileHomeScreen(),
        ),
      ),
      GoRoute(
        path: '/profile/wizard',
        pageBuilder: (context, state) => _buildSmoothTransition(
          state: state,
          child: const ProfileWizardScreen(),
        ),
      ),
      GoRoute(
        path: '/profile/edit',
        pageBuilder: (context, state) => _buildSmoothTransition(
          state: state,
          child: const EditProfileScreen(),
        ),
      ),
      GoRoute(
        path: '/profile/privacy',
        pageBuilder: (context, state) => _buildSmoothTransition(
          state: state,
          child: const PrivacySettingsScreen(),
        ),
      ),
      GoRoute(
        path: '/qr',
        pageBuilder: (context, state) => _buildSmoothTransition(
          state: state,
          child: const QRDisplayScreen(),
        ),
      ),
      GoRoute(
        path: '/qr/share',
        pageBuilder: (context, state) => _buildSmoothTransition(
          state: state,
          child: const QRShareScreen(),
        ),
      ),
      GoRoute(
        path: '/qr/preview',
        pageBuilder: (context, state) => _buildSmoothTransition(
          state: state,
          child: QRPreviewWebview(
            initialUid: state.uri.queryParameters['uid'],
          ),
        ),
      ),
      GoRoute(
        path: '/notifications',
        pageBuilder: (context, state) => _buildSmoothTransition(
          state: state,
          child: const NotificationsScreen(),
        ),
      ),
      GoRoute(
        path: '/documents',
        pageBuilder: (context, state) => _buildSmoothTransition(
          state: state,
          child: const DocumentsScreen(),
        ),
      ),
      GoRoute(
        path: '/scan-history',
        pageBuilder: (context, state) => _buildSmoothTransition(
          state: state,
          child: const ScanHistoryScreen(),
        ),
      ),
      GoRoute(
        path: '/scan-history/detail',
        pageBuilder: (context, state) {
          final scanId = state.uri.queryParameters['id'] ?? '';
          return _buildSmoothTransition(
            state: state,
            child: ScanDetailScreen(scanId: scanId),
          );
        },
      ),
      GoRoute(
        path: '/settings',
        pageBuilder: (context, state) => _buildSmoothTransition(
          state: state,
          child: const SettingsScreen(),
        ),
      ),
    ],
  );
});
