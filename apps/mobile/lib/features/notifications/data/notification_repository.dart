import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import 'notification_models.dart';

final notificationRepositoryProvider =
    Provider<NotificationRepository>((ref) {
  final client = ref.watch(apiClientProvider);
  return NotificationRepository(client);
});

class NotificationRepository {
  final ApiClient _client;

  NotificationRepository(this._client);

  Dio get _dio => _client.dio;

  Future<ScanHistoryResponse> getHistory({
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await _dio.get(
        '/notifications/history',
        queryParameters: {'page': page, 'page_size': pageSize},
      );
      return ScanHistoryResponse.fromJson(
          response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> markFalseAlarm(String scanId) async {
    try {
      await _dio.post('/notifications/false-alarm/$scanId');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<TestNotificationResponse> sendTestNotification() async {
    try {
      final response = await _dio.post('/notifications/test');
      return TestNotificationResponse.fromJson(
          response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> registerFcmToken(String fcmToken) async {
    try {
      await _dio.patch(
        '/auth/fcm-token',
        data: {'fcm_token': fcmToken},
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(DioException e) {
    final msg = e.response?.data is Map
        ? (e.response?.data['detail']?.toString() ?? e.message)
        : e.message;
    return Exception(msg ?? 'Notification request failed');
  }
}
