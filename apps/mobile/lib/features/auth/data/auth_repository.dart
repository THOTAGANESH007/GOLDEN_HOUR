import '../../../core/services/secure_storage_service.dart';
import 'auth_remote_source.dart';

class AuthRepository {
  final AuthRemoteSource _remoteSource;
  final SecureStorageService _storageService;

  AuthRepository({
    required AuthRemoteSource remoteSource,
    required SecureStorageService storageService,
  })  : _remoteSource = remoteSource,
        _storageService = storageService;

  /// Request OTP for given E.164 phone number
  Future<void> sendOtp({
    required String phone,
    required bool consentGiven,
  }) async {
    await _remoteSource.sendOtp(
      phone: phone,
      consentGiven: consentGiven,
    );
  }

  /// Verify OTP, persist tokens, and return user session data
  Future<Map<String, dynamic>> verifyOtp({
    required String phone,
    required String otp,
  }) async {
    final data = await _remoteSource.verifyOtp(phone: phone, otp: otp);

    final accessToken = data['access_token'] as String;
    final refreshToken = data['refresh_token'] as String;
    final userId = data['user_id']?.toString() ?? '';

    await _storageService.saveTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );

    await _storageService.saveUserData(
      userId: userId,
      phone: phone,
    );

    return data;
  }

  /// Check whether valid token exists in storage for auto-login
  Future<bool> isAuthenticated() async {
    return await _storageService.hasValidToken();
  }

  /// Retrieve cached user phone number
  Future<String?> getUserPhone() async {
    return await _storageService.getUserPhone();
  }

  /// Retrieve cached user ID
  Future<String?> getUserId() async {
    return await _storageService.getUserId();
  }

  /// Logout locally and revoke on backend
  Future<void> logout() async {
    final refreshToken = await _storageService.getRefreshToken();
    if (refreshToken != null) {
      await _remoteSource.logout(refreshToken: refreshToken);
    }
    await _storageService.clearAll();
  }

  /// Hard delete user account and wipe local storage
  Future<void> deleteAccount() async {
    await _remoteSource.deleteAccount();
    await _storageService.clearAll();
  }
}
