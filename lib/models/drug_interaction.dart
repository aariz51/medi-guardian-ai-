import 'package:flutter/material.dart';

enum InteractionSeverity {
  mild,
  moderate,
  severe,
  contraindicated,
}

class DrugInteraction {
  final String drug1;
  final String drug2;
  final String description;
  final InteractionSeverity severity;
  final String mechanism;
  final String recommendations;
  final List<String> signs;

  DrugInteraction({
    required this.drug1,
    required this.drug2,
    required this.description,
    required this.severity,
    required this.mechanism,
    required this.recommendations,
    required this.signs,
  });

  factory DrugInteraction.fromJson(Map<String, dynamic> json) {
    return DrugInteraction(
      drug1: json['drug1'] as String,
      drug2: json['drug2'] as String,
      description: json['description'] as String,
      severity: InteractionSeverity.values.firstWhere(
        (e) => e.toString() == json['severity'],
        orElse: () => InteractionSeverity.mild,
      ),
      mechanism: json['mechanism'] as String,
      recommendations: json['recommendations'] as String,
      signs: List<String>.from(json['signs'] as List),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'drug1': drug1,
      'drug2': drug2,
      'description': description,
      'severity': severity.toString(),
      'mechanism': mechanism,
      'recommendations': recommendations,
      'signs': signs,
    };
  }

  Color getSeverityColor() {
    switch (severity) {
      case InteractionSeverity.mild:
        return const Color(0xFFFFF3CD);
      case InteractionSeverity.moderate:
        return const Color(0xFFFFE0B2);
      case InteractionSeverity.severe:
        return const Color(0xFFFFCDD2);
      case InteractionSeverity.contraindicated:
        return const Color(0xFFE57373);
      default:
        return const Color(0xFFF5F5F5);
    }
  }

  String getSeverityText() {
    switch (severity) {
      case InteractionSeverity.mild:
        return 'Mild Interaction';
      case InteractionSeverity.moderate:
        return 'Moderate Interaction';
      case InteractionSeverity.severe:
        return 'Severe Interaction';
      case InteractionSeverity.contraindicated:
        return 'Contraindicated';
      default:
        return 'Unknown';
    }
  }
}
