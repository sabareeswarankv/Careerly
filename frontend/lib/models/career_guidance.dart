List<String> _toStringList(dynamic val) {
  if (val is List) {
    return val.map((e) => e.toString()).toList();
  }
  return [];
}

class CareerRecommendation {
  final String title;
  final String description;

  CareerRecommendation({
    required this.title,
    required this.description,
  });

  factory CareerRecommendation.fromJson(Map<String, dynamic> json) {
    return CareerRecommendation(
      title: json['title'] as String? ?? 'Career Path',
      description: json['description'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
      };
}

class SkillGap {
  final String skill;
  final String status;
  final String recommendation;

  SkillGap({
    required this.skill,
    required this.status,
    required this.recommendation,
  });

  factory SkillGap.fromJson(Map<String, dynamic> json) {
    return SkillGap(
      skill: json['skill'] as String? ?? '',
      status: json['status'] as String? ?? 'Developing',
      recommendation: json['recommendation'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'skill': skill,
        'status': status,
        'recommendation': recommendation,
      };
}

class RoadmapStep {
  final int step;
  final String title;
  final String description;
  final List<String> skillsToLearn;
  final String estimatedTimeline;
  final bool isCompleted;

  RoadmapStep({
    required this.step,
    required this.title,
    required this.description,
    this.skillsToLearn = const [],
    required this.estimatedTimeline,
    this.isCompleted = false,
  });

  RoadmapStep copyWith({bool? isCompleted}) {
    return RoadmapStep(
      step: step,
      title: title,
      description: description,
      skillsToLearn: skillsToLearn,
      estimatedTimeline: estimatedTimeline,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  factory RoadmapStep.fromJson(Map<String, dynamic> json) {
    return RoadmapStep(
      step: (json['step'] is num) ? (json['step'] as num).toInt() : 1,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      skillsToLearn: _toStringList(json['skills_to_learn'] ?? json['skillsToLearn']),
      estimatedTimeline: (json['estimated_timeline'] ?? json['estimatedTimeline'] ?? '2-3 weeks') as String,
      isCompleted: json['isCompleted'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'step': step,
        'title': title,
        'description': description,
        'skills_to_learn': skillsToLearn,
        'estimated_timeline': estimatedTimeline,
        'isCompleted': isCompleted,
      };
}

class PlacementPrepItem {
  final String area;
  final String advice;
  final List<String> keyTips;

  PlacementPrepItem({
    required this.area,
    required this.advice,
    this.keyTips = const [],
  });

  factory PlacementPrepItem.fromJson(Map<String, dynamic> json) {
    return PlacementPrepItem(
      area: json['area'] as String? ?? 'Preparation',
      advice: json['advice'] as String? ?? '',
      keyTips: _toStringList(json['key_tips'] ?? json['keyTips']),
    );
  }

  Map<String, dynamic> toJson() => {
        'area': area,
        'advice': advice,
        'key_tips': keyTips,
      };
}

class CareerGuidance {
  final String id;
  final CareerRecommendation careerRecommendation;
  final List<String> whyItFits;
  final List<String> currentStrengths;
  final List<SkillGap> skillGaps;
  final List<RoadmapStep> learningRoadmap;
  final List<PlacementPrepItem> placementPreparation;
  final String disclaimer;
  final String createdAt;

  CareerGuidance({
    required this.id,
    required this.careerRecommendation,
    required this.whyItFits,
    required this.currentStrengths,
    required this.skillGaps,
    required this.learningRoadmap,
    required this.placementPreparation,
    required this.disclaimer,
    required this.createdAt,
  });

  CareerGuidance copyWith({
    List<RoadmapStep>? learningRoadmap,
  }) {
    return CareerGuidance(
      id: id,
      careerRecommendation: careerRecommendation,
      whyItFits: whyItFits,
      currentStrengths: currentStrengths,
      skillGaps: skillGaps,
      learningRoadmap: learningRoadmap ?? this.learningRoadmap,
      placementPreparation: placementPreparation,
      disclaimer: disclaimer,
      createdAt: createdAt,
    );
  }

  factory CareerGuidance.fromJson(Map<String, dynamic> json, {String? id}) {
    return CareerGuidance(
      id: id ?? json['id'] as String? ?? DateTime.now().millisecondsSinceEpoch.toString(),
      careerRecommendation: CareerRecommendation.fromJson(
        (json['career_recommendation'] ?? json['careerRecommendation'] ?? {}) as Map<String, dynamic>,
      ),
      whyItFits: _toStringList(json['why_it_fits'] ?? json['whyItFits']),
      currentStrengths: _toStringList(json['current_strengths'] ?? json['currentStrengths']),
      skillGaps: ((json['skill_gaps'] ?? json['skillGaps']) as List<dynamic>?)
              ?.map((e) => SkillGap.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      learningRoadmap: ((json['learning_roadmap'] ?? json['learningRoadmap']) as List<dynamic>?)
              ?.map((e) => RoadmapStep.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      placementPreparation: ((json['placement_preparation'] ?? json['placementPreparation']) as List<dynamic>?)
              ?.map((e) => PlacementPrepItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      disclaimer: json['disclaimer'] as String? ??
          'Guidance and suggestions are based on your profile to help guide your preparation. Outcomes depend on your dedication and practice.',
      createdAt: json['createdAt'] as String? ?? DateTime.now().toIso8601String(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'careerRecommendation': careerRecommendation.toJson(),
        'whyItFits': whyItFits,
        'currentStrengths': currentStrengths,
        'skillGaps': skillGaps.map((e) => e.toJson()).toList(),
        'learningRoadmap': learningRoadmap.map((e) => e.toJson()).toList(),
        'placementPreparation': placementPreparation.map((e) => e.toJson()).toList(),
        'disclaimer': disclaimer,
        'createdAt': createdAt,
      };
}
