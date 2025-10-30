import 'package:uuid/uuid.dart';

enum SideEffectSeverity {
  mild,
  moderate,
  severe,
}

class SideEffect {
  final String id;
  final String medicationId;
  final String symptom;
  final int severity; // 1-5 scale
  final DateTime date;
  final String emoji;
  final String notes;
  final Map<String, dynamic> metadata;

  SideEffect({
    String? id,
    required this.medicationId,
    required this.symptom,
    required this.severity,
    required this.date,
    required this.emoji,
    this.notes = '',
    this.metadata = const {},
  }) : id = id ?? const Uuid().v4();

  factory SideEffect.fromJson(Map<String, dynamic> json) {
    return SideEffect(
      id: json['id'] as String,
      medicationId: json['medicationId'] as String,
      symptom: json['symptom'] as String,
      severity: json['severity'] as int,
      date: DateTime.parse(json['date'] as String),
      emoji: json['emoji'] as String,
      notes: json['notes'] as String? ?? '',
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'medicationId': medicationId,
      'symptom': symptom,
      'severity': severity,
      'date': date.toIso8601String(),
      'emoji': emoji,
      'notes': notes,
      'metadata': metadata,
    };
  }
}
