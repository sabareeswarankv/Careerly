List<String> _toStringList(dynamic val) {
  if (val is List) {
    return val.map((e) => e.toString()).toList();
  }
  return [];
}

class StudentProfile {
  final String uid;
  final String fullName;
  final String email;
  final String degree;
  final String department;
  final int semester;
  final double cgpa;
  final List<String> skills;
  final List<String> nonTechnicalSkills;
  final List<String> interests;
  final String careerGoal;
  final List<String> preferredRoles;
  final List<String> improvementAreas;
  final String? createdAt;
  final String? updatedAt;

  StudentProfile({
    required this.uid,
    required this.fullName,
    required this.email,
    required this.degree,
    required this.department,
    required this.semester,
    required this.cgpa,
    this.skills = const [],
    this.nonTechnicalSkills = const [],
    this.interests = const [],
    required this.careerGoal,
    this.preferredRoles = const [],
    this.improvementAreas = const [],
    this.createdAt,
    this.updatedAt,
  });

  int get completionPercentage {
    int filled = 0;
    const totalFields = 9;

    if (fullName.trim().isNotEmpty) filled++;
    if (email.trim().isNotEmpty) filled++;
    if (degree.trim().isNotEmpty) filled++;
    if (department.trim().isNotEmpty) filled++;
    if (semester > 0) filled++;
    if (cgpa > 0.0) filled++;
    if (skills.isNotEmpty) filled++;
    if (interests.isNotEmpty) filled++;
    if (careerGoal.trim().isNotEmpty) filled++;

    return ((filled / totalFields) * 100).round();
  }

  bool get isComplete => completionPercentage >= 70;

  factory StudentProfile.fromJson(Map<String, dynamic> json) {
    return StudentProfile(
      uid: json['uid'] as String? ?? '',
      fullName: (json['fullName'] ?? json['full_name'] ?? '') as String,
      email: json['email'] as String? ?? '',
      degree: json['degree'] as String? ?? '',
      department: json['department'] as String? ?? '',
      semester: (json['semester'] is num) ? (json['semester'] as num).toInt() : 1,
      cgpa: (json['cgpa'] is num) ? (json['cgpa'] as num).toDouble() : 0.0,
      skills: _toStringList(json['skills'] ?? json['technical_skills']),
      nonTechnicalSkills: _toStringList(json['nonTechnicalSkills'] ?? json['non_technical_skills']),
      interests: _toStringList(json['interests']),
      careerGoal: (json['careerGoal'] ?? json['career_goal'] ?? '') as String,
      preferredRoles: _toStringList(json['preferredRoles'] ?? json['preferred_roles']),
      improvementAreas: _toStringList(json['improvementAreas'] ?? json['improvement_areas']),
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'fullName': fullName,
      'email': email,
      'degree': degree,
      'department': department,
      'semester': semester,
      'cgpa': cgpa,
      'skills': skills,
      'nonTechnicalSkills': nonTechnicalSkills,
      'interests': interests,
      'careerGoal': careerGoal,
      'preferredRoles': preferredRoles,
      'improvementAreas': improvementAreas,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  StudentProfile copyWith({
    String? uid,
    String? fullName,
    String? email,
    String? degree,
    String? department,
    int? semester,
    double? cgpa,
    List<String>? skills,
    List<String>? nonTechnicalSkills,
    List<String>? interests,
    String? careerGoal,
    List<String>? preferredRoles,
    List<String>? improvementAreas,
    String? createdAt,
    String? updatedAt,
  }) {
    return StudentProfile(
      uid: uid ?? this.uid,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      degree: degree ?? this.degree,
      department: department ?? this.department,
      semester: semester ?? this.semester,
      cgpa: cgpa ?? this.cgpa,
      skills: skills ?? this.skills,
      nonTechnicalSkills: nonTechnicalSkills ?? this.nonTechnicalSkills,
      interests: interests ?? this.interests,
      careerGoal: careerGoal ?? this.careerGoal,
      preferredRoles: preferredRoles ?? this.preferredRoles,
      improvementAreas: improvementAreas ?? this.improvementAreas,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
