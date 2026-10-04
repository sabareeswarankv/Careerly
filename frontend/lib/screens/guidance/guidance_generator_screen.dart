import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/guidance_provider.dart';
import '../../providers/profile_provider.dart';
import '../../widgets/app_buttons.dart';
import '../../widgets/state_views.dart';
import '../profile/edit_profile_screen.dart';
import 'career_result_screen.dart';

class GuidanceGeneratorScreen extends StatefulWidget {
  const GuidanceGeneratorScreen({super.key});

  @override
  State<GuidanceGeneratorScreen> createState() => _GuidanceGeneratorScreenState();
}

class _GuidanceGeneratorScreenState extends State<GuidanceGeneratorScreen> {
  Future<void> _generateGuidance() async {
    final profileProvider = context.read<ProfileProvider>();
    final guidanceProvider = context.read<GuidanceProvider>();
    final authProvider = context.read<AuthProvider>();

    final profile = profileProvider.profile;
    if (profile == null) return;

    if (profile.careerGoal.isEmpty && profile.skills.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add your career goal or skills to personalize guidance.'),
        ),
      );
      return;
    }

    final token = authProvider.user != null ? null : null;

    final success = await guidanceProvider.generateCareerGuidance(
      profile,
      authToken: token,
    );

    if (success && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => CareerResultScreen(
            guidance: guidanceProvider.activeGuidance!,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider = context.watch<ProfileProvider>();
    final guidanceProvider = context.watch<GuidanceProvider>();
    final profile = profileProvider.profile;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Career Guidance'),
      ),
      body: Stack(
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                children: [
                  const Text(
                    'Tell us about yourself',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.slate900,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Your profile helps us personalize your career guidance.',
                    style: TextStyle(fontSize: 14, color: AppTheme.slate500),
                  ),
                  const SizedBox(height: 24),

                  if (guidanceProvider.errorMessage != null)
                    ErrorBanner(
                      message: guidanceProvider.errorMessage!,
                      onRetry: guidanceProvider.clearError,
                    ),

                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Current Profile Overview',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.slate900,
                                ),
                              ),
                              TextButton.icon(
                                icon: const Icon(Icons.edit, size: 16),
                                label: const Text('Edit Profile'),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                                  );
                                },
                              ),
                            ],
                          ),
                          const Divider(height: 20),
                          _ProfileItem(
                            label: 'Degree & Semester',
                            value: profile != null
                                ? '${profile.degree} (Semester ${profile.semester})'
                                : 'Not specified',
                          ),
                          const SizedBox(height: 10),
                          _ProfileItem(
                            label: 'Department',
                            value: profile?.department ?? 'Not specified',
                          ),
                          const SizedBox(height: 10),
                          _ProfileItem(
                            label: 'Current CGPA',
                            value: profile != null ? profile.cgpa.toStringAsFixed(1) : 'Not specified',
                          ),
                          const SizedBox(height: 10),
                          _ProfileItem(
                            label: 'Primary Career Goal',
                            value: profile?.careerGoal.isNotEmpty == true
                                ? profile!.careerGoal
                                : 'Not specified',
                            isBold: true,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Technical Skills',
                            style: TextStyle(fontSize: 13, color: AppTheme.slate500),
                          ),
                          const SizedBox(height: 6),
                          if (profile?.skills.isNotEmpty == true)
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: profile!.skills.map((s) {
                                return Chip(
                                  label: Text(s, style: const TextStyle(fontSize: 12)),
                                  backgroundColor: AppTheme.primary.withAlpha(20),
                                );
                              }).toList(),
                            )
                          else
                            const Text('No skills entered yet.', style: TextStyle(fontSize: 13, color: AppTheme.slate600)),
                          const SizedBox(height: 16),
                          const Text(
                            'Interests',
                            style: TextStyle(fontSize: 13, color: AppTheme.slate500),
                          ),
                          const SizedBox(height: 6),
                          if (profile?.interests.isNotEmpty == true)
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: profile!.interests.map((i) {
                                return Chip(
                                  label: Text(i, style: const TextStyle(fontSize: 12)),
                                  backgroundColor: AppTheme.slate100,
                                );
                              }).toList(),
                            )
                          else
                            const Text('No interests selected yet.', style: TextStyle(fontSize: 13, color: AppTheme.slate600)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  PrimaryButton(
                    label: 'Generate My Career Guidance',
                    icon: Icons.analytics_outlined,
                    isLoading: guidanceProvider.isGenerating,
                    onPressed: guidanceProvider.isGenerating ? null : _generateGuidance,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Guidance is tailored to your unique profile and will include recommendations, skill gaps, learning roadmap, and placement advice.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: AppTheme.slate500, height: 1.4),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),

          if (guidanceProvider.isGenerating)
            Container(
              color: Colors.white.withAlpha(230),
              child: LoadingView(
                message: 'Analyzing your profile...',
                subMessage: guidanceProvider.generationStep.isNotEmpty
                    ? guidanceProvider.generationStep
                    : 'Personalizing your career recommendations...',
              ),
            ),
        ],
      ),
    );
  }
}

class _ProfileItem extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;

  const _ProfileItem({required this.label, required this.value, this.isBold = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 140,
          child: Text(label, style: const TextStyle(fontSize: 13, color: AppTheme.slate500)),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
              color: isBold ? AppTheme.primary : AppTheme.slate900,
            ),
          ),
        ),
      ],
    );
  }
}
