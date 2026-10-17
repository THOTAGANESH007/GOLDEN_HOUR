import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/scan_models.dart';
import '../data/scan_repository.dart';
import 'scan_history_state.dart';

final scanHistoryNotifierProvider =
    StateNotifierProvider<ScanHistoryNotifier, ScanHistoryState>((ref) {
  final repo = ref.watch(scanRepositoryProvider);
  return ScanHistoryNotifier(repo)..loadInitial();
});

class ScanHistoryNotifier extends StateNotifier<ScanHistoryState> {
  final ScanRepository _repository;

  ScanHistoryNotifier(this._repository) : super(const ScanHistoryState());

  Future<void> loadInitial() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final res = await _repository.fetchScanEvents(page: 1, pageSize: 20);
      state = state.copyWith(
        isLoading: false,
        items: res.items,
        currentPage: 1,
        totalCount: res.total,
        hasMore: res.hasMore,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  Future<void> loadNextPage() async {
    if (state.isLoading || state.isLoadingMore || !state.hasMore) {
      return;
    }

    final nextPage = state.currentPage + 1;
    state = state.copyWith(isLoadingMore: true, clearError: true);

    try {
      final res = await _repository.fetchScanEvents(
        page: nextPage,
        pageSize: 20,
      );
      state = state.copyWith(
        isLoadingMore: false,
        items: [...state.items, ...res.items],
        currentPage: nextPage,
        totalCount: res.total,
        hasMore: res.hasMore,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingMore: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  Future<void> refresh() async {
    await loadInitial();
  }

  void selectEvent(ScanHistoryItem event) {
    state = state.copyWith(selectedEvent: event);
  }

  Future<ScanHistoryItem?> loadDetail(String scanId) async {
    state = state.copyWith(isLoadingDetail: true, clearError: true);
    try {
      final detail = await _repository.fetchScanEventDetail(scanId);
      final updatedList = state.items.map((item) {
        return item.id == scanId ? detail : item;
      }).toList();

      state = state.copyWith(
        isLoadingDetail: false,
        selectedEvent: detail,
        items: updatedList,
      );
      return detail;
    } catch (e) {
      state = state.copyWith(
        isLoadingDetail: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
      return null;
    }
  }

  Future<bool> markFalseAlarm(String scanId) async {
    state = state.copyWith(isMarkingFalseAlarm: true, clearError: true);
    try {
      final updated = await _repository.markFalseAlarm(scanId);
      final updatedList = state.items.map((item) {
        return item.id == scanId ? updated : item;
      }).toList();

      state = state.copyWith(
        isMarkingFalseAlarm: false,
        items: updatedList,
        selectedEvent:
            state.selectedEvent?.id == scanId ? updated : state.selectedEvent,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isMarkingFalseAlarm: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }
}
