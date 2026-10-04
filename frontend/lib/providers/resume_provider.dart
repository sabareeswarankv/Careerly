import 'package:flutter/foundation.dart';
import '../models/resume.dart';
import '../services/api_service.dart';

class ResumeProvider extends ChangeNotifier {
  final ApiService _apiService;

  AtsAnalyzeResponse? _atsResult;
  bool _isAnalyzing = false;
  bool _isExtractingFile = false;
  String? _errorMessage;

  ResumeProvider(this._apiService);

  AtsAnalyzeResponse? get atsResult => _atsResult;
  bool get isAnalyzing => _isAnalyzing;
  bool get isExtractingFile => _isExtractingFile;
  String? get errorMessage => _errorMessage;

  void clearResult() {
    _atsResult = null;
    _errorMessage = null;
    _isAnalyzing = false;
    _isExtractingFile = false;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<String?> extractFileText({
    required List<int> bytes,
    required String fileName,
    String? authToken,
  }) async {
    _isExtractingFile = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final text = await _apiService.extractResumeTextFromFile(
        fileBytes: bytes,
        fileName: fileName,
        authToken: authToken,
      );
      _isExtractingFile = false;
      notifyListeners();
      return text;
    } catch (e) {
      _errorMessage = e.toString();
      _isExtractingFile = false;
      notifyListeners();
      return null;
    }
  }

  Future<bool> analyzeResume({
    required String resumeText,
    required String targetRole,
    String jobDescription = '',
    String? authToken,
  }) async {
    _isAnalyzing = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _apiService.analyzeResumeAts(
        resumeText: resumeText,
        targetRole: targetRole,
        jobDescription: jobDescription,
        authToken: authToken,
      );

      _atsResult = result;
      _isAnalyzing = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isAnalyzing = false;
      notifyListeners();
      return false;
    }
  }
}
