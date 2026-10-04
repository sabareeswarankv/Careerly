import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:careerly/widgets/feature_card.dart';
import 'package:careerly/widgets/roadmap_tile.dart';
import 'package:careerly/widgets/state_views.dart';
import 'package:careerly/models/career_guidance.dart';

void main() {
  testWidgets('FeatureCard displays content and triggers tap callback', (WidgetTester tester) async {
    bool tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FeatureCard(
            title: 'Skill Development',
            description: 'Identify skills to build next',
            icon: Icons.psychology,
            iconColor: Colors.blue,
            onTap: () => tapped = true,
          ),
        ),
      ),
    );

    expect(find.text('Skill Development'), findsOneWidget);
    expect(find.text('Identify skills to build next'), findsOneWidget);
    expect(find.text('Explore'), findsOneWidget);

    await tester.tap(find.text('Skill Development'));
    expect(tapped, isTrue);
  });

  testWidgets('RoadmapTile renders step and responds to completion toggle', (WidgetTester tester) async {
    bool? newStatus;
    final step = RoadmapStep(
      step: 1,
      title: 'Foundation Phase',
      description: 'Master core programming fundamentals.',
      skillsToLearn: ['Python', 'Git'],
      estimatedTimeline: '2 weeks',
      isCompleted: false,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RoadmapTile(
            step: step,
            isLast: false,
            onToggleCompleted: (val) => newStatus = val,
          ),
        ),
      ),
    );

    expect(find.text('Foundation Phase'), findsOneWidget);
    expect(find.text('Python'), findsOneWidget);
    expect(find.text('Git'), findsOneWidget);

    // Tap checkbox
    await tester.tap(find.byType(Checkbox));
    await tester.pump();

    expect(newStatus, isTrue);
  });

  testWidgets('EmptyState displays title, message, and button', (WidgetTester tester) async {
    bool buttonPressed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: EmptyState(
            title: 'No Guidance Yet',
            description: 'Complete your profile to generate guidance.',
            buttonLabel: 'Get Started',
            onAction: () => buttonPressed = true,
          ),
        ),
      ),
    );

    expect(find.text('No Guidance Yet'), findsOneWidget);
    expect(find.text('Complete your profile to generate guidance.'), findsOneWidget);
    expect(find.text('Get Started'), findsOneWidget);

    await tester.tap(find.text('Get Started'));
    expect(buttonPressed, isTrue);
  });
}
