import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../constants/app_constants.dart';
import '../services/secure_storage_service.dart';
import 'auth_interceptor.dart';

class ApiClient {
  final Dio dio;
  final SecureStorageService storageService;

  ApiClient({
    required this.storageService,
    Dio? dioClient,
    String? baseUrl,
  }) : dio = dioClient ?? Dio() {
    String? envUrl;
    try {
      if (dotenv.isInitialized) {
        envUrl = dotenv.env['API_BASE_URL'];
      }
    } catch (_) {}

    final effectiveBaseUrl = baseUrl ?? envUrl ?? AppConstants.defaultApiBaseUrl;

    dio.options = BaseOptions(
      baseUrl: effectiveBaseUrl,
      connectTimeout: AppConstants.connectTimeout,
      receiveTimeout: AppConstants.receiveTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    dio.interceptors.add(
      AuthInterceptor(
        dio: dio,
        storageService: storageService,
        baseUrl: effectiveBaseUrl,
      ),
    );
  }

  // Helper error parser
  static String getErrorMessage(dynamic error) {
    if (error is DioException) {
      final data = error.response?.data;
      if (data is Map && data.containsKey('detail')) {
        return data['detail'].toString();
      }
      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.sendTimeout ||
          error.type == DioExceptionType.receiveTimeout) {
        return 'Connection timed out. Please check your internet connection.';
      }
      if (error.type == DioExceptionType.connectionError) {
        return 'Cannot connect to server. Please verify your connection.';
      }
      return error.message ?? 'An unexpected network error occurred.';
    }
    return error.toString();
  }
}
