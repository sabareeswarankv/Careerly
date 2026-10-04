import 'package:flutter_test/flutter_test.dart';
import 'package:careerly/models/student_profile.dart';
import 'package:careerly/models/career_guidance.dart';
import 'package:careerly/models/interview.dart';
import 'package:careerly/models/resume.dart';
import 'package:careerly/models/user_progress.dart';

void main() {
  group('StudentProfile Model Tests', () {
    test('serialization and completion score', () {
      final profile = StudentProfile(
        uid: 'student_123',
        fullName: 'Alex Kumar',
        email: 'alex@example.com',
        degree: 'B.Tech',
        department: 'Computer Science Engineering',
        semester: 6,
        cgpa: 8.5,
        skills: ['Python', 'SQL', 'C++'],
        interests: ['Artificial Intelligence'],
        careerGoal: 'AI / ML Engineer',
      );

      final json = profile.toJson();
      expect(json['uid'], 'student_123');
      expect(json['fullName'], 'Alex Kumar');
      expect(json['skills'], contains('Python'));
      expect(profile.completionPercentage, 100);
      expect(profile.isComplete, isTrue);

      final deserialized = StudentProfile.fromJson(json);
      expect(deserialized.uid, profile.uid);
      expect(deserialized.careerGoal, 'AI / ML Engineer');
      expect(deserialized.semester, 6);
    });

    test('incomplete profile calculation', () {
      final incomplete = StudentProfile(
        uid: 'user_new',
        fullName: 'New User',
        email: 'new@example.com',
        degree: '',
        department: '',
        semester: 1,
        cgpa: 0.0,
        careerGoal: '',
      );

      expect(incomplete.completionPercentage, lessThan(50));
      expect(incomplete.isComplete, isFalse);
    });
  });

  group('CareerGuidance Model Tests', () {
    test('deserialize complete career guidance payload', () {
      final payload = {
        'id': 'guidance_001',
        'careerRecommendation': {
          'title': 'Machine Learning Engineer',
          'description': 'Design, train, and deploy AI models.',
        },
        'whyItFits': [
          'Strong proficiency in Python',
          'Interest in Artificial Intelligence',
        ],
        'currentStrengths': [
          'Solid fundamentals in data structures',
        ],
        'skillGaps': [
          {
            'skill': 'PyTorch',
            'status': 'Developing',
            'recommendation': 'Build and train a neural network project.',
          }
        ],
        'learningRoadmap': [
          {
            'step': 1,
            'title': 'Foundation & Mathematics',
            'description': 'Master linear algebra and statistical learning.',
            'skillsToLearn': ['NumPy', 'Pandas'],
            'estimatedTimeline': '3 weeks',
            'isCompleted': false,
          }
        ],
        'placementPreparation': [
          {
            'area': 'Technical Interview',
            'advice': 'Practice explaining backpropagation and optimization algorithms.',
            'keyTips': ['Focus on trade-offs', 'Explain complexity'],
          }
        ],
        'disclaimer': 'Guidance and suggestions are based on your profile.',
        'createdAt': '2026-10-03T12:00:00Z',
      };

      final guidance = CareerGuidance.fromJson(payload);
      expect(guidance.careerRecommendation.title, 'Machine Learning Engineer');
      expect(guidance.whyItFits.length, 2);
      expect(guidance.skillGaps.first.status, 'Developing');
      expect(guidance.learningRoadmap.first.title, 'Foundation & Mathematics');
      expect(guidance.placementPreparation.first.area, 'Technical Interview');

      final serialized = guidance.toJson();
      expect(serialized['careerRecommendation']['title'], 'Machine Learning Engineer');
    });
  });

  group('UserProgress Model Tests', () {
    test('progress calculations', () {
      final progress = UserProgress(
        profileCompletion: 85,
        guidanceCount: 1,
        roadmapCompletedSteps: 2,
        roadmapTotalSteps: 5,
        placementReadinessScore: 75,
      );

      expect(progress.roadmapPercentage, 40);
      expect(progress.roadmapProgressFraction, 0.4);
      expect(progress.placementReadinessScore, 75);
    });
  });

  group('Interview Models Tests', () {
    test('deserialize and serialize interview question', () {
      final json = {
        'id': 'q1',
        'question': 'What are microservices?',
        'category': 'Technical',
        'context_hint': 'Assess architectural understanding',
        'sample_approach': 'Discuss decoupling, API gateways, independent deployment',
      };

      final q = InterviewQuestion.fromJson(json);
      expect(q.id, 'q1');
      expect(q.question, 'What are microservices?');
      expect(q.category, 'Technical');

      final serialized = q.toJson();
      expect(serialized['id'], 'q1');
    });

    test('deserialize interview evaluation', () {
      final json = {
        'score': 88,
        'verdict': 'Strong',
        'strengths': ['Clear explanation', 'Good real-world example'],
        'areas_for_improvement': ['Mention service mesh'],
        'suggested_ideal_answer': 'Microservices architecture structures an application...',
        'communication_tips': ['Use bulleted structure'],
      };

      final eval = InterviewEvaluateResponse.fromJson(json);
      expect(eval.score, 88);
      expect(eval.verdict, 'Strong');
      expect(eval.strengths.length, 2);
    });
  });

  group('Resume ATS Model Tests', () {
    test('deserialize ATS analysis response', () {
      final json = {
        'ats_score': 82,
        'verdict': 'Strong Fit',
        'matching_skills': ['Flutter', 'FastAPI'],
        'missing_critical_skills': ['Docker'],
        'formatting_feedback': ['Quantify project impact'],
        'bullet_optimizations': [
          {
            'original_text': 'Built a website',
            'optimized_text': 'Designed and launched responsive web platform for 1k users',
            'reason': 'Added scale and impact',
          }
        ],
        'executive_summary': 'Promising engineering candidate.',
      };

      final res = AtsAnalyzeResponse.fromJson(json);
      expect(res.atsScore, 82);
      expect(res.bulletOptimizations.first.reason, 'Added scale and impact');
    });
  });
}
