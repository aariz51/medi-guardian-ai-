import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  // OpenAI Configuration
  static String get openaiApiKey => dotenv.env['OPENAI_API_KEY'] ?? '';
  
  // Payment Configuration
  static String get googlePlayBillingKey => dotenv.env['GOOGLE_PLAY_BILLING_KEY'] ?? '';
  static String get appleAppStoreSharedSecret => dotenv.env['APPLE_APP_STORE_SHARED_SECRET'] ?? '';
  
  // Supabase Configuration
  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';
  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';
  
  // Firebase Configuration
  static String get firebaseProjectId => dotenv.env['FIREBASE_PROJECT_ID'] ?? '';
  static String get firebaseApiKey => dotenv.env['FIREBASE_API_KEY'] ?? '';
  
  // App Configuration
  static const String appName = String.fromEnvironment('APP_NAME', defaultValue: 'MediGuardian AI');
  static const String appVersion = String.fromEnvironment('APP_VERSION', defaultValue: '1.0.0');
  static const String environment = String.fromEnvironment('ENVIRONMENT', defaultValue: 'development');
  
  // Payment Product IDs
  static const String monthlyProductIdAndroid = String.fromEnvironment('MONTHLY_PRODUCT_ID_ANDROID', defaultValue: 'medi_guardian_monthly_android');
  static const String yearlyProductIdAndroid = String.fromEnvironment('YEARLY_PRODUCT_ID_ANDROID', defaultValue: 'medi_guardian_yearly_android');
  static const String monthlyProductIdIOS = String.fromEnvironment('MONTHLY_PRODUCT_ID_IOS', defaultValue: 'medi_guardian_monthly_ios');
  static const String yearlyProductIdIOS = String.fromEnvironment('YEARLY_PRODUCT_ID_IOS', defaultValue: 'medi_guardian_yearly_ios');
  
  // Free Trial Configuration
  static const int freeTrialDays = int.fromEnvironment('FREE_TRIAL_DAYS', defaultValue: 7);
  
  // Feature Flags
  static const bool enableAIPharmacist = bool.fromEnvironment('ENABLE_AI_PHARMACIST', defaultValue: true);
  static const bool enableHealthCheckup = bool.fromEnvironment('ENABLE_HEALTH_CHECKUP', defaultValue: true);
  static const bool enablePaymentIntegration = bool.fromEnvironment('ENABLE_PAYMENT_INTEGRATION', defaultValue: true);
  static const bool enableFreeTrial = bool.fromEnvironment('ENABLE_FREE_TRIAL', defaultValue: true);
  
  // Validation methods
  static bool get isOpenAIConfigured => openaiApiKey.isNotEmpty;
  static bool get isSupabaseConfigured => supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
  static bool get isFirebaseConfigured => firebaseProjectId.isNotEmpty && firebaseApiKey.isNotEmpty;
  static bool get isPaymentConfigured => googlePlayBillingKey.isNotEmpty || appleAppStoreSharedSecret.isNotEmpty;
  
  // Get product ID based on platform
  static String getMonthlyProductId() {
    // In a real app, you would check the platform here
    // For now, return Android product ID as default
    return monthlyProductIdAndroid;
  }
  
  static String getYearlyProductId() {
    // In a real app, you would check the platform here
    // For now, return Android product ID as default
    return yearlyProductIdAndroid;
  }
}