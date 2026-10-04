import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../config/constants.dart';
import '../../providers/auth_provider.dart';
import '../../providers/guidance_provider.dart';
import '../../providers/profile_provider.dart';
import '../../widgets/password_reset_dialog.dart';
import '../auth/login_screen.dart';
import '../profile/edit_profile_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _emailNotifications = true;
  bool _roadmapReminders = true;

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            children: [
              const _SettingsSectionHeader('Account'),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.person_outline, color: AppTheme.primary),
                      title: const Text('Profile Information'),
                      subtitle: Text(user?.email ?? 'Manage your academic details'),
                      trailing: const Icon(Icons.chevron_right, color: AppTheme.slate400),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                        );
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.lock_outline, color: AppTheme.slate700),
                      title: const Text('Password & Security'),
                      subtitle: const Text('Change your password or security question'),
                      trailing: const Icon(Icons.chevron_right, color: AppTheme.slate400),
                      onTap: () {
                        PasswordResetDialog.show(
                          context,
                          initialEmail: user?.email,
                          isSettingUp: false,
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              const _SettingsSectionHeader('Notifications'),
              Card(
                child: Column(
                  children: [
                    SwitchListTile(
                      secondary: const Icon(Icons.notifications_outlined, color: AppTheme.primary),
                      title: const Text('Career Updates & News'),
                      subtitle: const Text('Receive tailored guidance alerts and updates'),
                      value: _emailNotifications,
                      activeThumbColor: AppTheme.primary,
                      onChanged: (val) => setState(() => _emailNotifications = val),
                    ),
                    const Divider(height: 1),
                    SwitchListTile(
                      secondary: const Icon(Icons.alarm_outlined, color: AppTheme.primary),
                      title: const Text('Learning Roadmap Reminders'),
                      subtitle: const Text('Weekly milestone check-in reminders'),
                      value: _roadmapReminders,
                      activeThumbColor: AppTheme.primary,
                      onChanged: (val) => setState(() => _roadmapReminders = val),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              const _SettingsSectionHeader('About Careerly'),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: AppTheme.primary,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.school, color: Colors.white, size: 20),
                          ),
                          const SizedBox(width: 12),
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppConstants.appName,
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.slate900,
                                ),
                              ),
                              Text(
                                AppConstants.appTagline,
                                style: TextStyle(fontSize: 12, color: AppTheme.slate500),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'Careerly provides personalized career pathways, actionable skill gap analysis, customized learning roadmaps, and structured placement preparation for students.',
                        style: TextStyle(fontSize: 13, color: AppTheme.slate600, height: 1.5),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Version 1.0.0',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.slate400),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              OutlinedButton.icon(
                icon: const Icon(Icons.logout, color: AppTheme.error),
                label: const Text('Sign Out of Careerly', style: TextStyle(color: AppTheme.error)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppTheme.error),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () async {
                  await authProvider.signOut();
                  if (context.mounted) {
                    context.read<ProfileProvider>().clearProfile();
                    context.read<GuidanceProvider>().clearGuidance();
                    Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false,
                    );
                  }
                },
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsSectionHeader extends StatelessWidget {
  final String title;

  const _SettingsSectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: AppTheme.slate500,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
