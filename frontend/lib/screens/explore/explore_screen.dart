import 'package:flutter/material.dart';
import '../../config/app_theme.dart';
import '../guidance/guidance_generator_screen.dart';
import '../interview/interview_screen.dart';
import '../placement/placement_screen.dart';
import '../resume/ats_analyzer_screen.dart';
import '../roadmap/roadmap_screen.dart';
import '../skill_gap/skill_gap_screen.dart';
import '../../widgets/feature_card.dart';

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      children: [
        const Text(
          'Explore Career Pathways',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: AppTheme.slate900,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Discover personalized pathways, essential skill sets, and interview prep.',
          style: TextStyle(fontSize: 14, color: AppTheme.slate500),
        ),
        const SizedBox(height: 24),

        LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 600;
            final count = isWide ? 2 : 1;

            return GridView.count(
              crossAxisCount: count,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: isWide ? 1.5 : 1.7,
              children: [
                FeatureCard(
                  title: 'Career Recommendations',
                  description:
                      'Analyze your current academic profile and technical skills to discover high-fit career paths.',
                  icon: Icons.school_outlined,
                  iconColor: AppTheme.primary,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const GuidanceGeneratorScreen()),
                    );
                  },
                ),
                FeatureCard(
                  title: 'Skill Development',
                  description:
                      'Map your existing proficiencies against modern industry expectations to pinpoint target growth areas.',
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
                  title: 'Learning Roadmaps',
                  description:
                      'Follow a structured, milestone-driven pathway organized from foundational concepts to advanced projects.',
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
                  title: 'Placement Preparation',
                  description:
                      'Sharpen your readiness across technical rounds, DSA problems, core fundamentals, and HR interviews.',
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
                  title: 'AI Mock Interviewer',
                  description:
                      'Practice real technical, logic, and HR interview questions with instant AI scoring and ideal answers.',
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
                  title: 'Resume ATS Matcher',
                  description:
                      'Benchmark your resume against target roles, identify keyword gaps, and get STAR-optimized bullet points.',
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

        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Popular Engineering Pathways',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.slate900,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'High-demand domains students frequently explore in Careerly',
                  style: TextStyle(fontSize: 13, color: AppTheme.slate500),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: const [
                    _RolePill('AI & Machine Learning'),
                    _RolePill('Data Science & Analytics'),
                    _RolePill('Full Stack Development'),
                    _RolePill('Cloud Solutions'),
                    _RolePill('Mobile App Engineering'),
                    _RolePill('DevOps & Infrastructure'),
                    _RolePill('Cybersecurity'),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }
}

class _RolePill extends StatelessWidget {
  final String label;

  const _RolePill(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.slate100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppTheme.slate700,
        ),
      ),
    );
  }
}
