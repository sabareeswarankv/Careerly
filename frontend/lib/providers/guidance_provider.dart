import 'package:flutter/foundation.dart';
import '../models/career_guidance.dart';
import '../models/student_profile.dart';
import '../models/user_progress.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class GuidanceProvider extends ChangeNotifier {
  final ApiService _apiService;
  final StorageService _storageService;

  CareerGuidance? _activeGuidance;
  List<CareerGuidance> _savedGuidanceList = [];
  bool _isGenerating = false;
  String _generationStep = '';
  String? _errorMessage;

  GuidanceProvider(this._apiService, this._storageService);

  CareerGuidance? get activeGuidance => _activeGuidance;
  List<CareerGuidance> get savedGuidanceList => _savedGuidanceList;
  bool get isGenerating => _isGenerating;
  String get generationStep => _generationStep;
  String? get errorMessage => _errorMessage;

  void selectGuidance(CareerGuidance guidance) {
    _activeGuidance = guidance;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearGuidance() {
    _activeGuidance = null;
    _savedGuidanceList = [];
    _isGenerating = false;
    _generationStep = '';
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> generateCareerGuidance(
    StudentProfile profile, {
    String? authToken,
  }) async {
    _isGenerating = true;
    _errorMessage = null;
    _generationStep = 'Analyzing your profile...';
    notifyListeners();

    try {
      Future.delayed(const Duration(milliseconds: 1400), () {
        if (_isGenerating) {
          _generationStep = 'Evaluating your strengths and skill gaps...';
          notifyListeners();
        }
      });

      Future.delayed(const Duration(milliseconds: 3200), () {
        if (_isGenerating) {
          _generationStep = 'Designing personalized learning roadmap...';
          notifyListeners();
        }
      });

      Future.delayed(const Duration(milliseconds: 5000), () {
        if (_isGenerating) {
          _generationStep = 'Finalizing placement & interview recommendations...';
          notifyListeners();
        }
      });

      final result = await _apiService.generateCareerGuidance(profile, authToken: authToken);
      _activeGuidance = result;

      await _storageService.saveGuidance(profile.uid, result);
      await loadSavedGuidances(profile.uid);

      _isGenerating = false;
      _generationStep = '';
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isGenerating = false;
      _generationStep = '';
      notifyListeners();
      return false;
    }
  }

  Future<void> loadSavedGuidances(String uid) async {
    try {
      final list = await _storageService.getSavedGuidance(uid);
      _savedGuidanceList = list;
      if (_activeGuidance == null && list.isNotEmpty) {
        _activeGuidance = list.first;
      }
      notifyListeners();
    } catch (_) {}
  }

  Future<void> toggleRoadmapStep(String uid, int stepNumber, bool isCompleted) async {
    if (_activeGuidance == null) return;

    final updatedRoadmap = _activeGuidance!.learningRoadmap.map((s) {
      if (s.step == stepNumber) {
        return s.copyWith(isCompleted: isCompleted);
      }
      return s;
    }).toList();

    _activeGuidance = _activeGuidance!.copyWith(learningRoadmap: updatedRoadmap);
    notifyListeners();

    await _storageService.updateRoadmapStep(uid, _activeGuidance!.id, stepNumber, isCompleted);
  }

  UserProgress calculateProgress(StudentProfile? profile) {
    final profileComp = profile?.completionPercentage ?? 0;
    final guidanceCount = _savedGuidanceList.length;

    int completedSteps = 0;
    int totalSteps = 0;

    if (_activeGuidance != null) {
      totalSteps = _activeGuidance!.learningRoadmap.length;
      completedSteps = _activeGuidance!.learningRoadmap.where((s) => s.isCompleted).length;
    }

    int readiness = 0;
    if (profileComp > 0) readiness += (profileComp * 0.3).round();
    if (guidanceCount > 0) readiness += 20;
    if (totalSteps > 0) {
      final roadmapRatio = completedSteps / totalSteps;
      readiness += (roadmapRatio * 50).round();
    }

    return UserProgress(
      profileCompletion: profileComp,
      guidanceCount: guidanceCount,
      roadmapCompletedSteps: completedSteps,
      roadmapTotalSteps: totalSteps,
      placementReadinessScore: readiness.clamp(0, 100),
    );
  }
}
