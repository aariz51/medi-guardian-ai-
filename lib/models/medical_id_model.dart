class MedicalIdModel {
  final String id;
  final String userId;
  final String? qrCode;
  final List<String> conditions;
  final List<String> allergies;
  final List<String> medications;
  final String? bloodType;
  final bool isOrganDonor;
  final String? emergencyContact;
  final DateTime createdAt;
  final DateTime updatedAt;

  MedicalIdModel({
    required this.id,
    required this.userId,
    this.qrCode,
    this.conditions = const [],
    this.allergies = const [],
    this.medications = const [],
    this.bloodType,
    this.isOrganDonor = false,
    this.emergencyContact,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MedicalIdModel.fromJson(Map<String, dynamic> json) {
    return MedicalIdModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      qrCode: json['qr_code'] as String?,
      conditions: (json['conditions'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      allergies: (json['allergies'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      medications: (json['medications'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      bloodType: json['blood_type'] as String?,
      isOrganDonor: json['organ_donor'] as bool? ?? false,
      emergencyContact: json['emergency_contact'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'qr_code': qrCode,
      'conditions': conditions,
      'allergies': allergies,
      'medications': medications,
      'blood_type': bloodType,
      'organ_donor': isOrganDonor,
      'emergency_contact': emergencyContact,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
} 