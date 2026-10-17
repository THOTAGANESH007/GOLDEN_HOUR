import 'package:intl/intl.dart';

class ScanHistoryItem {
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

  const ScanHistoryItem({
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

  factory ScanHistoryItem.fromJson(Map<String, dynamic> json) {
    return ScanHistoryItem(
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

  ScanHistoryItem copyWith({
    String? id,
    String? qrUid,
    String? responderName,
    String? responderHospital,
    double? latitude,
    double? longitude,
    String? locationArea,
    String? googleMapsUrl,
    String? deviceType,
    bool? smsSent,
    bool? whatsappSent,
    bool? fcmSent,
    bool? emailSent,
    bool? notificationSuppressed,
    bool? isFalseAlarm,
    DateTime? scannedAt,
  }) {
    return ScanHistoryItem(
      id: id ?? this.id,
      qrUid: qrUid ?? this.qrUid,
      responderName: responderName ?? this.responderName,
      responderHospital: responderHospital ?? this.responderHospital,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      locationArea: locationArea ?? this.locationArea,
      googleMapsUrl: googleMapsUrl ?? this.googleMapsUrl,
      deviceType: deviceType ?? this.deviceType,
      smsSent: smsSent ?? this.smsSent,
      whatsappSent: whatsappSent ?? this.whatsappSent,
      fcmSent: fcmSent ?? this.fcmSent,
      emailSent: emailSent ?? this.emailSent,
      notificationSuppressed:
          notificationSuppressed ?? this.notificationSuppressed,
      isFalseAlarm: isFalseAlarm ?? this.isFalseAlarm,
      scannedAt: scannedAt ?? this.scannedAt,
    );
  }

  String get formattedDate =>
      DateFormat('dd MMM yyyy, hh:mm a').format(scannedAt.toLocal());

  String get relativeTime {
    final now = DateTime.now();
    final difference = now.difference(scannedAt);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('dd MMM').format(scannedAt.toLocal());
    }
  }

  /// Whether 60 seconds have elapsed since the scan was created
  bool get isFalseAlarmAvailable {
    final elapsedSeconds = DateTime.now().difference(scannedAt).inSeconds;
    return elapsedSeconds >= 60;
  }

  /// Seconds remaining until the false alarm action is unlocked
  int get secondsUntilFalseAlarmAvailable {
    final elapsedSeconds = DateTime.now().difference(scannedAt).inSeconds;
    final remaining = 60 - elapsedSeconds;
    return remaining > 0 ? remaining : 0;
  }

  String get displayLocation {
    if (locationArea != null && locationArea!.trim().isNotEmpty) {
      return locationArea!.trim();
    }
    if (latitude != null && longitude != null) {
      return '${latitude!.toStringAsFixed(4)}, ${longitude!.toStringAsFixed(4)}';
    }
    return 'Location unavailable';
  }

  String get displayResponder {
    if (responderName != null && responderName!.trim().isNotEmpty) {
      if (responderHospital != null && responderHospital!.trim().isNotEmpty) {
        return '$responderName • $responderHospital';
      }
      return responderName!;
    }
    if (responderHospital != null && responderHospital!.trim().isNotEmpty) {
      return responderHospital!;
    }
    return 'Anonymous Responder';
  }

  String get resolvedMapsUrl {
    if (googleMapsUrl != null && googleMapsUrl!.isNotEmpty) {
      return googleMapsUrl!;
    }
    if (latitude != null && longitude != null) {
      return 'https://maps.google.com/?q=$latitude,$longitude';
    }
    return '';
  }
}

class ScanHistoryListResponse {
  final List<ScanHistoryItem> items;
  final int total;
  final int page;
  final int pageSize;

  const ScanHistoryListResponse({
    required this.items,
    required this.total,
    required this.page,
    required this.pageSize,
  });

  bool get hasMore => (page * pageSize) < total;

  factory ScanHistoryListResponse.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List<dynamic>? ?? [];
    return ScanHistoryListResponse(
      items: rawItems
          .map((e) => ScanHistoryItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: json['total'] as int? ?? 0,
      page: json['page'] as int? ?? 1,
      pageSize: json['page_size'] as int? ?? 20,
    );
  }
}
