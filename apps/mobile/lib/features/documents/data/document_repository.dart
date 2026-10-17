import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import 'document_models.dart';

final documentRepositoryProvider = Provider<DocumentRepository>((ref) {
  final client = ref.watch(apiClientProvider);
  return DocumentRepository(client);
});

class DocumentRepository {
  final ApiClient _client;

  DocumentRepository(this._client);

  Dio get _dio => _client.dio;

  Future<List<DocumentItem>> getDocuments() async {
    try {
      final response = await _dio.get('/documents');
      final list = response.data as List<dynamic>;
      return list
          .map((item) => DocumentItem.fromJson(item as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<DocumentItem> uploadDocument({
    required String fileName,
    required String fileType,
    required String mimeType,
    String? filePath,
    Uint8List? fileBytes,
  }) async {
    try {
      MultipartFile multipartFile;
      if (filePath != null && filePath.isNotEmpty) {
        multipartFile = await MultipartFile.fromFile(
          filePath,
          filename: fileName,
        );
      } else if (fileBytes != null) {
        multipartFile = MultipartFile.fromBytes(
          fileBytes,
          filename: fileName,
        );
      } else {
        throw Exception('Neither file path nor bytes provided for upload');
      }

      final formData = FormData.fromMap({
        'file': multipartFile,
        'file_type': fileType,
      });

      final response = await _dio.post(
        '/documents/upload',
        data: formData,
      );

      return DocumentItem.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> deleteDocument(String id) async {
    try {
      await _dio.delete('/documents/$id');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(DioException e) {
    final msg = e.response?.data is Map
        ? (e.response?.data['detail']?.toString() ?? e.message)
        : e.message;
    return Exception(msg ?? 'Document request failed');
  }
}
