import '../data/guide_model.dart';

class GuideState {
  final List<EmergencyGuide> allGuides;
  final List<EmergencyGuide> filteredGuides;
  final List<String> categories;
  final String selectedCategory;
  final String searchQuery;
  final bool isLoading;
  final String? error;
  final Map<String, EmergencyGuide> loadedGuideDetails;

  const GuideState({
    this.allGuides = const [],
    this.filteredGuides = const [],
    this.categories = const ['All'],
    this.selectedCategory = 'All',
    this.searchQuery = '',
    this.isLoading = false,
    this.error,
    this.loadedGuideDetails = const {},
  });

  GuideState copyWith({
    List<EmergencyGuide>? allGuides,
    List<EmergencyGuide>? filteredGuides,
    List<String>? categories,
    String? selectedCategory,
    String? searchQuery,
    bool? isLoading,
    String? error,
    Map<String, EmergencyGuide>? loadedGuideDetails,
  }) {
    return GuideState(
      allGuides: allGuides ?? this.allGuides,
      filteredGuides: filteredGuides ?? this.filteredGuides,
      categories: categories ?? this.categories,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      searchQuery: searchQuery ?? this.searchQuery,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      loadedGuideDetails: loadedGuideDetails ?? this.loadedGuideDetails,
    );
  }
}

