import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../../models/onboarding_data.dart';

class OnboardingPage4 extends StatefulWidget {
  const OnboardingPage4({super.key});

  @override
  State<OnboardingPage4> createState() => _OnboardingPage4State();
}

class _OnboardingPage4State extends State<OnboardingPage4> {
  bool _medicationReminders = true;
  bool _healthAlerts = true;
  bool _dailyCheckIns = false;
  bool _dataAnalytics = true;
  String _reminderTime = 'Morning';
  String _themePreference = 'System';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Configure Your Preferences',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Customize your experience with these settings',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 32),
            
            // Notification Preferences
            _buildPreferenceSection(
              'Notifications',
              [
                _buildEnhancedSwitchTile(
                  'Medication Reminders',
                  'Get notified about your medication schedule',
                  _medicationReminders,
                  (value) => setState(() => _medicationReminders = value),
                ),
                const SizedBox(height: 12),
                _buildEnhancedSwitchTile(
                  'Health Alerts',
                  'Receive important health updates and warnings',
                  _healthAlerts,
                  (value) => setState(() => _healthAlerts = value),
                ),
                const SizedBox(height: 12),
                _buildEnhancedSwitchTile(
                  'Daily Health Check-ins',
                  'Reminder to log your daily health metrics',
                  _dailyCheckIns,
                  (value) => setState(() => _dailyCheckIns = value),
                ),
              ],
            ),
            const SizedBox(height: 24),
          // Persist to shared onboarding holder
          Builder(builder: (_) {
            OnboardingData.current['prefs'] = {
              'medication_reminders': _medicationReminders,
              'health_alerts': _healthAlerts,
              'daily_checkins': _dailyCheckIns,
              'reminder_time': _reminderTime,
              'theme': _themePreference,
            };
            return const SizedBox.shrink();
          }),
            
            // Reminder Time
            const Text(
              'Preferred Reminder Time',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: ['Morning', 'Afternoon', 'Evening'].map((time) {
                final isSelected = _reminderTime == time;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: InkWell(
                      onTap: () => setState(() => _reminderTime = time),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.white.withOpacity(0.3)
                              : Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? Colors.white
                                : Colors.white.withOpacity(0.3),
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Text(
                          time,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight:
                                isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),
            
            // Privacy & Analytics
            _buildPreferenceSection(
              'Privacy & Analytics',
              [
                _buildEnhancedSwitchTile(
                  'Anonymous Usage Analytics',
                  'Help us improve by sharing anonymous data',
                  _dataAnalytics,
                  (value) => setState(() => _dataAnalytics = value),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreferenceSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        ...children,
      ],
    );
  }

  Widget _buildEnhancedSwitchTile(String title, String subtitle, bool value, ValueChanged<bool> onChanged) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                Text(subtitle, style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.7))),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => onChanged(!value),
            child: AnimatedContainer(
              duration: Duration(milliseconds: 200),
              width: 56,
              height: 32,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: value ? AppTheme.primaryGreen : Colors.grey.shade400,
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 4, offset: Offset(0, 2))],
              ),
              child: Stack(
                children: [
                  AnimatedPositioned(
                    duration: Duration(milliseconds: 200),
                    left: value ? 24 : 2,
                    top: 2,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                      child: Icon(
                        value ? Icons.check : Icons.close,
                        size: 16,
                        color: value ? AppTheme.primaryGreen : Colors.grey.shade500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}