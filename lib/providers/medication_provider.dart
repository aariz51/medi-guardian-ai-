import 'package:flutter/material.dart';
import '../models/medication.dart';

class MedicationProvider extends ChangeNotifier {
  List<Medication> _medications = [];

  List<Medication> get medications => _medications;

  void addMedication(Medication medication) {
    _medications.add(medication);
    notifyListeners();
  }

  void removeMedication(String id) {
    _medications.removeWhere((med) => med.id == id);
    notifyListeners();
  }

  void updateMedication(Medication updatedMedication) {
    final index = _medications.indexWhere((med) => med.id == updatedMedication.id);
    if (index != -1) {
      _medications[index] = updatedMedication;
      notifyListeners();
    }
  }
}
