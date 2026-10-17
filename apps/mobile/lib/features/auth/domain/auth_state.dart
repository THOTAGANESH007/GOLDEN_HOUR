enum AuthStatus {
  initial,
  loading,
  otpSent,
  authenticated,
  unauthenticated,
  error,
}

class AuthState {
  final AuthStatus status;
  final String? phone;
  final String? userId;
  final String? errorMessage;
  final int resendCountdown;

  const AuthState({
    this.status = AuthStatus.initial,
    this.phone,
    this.userId,
    this.errorMessage,
    this.resendCountdown = 0,
  });

  bool get isLoading => status == AuthStatus.loading;
  bool get isAuthenticated => status == AuthStatus.authenticated;

  AuthState copyWith({
    AuthStatus? status,
    String? phone,
    String? userId,
    String? errorMessage,
    int? resendCountdown,
  }) {
    return AuthState(
      status: status ?? this.status,
      phone: phone ?? this.phone,
      userId: userId ?? this.userId,
      errorMessage: errorMessage,
      resendCountdown: resendCountdown ?? this.resendCountdown,
    );
  }
}
