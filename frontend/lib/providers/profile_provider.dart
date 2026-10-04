import 'package:flutter/foundation.dart';
import '../models/student_profile.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class ProfileProvider extends ChangeNotifier {
  final StorageService _storageService;
  final ApiService _apiService;

  StudentProfile? _profile;
  bool _isLoading = false;
  String? _errorMessage;

  ProfileProvider(this._storageService, this._apiService);

  StudentProfile? get profile => _profile;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  bool get hasProfile => _profile != null && _profile!.fullName.isNotEmpty;

  Future<void> loadProfile(String uid, {String? userEmail, String? userDisplayName}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      StudentProfile? existing = await _storageService.getProfile(uid);

      existing ??= await _apiService.getProfile(uid);

      if (existing != null) {
        _profile = existing;
      } else {
        _profile = StudentProfile(
          uid: uid,
          fullName: userDisplayName ?? '',
          email: userEmail ?? '',
          degree: 'B.Tech',
          department: 'Computer Science Engineering',
          semester: 5,
          cgpa: 8.0,
          skills: [],
          nonTechnicalSkills: [],
          interests: [],
          careerGoal: '',
          preferredRoles: [],
          improvementAreas: [],
          createdAt: DateTime.now().toIso8601String(),
        );
      }
    } catch (e) {
      _errorMessage = 'Failed to load student profile: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> saveProfile(StudentProfile updatedProfile, {String? authToken}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final now = DateTime.now().toIso8601String();
      final profileToSave = updatedProfile.copyWith(
        updatedAt: now,
        createdAt: updatedProfile.createdAt ?? now,
      );

      await _storageService.saveProfile(profileToSave);

      try {
        await _apiService.saveProfile(profileToSave, authToken: authToken);
      } catch (_) {
      }

      _profile = profileToSave;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Could not save profile: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearProfile() {
    _profile = null;
    notifyListeners();
  }
}
