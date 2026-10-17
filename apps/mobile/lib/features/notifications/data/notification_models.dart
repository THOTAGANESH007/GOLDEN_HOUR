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
