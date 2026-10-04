import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../providers/guidance_provider.dart';
import '../../widgets/state_views.dart';
import '../guidance/guidance_generator_screen.dart';

class PlacementScreen extends StatefulWidget {
  const PlacementScreen({super.key});

  @override
  State<PlacementScreen> createState() => _PlacementScreenState();
}

class _PlacementScreenState extends State<PlacementScreen> {
  String _selectedCategory = 'All';

  final List<String> _categories = [
    'All',
    'Aptitude',
    'Technical Interview',
    'Coding',
    'HR Interview',
    'Resume'
  ];

  @override
  Widget build(BuildContext context) {
    final guidanceProvider = context.watch<GuidanceProvider>();
    final activeGuidance = guidanceProvider.activeGuidance;

    if (activeGuidance == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Placement Preparation')),
        body: EmptyState(
          icon: Icons.work_outline,
          title: 'No placement guidance yet',
          description:
              'Generate your personalized career guidance to get actionable preparation advice for your interviews.',
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

    final allItems = activeGuidance.placementPreparation;
    final filtered = _selectedCategory == 'All'
        ? allItems
        : allItems.where((p) => p.area.toLowerCase().contains(_selectedCategory.toLowerCase())).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Placement Preparation'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 860),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _categories.map((cat) {
                      final isSelected = _selectedCategory == cat;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(cat),
                          selected: isSelected,
                          onSelected: (_) => setState(() => _selectedCategory = cat),
                          selectedColor: AppTheme.primary.withAlpha(25),
                          checkmarkColor: AppTheme.primary,
                          labelStyle: TextStyle(
                            fontSize: 13,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                            color: isSelected ? AppTheme.primaryDark : AppTheme.slate700,
                          ),
                          side: BorderSide(
                            color: isSelected ? AppTheme.primary : AppTheme.slate200,
                          ),
                          backgroundColor: Colors.white,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const Divider(height: 1),

              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final prep = filtered[index];
                    IconData icon;
                    Color color;

                    if (prep.area.toLowerCase().contains('coding')) {
                      icon = Icons.code;
                      color = const Color(0xFF0EA5E9);
                    } else if (prep.area.toLowerCase().contains('technical')) {
                      icon = Icons.terminal;
                      color = const Color(0xFF6366F1);
                    } else if (prep.area.toLowerCase().contains('aptitude')) {
                      icon = Icons.calculate_outlined;
                      color = const Color(0xFFF59E0B);
                    } else if (prep.area.toLowerCase().contains('hr')) {
                      icon = Icons.groups_outlined;
                      color = const Color(0xFF10B981);
                    } else {
                      icon = Icons.description_outlined;
                      color = const Color(0xFF8B5CF6);
                    }

                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
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
                                    color: color.withAlpha(20),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(icon, color: color, size: 20),
                                ),
                                const SizedBox(width: 14),
                                Text(
                                  prep.area,
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.slate900,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Text(
                              prep.advice,
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppTheme.slate700,
                                height: 1.5,
                              ),
                            ),
                            if (prep.keyTips.isNotEmpty) ...[
                              const SizedBox(height: 14),
                              const Text(
                                'Recommended Action Items & Tips:',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.slate500,
                                  letterSpacing: 0.2,
                                ),
                              ),
                              const SizedBox(height: 8),
                              ...prep.keyTips.map((tip) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 6),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Icon(Icons.arrow_right, size: 20, color: AppTheme.primary),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          tip,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: AppTheme.slate700,
                                            height: 1.4,
                                          ),
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
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
