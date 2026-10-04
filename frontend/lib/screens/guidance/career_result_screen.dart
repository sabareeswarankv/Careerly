import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../models/career_guidance.dart';
import '../../providers/auth_provider.dart';
import '../../providers/guidance_provider.dart';
import '../../widgets/roadmap_tile.dart';
import '../../widgets/state_views.dart';

class CareerResultScreen extends StatefulWidget {
  final CareerGuidance guidance;

  const CareerResultScreen({
    super.key,
    required this.guidance,
  });

  @override
  State<CareerResultScreen> createState() => _CareerResultScreenState();
}

class _CareerResultScreenState extends State<CareerResultScreen> {
  late CareerGuidance _currentGuidance;

  @override
  void initState() {
    super.initState();
    _currentGuidance = widget.guidance;
  }

  @override
  Widget build(BuildContext context) {
    final guidanceProvider = context.watch<GuidanceProvider>();
    final activeGuidance = guidanceProvider.activeGuidance ?? _currentGuidance;
    final authUser = context.read<AuthProvider>().user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Career Guidance'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            tooltip: 'Share Guidance',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Guidance saved to your profile history.')),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 860),
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4F46E5), Color(0xFF6366F1)],
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
                padding: const EdgeInsets.all(28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(50),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.stars, color: Colors.white, size: 14),
                          SizedBox(width: 6),
                          Text(
                            'RECOMMENDED CAREER PATH',
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
                    const SizedBox(height: 14),
                    Text(
                      activeGuidance.careerRecommendation.title,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      activeGuidance.careerRecommendation.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withAlpha(235),
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              const SectionHeader(
                title: 'Why this fits you',
                subtitle: 'Key alignments identified between your profile and this role',
              ),
              const SizedBox(height: 12),
              Column(
                children: activeGuidance.whyItFits.map((reason) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppTheme.slate200),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withAlpha(20),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.check, color: AppTheme.primary, size: 16),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            reason,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppTheme.slate800,
                              height: 1.45,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              const SectionHeader(
                title: 'Your strengths',
                subtitle: 'Valuable foundational skills you already demonstrate',
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    children: activeGuidance.currentStrengths.map((str) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.verified, color: AppTheme.success, size: 18),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                str,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: AppTheme.slate800,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              const SectionHeader(
                title: 'Skills to improve',
                subtitle: 'Specific competencies to prioritize for this career path',
              ),
              const SizedBox(height: 12),
              Column(
                children: activeGuidance.skillGaps.map((gap) {
                  Color badgeColor;
                  switch (gap.status) {
                    case 'Strong':
                      badgeColor = AppTheme.success;
                      break;
                    case 'Needs Improvement':
                      badgeColor = AppTheme.error;
                      break;
                    default:
                      badgeColor = AppTheme.warning;
                  }

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppTheme.slate200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                gap.skill,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.slate900,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: badgeColor.withAlpha(20),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                gap.status,
                                style: TextStyle(
                                  color: badgeColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          gap.recommendation,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppTheme.slate600,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 28),

              const SectionHeader(
                title: 'Your learning roadmap',
                subtitle: 'Step-by-step milestones to prepare for your target career',
              ),
              const SizedBox(height: 16),
              ...activeGuidance.learningRoadmap.asMap().entries.map((entry) {
                final idx = entry.key;
                final step = entry.value;
                final isLast = idx == activeGuidance.learningRoadmap.length - 1;

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
              const SizedBox(height: 24),

              const SectionHeader(
                title: 'Placement Preparation',
                subtitle: 'Key interview and readiness recommendations across five pillars',
              ),
              const SizedBox(height: 12),
              ...activeGuidance.placementPreparation.map((prep) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: AppTheme.secondary.withAlpha(25),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.work_outline, color: AppTheme.secondary, size: 18),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              prep.area,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.slate900,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          prep.advice,
                          style: const TextStyle(
                            fontSize: 13.5,
                            color: AppTheme.slate700,
                            height: 1.5,
                          ),
                        ),
                        if (prep.keyTips.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          ...prep.keyTips.map((tip) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('• ', style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold)),
                                  Expanded(
                                    child: Text(
                                      tip,
                                      style: const TextStyle(fontSize: 12.5, color: AppTheme.slate600),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 24),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.slate100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline, color: AppTheme.slate500, size: 18),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        activeGuidance.disclaimer,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.slate600,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
