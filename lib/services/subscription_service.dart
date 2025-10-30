import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/subscription_tier.dart';
import 'payment_service.dart';

class SubscriptionService {
  static final SubscriptionService _instance = SubscriptionService._internal();
  factory SubscriptionService() => _instance;
  SubscriptionService._internal();

  final PaymentService _paymentService = PaymentService();
  
  static const String _subscriptionTierKey = 'subscription_tier';
  static const String _trialStartDateKey = 'trial_start_date';
  static const String _trialTierKey = 'trial_tier';
  static const String _aiQueriesUsedKey = 'ai_queries_used';
  static const String _healthCheckupsUsedKey = 'health_checkups_used';
  static const String _lastResetDateKey = 'last_reset_date';

  SubscriptionTier _currentTier = SubscriptionTier.free;
  DateTime? _trialStartDate;
  SubscriptionTier? _trialTier;
  int _aiQueriesUsed = 0;
  int _healthCheckupsUsed = 0;
  DateTime? _lastResetDate;

  SubscriptionTier get currentTier => _currentTier;
  DateTime? get trialStartDate => _trialStartDate;
  SubscriptionTier? get trialTier => _trialTier;
  int get aiQueriesUsed => _aiQueriesUsed;
  int get healthCheckupsUsed => _healthCheckupsUsed;

  Future<void> initialize() async {
    await _paymentService.initialize();
    await _loadSubscriptionData();
    await _checkTrialExpiry();
    await _resetDailyCounters();
  }

  Future<void> _loadSubscriptionData() async {
    final prefs = await SharedPreferences.getInstance();
    
    final tierIndex = prefs.getInt(_subscriptionTierKey) ?? 0;
    _currentTier = SubscriptionTier.values[tierIndex];
    
    final trialStartTimestamp = prefs.getInt(_trialStartDateKey);
    if (trialStartTimestamp != null) {
      _trialStartDate = DateTime.fromMillisecondsSinceEpoch(trialStartTimestamp);
    }
    
    final trialTierIndex = prefs.getInt(_trialTierKey);
    if (trialTierIndex != null) {
      _trialTier = SubscriptionTier.values[trialTierIndex];
    }
    
    _aiQueriesUsed = prefs.getInt(_aiQueriesUsedKey) ?? 0;
    _healthCheckupsUsed = prefs.getInt(_healthCheckupsUsedKey) ?? 0;
    
    final lastResetTimestamp = prefs.getInt(_lastResetDateKey);
    if (lastResetTimestamp != null) {
      _lastResetDate = DateTime.fromMillisecondsSinceEpoch(lastResetTimestamp);
    }
  }

  Future<void> _saveSubscriptionData() async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.setInt(_subscriptionTierKey, _currentTier.index);
    
    if (_trialStartDate != null) {
      await prefs.setInt(_trialStartDateKey, _trialStartDate!.millisecondsSinceEpoch);
    }
    
    if (_trialTier != null) {
      await prefs.setInt(_trialTierKey, _trialTier!.index);
    }
    
    await prefs.setInt(_aiQueriesUsedKey, _aiQueriesUsed);
    await prefs.setInt(_healthCheckupsUsedKey, _healthCheckupsUsed);
    
    if (_lastResetDate != null) {
      await prefs.setInt(_lastResetDateKey, _lastResetDate!.millisecondsSinceEpoch);
    }
  }

  Future<void> _checkTrialExpiry() async {
    if (_trialStartDate != null && _trialTier != null) {
      final trialEndDate = _trialStartDate!.add(Duration(days: _trialTier!.freeTrialDays));
      
      if (DateTime.now().isAfter(trialEndDate)) {
        // Trial expired, revert to free tier
        _currentTier = SubscriptionTier.free;
        _trialStartDate = null;
        _trialTier = null;
        await _saveSubscriptionData();
      }
    }
  }

  Future<void> _resetDailyCounters() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    if (_lastResetDate == null || !_lastResetDate!.isAtSameMomentAs(today)) {
      _aiQueriesUsed = 0;
      _healthCheckupsUsed = 0;
      _lastResetDate = today;
      await _saveSubscriptionData();
    }
  }

  Future<bool> upgradeToTier(SubscriptionTier tier) async {
    try {
      if (tier == SubscriptionTier.free) {
        _currentTier = tier;
        await _saveSubscriptionData();
        return true;
      }

      // Check if user wants to start free trial
      if (tier.hasFreeTrial && !_hasActiveTrial()) {
        return await startFreeTrial(tier);
      }

      // Purchase subscription
      final success = await _paymentService.purchaseSubscription(tier);
      
      if (success) {
        _currentTier = tier;
        await _saveSubscriptionData();
        // Persist subscription in Supabase (best-effort)
        try {
          final supabase = Supabase.instance.client;
          final userId = supabase.auth.currentUser?.id;
          if (userId != null) {
            await supabase.from('user_profiles').update({
              'subscription_tier': tier.name,
              'subscription_status': 'active',
              'trial_started_at': null,
              'trial_tier': null,
              'updated_at': DateTime.now().toIso8601String(),
            }).eq('id', userId);
          }
        } catch (_) {}
        return true;
      }
      
      return false;
    } catch (e) {
      print('Upgrade error: $e');
      return false;
    }
  }

  Future<bool> startFreeTrial(SubscriptionTier tier) async {
    try {
      if (!tier.hasFreeTrial || _hasActiveTrial()) {
        return false;
      }

      final success = await _paymentService.startFreeTrial(tier);
      
      if (success) {
        _trialStartDate = DateTime.now();
        _trialTier = tier;
        _currentTier = tier;
        await _saveSubscriptionData();
        // Persist trial in Supabase (best-effort)
        try {
          final supabase = Supabase.instance.client;
          final userId = supabase.auth.currentUser?.id;
          if (userId != null) {
            await supabase.from('user_profiles').update({
              'subscription_tier': tier.name,
              'subscription_status': 'trialing',
              'trial_started_at': DateTime.now().toIso8601String(),
              'trial_tier': tier.name,
              'updated_at': DateTime.now().toIso8601String(),
            }).eq('id', userId);
          }
        } catch (_) {}
        return true;
      }
      
      return false;
    } catch (e) {
      print('Free trial error: $e');
      return false;
    }
  }

  bool _hasActiveTrial() {
    if (_trialStartDate == null || _trialTier == null) {
      return false;
    }
    
    final trialEndDate = _trialStartDate!.add(Duration(days: _trialTier!.freeTrialDays));
    return DateTime.now().isBefore(trialEndDate);
  }

  bool canUseAIFeature() {
    if (_currentTier == SubscriptionTier.free) {
      return _aiQueriesUsed < _currentTier.maxAIQueriesPerDay;
    }
    return true;
  }

  bool canUseHealthCheckup() {
    if (_currentTier == SubscriptionTier.free) {
      return _healthCheckupsUsed < _currentTier.maxHealthCheckupsPerDay;
    }
    return true;
  }

  Future<void> recordAIQuery() async {
    if (_currentTier.maxAIQueriesPerDay != -1) {
      _aiQueriesUsed++;
      await _saveSubscriptionData();
    }
  }

  Future<void> recordHealthCheckup() async {
    if (_currentTier.maxHealthCheckupsPerDay != -1) {
      _healthCheckupsUsed++;
      await _saveSubscriptionData();
    }
  }

  int getRemainingAIQueries() {
    if (_currentTier.maxAIQueriesPerDay == -1) {
      return -1; // Unlimited
    }
    return _currentTier.maxAIQueriesPerDay - _aiQueriesUsed;
  }

  int getRemainingHealthCheckups() {
    if (_currentTier.maxHealthCheckupsPerDay == -1) {
      return -1; // Unlimited
    }
    return _currentTier.maxHealthCheckupsPerDay - _healthCheckupsUsed;
  }

  bool hasFeature(String feature) {
    switch (feature) {
      case 'ai_pharmacist':
        return _currentTier.hasAIFeatures;
      case 'health_checkup':
        return _currentTier.hasAdvancedHealthTracking;
      case 'document_upload':
        return _currentTier.hasDocumentUpload;
      case 'voice_features':
        return _currentTier.hasVoiceFeatures;
      case 'priority_support':
        return _currentTier.hasPrioritySupport;
      case 'family_care':
        return _currentTier.hasFamilyCare;
      case 'emergency_features':
        return _currentTier.hasEmergencyFeatures;
      default:
        return false;
    }
  }

  int getMaxMedications() {
    return _currentTier.maxMedications;
  }

  int getMaxFamilyMembers() {
    return _currentTier.maxFamilyMembers;
  }

  bool isTrialActive() {
    return _hasActiveTrial();
  }

  int getTrialDaysRemaining() {
    if (!_hasActiveTrial()) {
      return 0;
    }
    
    final trialEndDate = _trialStartDate!.add(Duration(days: _trialTier!.freeTrialDays));
    final remaining = trialEndDate.difference(DateTime.now()).inDays;
    return remaining > 0 ? remaining : 0;
  }

  Future<void> cancelSubscription() async {
    await _paymentService.cancelSubscription();
    _currentTier = SubscriptionTier.free;
    _trialStartDate = null;
    _trialTier = null;
    await _saveSubscriptionData();
    // Persist cancellation in Supabase (best-effort)
    try {
      final supabase = Supabase.instance.client;
      final userId = supabase.auth.currentUser?.id;
      if (userId != null) {
        await supabase.from('user_profiles').update({
          'subscription_tier': 'free',
          'subscription_status': 'canceled',
          'trial_started_at': null,
          'trial_tier': null,
          'updated_at': DateTime.now().toIso8601String(),
        }).eq('id', userId);
      }
    } catch (_) {}
  }

  Map<String, dynamic> getSubscriptionInfo() {
    return {
      'tier': _currentTier.name,
      'displayName': _currentTier.displayName,
      'price': _currentTier.price,
      'billingPeriod': _currentTier.billingPeriod,
      'features': _currentTier.features,
      'maxMedications': _currentTier.maxMedications,
      'maxAIQueries': _currentTier.maxAIQueriesPerDay,
      'maxHealthCheckups': _currentTier.maxHealthCheckupsPerDay,
      'maxFamilyMembers': _currentTier.maxFamilyMembers,
      'isTrialActive': isTrialActive(),
      'trialDaysRemaining': getTrialDaysRemaining(),
      'aiQueriesUsed': _aiQueriesUsed,
      'healthCheckupsUsed': _healthCheckupsUsed,
      'remainingAIQueries': getRemainingAIQueries(),
      'remainingHealthCheckups': getRemainingHealthCheckups(),
    };
  }
}
