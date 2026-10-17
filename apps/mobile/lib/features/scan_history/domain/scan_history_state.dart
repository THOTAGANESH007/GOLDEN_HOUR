import '../data/scan_models.dart';

class ScanHistoryState {
  final bool isLoading;
  final bool isLoadingMore;
  final bool isMarkingFalseAlarm;
  final bool isLoadingDetail;
  final List<ScanHistoryItem> items;
  final int currentPage;
  final int totalCount;
  final bool hasMore;
  final ScanHistoryItem? selectedEvent;
  final String? errorMessage;

  const ScanHistoryState({
    this.isLoading = false,
    this.isLoadingMore = false,
    this.isMarkingFalseAlarm = false,
    this.isLoadingDetail = false,
    this.items = const [],
    this.currentPage = 1,
    this.totalCount = 0,
    this.hasMore = false,
    this.selectedEvent,
    this.errorMessage,
  });

  ScanHistoryState copyWith({
    bool? isLoading,
    bool? isLoadingMore,
    bool? isMarkingFalseAlarm,
    bool? isLoadingDetail,
    List<ScanHistoryItem>? items,
    int? currentPage,
    int? totalCount,
    bool? hasMore,
    ScanHistoryItem? selectedEvent,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ScanHistoryState(
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isMarkingFalseAlarm: isMarkingFalseAlarm ?? this.isMarkingFalseAlarm,
      isLoadingDetail: isLoadingDetail ?? this.isLoadingDetail,
      items: items ?? this.items,
      currentPage: currentPage ?? this.currentPage,
      totalCount: totalCount ?? this.totalCount,
      hasMore: hasMore ?? this.hasMore,
      selectedEvent: selectedEvent ?? this.selectedEvent,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  int get falseAlarmCount => items.where((e) => e.isFalseAlarm).length;
  int get activeScanCount => items.where((e) => !e.isFalseAlarm).length;
}
