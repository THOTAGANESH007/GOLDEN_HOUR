import 'package:dio/dio.dart';
import '../services/secure_storage_service.dart';

class AuthInterceptor extends QueuedInterceptor {
  final Dio _dio;
  final SecureStorageService _storageService;
  final String _baseUrl;

  AuthInterceptor({
    required Dio dio,
    required SecureStorageService storageService,
    required String baseUrl,
  })  : _dio = dio,
        _storageService = storageService,
        _baseUrl = baseUrl;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Skip token for unauthenticated auth endpoints
    final path = options.path;
    final isAuthPublic = path.contains('/auth/send-otp') ||
        path.contains('/auth/verify-otp') ||
        path.contains('/auth/refresh');

    if (!isAuthPublic && !options.headers.containsKey('Authorization')) {
      final token = await _storageService.getAccessToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }

    return handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final response = err.response;
    final requestOptions = err.requestOptions;

    // Check if error is 401 Unauthorized
    if (response?.statusCode == 401) {
      final isRefreshEndpoint = requestOptions.path.contains('/auth/refresh');
      final isAlreadyRetried = requestOptions.extra['isRetry'] == true;

      if (!isRefreshEndpoint && !isAlreadyRetried) {
        final refreshToken = await _storageService.getRefreshToken();
        if (refreshToken != null && refreshToken.isNotEmpty) {
          try {
            // Attempt silent token refresh
            final refreshResponse = await _dio.post(
              '$_baseUrl/auth/refresh',
              data: {'refresh_token': refreshToken},
              options: Options(extra: {'isRetry': true}),
            );

            if (refreshResponse.statusCode == 200) {
              final newAccessToken = refreshResponse.data['access_token'] as String;
              final newRefreshToken = refreshResponse.data['refresh_token'] as String? ?? refreshToken;

              await _storageService.saveTokens(
                accessToken: newAccessToken,
                refreshToken: newRefreshToken,
              );

              // Retry original request with new access token
              requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';
              requestOptions.extra['isRetry'] = true;

              final retryResponse = await _dio.fetch(requestOptions);
              return handler.resolve(retryResponse);
            }
          } catch (refreshErr) {
            // Refresh failed (token expired or revoked)
            await _storageService.clearAll();
          }
        } else {
          await _storageService.clearAll();
        }
      }
    }

    return handler.next(err);
  }
}
