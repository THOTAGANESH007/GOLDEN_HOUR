import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/notification_models.dart';
import '../data/notification_repository.dart';
import 'notification_state.dart';

final notificationNotifierProvider =
    StateNotifierProvider<NotificationNotifier, NotificationState>((ref) {
  final repo = ref.watch(notificationRepositoryProvider);
  return NotificationNotifier(repo);
});

class NotificationNotifier extends StateNotifier<NotificationState> {
  final NotificationRepository _repo;

  NotificationNotifier(this._repo) : super(const NotificationState()) {
    loadHistory();
  }

  Future<void> loadHistory({int page = 1}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final response = await _repo.getHistory(page: page);
      state = state.copyWith(
        isLoading: false,
        events: response.items,
        totalEvents: response.total,
        currentPage: response.page,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  Future<bool> markFalseAlarm(String scanId) async {
    try {
      await _repo.markFalseAlarm(scanId);
      final updatedList = state.events.map((e) {
        if (e.id == scanId) {
          return e.copyWith(isFalseAlarm: true);
        }
        return e;
      }).toList();
      state = state.copyWith(events: updatedList);
      return true;
    } catch (e) {
      state = state.copyWith(
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  Future<TestNotificationResponse?> sendTestNotification() async {
    state = state.copyWith(
      isSendingTest: true,
      clearError: true,
      clearTestMessage: true,
    );
    try {
      final result = await _repo.sendTestNotification();
      state = state.copyWith(
        isSendingTest: false,
        testSuccessMessage:
            'Test notification sent! SMS: ${result.smsSent ? "✅ Delivered" : "⚠️ Failed"}, WhatsApp: ${result.whatsappSent ? "✅ Delivered" : "⚠️ Failed"}',
      );
      return result;
    } catch (e) {
      state = state.copyWith(
        isSendingTest: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
      return null;
    }
  }

  Future<void> registerFcmToken(String fcmToken) async {
    try {
      await _repo.registerFcmToken(fcmToken);
    } catch (e) {
      // Background registration silent error
    }
  }
}
