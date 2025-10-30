# MediGuardian AI - Medical Safety & Health Monitoring App

A comprehensive Flutter mobile application for medication safety, health tracking, and AI-powered health assistance.

## 🚀 Quick Start

### Prerequisites
- Flutter SDK 3.8 or higher
- Dart SDK 3.8 or higher
- Android Studio / VS Code with Flutter extensions
- Supabase account
- OpenAI API key

### Installation

1. **Clone the repository:**
```bash
git clone <repository-url>
cd medi_guardian_ai
```

2. **Install dependencies:**
```bash
flutter pub get
```

3. **Set up environment variables:**
   - Copy `.env.example` to `.env`
   - Fill in your API keys:
     ```env
     OPENAI_API_KEY=sk-your_openai_api_key_here
     SUPABASE_URL=https://your-project.supabase.co
     SUPABASE_ANON_KEY=your_supabase_anon_key
     SUPABASE_SERVICE_ROLE_KEY=your_supabase_service_role_key
     ```

4. **Set up Supabase Database:**
   - Create a new Supabase project
   - Run the SQL schema from `SUPABASE_SCHEMA.sql` in the SQL editor
   - This creates all necessary tables and security policies

5. **Run the app:**
```bash
flutter run
```

## 📋 Features

### ✅ Implemented Features

**Free Tier:**
- ✅ Beautiful onboarding flow with personal information collection
- ✅ Email-based authentication with Supabase
- ✅ Material Design 3 UI with glassmorphic effects
- ✅ 5-tab navigation (Home, Medications, Health, AI Assistant, Profile)
- ✅ Medication tracking UI with reminders
- ✅ Health metrics monitoring
- ✅ AI Assistant chat interface
- ✅ Profile management

**Premium Features (Ready for Implementation):**
- 🚀 AI-powered medication analysis
- 🚀 Advanced health monitoring & analytics
- 🚀 Emergency protocol generator with QR codes
- 🚀 Family care coordination
- 🚀 In-app purchases

## 🏗️ Architecture

### Tech Stack
- **Framework**: Flutter 3.8+
- **State Management**: Provider
- **Backend**: Supabase (Auth, Database, Storage)
- **AI**: OpenAI GPT-4 for medical assistance
- **Design**: Material Design 3, Glassmorphism
- **Charts**: FL Chart, Syncfusion Charts

### Project Structure
```
lib/
├── main.dart                 # App entry point
├── config/
│   └── env_config.dart      # Environment configuration
├── theme/
│   └── app_theme.dart       # Material Design 3 themes
├── models/                   # Data models
│   ├── medication.dart
│   ├── drug_interaction.dart
│   ├── health_metric.dart
│   ├── side_effect.dart
│   └── user.dart
├── screens/                  # UI screens
│   ├── onboarding/
│   │   ├── onboarding_screen.dart
│   │   └── pages/
│   ├── auth/
│   │   ├── login_screen.dart
│   │   └── signup_screen.dart
│   ├── main_screen.dart
│   ├── home_screen.dart
│   ├── medications_screen.dart
│   ├── health_tracker_screen.dart
│   ├── ai_assistant_screen.dart
│   └── profile_screen.dart
├── widgets/                  # Reusable widgets
│   └── glassmorphic_card.dart
├── services/                 # Business logic
│   ├── auth_service.dart
│   ├── medication_service.dart
│   └── openai_service.dart
└── providers/                # State management
    └── medication_provider.dart
```

## 🔐 Environment Setup

### Supabase Setup
1. Create a project at [supabase.com](https://supabase.com)
2. Get your project URL and API keys from Project Settings
3. Run the `SUPABASE_SCHEMA.sql` to create tables
4. Enable Email authentication in Authentication settings

### OpenAI Setup
1. Get an API key from [platform.openai.com](https://platform.openai.com)
2. Add it to your `.env` file
3. The app uses GPT-4o-mini for cost-effective AI features

## 📱 User Flow

1. **Onboarding**: Collect user information (personal, medical, preferences)
2. **Authentication**: Email signup/signin with verification
3. **Main App**: Access all features through bottom navigation
4. **AI Assistant**: Get medication advice and health insights
5. **Profile**: Manage settings and view medical information

## 🎨 Design Features

- Modern glassmorphic UI with Material Design 3
- Beautiful gradient backgrounds throughout
- Smooth animations and transitions
- Dark/Light theme support
- Responsive layout for all devices
- Accessibility features built-in

## 🔒 Security & Privacy

- HIPAA-compliant data handling
- Row-Level Security (RLS) in Supabase
- Secure authentication with Supabase Auth
- Encrypted database connections
- User data privacy controls

## 📊 Database Schema

The app uses Supabase PostgreSQL with the following main tables:
- `user_profiles` - User information and preferences
- `medications` - Medication tracking
- `health_metrics` - Vital signs and health data
- `side_effects` - Side effect logging
- `drug_interactions` - Interaction database
- `emergency_contacts` - Emergency contact information
- `medication_reminders` - Reminder scheduling
- `ai_chat_history` - AI conversation history

## 🚧 Roadmap

### Phase 1 (Complete)
- ✅ App structure and UI
- ✅ Authentication system
- ✅ Onboarding flow
- ✅ Database schema

### Phase 2 (In Progress)
- ⏳ Medication CRUD operations
- ⏳ Drug interaction checker
- ⏳ Health metrics tracking
- ⏳ AI chat integration

### Phase 3 (Future)
- Advanced analytics and charts
- Medication reminders with notifications
- Camera-based pill identification
- QR code generation for Medical ID
- Premium feature implementation

## 📝 Notes

- The `.env` file is gitignored - never commit API keys
- Always use environment variables for sensitive data
- Test thoroughly before deploying to production
- Follow healthcare compliance standards

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## 📄 License

This project is licensed under the MIT License.

## 📧 Support

For support, email support@mediguardian.ai or open an issue in the repository.
"# medi-guardian-ai-" 
