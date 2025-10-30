import 'dart:math';
import 'dart:convert';

class Medication {
  final String id;
  final String name;
  final String dosage;
  final String frequency;
  final String imageUrl;
  final DateTime startDate;
  final DateTime? endDate;
  final List<TimeOfDay> reminderTimes;
  final String notes;
  final bool isActive;
  final Map<String, dynamic> metadata;

  Medication({
    String? id,
    required this.name,
    required this.dosage,
    required this.frequency,
    this.imageUrl = '',
    required this.startDate,
    this.endDate,
    required this.reminderTimes,
    this.notes = '',
    this.isActive = true,
    this.metadata = const {},
  }) : id = id ?? _generateId();

  static String _generateId() {
    final random = Random();
    final bytes = List<int>.generate(16, (i) => random.nextInt(256));
    return base64UrlEncode(bytes).substring(0, 22);
  }

  factory Medication.fromJson(Map<String, dynamic> json) {
    return Medication(
      id: json['id'] as String,
      name: json['name'] as String,
      dosage: json['dosage'] as String,
      frequency: json['frequency'] as String,
      imageUrl: json['imageUrl'] as String? ?? '',
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] != null 
          ? DateTime.parse(json['endDate'] as String) 
          : null,
      reminderTimes: (json['reminderTimes'] as List)
          .map((t) => TimeOfDay(
                hour: t['hour'] as int,
                minute: t['minute'] as int,
              ))
          .toList(),
      notes: json['notes'] as String? ?? '',
      isActive: json['isActive'] as bool? ?? true,
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'dosage': dosage,
      'frequency': frequency,
      'imageUrl': imageUrl,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'reminderTimes': reminderTimes
          .map((t) => {'hour': t.hour, 'minute': t.minute})
          .toList(),
      'notes': notes,
      'isActive': isActive,
      'metadata': metadata,
    };
  }

  Medication copyWith({
    String? id,
    String? name,
    String? dosage,
    String? frequency,
    String? imageUrl,
    DateTime? startDate,
    DateTime? endDate,
    List<TimeOfDay>? reminderTimes,
    String? notes,
    bool? isActive,
    Map<String, dynamic>? metadata,
  }) {
    return Medication(
      id: id ?? this.id,
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      frequency: frequency ?? this.frequency,
      imageUrl: imageUrl ?? this.imageUrl,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      reminderTimes: reminderTimes ?? this.reminderTimes,
      notes: notes ?? this.notes,
      isActive: isActive ?? this.isActive,
      metadata: metadata ?? this.metadata,
    );
  }
}

class TimeOfDay {
  final int hour;
  final int minute;

  TimeOfDay({required this.hour, required this.minute});
}
