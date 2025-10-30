import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/medication.dart';

class MedicationService {
  final SupabaseClient _supabase = Supabase.instance.client;
  
  // Get all medications for current user
  Future<List<Medication>> getMedications() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return [];
      
      final response = await _supabase
          .from('medications')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      
      return (response as List)
          .map((json) => Medication.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch medications: $e');
    }
  }
  
  // Add medication
  Future<void> addMedication(Medication medication) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');
      
      await _supabase
          .from('medications')
          .insert(medication.toJson()..['user_id'] = userId);
    } catch (e) {
      throw Exception('Failed to add medication: $e');
    }
  }
  
  // Update medication
  Future<void> updateMedication(Medication medication) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');
      
      await _supabase
          .from('medications')
          .update(medication.toJson())
          .eq('id', medication.id)
          .eq('user_id', userId);
    } catch (e) {
      throw Exception('Failed to update medication: $e');
    }
  }
  
  // Delete medication
  Future<void> deleteMedication(String medicationId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');
      
      await _supabase
          .from('medications')
          .delete()
          .eq('id', medicationId)
          .eq('user_id', userId);
    } catch (e) {
      throw Exception('Failed to delete medication: $e');
    }
  }
  
  // Search medications
  Future<List<Medication>> searchMedications(String query) async {
    try {
      final medications = await getMedications();
      return medications
          .where((med) =>
              med.name.toLowerCase().contains(query.toLowerCase()) ||
              med.notes.toLowerCase().contains(query.toLowerCase()))
          .toList();
    } catch (e) {
      throw Exception('Failed to search medications: $e');
    }
  }
}
