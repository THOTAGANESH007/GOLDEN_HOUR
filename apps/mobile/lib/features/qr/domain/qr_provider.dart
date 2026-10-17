import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/qr_repository.dart';
import 'qr_state.dart';

final qrNotifierProvider =
    StateNotifierProvider<QRNotifier, QRState>((ref) {
  final repo = ref.watch(qrRepositoryProvider);
  return QRNotifier(repo);
});

class QRNotifier extends StateNotifier<QRState> {
  final QRRepository _repo;

  QRNotifier(this._repo) : super(const QRState()) {
    loadQr();
  }

  Future<void> loadQr() async {
    // 1. Immediately hydrate with cached offline UID if available
    final cachedUid = await _repo.getCachedQrUid();
    if (cachedUid != null && cachedUid.isNotEmpty) {
      state = state.copyWith(
        qrUid: cachedUid,
        qrUrl: _repo.buildResponderUrl(cachedUid),
        isOffline: true,
      );
    } else {
      state = state.copyWith(isLoading: true, clearError: true);
    }

    // 2. Fetch / verify with backend
    try {
      final data = await _repo.generateQr();
      state = state.copyWith(
        isLoading: false,
        qrUid: data.qrUid,
        qrUrl: data.qrUrl.isNotEmpty
            ? data.qrUrl
            : _repo.buildResponderUrl(data.qrUid),
        isOffline: false,
        clearError: true,
      );
    } catch (e) {
      // If we already have a cached UID, keep it active in offline mode
      if (state.qrUid != null && state.qrUid!.isNotEmpty) {
        state = state.copyWith(isLoading: false, isOffline: true);
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: e.toString().replaceAll('Exception: ', ''),
        );
      }
    }
  }

  Future<bool> regenerateQr() async {
    state = state.copyWith(
      isRegenerating: true,
      clearError: true,
      clearRegeneratedMessage: true,
    );
    try {
      final data = await _repo.regenerateQr();
      state = state.copyWith(
        isRegenerating: false,
        qrUid: data.qrUid,
        qrUrl: data.qrUrl.isNotEmpty
            ? data.qrUrl
            : _repo.buildResponderUrl(data.qrUid),
        regeneratedMessage: data.message ?? 'New QR code created successfully.',
        isOffline: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isRegenerating: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }
}
