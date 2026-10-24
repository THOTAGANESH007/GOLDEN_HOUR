import 'dart:convert';

class MedicationItem {
  final String name;
  final String dosage;
  final String frequency;

  const MedicationItem({
    required this.name,
    required this.dosage,
    required this.frequency,
  });

  factory MedicationItem.fromJson(Map<String, dynamic> json) {
    return MedicationItem(
      name: json['name'] as String? ?? '',
      dosage: json['dosage'] as String? ?? '',
      frequency: json['frequency'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'dosage': dosage,
      'frequency': frequency,
    };
  }

  MedicationItem copyWith({
    String? name,
    String? dosage,
    String? frequency,
  }) {
    return MedicationItem(
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      frequency: frequency ?? this.frequency,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MedicationItem &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          dosage == other.dosage &&
          frequency == other.frequency;

  @override
  int get hashCode => name.hashCode ^ dosage.hashCode ^ frequency.hashCode;
}

class EmergencyContact {
  final String? id;
  final String? userId;
  final String name;
  final String relation;
  final String phone;
  final bool whatsappEnabled;
  final bool notifyOnScan;
  final int sortOrder;

  const EmergencyContact({
    this.id,
    this.userId,
    required this.name,
    required this.relation,
    required this.phone,
    this.whatsappEnabled = true,
    this.notifyOnScan = true,
    this.sortOrder = 0,
  });

  factory EmergencyContact.fromJson(Map<String, dynamic> json) {
    return EmergencyContact(
      id: json['id'] as String?,
      userId: json['user_id'] as String?,
      name: json['name'] as String? ?? '',
      relation: json['relation'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      whatsappEnabled: json['whatsapp_enabled'] as bool? ?? true,
      notifyOnScan: json['notify_on_scan'] as bool? ?? true,
      sortOrder: json['sort_order'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      'name': name,
      'relation': relation,
      'phone': phone,
      'whatsapp_enabled': whatsappEnabled,
      'notify_on_scan': notifyOnScan,
      'sort_order': sortOrder,
    };
  }

  EmergencyContact copyWith({
    String? id,
    String? userId,
    String? name,
    String? relation,
    String? phone,
    bool? whatsappEnabled,
    bool? notifyOnScan,
    int? sortOrder,
  }) {
    return EmergencyContact(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      relation: relation ?? this.relation,
      phone: phone ?? this.phone,
      whatsappEnabled: whatsappEnabled ?? this.whatsappEnabled,
      notifyOnScan: notifyOnScan ?? this.notifyOnScan,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}

class ProfileCompletion {
  final int score;
  final List<String> missing;

  const ProfileCompletion({
    required this.score,
    required this.missing,
  });

  factory ProfileCompletion.fromJson(Map<String, dynamic> json) {
    return ProfileCompletion(
      score: (json['score'] as num?)?.toInt() ?? 0,
      missing: (json['missing'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
    );
  }
}

class PatientProfile {
  final String id;
  final String userId;
  final String? qrUid;
  final bool qrIsActive;
  final String? fullName;
  final String? dateOfBirth; // YYYY-MM-DD
  final String? gender;
  final String? photoUrl;
  final String? bloodGroup;
  final List<String> allergies;
  final List<String> chronicConditions;
  final List<MedicationItem> medications;
  final List<String> pastSurgeries;
  final List<String> implants;
  final bool isOrganDonor;
  final String? doctorName;
  final String? doctorPhone;
  final bool showName;
  final bool showDob;
  final bool showPhoto;
  final bool wizardCompleted;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  int? get age {
    if (dateOfBirth == null || dateOfBirth!.isEmpty) return null;
    try {
      final dob = DateTime.parse(dateOfBirth!);
      final today = DateTime.now();
      int calculated = today.year - dob.year;
      if (today.month < dob.month ||
          (today.month == dob.month && today.day < dob.day)) {
        calculated--;
      }
      return calculated >= 0 ? calculated : null;
    } catch (_) {
      return null;
    }
  }

  const PatientProfile({
    required this.id,
    required this.userId,
    this.qrUid,
    this.qrIsActive = true,
    this.fullName,
    this.dateOfBirth,
    this.gender,
    this.photoUrl,
    this.bloodGroup,
    this.allergies = const [],
    this.chronicConditions = const [],
    this.medications = const [],
    this.pastSurgeries = const [],
    this.implants = const [],
    this.isOrganDonor = false,
    this.doctorName,
    this.doctorPhone,
    this.showName = true,
    this.showDob = true,
    this.showPhoto = false,
    this.wizardCompleted = false,
    this.createdAt,
    this.updatedAt,
  });

  factory PatientProfile.fromJson(Map<String, dynamic> json) {
    List<MedicationItem> parsedMedications = [];
    if (json['medications'] != null) {
      final list = json['medications'] as List<dynamic>;
      parsedMedications = list.map((item) {
        if (item is Map<String, dynamic>) {
          return MedicationItem.fromJson(item);
        } else if (item is String) {
          try {
            final decoded = jsonDecode(item) as Map<String, dynamic>;
            return MedicationItem.fromJson(decoded);
          } catch (_) {
            return MedicationItem(name: item, dosage: '', frequency: '');
          }
        }
        return const MedicationItem(name: '', dosage: '', frequency: '');
      }).toList();
    }

    return PatientProfile(
      id: json['id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      qrUid: json['qr_uid'] as String?,
      qrIsActive: json['qr_is_active'] as bool? ?? true,
      fullName: json['full_name'] as String?,
      dateOfBirth: json['date_of_birth'] as String?,
      gender: json['gender'] as String?,
      photoUrl: json['photo_url'] as String?,
      bloodGroup: json['blood_group'] as String?,
      allergies: (json['allergies'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      chronicConditions: (json['chronic_conditions'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      medications: parsedMedications,
      pastSurgeries: (json['past_surgeries'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      implants: (json['implants'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      isOrganDonor: json['is_organ_donor'] as bool? ?? false,
      doctorName: json['doctor_name'] as String?,
      doctorPhone: json['doctor_phone'] as String?,
      showName: json['show_name'] as bool? ?? true,
      showDob: json['show_dob'] as bool? ?? true,
      showPhoto: json['show_photo'] as bool? ?? false,
      wizardCompleted: json['wizard_completed'] as bool? ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      if (fullName != null) 'full_name': fullName,
      if (dateOfBirth != null) 'date_of_birth': dateOfBirth,
      if (gender != null) 'gender': gender,
      if (bloodGroup != null) 'blood_group': bloodGroup,
      'allergies': allergies,
      'chronic_conditions': chronicConditions,
      'medications': medications.map((m) => m.toJson()).toList(),
      'past_surgeries': pastSurgeries,
      'implants': implants,
      'is_organ_donor': isOrganDonor,
      if (doctorName != null) 'doctor_name': doctorName,
      if (doctorPhone != null) 'doctor_phone': doctorPhone,
      'wizard_completed': wizardCompleted,
    };
  }

  PatientProfile copyWith({
    String? id,
    String? userId,
    String? qrUid,
    bool? qrIsActive,
    String? fullName,
    String? dateOfBirth,
    String? gender,
    String? photoUrl,
    String? bloodGroup,
    List<String>? allergies,
    List<String>? chronicConditions,
    List<MedicationItem>? medications,
    List<String>? pastSurgeries,
    List<String>? implants,
    bool? isOrganDonor,
    String? doctorName,
    String? doctorPhone,
    bool? showName,
    bool? showDob,
    bool? showPhoto,
    bool? wizardCompleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PatientProfile(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      qrUid: qrUid ?? this.qrUid,
      qrIsActive: qrIsActive ?? this.qrIsActive,
      fullName: fullName ?? this.fullName,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      photoUrl: photoUrl ?? this.photoUrl,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      allergies: allergies ?? this.allergies,
      chronicConditions: chronicConditions ?? this.chronicConditions,
      medications: medications ?? this.medications,
      pastSurgeries: pastSurgeries ?? this.pastSurgeries,
      implants: implants ?? this.implants,
      isOrganDonor: isOrganDonor ?? this.isOrganDonor,
      doctorName: doctorName ?? this.doctorName,
      doctorPhone: doctorPhone ?? this.doctorPhone,
      showName: showName ?? this.showName,
      showDob: showDob ?? this.showDob,
      showPhoto: showPhoto ?? this.showPhoto,
      wizardCompleted: wizardCompleted ?? this.wizardCompleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
