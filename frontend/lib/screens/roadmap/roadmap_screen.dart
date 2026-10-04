import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/guidance_provider.dart';
import '../../widgets/roadmap_tile.dart';
import '../../widgets/state_views.dart';
import '../guidance/guidance_generator_screen.dart';

class RoadmapScreen extends StatelessWidget {
  const RoadmapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final guidanceProvider = context.watch<GuidanceProvider>();
    final activeGuidance = guidanceProvider.activeGuidance;
    final authUser = context.read<AuthProvider>().user;

    if (activeGuidance == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Learning Roadmap')),
        body: EmptyState(
          icon: Icons.timeline,
          title: 'No learning roadmap yet',
          description: 'Generate your career guidance to receive a personalized, step-by-step learning roadmap.',
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

    final roadmap = activeGuidance.learningRoadmap;
    final completedCount = roadmap.where((s) => s.isCompleted).length;
    final totalCount = roadmap.length;
    final progressFraction = totalCount > 0 ? (completedCount / totalCount) : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Learning Roadmap'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 860),
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            children: [
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.slate200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              activeGuidance.careerRecommendation.title,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.slate900,
                              ),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'Personalized Learning Pathway',
                              style: TextStyle(fontSize: 13, color: AppTheme.slate500),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withAlpha(20),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '$completedCount of $totalCount Completed',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.primaryDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: progressFraction,
                        minHeight: 8,
                        backgroundColor: AppTheme.slate100,
                        valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.success),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              const SectionHeader(
                title: 'Roadmap Milestones',
                subtitle: 'Check off steps as you complete them to track your learning journey',
              ),
              const SizedBox(height: 16),

              ...roadmap.asMap().entries.map((entry) {
                final idx = entry.key;
                final step = entry.value;
                final isLast = idx == roadmap.length - 1;

                return RoadmapTile(
                  step: step,
                  isLast: isLast,
                  onToggleCompleted: (done) {
                    if (authUser != null) {
                      guidanceProvider.toggleRoadmapStep(
                        authUser.uid,
                        step.step,
                        done,
                      );
                    }
                  },
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
