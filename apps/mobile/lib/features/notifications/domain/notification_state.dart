import '../data/notification_models.dart';

class NotificationState {
  final bool isLoading;
  final bool isSendingTest;
  final String? errorMessage;
  final String? testSuccessMessage;
  final List<ScanEventItem> events;
  final int totalEvents;
  final int currentPage;

  const NotificationState({
    this.isLoading = false,
    this.isSendingTest = false,
    this.errorMessage,
    this.testSuccessMessage,
    this.events = const [],
    this.totalEvents = 0,
    this.currentPage = 1,
  });

  NotificationState copyWith({
    bool? isLoading,
    bool? isSendingTest,
    String? errorMessage,
    bool clearError = false,
    String? testSuccessMessage,
    bool clearTestMessage = false,
    List<ScanEventItem>? events,
    int? totalEvents,
    int? currentPage,
  }) {
    return NotificationState(
      isLoading: isLoading ?? this.isLoading,
      isSendingTest: isSendingTest ?? this.isSendingTest,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      testSuccessMessage: clearTestMessage
          ? null
          : (testSuccessMessage ?? this.testSuccessMessage),
      events: events ?? this.events,
      totalEvents: totalEvents ?? this.totalEvents,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}
