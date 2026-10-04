import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/constants.dart';
import '../models/career_guidance.dart';
import '../models/student_profile.dart';
import '../models/interview.dart';
import '../models/resume.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, [this.statusCode]);

  @override
  String toString() => message;
}

class ApiService {
  final String baseUrl;
  final http.Client _client;

  ApiService({
    String? baseUrl,
    http.Client? client,
  })  : baseUrl = baseUrl ?? AppConstants.defaultApiBaseUrl,
        _client = client ?? http.Client();

  Map<String, String> _headers([String? token]) {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Future<bool> checkHealth() async {
    try {
      final response = await _client
          .get(Uri.parse('$baseUrl/health'))
          .timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<CareerGuidance> generateCareerGuidance(
    StudentProfile profile, {
    String? authToken,
  }) async {
    final url = Uri.parse('$baseUrl/api/ai/career-guidance');
    try {
      final response = await _client
          .post(
            url,
            headers: _headers(authToken),
            body: jsonEncode({
              'profile': profile.toJson(),
            }),
          )
          .timeout(const Duration(seconds: 70));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return CareerGuidance.fromJson(data);
      } else {
        String errorMsg = 'Could not generate guidance. Please try again.';
        try {
          final errBody = jsonDecode(response.body);
          if (errBody is Map && errBody.containsKey('detail')) {
            errorMsg = errBody['detail'].toString();
          }
        } catch (_) {}
        throw ApiException(errorMsg, response.statusCode);
      }
    } on SocketException {
      throw ApiException(
        'Unable to connect to the server. Please ensure the backend is running at $baseUrl.',
      );
    } on http.ClientException {
      throw ApiException('Network connection failed. Please check your internet connection.');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('An unexpected error occurred while preparing your guidance: $e');
    }
  }

  Future<StudentProfile> saveProfile(
    StudentProfile profile, {
    String? authToken,
  }) async {
    final url = Uri.parse('$baseUrl/api/student/profile');
    try {
      final response = await _client
          .post(
            url,
            headers: _headers(authToken),
            body: jsonEncode(profile.toJson()),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return StudentProfile.fromJson(data);
      } else {
        throw ApiException('Failed to save profile on server.', response.statusCode);
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Profile sync error: $e');
    }
  }

  Future<StudentProfile?> getProfile(
    String uid, {
    String? authToken,
  }) async {
    final url = Uri.parse('$baseUrl/api/student/profile/$uid');
    try {
      final response = await _client
          .get(url, headers: _headers(authToken))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return StudentProfile.fromJson(data);
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw ApiException('Failed to retrieve profile.', response.statusCode);
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      return null;
    }
  }

  Future<InterviewGenerateResponse> generateInterviewQuestions({
    required String role,
    String experienceLevel = 'Fresher / Entry-Level',
    String interviewType = 'Mixed',
    List<String> skills = const [],
    int numQuestions = 4,
    String? authToken,
  }) async {
    final url = Uri.parse('$baseUrl/api/interview/generate');
    try {
      final response = await _client
          .post(
            url,
            headers: _headers(authToken),
            body: jsonEncode({
              'role': role,
              'experience_level': experienceLevel,
              'interview_type': interviewType,
              'skills': skills,
              'num_questions': numQuestions,
            }),
          )
          .timeout(const Duration(seconds: 45));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return InterviewGenerateResponse.fromJson(data);
      } else {
        final body = jsonDecode(response.body);
        throw ApiException(body['detail'] ?? 'Failed to generate interview questions.', response.statusCode);
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error during interview setup: $e');
    }
  }

  Future<InterviewEvaluateResponse> evaluateInterviewAnswer({
    required String role,
    required String question,
    required String category,
    required String studentAnswer,
    String? authToken,
  }) async {
    final url = Uri.parse('$baseUrl/api/interview/evaluate');
    try {
      final response = await _client
          .post(
            url,
            headers: _headers(authToken),
            body: jsonEncode({
              'role': role,
              'question': question,
              'category': category,
              'student_answer': studentAnswer,
            }),
          )
          .timeout(const Duration(seconds: 45));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return InterviewEvaluateResponse.fromJson(data);
      } else {
        final body = jsonDecode(response.body);
        throw ApiException(body['detail'] ?? 'Failed to evaluate answer.', response.statusCode);
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error during answer evaluation: $e');
    }
  }

  Future<AtsAnalyzeResponse> analyzeResumeAts({
    required String resumeText,
    required String targetRole,
    String jobDescription = '',
    String? authToken,
  }) async {
    final url = Uri.parse('$baseUrl/api/resume/analyze-ats');
    try {
      final response = await _client
          .post(
            url,
            headers: _headers(authToken),
            body: jsonEncode({
              'resume_text': resumeText,
              'target_role': targetRole,
              'job_description': jobDescription,
            }),
          )
          .timeout(const Duration(seconds: 45));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return AtsAnalyzeResponse.fromJson(data);
      } else {
        final body = jsonDecode(response.body);
        throw ApiException(body['detail'] ?? 'Failed to analyze resume.', response.statusCode);
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error during ATS analysis: $e');
    }
  }

  Future<String> extractResumeTextFromFile({
    required List<int> fileBytes,
    required String fileName,
    String? authToken,
  }) async {
    final url = Uri.parse('$baseUrl/api/resume/extract-text');
    try {
      final request = http.MultipartRequest('POST', url);
      if (authToken != null) {
        request.headers['Authorization'] = 'Bearer $authToken';
      }
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          fileBytes,
          filename: fileName,
        ),
      );
      final streamedResponse = await request.send().timeout(const Duration(seconds: 30));
      final response = await http.Response.fromStream(streamedResponse);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return data['text'] as String;
      } else {
        final body = jsonDecode(response.body);
        throw ApiException(body['detail'] ?? 'Failed to extract text from document.', response.statusCode);
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to read document: $e');
    }
  }
}
