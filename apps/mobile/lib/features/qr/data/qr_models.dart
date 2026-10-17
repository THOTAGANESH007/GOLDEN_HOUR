class QRData {
  final String qrUid;
  final String qrUrl;
  final String? message;

  const QRData({
    required this.qrUid,
    required this.qrUrl,
    this.message,
  });

  factory QRData.fromJson(Map<String, dynamic> json) {
    return QRData(
      qrUid: json['qr_uid'] as String? ?? '',
      qrUrl: json['qr_url'] as String? ?? '',
      message: json['message'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'qr_uid': qrUid,
      'qr_url': qrUrl,
      if (message != null) 'message': message,
    };
  }
}
