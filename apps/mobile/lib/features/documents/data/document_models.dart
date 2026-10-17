import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

enum DocumentType {
  prescription('prescription', 'Prescription', Icons.medication_outlined, AppColors.info),
  labReport('lab_report', 'Lab Report', Icons.science_outlined, AppColors.secondary),
  dischargeSummary('discharge_summary', 'Discharge Summary', Icons.local_hospital_outlined, AppColors.primary),
  insuranceCard('insurance_card', 'Insurance Card', Icons.health_and_safety_outlined, AppColors.success),
  other('other', 'Other Document', Icons.description_outlined, Colors.grey);

  final String key;
  final String label;
  final IconData icon;
  final Color color;

  const DocumentType(this.key, this.label, this.icon, this.color);

  static DocumentType fromKey(String key) {
    return DocumentType.values.firstWhere(
      (e) => e.key == key,
      orElse: () => DocumentType.other,
    );
  }
}

class DocumentItem {
  final String id;
  final String fileName;
  final String fileType;
  final String mimeType;
  final int fileSizeBytes;
  final String? publicUrl;
  final DateTime uploadedAt;

  const DocumentItem({
    required this.id,
    required this.fileName,
    required this.fileType,
    required this.mimeType,
    required this.fileSizeBytes,
    this.publicUrl,
    required this.uploadedAt,
  });

  DocumentType get typeEnum => DocumentType.fromKey(fileType);

  bool get isPdf =>
      mimeType == 'application/pdf' ||
      fileName.toLowerCase().endsWith('.pdf');

  bool get isImage =>
      mimeType.startsWith('image/') ||
      fileName.toLowerCase().endsWith('.jpg') ||
      fileName.toLowerCase().endsWith('.jpeg') ||
      fileName.toLowerCase().endsWith('.png');

  String get formattedSize {
    if (fileSizeBytes < 1024) {
      return '$fileSizeBytes B';
    } else if (fileSizeBytes < 1024 * 1024) {
      final kb = (fileSizeBytes / 1024).toStringAsFixed(1);
      return '$kb KB';
    } else {
      final mb = (fileSizeBytes / (1024 * 1024)).toStringAsFixed(1);
      return '$mb MB';
    }
  }

  factory DocumentItem.fromJson(Map<String, dynamic> json) {
    return DocumentItem(
      id: json['id'] as String? ?? '',
      fileName: json['file_name'] as String? ?? 'Document',
      fileType: json['file_type'] as String? ?? 'other',
      mimeType: json['mime_type'] as String? ?? 'application/octet-stream',
      fileSizeBytes: (json['file_size_bytes'] as num?)?.toInt() ?? 0,
      publicUrl: json['public_url'] as String?,
      uploadedAt: json['uploaded_at'] != null
          ? DateTime.tryParse(json['uploaded_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'file_name': fileName,
      'file_type': fileType,
      'mime_type': mimeType,
      'file_size_bytes': fileSizeBytes,
      if (publicUrl != null) 'public_url': publicUrl,
      'uploaded_at': uploadedAt.toIso8601String(),
    };
  }
}
