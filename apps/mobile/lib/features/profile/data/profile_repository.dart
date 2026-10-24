import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import 'profile_models.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final client = ref.watch(apiClientProvider);
  return ProfileRepository(client);
});

class ProfileRepository {
  final ApiClient _client;

  ProfileRepository(this._client);

  Dio get _dio => _client.dio;

  Future<PatientProfile> getProfile() async {
    try {
      final response = await _dio.get('/profile/me');
      return PatientProfile.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<PatientProfile> updateProfile(Map<String, dynamic> data) async {
    try {
      final response = await _dio.put('/profile/me', data: data);
      return PatientProfile.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<PatientProfile> uploadPhoto(String filePath) async {
    try {
      final fileName = filePath.split('/').last;
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath, filename: fileName),
      });
      final response = await _dio.post('/profile/me/photo', data: formData);
      return PatientProfile.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<PatientProfile> updatePrivacy({
    bool? showName,
    bool? showDob,
    bool? showPhoto,
  }) async {
    try {
      final payload = <String, dynamic>{};
      if (showName != null) payload['show_name'] = showName;
      if (showDob != null) payload['show_dob'] = showDob;
      if (showPhoto != null) payload['show_photo'] = showPhoto;

      final response = await _dio.patch('/profile/me/privacy', data: payload);
      return PatientProfile.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<PatientProfile> updateQrStatus(bool isActive) async {
    try {
      final response = await _dio.patch(
        '/profile/me/status',
        data: {'qr_is_active': isActive},
      );
      return PatientProfile.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<ProfileCompletion> getCompletion() async {
    try {
      final response = await _dio.get('/profile/completion');
      return ProfileCompletion.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<EmergencyContact>> getContacts() async {
    try {
      final response = await _dio.get('/profile/contacts');
      final list = response.data as List<dynamic>;
      return list
          .map((item) => EmergencyContact.fromJson(item as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<EmergencyContact> addContact(EmergencyContact contact) async {
    try {
      final response = await _dio.post('/profile/contacts', data: contact.toJson());
      return EmergencyContact.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<EmergencyContact> updateContact(
    String contactId,
    Map<String, dynamic> updates,
  ) async {
    try {
      final response = await _dio.put('/profile/contacts/$contactId', data: updates);
      return EmergencyContact.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> deleteContact(String contactId) async {
    try {
      await _dio.delete('/profile/contacts/$contactId');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(DioException e) {
    final msg = e.response?.data is Map
        ? (e.response?.data['detail']?.toString() ?? e.message)
        : e.message;
    return Exception(msg ?? 'Profile request failed');
  }
}
