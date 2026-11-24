class ScanEventItem {
  final String id;
  final String qrUid;
  final String? responderName;
  final String? responderHospital;
  final double? latitude;
  final double? longitude;
  final String? locationArea;
  final String? googleMapsUrl;
  final String? deviceType;
  final bool smsSent;
  final bool whatsappSent;
  final bool fcmSent;
  final bool emailSent;
  final bool notificationSuppressed;
  final bool isFalseAlarm;
  final DateTime scannedAt;

  const ScanEventItem({
    required this.id,
    required this.qrUid,
    this.responderName,
    this.responderHospital,
    this.latitude,
    this.longitude,
    this.locationArea,
    this.googleMapsUrl,
    this.deviceType,
    this.smsSent = false,
    this.whatsappSent = false,
    this.fcmSent = false,
    this.emailSent = false,
    this.notificationSuppressed = false,
    this.isFalseAlarm = false,
    required this.scannedAt,
  });

  factory ScanEventItem.fromJson(Map<String, dynamic> json) {
    return ScanEventItem(
      id: json['id'] as String? ?? '',
      qrUid: json['qr_uid'] as String? ?? '',
      responderName: json['responder_name'] as String?,
      responderHospital: json['responder_hospital'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      locationArea: json['location_area'] as String?,
      googleMapsUrl: json['google_maps_url'] as String?,
      deviceType: json['device_type'] as String?,
      smsSent: json['sms_sent'] as bool? ?? false,
      whatsappSent: json['whatsapp_sent'] as bool? ?? false,
      fcmSent: json['fcm_sent'] as bool? ?? false,
      emailSent: json['email_sent'] as bool? ?? false,
      notificationSuppressed:
          json['notification_suppressed'] as bool? ?? false,
      isFalseAlarm: json['is_false_alarm'] as bool? ?? false,
      scannedAt: json['scanned_at'] != null
          ? DateTime.tryParse(json['scanned_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'qr_uid': qrUid,
      'responder_name': responderName,
      'responder_hospital': responderHospital,
      'latitude': latitude,
      'longitude': longitude,
      'location_area': locationArea,
      'google_maps_url': googleMapsUrl,
      'device_type': deviceType,
      'sms_sent': smsSent,
      'whatsapp_sent': whatsappSent,
      'fcm_sent': fcmSent,
      'email_sent': emailSent,
      'notification_suppressed': notificationSuppressed,
      'is_false_alarm': isFalseAlarm,
      'scanned_at': scannedAt.toIso8601String(),
    };
  }

  ScanEventItem copyWith({
    bool? isFalseAlarm,
  }) {
    return ScanEventItem(
      id: id,
      qrUid: qrUid,
      responderName: responderName,
      responderHospital: responderHospital,
      latitude: latitude,
      longitude: longitude,
      locationArea: locationArea,
      googleMapsUrl: googleMapsUrl,
      deviceType: deviceType,
      smsSent: smsSent,
      whatsappSent: whatsappSent,
      fcmSent: fcmSent,
      emailSent: emailSent,
      notificationSuppressed: notificationSuppressed,
      isFalseAlarm: isFalseAlarm ?? this.isFalseAlarm,
      scannedAt: scannedAt,
    );
  }
}

class ScanHistoryResponse {
  final List<ScanEventItem> items;
  final int total;
  final int page;
  final int pageSize;

  const ScanHistoryResponse({
    required this.items,
    required this.total,
    required this.page,
    required this.pageSize,
  });

  factory ScanHistoryResponse.fromJson(Map<String, dynamic> json) {
    final list = json['items'] as List<dynamic>? ?? [];
    return ScanHistoryResponse(
      items: list
          .map((e) => ScanEventItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: (json['total'] as num?)?.toInt() ?? 0,
      page: (json['page'] as num?)?.toInt() ?? 1,
      pageSize: (json['page_size'] as num?)?.toInt() ?? 20,
    );
  }
}

class TestNotificationResponse {
  final bool smsSent;
  final bool whatsappSent;
  final String message;

  const TestNotificationResponse({
    required this.smsSent,
    required this.whatsappSent,
    required this.message,
  });

  factory TestNotificationResponse.fromJson(Map<String, dynamic> json) {
    return TestNotificationResponse(
      smsSent: json['sms_sent'] as bool? ?? false,
      whatsappSent: json['whatsapp_sent'] as bool? ?? false,
      message: json['message'] as String? ?? 'Test notification sent',
    );
  }
}

class NotificationCategory {
  static const String emergencySos = 'emergency_sos';
  static const String safetyTip = 'safety_tip';
  static const String appUpdate = 'app_update';
  static const String radarAlert = 'radar_alert';
  static const String patientQrScan = 'patient_qr_scan';
}

class NotificationPayload {
  final String title;
  final String body;
  final String category;
  final Map<String, dynamic> data;
  final bool isDataOnly;
  final String? scanId;
  final String? mapsUrl;
  final String? locationArea;
  final DateTime timestamp;

  const NotificationPayload({
    required this.title,
    required this.body,
    required this.category,
    this.data = const {},
    this.isDataOnly = false,
    this.scanId,
    this.mapsUrl,
    this.locationArea,
    required this.timestamp,
  });

  factory NotificationPayload.fromDataMap({
    String? notificationTitle,
    String? notificationBody,
    required Map<String, dynamic> data,
  }) {
    final title = notificationTitle ??
        data['title'] as String? ??
        '🚨 Emergency Alert';
    final body = notificationBody ??
        data['body'] as String? ??
        'Incident update received';
    final category = data['category'] as String? ??
        data['type'] as String? ??
        NotificationCategory.emergencySos;
    final isDataOnly = notificationTitle == null && notificationBody == null;

    return NotificationPayload(
      title: title,
      body: body,
      category: category,
      data: data,
      isDataOnly: isDataOnly,
      scanId: data['scan_id'] as String? ?? data['id'] as String?,
      mapsUrl: data['maps_url'] as String? ?? data['google_maps_url'] as String?,
      locationArea: data['location_area'] as String?,
      timestamp: DateTime.now(),
    );
  }

  /// Evaluates target in-app navigation route according to notification category
  String getTargetRoute() {
    switch (category) {
      case NotificationCategory.safetyTip:
        return '/guides';
      case NotificationCategory.radarAlert:
        return '/location/map';
      case NotificationCategory.appUpdate:
        return '/notifications';
      case NotificationCategory.emergencySos:
      case NotificationCategory.patientQrScan:
      default:
        if (scanId != null && scanId!.isNotEmpty) {
          return '/scan-history/detail?id=$scanId';
        }
        return '/scan-history';
    }
  }
}

class PushNotificationSendRequest {
  final String title;
  final String body;
  final String category;
  final bool isDataOnly;
  final List<String>? targetUserIds;
  final List<String>? fcmTokens;
  final Map<String, String>? data;

  const PushNotificationSendRequest({
    required this.title,
    required this.body,
    this.category = NotificationCategory.emergencySos,
    this.isDataOnly = false,
    this.targetUserIds,
    this.fcmTokens,
    this.data,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'body': body,
        'category': category,
        'is_data_only': isDataOnly,
        if (targetUserIds != null) 'target_user_ids': targetUserIds,
        if (fcmTokens != null) 'fcm_tokens': fcmTokens,
        if (data != null) 'data': data,
      };
}

class PushNotificationSendResponse {
  final String status;
  final String message;
  final int successCount;
  final int failureCount;
  final String category;
  final bool isDataOnly;
  final String analyticsEvent;
  final String dispatchedAt;

  const PushNotificationSendResponse({
    required this.status,
    required this.message,
    required this.successCount,
    required this.failureCount,
    required this.category,
    required this.isDataOnly,
    required this.analyticsEvent,
    required this.dispatchedAt,
  });

  factory PushNotificationSendResponse.fromJson(Map<String, dynamic> json) =>
      PushNotificationSendResponse(
        status: json['status'] as String? ?? 'success',
        message: json['message'] as String? ?? '',
        successCount: (json['success_count'] as num?)?.toInt() ?? 0,
        failureCount: (json['failure_count'] as num?)?.toInt() ?? 0,
        category: json['category'] as String? ?? NotificationCategory.emergencySos,
        isDataOnly: json['is_data_only'] as bool? ?? false,
        analyticsEvent:
            json['analytics_event'] as String? ?? 'notification_sent',
        dispatchedAt: json['dispatched_at'] as String? ?? '',
      );
}
