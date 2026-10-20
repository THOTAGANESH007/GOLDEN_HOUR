import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import '../../../core/network/api_client.dart';
import '../../../core/services/secure_storage_service.dart';
import '../data/auth_remote_source.dart';
import '../data/auth_repository.dart';
import 'auth_state.dart';

// ── Providers ──────────────────────────────────────────────────────────────────

final authRemoteSourceProvider = Provider<AuthRemoteSource>((ref) {
  final client = ref.watch(apiClientProvider);
  return AuthRemoteSource(client);
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    remoteSource: ref.watch(authRemoteSourceProvider),
    storageService: ref.watch(secureStorageServiceProvider),
  );
});

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(authRepositoryProvider));
});

// ── Notifier ───────────────────────────────────────────────────────────────────

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;
  Timer? _countdownTimer;

  AuthNotifier(this._repository) : super(const AuthState());

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  /// Initialize & check whether user is already logged in (auto-login check)
  Future<void> checkAuthStatus() async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final isLoggedIn = await _repository.isAuthenticated();
      if (isLoggedIn) {
        final phone = await _repository.getUserPhone();
        final userId = await _repository.getUserId();
        state = state.copyWith(
          status: AuthStatus.authenticated,
          phone: phone,
          userId: userId,
        );
      } else {
        state = state.copyWith(status: AuthStatus.unauthenticated);
      }
    } catch (_) {
      state = state.copyWith(status: AuthStatus.unauthenticated);
    }
  }

  /// Send OTP to user phone
  Future<bool> sendOtp({
    required String phone,
    required bool consentGiven,
  }) async {
    if (!consentGiven) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Please accept DPDPA consent terms to continue.',
      );
      return false;
    }

    state = state.copyWith(
      status: AuthStatus.loading,
      errorMessage: null,
      phone: phone,
    );

    try {
      await _repository.sendOtp(
        phone: phone,
        consentGiven: consentGiven,
      );

      _startCountdown(60);

      state = state.copyWith(
        status: AuthStatus.otpSent,
        phone: phone,
        errorMessage: null,
      );
      return true;
    } catch (e, stackTrace) {
      await Sentry.captureException(e, stackTrace: stackTrace);
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  /// Verify entered 6-digit OTP
  Future<bool> verifyOtp(String otp) async {
    final currentPhone = state.phone;
    if (currentPhone == null || currentPhone.isEmpty) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Phone number missing. Please restart login.',
      );
      return false;
    }

    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);

    try {
      final data = await _repository.verifyOtp(
        phone: currentPhone,
        otp: otp.trim(),
      );

      _countdownTimer?.cancel();

      state = state.copyWith(
        status: AuthStatus.authenticated,
        phone: currentPhone,
        userId: data['user_id']?.toString(),
        errorMessage: null,
      );
      return true;
    } catch (e, stackTrace) {
      await Sentry.captureException(e, stackTrace: stackTrace);
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  /// Sign in with Google / Firebase
  Future<bool> signInWithGoogle() async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);

    try {
      final googleSignIn = GoogleSignIn(
        serverClientId: '226834628996-j852ld7lg3j4hf0m7cvc5fh2ccf1rnor.apps.googleusercontent.com',
        scopes: ['email', 'profile'],
      );
      final googleAccount = await googleSignIn.signIn();

      if (googleAccount == null) {
        // User dismissed the Google sign-in dialog
        state = state.copyWith(status: AuthStatus.unauthenticated);
        return false;
      }

      final googleAuth = await googleAccount.authentication;
      final idToken = googleAuth.idToken;

      if (idToken == null) {
        throw 'Failed to obtain Google ID token. Please check Google Play Services.';
      }

      // Link with Firebase Auth locally
      try {
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        await FirebaseAuth.instance.signInWithCredential(credential);
      } catch (_) {
        // Continue if local firebase auth client encounters non-critical issue
      }

      // Authenticate with Golden Hour Backend
      final data = await _repository.signInWithGoogle(idToken: idToken);

      state = state.copyWith(
        status: AuthStatus.authenticated,
        userId: data['user_id']?.toString(),
        errorMessage: null,
      );
      return true;
    } catch (e, stackTrace) {
      await Sentry.captureException(e, stackTrace: stackTrace);
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  /// Resend OTP after 60s cooldown
  Future<bool> resendOtp() async {
    if (state.resendCountdown > 0 || state.phone == null) return false;
    return await sendOtp(phone: state.phone!, consentGiven: true);
  }

  /// Logout and clear credentials
  Future<void> logout() async {
    _countdownTimer?.cancel();
    state = state.copyWith(status: AuthStatus.loading);
    try {
      await _repository.logout();
      try {
        await GoogleSignIn().signOut();
        await FirebaseAuth.instance.signOut();
      } catch (_) {}
    } finally {
      state = const AuthState(status: AuthStatus.unauthenticated);
    }
  }

  /// Hard delete user account and wipe session (DPDPA right to erasure)
  Future<bool> deleteAccount() async {
    _countdownTimer?.cancel();
    state = state.copyWith(status: AuthStatus.loading);
    try {
      await _repository.deleteAccount();
      state = const AuthState(status: AuthStatus.unauthenticated);
      return true;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  void clearError() {
    if (state.errorMessage != null) {
      state = state.copyWith(errorMessage: null);
    }
  }

  void _startCountdown(int seconds) {
    _countdownTimer?.cancel();
    state = state.copyWith(resendCountdown: seconds);

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.resendCountdown <= 1) {
        timer.cancel();
        state = state.copyWith(resendCountdown: 0);
      } else {
        state = state.copyWith(resendCountdown: state.resendCountdown - 1);
      }
    });
  }
}
