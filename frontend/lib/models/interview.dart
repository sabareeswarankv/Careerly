class InterviewQuestion {
  final String id;
  final String question;
  final String category;
  final String contextHint;
  final String sampleApproach;

  const InterviewQuestion({
    required this.id,
    required this.question,
    required this.category,
    required this.contextHint,
    required this.sampleApproach,
  });

  factory InterviewQuestion.fromJson(Map<String, dynamic> json) {
    return InterviewQuestion(
      id: json['id'] as String? ?? 'q',
      question: json['question'] as String? ?? '',
      category: json['category'] as String? ?? 'Technical',
      contextHint: json['context_hint'] as String? ?? json['contextHint'] as String? ?? '',
      sampleApproach: json['sample_approach'] as String? ?? json['sampleApproach'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'category': category,
      'context_hint': contextHint,
      'sample_approach': sampleApproach,
    };
  }
}

class InterviewGenerateResponse {
  final String role;
  final String interviewType;
  final List<InterviewQuestion> questions;

  const InterviewGenerateResponse({
    required this.role,
    required this.interviewType,
    required this.questions,
  });

  factory InterviewGenerateResponse.fromJson(Map<String, dynamic> json) {
    final rawQuestions = json['questions'] as List<dynamic>? ?? [];
    return InterviewGenerateResponse(
      role: json['role'] as String? ?? '',
      interviewType: json['interview_type'] as String? ?? json['interviewType'] as String? ?? 'Technical',
      questions: rawQuestions.map((q) => InterviewQuestion.fromJson(q as Map<String, dynamic>)).toList(),
    );
  }
}

class InterviewEvaluateResponse {
  final int score;
  final String verdict;
  final List<String> strengths;
  final List<String> areasForImprovement;
  final String suggestedIdealAnswer;
  final List<String> communicationTips;

  const InterviewEvaluateResponse({
    required this.score,
    required this.verdict,
    required this.strengths,
    required this.areasForImprovement,
    required this.suggestedIdealAnswer,
    required this.communicationTips,
  });

  factory InterviewEvaluateResponse.fromJson(Map<String, dynamic> json) {
    return InterviewEvaluateResponse(
      score: (json['score'] as num?)?.toInt() ?? 0,
      verdict: json['verdict'] as String? ?? 'Needs Review',
      strengths: (json['strengths'] as List<dynamic>?)?.map((s) => s.toString()).toList() ?? [],
      areasForImprovement: (json['areas_for_improvement'] as List<dynamic>?)?.map((s) => s.toString()).toList() ?? [],
      suggestedIdealAnswer: json['suggested_ideal_answer'] as String? ?? '',
      communicationTips: (json['communication_tips'] as List<dynamic>?)?.map((s) => s.toString()).toList() ?? [],
    );
  }
}
