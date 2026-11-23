import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/guide_model.dart';
import '../data/guide_repository.dart';
import 'guide_state.dart';

final guideRepositoryProvider = Provider<GuideRepository>((ref) {
  return GuideRepository();
});

class GuideNotifier extends StateNotifier<GuideState> {
  final GuideRepository _repository;

  GuideNotifier(this._repository) : super(const GuideState()) {
    init();
  }

  void init() {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final guides = _repository.getAllGuides();
      final categories = _repository.getCategories();
      state = state.copyWith(
        allGuides: guides,
        filteredGuides: guides,
        categories: categories,
        selectedCategory: 'All',
        searchQuery: '',
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void selectCategory(String category) {
    if (state.selectedCategory == category) return;
    _applyFilters(category: category, query: state.searchQuery);
  }

  void search(String query) {
    _applyFilters(category: state.selectedCategory, query: query);
  }

  void clearSearch() {
    _applyFilters(category: state.selectedCategory, query: '');
  }

  void _applyFilters({required String category, required String query}) {
    final filtered = _repository.searchGuides(query: query, category: category);
    state = state.copyWith(
      selectedCategory: category,
      searchQuery: query,
      filteredGuides: filtered,
    );
  }

  Future<EmergencyGuide?> loadGuideDetail(String id) async {
    if (state.loadedGuideDetails.containsKey(id)) {
      return state.loadedGuideDetails[id];
    }

    try {
      final guide = await _repository.getGuideById(id);
      if (guide != null) {
        final updatedMap = Map<String, EmergencyGuide>.from(state.loadedGuideDetails);
        updatedMap[id] = guide;
        state = state.copyWith(loadedGuideDetails: updatedMap);
      }
      return guide;
    } catch (e) {
      state = state.copyWith(error: 'Failed to load guide: $e');
      return null;
    }
  }
}

final guideNotifierProvider =
    StateNotifierProvider<GuideNotifier, GuideState>((ref) {
  final repository = ref.watch(guideRepositoryProvider);
  return GuideNotifier(repository);
});

