import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user.dart' as models;

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;
  
  // Get current user
  User? get currentUser => _supabase.auth.currentUser;
  
  // Check if user is signed in
  bool get isSignedIn => currentUser != null;
  
  // Sign up with email
  Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
    String? fullName,
    String? phoneNumber,
    DateTime? dateOfBirth,
    String? gender,
    Map<String, dynamic>? medicalInfo,
  }) async {
    try {
      // Sign up user
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );
      
      // Profile row is created by a Supabase trigger. Optionally update extra fields after creation.
      if (response.user != null && (fullName != null || phoneNumber != null || gender != null || medicalInfo != null || dateOfBirth != null)) {
        try {
          await _supabase
              .from('user_profiles')
              .update({
                if (fullName != null) 'full_name': fullName,
                if (phoneNumber != null) 'phone_number': phoneNumber,
                if (dateOfBirth != null) 'date_of_birth': dateOfBirth.toIso8601String(),
                if (gender != null) 'gender': gender,
                if (medicalInfo != null) 'medical_info': medicalInfo,
                'updated_at': DateTime.now().toIso8601String(),
              })
              .eq('id', response.user!.id);
        } catch (_) {
          // Ignore if profile not yet available; it will be created by trigger shortly
        }
      }
      
      return response;
    } catch (e) {
      throw Exception('Sign up failed: $e');
    }
  }
  
  // Sign in with email
  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      return await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw Exception('Sign in failed: $e');
    }
  }
  
  // Sign out
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }
  
  // Send verification email
  Future<void> sendVerificationEmail() async {
    try {
      await _supabase.auth.resend(
        type: OtpType.signup,
        email: currentUser?.email ?? '',
      );
    } catch (e) {
      throw Exception('Failed to send verification email: $e');
    }
  }
  
  // Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email);
    } catch (e) {
      throw Exception('Failed to send password reset email: $e');
    }
  }
  
  // Update password
  Future<void> updatePassword(String newPassword) async {
    try {
      await _supabase.auth.updateUser(
        UserAttributes(password: newPassword),
      );
    } catch (e) {
      throw Exception('Failed to update password: $e');
    }
  }
  
  // Update user profile
  Future<void> updateUserProfile(Map<String, dynamic> updates) async {
    try {
      await _supabase
          .from('user_profiles')
          .update(updates)
          .eq('id', currentUser!.id);
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }
  
  // Get user profile
  Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      final response = await _supabase
          .from('user_profiles')
          .select()
          .eq('id', currentUser!.id)
          .single();
      
      return response as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }
  
  // Auth state stream
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;
}
