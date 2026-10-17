import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import 'scan_models.dart';

final scanRepositoryProvider = Provider<ScanRepository>((ref) {
  final client = ref.watch(apiClientProvider);
  return ScanRepository(client);
});

class ScanRepository {
  final ApiClient _client;

  ScanRepository(this._client);

  Dio get _dio => _client.dio;

  /// Fetch paginated scan history
  Future<ScanHistoryListResponse> fetchScanEvents({
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await _dio.get(
        '/scan-events',
        queryParameters: {
          'page': page,
          'page_size': pageSize,
        },
      );
      return ScanHistoryListResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Fetch single scan event by ID
  Future<ScanHistoryItem> fetchScanEventDetail(String scanId) async {
    try {
      final response = await _dio.get('/scan-events/$scanId');
      return ScanHistoryItem.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Mark a scan event as a false alarm
  Future<ScanHistoryItem> markFalseAlarm(String scanId) async {
    try {
      final response = await _dio.patch('/scan-events/$scanId/false-alarm');
      return ScanHistoryItem.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(DioException e) {
    if (e.response != null && e.response?.data is Map<String, dynamic>) {
      final detail = (e.response!.data as Map<String, dynamic>)['detail'];
      return Exception(detail?.toString() ?? 'An unexpected error occurred.');
    }
    return Exception(e.message ?? 'Network connection error.');
  }
}
