class BulletOptimization {
  final String originalText;
  final String optimizedText;
  final String reason;

  const BulletOptimization({
    required this.originalText,
    required this.optimizedText,
    required this.reason,
  });

  factory BulletOptimization.fromJson(Map<String, dynamic> json) {
    return BulletOptimization(
      originalText: json['original_text'] as String? ?? json['originalText'] as String? ?? '',
      optimizedText: json['optimized_text'] as String? ?? json['optimizedText'] as String? ?? '',
      reason: json['reason'] as String? ?? '',
    );
  }
}

class AtsAnalyzeResponse {
  final int atsScore;
  final String verdict;
  final List<String> matchingSkills;
  final List<String> missingCriticalSkills;
  final List<String> formattingFeedback;
  final List<BulletOptimization> bulletOptimizations;
  final String executiveSummary;

  const AtsAnalyzeResponse({
    required this.atsScore,
    required this.verdict,
    required this.matchingSkills,
    required this.missingCriticalSkills,
    required this.formattingFeedback,
    required this.bulletOptimizations,
    required this.executiveSummary,
  });

  factory AtsAnalyzeResponse.fromJson(Map<String, dynamic> json) {
    final rawOptimizations = json['bullet_optimizations'] as List<dynamic>? ?? [];

    return AtsAnalyzeResponse(
      atsScore: (json['ats_score'] as num?)?.toInt() ?? 0,
      verdict: json['verdict'] as String? ?? 'Moderate Fit',
      matchingSkills: (json['matching_skills'] as List<dynamic>?)?.map((s) => s.toString()).toList() ?? [],
      missingCriticalSkills: (json['missing_critical_skills'] as List<dynamic>?)?.map((s) => s.toString()).toList() ?? [],
      formattingFeedback: (json['formatting_feedback'] as List<dynamic>?)?.map((s) => s.toString()).toList() ?? [],
      bulletOptimizations: rawOptimizations.map((b) => BulletOptimization.fromJson(b as Map<String, dynamic>)).toList(),
      executiveSummary: json['executive_summary'] as String? ?? '',
    );
  }
}
