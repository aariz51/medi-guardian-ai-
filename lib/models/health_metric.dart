import 'package:uuid/uuid.dart';

enum MetricType {
  bloodPressure,
  heartRate,
  temperature,
  weight,
  bloodSugar,
  sleep,
  mood,
  energy,
}

class HealthMetric {
  final String id;
  final MetricType type;
  final double value;
  final double? secondaryValue; // For blood pressure (systolic/diastolic)
  final DateTime timestamp;
  final String notes;
  final Map<String, dynamic> metadata;

  HealthMetric({
    String? id,
    required this.type,
    required this.value,
    this.secondaryValue,
    required this.timestamp,
    this.notes = '',
    this.metadata = const {},
  }) : id = id ?? const Uuid().v4();

  factory HealthMetric.fromJson(Map<String, dynamic> json) {
    return HealthMetric(
      id: json['id'] as String,
      type: MetricType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => MetricType.mood,
      ),
      value: (json['value'] as num).toDouble(),
      secondaryValue: json['secondaryValue'] != null
          ? (json['secondaryValue'] as num).toDouble()
          : null,
      timestamp: DateTime.parse(json['timestamp'] as String),
      notes: json['notes'] as String? ?? '',
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.toString(),
      'value': value,
      'secondaryValue': secondaryValue,
      'timestamp': timestamp.toIso8601String(),
      'notes': notes,
      'metadata': metadata,
    };
  }

  String getDisplayName() {
    switch (type) {
      case MetricType.bloodPressure:
        return 'Blood Pressure';
      case MetricType.heartRate:
        return 'Heart Rate';
      case MetricType.temperature:
        return 'Temperature';
      case MetricType.weight:
        return 'Weight';
      case MetricType.bloodSugar:
        return 'Blood Sugar';
      case MetricType.sleep:
        return 'Sleep';
      case MetricType.mood:
        return 'Mood';
      case MetricType.energy:
        return 'Energy';
    }
  }

  String getUnit() {
    switch (type) {
      case MetricType.bloodPressure:
        return 'mmHg';
      case MetricType.heartRate:
        return 'bpm';
      case MetricType.temperature:
        return '°F';
      case MetricType.weight:
        return 'lbs';
      case MetricType.bloodSugar:
        return 'mg/dL';
      case MetricType.sleep:
        return 'hours';
      case MetricType.mood:
        return '/10';
      case MetricType.energy:
        return '/10';
    }
  }

  String getDisplayValue() {
    if (secondaryValue != null) {
      return '$value/$secondaryValue';
    }
    return value.toStringAsFixed(1);
  }
}
