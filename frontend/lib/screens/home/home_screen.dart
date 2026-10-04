import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/guidance_provider.dart';
import '../../providers/profile_provider.dart';
import '../../widgets/feature_card.dart';
import '../../widgets/state_views.dart';
import '../guidance/guidance_generator_screen.dart';
import '../guidance/saved_guidance_screen.dart';
import '../interview/interview_screen.dart';
import '../profile/edit_profile_screen.dart';
import '../placement/placement_screen.dart';
import '../resume/ats_analyzer_screen.dart';
import '../roadmap/roadmap_screen.dart';
import '../skill_gap/skill_gap_screen.dart';

class HomeScreen extends StatelessWidget {
  final ValueChanged<int> onNavigateTab;

  const HomeScreen({super.key, required this.onNavigateTab});

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider = context.watch<ProfileProvider>();
    final guidanceProvider = context.watch<GuidanceProvider>();
    final authProvider = context.watch<AuthProvider>();

    final profile = profileProvider.profile;
    final studentName = profile?.fullName.isNotEmpty == true
        ? profile!.fullName.split(' ').first
        : (authProvider.user?.displayName.isNotEmpty == true
            ? authProvider.user!.displayName.split(' ').first
            : 'Student');

    final progress = guidanceProvider.calculateProgress(profile);
    final activeGuidance = guidanceProvider.activeGuidance;
    final hasGuidance = activeGuidance != null;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      children: [
        Text(
          '${_getGreeting()}, $studentName 👋',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: AppTheme.slate900,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Ready to take the next step in your career?',
          style: TextStyle(
            fontSize: 14,
            color: AppTheme.slate500,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 24),

        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppTheme.primary, Color(0xFF6366F1)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primary.withAlpha(70),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(40),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.trending_up, color: Colors.white, size: 14),
                        SizedBox(width: 6),
                        Text(
                          'CAREER INTELLIGENCE',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const Text(
                'Discover your career path',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Get personalized guidance based on your skills, interests and goals.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppTheme.primaryDark,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: const Icon(Icons.arrow_forward, size: 18),
                label: Text(hasGuidance ? 'Generate New Guidance' : 'Get Career Guidance'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const GuidanceGeneratorScreen()),
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),

        const SectionHeader(
          title: 'Continue your journey',
          subtitle: 'Core modules to elevate your career readiness',
        ),
        const SizedBox(height: 12),

        LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 600;
            return GridView.count(
              crossAxisCount: isWide ? 2 : 1,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: isWide ? 1.6 : 2.0,
              children: [
                FeatureCard(
                  title: 'Career Guidance',
                  description: 'Explore career paths that fit you.',
                  icon: Icons.explore_outlined,
                  iconColor: AppTheme.primary,
                  onTap: () {
                    if (hasGuidance) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SavedGuidanceScreen()),
                      );
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const GuidanceGeneratorScreen()),
                      );
                    }
                  },
                ),
                FeatureCard(
                  title: 'Skill Development',
                  description: 'Identify the skills you should build next.',
                  icon: Icons.psychology_outlined,
                  iconColor: const Color(0xFF0EA5E9),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SkillGapScreen()),
                    );
                  },
                ),
                FeatureCard(
                  title: 'Learning Roadmap',
                  description: 'Follow your personalized learning path.',
                  icon: Icons.timeline,
                  iconColor: const Color(0xFF10B981),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const RoadmapScreen()),
                    );
                  },
                ),
                FeatureCard(
                  title: 'Placement Prep',
                  description: 'Prepare for interviews and placements.',
                  icon: Icons.work_outline,
                  iconColor: const Color(0xFFF59E0B),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const PlacementScreen()),
                    );
                  },
                ),
                FeatureCard(
                  title: 'AI Mock Interview',
                  description: 'Role-specific technical & HR drill with AI scoring.',
                  icon: Icons.record_voice_over_outlined,
                  iconColor: const Color(0xFF6366F1),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const InterviewScreen()),
                    );
                  },
                ),
                FeatureCard(
                  title: 'Resume ATS Match',
                  description: 'Keyword gap scan and STAR bullet optimization.',
                  icon: Icons.description_outlined,
                  iconColor: const Color(0xFF0EA5E9),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AtsAnalyzerScreen()),
                    );
                  },
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 32),

        SectionHeader(
          title: 'Your progress',
          subtitle: 'Real-time metrics based on your activity and milestones',
          action: TextButton(
            onPressed: () => onNavigateTab(2),
            child: const Text('View All'),
          ),
        ),
        const SizedBox(height: 12),

        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        hasGuidance
                            ? 'Target: ${activeGuidance.careerRecommendation.title}'
                            : 'Profile Completion',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.slate900,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withAlpha(20),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        hasGuidance
                            ? '${progress.roadmapCompletedSteps}/${progress.roadmapTotalSteps} Steps'
                            : '${progress.profileCompletion}% Complete',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primaryDark,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: hasGuidance
                        ? progress.roadmapProgressFraction
                        : (progress.profileCompletion / 100),
                    minHeight: 8,
                    backgroundColor: AppTheme.slate100,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.success),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _SummaryStat(
                        label: 'Readiness Score',
                        value: '${progress.placementReadinessScore}%',
                        icon: Icons.check_circle_outline,
                        color: AppTheme.success,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _SummaryStat(
                        label: 'Guidance Sessions',
                        value: '${progress.guidanceCount}',
                        icon: Icons.bookmark_outline,
                        color: AppTheme.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        if (profile != null && profile.completionPercentage < 70) ...[
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.warning.withAlpha(20),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.warning.withAlpha(60)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: AppTheme.warning, size: 24),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Complete your student profile',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.slate900,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Adding your technical skills and interests improves guidance precision.',
                        style: TextStyle(fontSize: 12, color: AppTheme.slate600),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                    );
                  },
                  child: const Text('Update'),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 40),
      ],
    );
  }
}

class _SummaryStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _SummaryStat({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.slate50,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.slate900,
                ),
              ),
              Text(
                label,
                style: const TextStyle(fontSize: 11, color: AppTheme.slate500),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
