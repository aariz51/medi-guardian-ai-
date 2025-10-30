enum SubscriptionTier {
  free,
  monthly,
  yearly,
}

extension SubscriptionTierExtension on SubscriptionTier {
  String get name {
    switch (this) {
      case SubscriptionTier.free:
        return 'Free';
      case SubscriptionTier.monthly:
        return 'Monthly';
      case SubscriptionTier.yearly:
        return 'Yearly';
    }
  }

  String get displayName {
    switch (this) {
      case SubscriptionTier.free:
        return 'Basic Protection';
      case SubscriptionTier.monthly:
        return 'Complete Safety Shield';
      case SubscriptionTier.yearly:
        return 'Annual Health Guardian';
    }
  }

  double get price {
    switch (this) {
      case SubscriptionTier.free:
        return 0.0;
      case SubscriptionTier.monthly:
        return 9.99;
      case SubscriptionTier.yearly:
        return 99.99;
    }
  }

  int get maxMedications {
    switch (this) {
      case SubscriptionTier.free:
        return 5;
      case SubscriptionTier.monthly:
      case SubscriptionTier.yearly:
        return -1; // Unlimited
    }
  }

  int get maxAIQueriesPerDay {
    switch (this) {
      case SubscriptionTier.free:
        return 10;
      case SubscriptionTier.monthly:
        return 100;
      case SubscriptionTier.yearly:
        return -1; // Unlimited
    }
  }

  int get maxHealthCheckupsPerDay {
    switch (this) {
      case SubscriptionTier.free:
        return 3;
      case SubscriptionTier.monthly:
        return 20;
      case SubscriptionTier.yearly:
        return -1; // Unlimited
    }
  }

  bool get hasAIFeatures {
    return this != SubscriptionTier.free;
  }

  bool get hasAdvancedHealthTracking {
    return this != SubscriptionTier.free;
  }

  bool get hasEmergencyFeatures {
    return this != SubscriptionTier.free;
  }

  bool get hasFamilyCare {
    return this == SubscriptionTier.yearly;
  }

  bool get hasDocumentUpload {
    return this != SubscriptionTier.free;
  }

  bool get hasVoiceFeatures {
    return this != SubscriptionTier.free;
  }

  bool get hasPrioritySupport {
    return this != SubscriptionTier.free;
  }

  int get maxFamilyMembers {
    switch (this) {
      case SubscriptionTier.free:
        return 1;
      case SubscriptionTier.monthly:
        return 1;
      case SubscriptionTier.yearly:
        return 5;
    }
  }

  String get billingPeriod {
    switch (this) {
      case SubscriptionTier.free:
        return 'Forever';
      case SubscriptionTier.monthly:
        return 'Per month';
      case SubscriptionTier.yearly:
        return 'Per year';
    }
  }

  List<String> get features {
    switch (this) {
      case SubscriptionTier.free:
        return [
          'Track up to 5 medications',
          'Basic drug interaction warnings',
          'Simple reminder alerts',
          'Side effect logging',
          '10 AI queries per day',
          '3 health checkups per day',
        ];
      case SubscriptionTier.monthly:
        return [
          'Unlimited medications',
          'AI Pharmacist Assistant',
          'Real-time health monitoring',
          'Emergency medical ID',
          '100 AI queries per day',
          '20 health checkups per day',
          'Document upload support',
          'Voice interaction',
          'Priority support',
        ];
      case SubscriptionTier.yearly:
        return [
          'All Monthly features',
          'Unlimited AI queries',
          'Unlimited health checkups',
          'Family care coordination (up to 5 members)',
          'Advanced health analytics',
          'Annual health reports',
          '24/7 priority support',
          'Early access to new features',
          'Custom AI health insights',
        ];
    }
  }

  bool get hasFreeTrial {
    return this != SubscriptionTier.free;
  }

  int get freeTrialDays {
    switch (this) {
      case SubscriptionTier.free:
        return 0;
      case SubscriptionTier.monthly:
        return 7;
      case SubscriptionTier.yearly:
        return 7;
    }
  }
} 