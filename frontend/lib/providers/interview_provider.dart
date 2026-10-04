import 'package:flutter/foundation.dart';
import '../models/interview.dart';
import '../services/api_service.dart';

class InterviewProvider extends ChangeNotifier {
  final ApiService _apiService;

  InterviewGenerateResponse? _session;
  int _currentQuestionIndex = 0;
  bool _isLoading = false;
  bool _isEvaluating = false;
  String? _errorMessage;
  final Map<String, InterviewEvaluateResponse> _evaluations = {};

  InterviewProvider(this._apiService);

  InterviewGenerateResponse? get session => _session;
  int get currentQuestionIndex => _currentQuestionIndex;
  bool get isLoading => _isLoading;
  bool get isEvaluating => _isEvaluating;
  String? get errorMessage => _errorMessage;

  InterviewQuestion? get currentQuestion {
    if (_session == null || _session!.questions.isEmpty) return null;
    if (_currentQuestionIndex >= 0 && _currentQuestionIndex < _session!.questions.length) {
      return _session!.questions[_currentQuestionIndex];
    }
    return null;
  }

  InterviewEvaluateResponse? get currentEvaluation {
    final q = currentQuestion;
    if (q == null) return null;
    return _evaluations[q.id];
  }

  bool get hasCompletedAll {
    if (_session == null || _session!.questions.isEmpty) return false;
    return _evaluations.length == _session!.questions.length;
  }

  int get completedCount => _evaluations.length;
  int get totalCount => _session?.questions.length ?? 0;

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void resetSession() {
    _session = null;
    _currentQuestionIndex = 0;
    _evaluations.clear();
    _errorMessage = null;
    _isLoading = false;
    _isEvaluating = false;
    notifyListeners();
  }

  void goToQuestion(int index) {
    if (_session != null && index >= 0 && index < _session!.questions.length) {
      _currentQuestionIndex = index;
      notifyListeners();
    }
  }

  Future<bool> startInterview({
    required String role,
    String experienceLevel = 'Fresher / Entry-Level',
    String interviewType = 'Mixed',
    List<String> skills = const [],
    int numQuestions = 4,
    String? authToken,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    _evaluations.clear();
    _currentQuestionIndex = 0;
    notifyListeners();

    try {
      final response = await _apiService.generateInterviewQuestions(
        role: role,
        experienceLevel: experienceLevel,
        interviewType: interviewType,
        skills: skills,
        numQuestions: numQuestions,
        authToken: authToken,
      );

      _session = response;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> submitAnswer({
    required String studentAnswer,
    String? authToken,
  }) async {
    final q = currentQuestion;
    if (_session == null || q == null) return false;

    _isEvaluating = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final eval = await _apiService.evaluateInterviewAnswer(
        role: _session!.role,
        question: q.question,
        category: q.category,
        studentAnswer: studentAnswer,
        authToken: authToken,
      );

      _evaluations[q.id] = eval;
      _isEvaluating = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isEvaluating = false;
      notifyListeners();
      return false;
    }
  }
}
