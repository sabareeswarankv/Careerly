import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../config/app_theme.dart';
import '../../providers/guidance_provider.dart';
import '../../widgets/state_views.dart';
import 'career_result_screen.dart';
import 'guidance_generator_screen.dart';

class SavedGuidanceScreen extends StatelessWidget {
  const SavedGuidanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final guidanceProvider = context.watch<GuidanceProvider>();
    final list = guidanceProvider.savedGuidanceList;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Career Guidance'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: list.isEmpty
              ? EmptyState(
                  icon: Icons.bookmark_border,
                  title: 'No saved guidance yet',
                  description:
                      'Complete your profile and generate personalized AI career guidance to view it here.',
                  buttonLabel: 'Generate Guidance',
                  onAction: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const GuidanceGeneratorScreen()),
                    );
                  },
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final item = list[index];
                    DateTime parsedDate;
                    try {
                      parsedDate = DateTime.parse(item.createdAt);
                    } catch (_) {
                      parsedDate = DateTime.now();
                    }
                    final formattedDate = DateFormat('MMM dd, yyyy • hh:mm a').format(parsedDate);

                    return Card(
                      margin: const EdgeInsets.only(bottom: 14),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          guidanceProvider.selectGuidance(item);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CareerResultScreen(guidance: item),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppTheme.primary.withAlpha(20),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      formattedDate,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme.primaryDark,
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                  const Icon(Icons.arrow_forward_ios, size: 14, color: AppTheme.slate400),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                item.careerRecommendation.title,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.slate900,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                item.careerRecommendation.description,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppTheme.slate600,
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  _MetaTag(
                                    icon: Icons.checklist,
                                    label: '${item.learningRoadmap.where((s) => s.isCompleted).length}/${item.learningRoadmap.length} Milestones',
                                  ),
                                  const SizedBox(width: 12),
                                  _MetaTag(
                                    icon: Icons.psychology_outlined,
                                    label: '${item.skillGaps.length} Skill Evaluations',
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }
}

class _MetaTag extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MetaTag({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppTheme.slate500),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppTheme.slate600),
        ),
      ],
    );
  }
}
