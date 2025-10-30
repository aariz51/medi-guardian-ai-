import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/glassmorphic_card.dart';
import 'subscription_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final supabase = Supabase.instance.client;
    final userId = supabase.auth.currentUser?.id;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await Supabase.instance.client.auth.signOut();
              if (context.mounted) {
                Navigator.of(context).pushNamedAndRemoveUntil('/welcome', (r) => false);
              }
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.lightBlue.withOpacity(0.3),
              Colors.white,
            ],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            GlassmorphicCard(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: userId == null
                    ? Future.value([])
                    : supabase
                        .from('user_profiles')
                        .select()
                        .eq('id', userId)
                        .limit(1),
                builder: (context, snapshot) {
                  final profile = (snapshot.data != null && snapshot.data!.isNotEmpty)
                      ? snapshot.data!.first
                      : null;
                  final fullName = profile != null && (profile['full_name'] as String?)?.isNotEmpty == true
                      ? profile['full_name'] as String
                      : (supabase.auth.currentUser?.email?.split('@').first ?? 'User');
                  final email = profile != null && (profile['email'] as String?)?.isNotEmpty == true
                      ? profile['email'] as String
                      : (supabase.auth.currentUser?.email ?? '');
                  final tier = profile != null && (profile['subscription_tier'] as String?)?.isNotEmpty == true
                      ? profile['subscription_tier'] as String
                      : 'free';

                  return Column(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryBlue,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.person,
                          size: 50,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        fullName,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        email,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                        ),
                      ),
                      if (snapshot.connectionState == ConnectionState.waiting)
                        const Padding(
                          padding: EdgeInsets.only(top: 8.0),
                          child: SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                        ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            _buildSectionHeader('Account'),
            GlassmorphicCard(
              child: Column(
                children: [
                  _buildMenuItem(
                    Icons.credit_card,
                    'Subscription',
                    'dynamic',
                    AppTheme.primaryGreen,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SubscriptionScreen()),
                      );
                    },
                  ),
                  const Divider(),
                  _buildMenuItem(
                    Icons.notifications,
                    'Notifications',
                    'Enabled',
                    Colors.blue,
                    () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Notification settings coming soon!')),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildSectionHeader('Safety'),
            GlassmorphicCard(
              child: Column(
                children: [
                  _buildMenuItem(
                    Icons.emergency,
                    'Emergency Contacts',
                    '2 contacts',
                    Colors.red,
                    () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Emergency contacts coming soon!')),
                      );
                    },
                  ),
                  const Divider(),
                  _buildMenuItem(
                    Icons.qr_code,
                    'Medical ID',
                    'View QR code',
                    AppTheme.primaryBlue,
                    () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Medical ID coming soon!')),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildSectionHeader('About'),
            GlassmorphicCard(
              child: Column(
                children: [
                  _buildMenuItem(
                    Icons.help_outline,
                    'Help & Support',
                    'Get help',
                    Colors.grey,
                    () {
                      showAboutDialog(
                        context: context,
                        applicationName: 'MediGuardian AI',
                        applicationVersion: '1.0.0',
                        applicationIcon: const Icon(Icons.health_and_safety, size: 48, color: AppTheme.primaryBlue),
                      );
                    },
                  ),
                  const Divider(),
                  _buildMenuItem(
                    Icons.info_outline,
                    'About',
                    'Version 1.0.0',
                    Colors.grey,
                    () {
                      showAboutDialog(
                        context: context,
                        applicationName: 'MediGuardian AI',
                        applicationVersion: '1.0.0',
                        applicationLegalese: 'Your intelligent companion for safe medication management',
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    IconData icon,
    String title,
    String subtitle,
    Color iconColor,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}
