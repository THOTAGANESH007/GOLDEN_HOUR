class QRState {
  final bool isLoading;
  final bool isRegenerating;
  final String? qrUid;
  final String? qrUrl;
  final String? errorMessage;
  final String? regeneratedMessage;
  final bool isOffline;

  const QRState({
    this.isLoading = false,
    this.isRegenerating = false,
    this.qrUid,
    this.qrUrl,
    this.errorMessage,
    this.regeneratedMessage,
    this.isOffline = false,
  });

  QRState copyWith({
    bool? isLoading,
    bool? isRegenerating,
    String? qrUid,
    String? qrUrl,
    String? errorMessage,
    bool clearError = false,
    String? regeneratedMessage,
    bool clearRegeneratedMessage = false,
    bool? isOffline,
  }) {
    return QRState(
      isLoading: isLoading ?? this.isLoading,
      isRegenerating: isRegenerating ?? this.isRegenerating,
      qrUid: qrUid ?? this.qrUid,
      qrUrl: qrUrl ?? this.qrUrl,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      regeneratedMessage: clearRegeneratedMessage
          ? null
          : (regeneratedMessage ?? this.regeneratedMessage),
      isOffline: isOffline ?? this.isOffline,
    );
  }
}
