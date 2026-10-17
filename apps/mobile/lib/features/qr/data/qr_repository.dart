import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/network/api_client.dart';
import '../../../core/services/secure_storage_service.dart';
import 'qr_models.dart';

final qrRepositoryProvider = Provider<QRRepository>((ref) {
  final client = ref.watch(apiClientProvider);
  final storage = ref.watch(secureStorageServiceProvider);
  return QRRepository(client, storage);
});

class QRRepository {
  final ApiClient _client;
  final SecureStorageService _storage;

  QRRepository(this._client, this._storage);

  Dio get _dio => _client.dio;

  String buildResponderUrl(String uid) {
    return '${AppConstants.defaultResponderWebUrl}/$uid';
  }

  Future<String?> getCachedQrUid() async {
    return await _storage.getCachedQrUid();
  }

  Future<void> saveCachedQrUid(String uid) async {
    await _storage.saveCachedQrUid(uid);
  }

  Future<QRData> generateQr() async {
    try {
      final response = await _dio.post('/qr/generate');
      final data = QRData.fromJson(response.data as Map<String, dynamic>);
      if (data.qrUid.isNotEmpty) {
        await saveCachedQrUid(data.qrUid);
      }
      return data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<QRData> regenerateQr() async {
    try {
      final response = await _dio.post('/qr/regenerate');
      final data = QRData.fromJson(response.data as Map<String, dynamic>);
      if (data.qrUid.isNotEmpty) {
        await saveCachedQrUid(data.qrUid);
      }
      return data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(DioException e) {
    final msg = e.response?.data is Map
        ? (e.response?.data['detail']?.toString() ?? e.message)
        : e.message;
    return Exception(msg ?? 'QR operation failed');
  }
}
