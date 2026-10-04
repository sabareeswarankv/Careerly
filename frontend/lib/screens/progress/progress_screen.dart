import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../providers/guidance_provider.dart';
import '../../providers/profile_provider.dart';
import '../../widgets/app_buttons.dart';
import '../../widgets/state_views.dart';
import '../guidance/guidance_generator_screen.dart';
import '../profile/edit_profile_screen.dart';
import '../roadmap/roadmap_screen.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profileProvider = context.watch<ProfileProvider>();
    final guidanceProvider = context.watch<GuidanceProvider>();

    final profile = profileProvider.profile;
    final progress = guidanceProvider.calculateProgress(profile);
    final activeGuidance = guidanceProvider.activeGuidance;

    final hasData = profile != null && (profile.completionPercentage > 0 || progress.guidanceCount > 0);

    if (!hasData) {
      return EmptyState(
        icon: Icons.trending_up,
        title: 'Start tracking your progress',
        description: 'Complete your profile and generate your first career guidance to monitor your growth milestones.',
        buttonLabel: 'Complete Profile',
        onAction: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const EditProfileScreen()),
          );
        },
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      children: [
        const Text(
          'Your Career Progress',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: AppTheme.slate900,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Track your career readiness and learning roadmap milestones',
          style: TextStyle(fontSize: 14, color: AppTheme.slate500),
        ),
        const SizedBox(height: 24),

        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF312E81), Color(0xFF4F46E5)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primary.withAlpha(50),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'CAREER READINESS SCORE',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.white70,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${progress.placementReadinessScore}%',
                      style: const TextStyle(
                        fontSize: 38,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      progress.placementReadinessScore >= 70
                          ? 'Strong progress toward placement readiness.'
                          : 'Continue completing profile and roadmap milestones.',
                      style: TextStyle(fontSize: 13, color: Colors.white.withAlpha(220)),
                    ),
                  ],
                ),
              ),
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(30),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.emoji_events_outlined, color: Colors.white, size: 32),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 600;
            return GridView.count(
              crossAxisCount: isWide ? 3 : 1,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: isWide ? 1.6 : 2.6,
              children: [
                _MetricCard(
                  title: 'Profile Completeness',
                  value: '${progress.profileCompletion}%',
                  subtitle: profile.isComplete ? 'Profile well-rounded' : 'Add remaining details',
                  icon: Icons.person_outline,
                  color: AppTheme.primary,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                    );
                  },
                ),
                _MetricCard(
                  title: 'Roadmap Milestones',
                  value: '${progress.roadmapCompletedSteps} / ${progress.roadmapTotalSteps}',
                  subtitle: '${progress.roadmapPercentage}% completed',
                  icon: Icons.timeline,
                  color: AppTheme.success,
                  onTap: activeGuidance != null
                      ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const RoadmapScreen()),
                          );
                        }
                      : null,
                ),
                _MetricCard(
                  title: 'Guidance Sessions',
                  value: '${progress.guidanceCount}',
                  subtitle: progress.guidanceCount > 0 ? 'Guidance stored' : 'None generated',
                  icon: Icons.assessment_outlined,
                  color: AppTheme.secondary,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const GuidanceGeneratorScreen()),
                    );
                  },
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 28),

        if (activeGuidance != null) ...[
          const SectionHeader(
            title: 'Active Career Goal Target',
            subtitle: 'Milestones configured for your selected pathway',
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
                          activeGuidance.careerRecommendation.title,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.slate900,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const RoadmapScreen()),
                          );
                        },
                        child: const Text('Open Roadmap'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${progress.roadmapCompletedSteps} of ${progress.roadmapTotalSteps} milestones marked as completed',
                    style: const TextStyle(fontSize: 13, color: AppTheme.slate600),
                  ),
                  const SizedBox(height: 14),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: progress.roadmapProgressFraction,
                      minHeight: 8,
                      backgroundColor: AppTheme.slate100,
                      valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.success),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ] else ...[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Icon(Icons.explore_outlined, size: 40, color: AppTheme.slate400),
                  const SizedBox(height: 12),
                  const Text(
                    'No active roadmap yet',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.slate800),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Generate your first career guidance to track customized learning milestones.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: AppTheme.slate500),
                  ),
                  const SizedBox(height: 16),
                  PrimaryButton(
                    label: 'Get Career Guidance',
                    fullWidth: false,
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
          ),
        ],
        const SizedBox(height: 40),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.slate600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(icon, size: 20, color: color),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppTheme.slate900),
              ),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 12, color: AppTheme.slate500),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
