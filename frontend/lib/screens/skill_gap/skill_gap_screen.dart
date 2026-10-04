import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../providers/guidance_provider.dart';
import '../../widgets/state_views.dart';
import '../guidance/guidance_generator_screen.dart';

class SkillGapScreen extends StatelessWidget {
  const SkillGapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final guidanceProvider = context.watch<GuidanceProvider>();
    final activeGuidance = guidanceProvider.activeGuidance;

    if (activeGuidance == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Skill Development')),
        body: EmptyState(
          icon: Icons.psychology_outlined,
          title: 'No skill analysis yet',
          description: 'Generate your personalized career guidance to identify current strengths and skill gaps.',
          buttonLabel: 'Get Career Guidance',
          onAction: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const GuidanceGeneratorScreen()),
            );
          },
        ),
      );
    }

    final strengths = activeGuidance.currentStrengths;
    final gaps = activeGuidance.skillGaps;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Build the right skills'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 860),
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withAlpha(15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.primary.withAlpha(40)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppTheme.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.bolt, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Target Role Alignment',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.primaryDark),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            activeGuidance.careerRecommendation.title,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.slate900),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              const SectionHeader(
                title: 'Current strengths',
                subtitle: 'Skills you already possess that give you an advantage',
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    children: strengths.map((s) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.check_circle, color: AppTheme.success, size: 20),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                s,
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppTheme.slate800),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 28),

              const SectionHeader(
                title: 'Skills to develop & improve',
                subtitle: 'Key technical competencies recommended for this career pathway',
              ),
              const SizedBox(height: 12),
              ...gaps.map((gap) {
                Color statusColor;
                IconData statusIcon;
                switch (gap.status) {
                  case 'Strong':
                    statusColor = AppTheme.success;
                    statusIcon = Icons.star_outline;
                    break;
                  case 'Needs Improvement':
                    statusColor = AppTheme.error;
                    statusIcon = Icons.priority_high;
                    break;
                  default:
                    statusColor = AppTheme.warning;
                    statusIcon = Icons.hourglass_top;
                }

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                gap.skill,
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.slate900),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: statusColor.withAlpha(20),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(statusIcon, size: 14, color: statusColor),
                                  const SizedBox(width: 4),
                                  Text(
                                    gap.status,
                                    style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.w700),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          gap.recommendation,
                          style: const TextStyle(fontSize: 13.5, color: AppTheme.slate700, height: 1.45),
                        ),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
