class AppConstants {
  // App Info
  static const String appName = 'Golden Hour';
  static const String appVersion = '1.0.0';

  // Storage Keys
  static const String keyAccessToken = 'access_token';
  static const String keyRefreshToken = 'refresh_token';
  static const String keyUserId = 'user_id';
  static const String keyUserPhone = 'user_phone';
  static const String keyWizardCompleted = 'wizard_completed';
  static const String keyCachedQrUid = 'cached_qr_uid';

  // Network Defaults
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);

  // Default API Base URLs
  static const String defaultApiBaseUrl =
      'https://golden-hour-cvpg.onrender.com/api/v1';
  static const String defaultResponderWebUrl =
      'https://goldenhr.ganeshthota656.workers.dev/p';

  // DPDPA Consent Text
  static const String dpdpaConsentText =
      'I consent to Golden Hour storing and securely processing my emergency medical data and emergency contact information in accordance with India’s Digital Personal Data Protection Act (DPDPA 2023).';
}
