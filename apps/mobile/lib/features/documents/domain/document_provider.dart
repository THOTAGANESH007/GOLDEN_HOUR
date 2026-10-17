import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/document_repository.dart';
import 'document_state.dart';

final documentNotifierProvider =
    StateNotifierProvider<DocumentNotifier, DocumentState>((ref) {
  final repo = ref.watch(documentRepositoryProvider);
  return DocumentNotifier(repo);
});

class DocumentNotifier extends StateNotifier<DocumentState> {
  final DocumentRepository _repo;

  DocumentNotifier(this._repo) : super(const DocumentState()) {
    loadDocuments();
  }

  Future<void> loadDocuments() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final list = await _repo.getDocuments();
      state = state.copyWith(
        isLoading: false,
        documents: list,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  void setFilter(String filter) {
    state = state.copyWith(selectedFilter: filter);
  }

  Future<bool> uploadDocument({
    required String fileName,
    required String fileType,
    required String mimeType,
    String? filePath,
    Uint8List? fileBytes,
  }) async {
    state = state.copyWith(isUploading: true, clearError: true);
    try {
      final newDoc = await _repo.uploadDocument(
        fileName: fileName,
        fileType: fileType,
        mimeType: mimeType,
        filePath: filePath,
        fileBytes: fileBytes,
      );
      state = state.copyWith(
        isUploading: false,
        documents: [newDoc, ...state.documents],
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isUploading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  Future<bool> deleteDocument(String id) async {
    try {
      await _repo.deleteDocument(id);
      final updated = state.documents.where((d) => d.id != id).toList();
      state = state.copyWith(documents: updated);
      return true;
    } catch (e) {
      state = state.copyWith(
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }
}
