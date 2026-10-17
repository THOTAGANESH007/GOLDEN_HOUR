import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';

class AuthRemoteSource {
  final ApiClient _apiClient;

  AuthRemoteSource(this._apiClient);

  Dio get _dio => _apiClient.dio;

  /// Send 6-digit OTP to user's phone via Fast2SMS / SMS Provider
  Future<void> sendOtp({
    required String phone,
    required bool consentGiven,
  }) async {
    try {
      await _dio.post(
        '/auth/send-otp',
        data: {
          'phone': phone,
          'consent_given': consentGiven,
        },
      );
    } catch (e) {
      throw ApiClient.getErrorMessage(e);
    }
  }

  /// Verify 6-digit OTP and obtain JWT access + refresh tokens
  Future<Map<String, dynamic>> verifyOtp({
    required String phone,
    required String otp,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/verify-otp',
        data: {
          'phone': phone,
          'otp': otp,
        },
      );
      return Map<String, dynamic>.from(response.data as Map);
    } catch (e) {
      throw ApiClient.getErrorMessage(e);
    }
  }

  /// Revoke tokens on server side
  Future<void> logout({required String refreshToken}) async {
    try {
      await _dio.post(
        '/auth/logout',
        data: {'refresh_token': refreshToken},
      );
    } catch (_) {
      // Best-effort logout on server
    }
  }

  /// DPDPA Right to Erasure — permanently delete user account and all PII
  Future<void> deleteAccount() async {
    try {
      await _dio.delete('/auth/delete-account');
    } catch (e) {
      throw ApiClient.getErrorMessage(e);
    }
  }
}
