import '../data/document_models.dart';

class DocumentState {
  final bool isLoading;
  final bool isUploading;
  final String? errorMessage;
  final List<DocumentItem> documents;
  final String selectedFilter;

  const DocumentState({
    this.isLoading = false,
    this.isUploading = false,
    this.errorMessage,
    this.documents = const [],
    this.selectedFilter = 'all',
  });

  List<DocumentItem> get filteredDocuments {
    if (selectedFilter == 'all') {
      return documents;
    }
    return documents.where((d) => d.fileType == selectedFilter).toList();
  }

  DocumentState copyWith({
    bool? isLoading,
    bool? isUploading,
    String? errorMessage,
    bool clearError = false,
    List<DocumentItem>? documents,
    String? selectedFilter,
  }) {
    return DocumentState(
      isLoading: isLoading ?? this.isLoading,
      isUploading: isUploading ?? this.isUploading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      documents: documents ?? this.documents,
      selectedFilter: selectedFilter ?? this.selectedFilter,
    );
  }
}
