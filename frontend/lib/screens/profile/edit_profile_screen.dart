import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../config/constants.dart';
import '../../models/student_profile.dart';
import '../../providers/auth_provider.dart';
import '../../providers/profile_provider.dart';
import '../../widgets/app_buttons.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/chip_selector.dart';
import '../../widgets/state_views.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _cgpaController;
  late TextEditingController _careerGoalController;

  String _degree = AppConstants.degrees.first;
  String _department = AppConstants.departments.first;
  int _semester = 5;

  List<String> _skills = [];
  List<String> _nonTechnicalSkills = [];
  List<String> _interests = [];
  List<String> _preferredRoles = [];
  List<String> _improvementAreas = [];

  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final profile = context.read<ProfileProvider>().profile;
      final authUser = context.read<AuthProvider>().user;

      _nameController = TextEditingController(
        text: profile?.fullName ?? authUser?.displayName ?? '',
      );
      _emailController = TextEditingController(
        text: profile?.email ?? authUser?.email ?? '',
      );
      _cgpaController = TextEditingController(
        text: (profile != null && profile.cgpa > 0) ? profile.cgpa.toString() : '8.0',
      );
      _careerGoalController = TextEditingController(
        text: profile?.careerGoal ?? 'Software Engineer',
      );

      if (profile != null) {
        if (AppConstants.degrees.contains(profile.degree)) {
          _degree = profile.degree;
        }
        if (AppConstants.departments.contains(profile.department)) {
          _department = profile.department;
        }
        _semester = profile.semester;
        _skills = List<String>.from(profile.skills);
        _nonTechnicalSkills = List<String>.from(profile.nonTechnicalSkills);
        _interests = List<String>.from(profile.interests);
        _preferredRoles = List<String>.from(profile.preferredRoles);
        _improvementAreas = List<String>.from(profile.improvementAreas);
      } else {
        _skills = ['Python', 'SQL', 'Data Structures'];
        _interests = ['Artificial Intelligence', 'Web Development'];
      }

      _initialized = true;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _cgpaController.dispose();
    _careerGoalController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final profileProvider = context.read<ProfileProvider>();
    final authUser = context.read<AuthProvider>().user;
    if (authUser == null) return;

    final double parsedCgpa = double.tryParse(_cgpaController.text.trim()) ?? 8.0;

    final updated = StudentProfile(
      uid: authUser.uid,
      fullName: _nameController.text.trim(),
      email: _emailController.text.trim(),
      degree: _degree,
      department: _department,
      semester: _semester,
      cgpa: parsedCgpa,
      skills: _skills,
      nonTechnicalSkills: _nonTechnicalSkills,
      interests: _interests,
      careerGoal: _careerGoalController.text.trim(),
      preferredRoles: _preferredRoles,
      improvementAreas: _improvementAreas,
      createdAt: profileProvider.profile?.createdAt,
    );

    final success = await profileProvider.saveProfile(updated);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile saved successfully!')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider = context.watch<ProfileProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Student Profile'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              children: [
                if (profileProvider.errorMessage != null)
                  ErrorBanner(message: profileProvider.errorMessage!),

                const SectionHeader(
                  title: 'Academic Background',
                  subtitle: 'Helps personalize career paths aligned with your coursework',
                ),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        AppTextField(
                          label: 'Full Name',
                          hint: 'Enter your full name',
                          controller: _nameController,
                          validator: (val) =>
                              val == null || val.trim().isEmpty ? 'Full name is required' : null,
                        ),
                        const SizedBox(height: 16),
                        AppTextField(
                          label: 'Email',
                          hint: 'student@example.com',
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          validator: (val) =>
                              val == null || val.trim().isEmpty ? 'Email is required' : null,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Degree',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.slate800,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  DropdownButtonFormField<String>(
                                    initialValue: _degree,
                                    isExpanded: true,
                                    decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12)),
                                    items: AppConstants.degrees
                                        .map((d) => DropdownMenuItem(value: d, child: Text(d, style: const TextStyle(fontSize: 14))))
                                        .toList(),
                                    onChanged: (val) {
                                      if (val != null) setState(() => _degree = val);
                                    },
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Semester',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.slate800,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  DropdownButtonFormField<int>(
                                    initialValue: _semester,
                                    isExpanded: true,
                                    decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12)),
                                    items: List.generate(8, (i) => i + 1)
                                        .map((s) => DropdownMenuItem(value: s, child: Text('Semester $s', style: const TextStyle(fontSize: 14))))
                                        .toList(),
                                    onChanged: (val) {
                                      if (val != null) setState(() => _semester = val);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Department',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.slate800,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  DropdownButtonFormField<String>(
                                    initialValue: _department,
                                    isExpanded: true,
                                    decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12)),
                                    items: AppConstants.departments
                                        .map((dep) => DropdownMenuItem(
                                              value: dep,
                                              child: Text(
                                                dep,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(fontSize: 14),
                                              ),
                                            ))
                                        .toList(),
                                    onChanged: (val) {
                                      if (val != null) setState(() => _department = val);
                                    },
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              flex: 2,
                              child: AppTextField(
                                label: 'CGPA',
                                hint: '8.5',
                                controller: _cgpaController,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                validator: (val) {
                                  if (val == null || val.trim().isEmpty) return 'Enter CGPA';
                                  final num = double.tryParse(val.trim());
                                  if (num == null || num < 0.0 || num > 10.0) return '0.0 - 10.0';
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                const SectionHeader(
                  title: 'Skills & Competencies',
                  subtitle: 'Select current technical abilities and soft skills',
                ),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ChipSelector(
                          title: 'Technical Skills',
                          subtitle: 'Languages, frameworks, and technologies you know',
                          suggestions: AppConstants.suggestedTechSkills,
                          selected: _skills,
                          onChanged: (list) => setState(() => _skills = list),
                          addHint: 'Add another skill (e.g. Flutter, Kotlin)...',
                        ),
                        const Divider(height: 32),
                        ChipSelector(
                          title: 'Non-Technical & Soft Skills',
                          subtitle: 'Interpersonal, teamwork, and communication competencies',
                          suggestions: AppConstants.suggestedSoftSkills,
                          selected: _nonTechnicalSkills,
                          onChanged: (list) => setState(() => _nonTechnicalSkills = list),
                          addHint: 'Add custom soft skill...',
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                const SectionHeader(
                  title: 'Interests & Career Goals',
                  subtitle: 'Define your desired destination and target roles',
                ),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppTextField(
                          label: 'Primary Career Goal',
                          hint: 'e.g. AI / ML Engineer, Full Stack Developer',
                          controller: _careerGoalController,
                          validator: (val) =>
                              val == null || val.trim().isEmpty ? 'Please enter your primary goal' : null,
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: AppConstants.suggestedCareerGoals.take(6).map((goal) {
                            return ActionChip(
                              label: Text(goal, style: const TextStyle(fontSize: 12)),
                              backgroundColor: AppTheme.slate100,
                              onPressed: () {
                                setState(() => _careerGoalController.text = goal);
                              },
                            );
                          }).toList(),
                        ),
                        const Divider(height: 32),
                        ChipSelector(
                          title: 'Technology & Domain Interests',
                          suggestions: AppConstants.suggestedInterests,
                          selected: _interests,
                          onChanged: (list) => setState(() => _interests = list),
                          addHint: 'Add interest...',
                        ),
                        const Divider(height: 32),
                        ChipSelector(
                          title: 'Areas for Improvement',
                          subtitle: 'Skills or topics you are eager to build further',
                          suggestions: const [
                            'Data Structures & Algorithms',
                            'System Design',
                            'Cloud & Deployment',
                            'Interview Communication',
                            'Aptitude Tests'
                          ],
                          selected: _improvementAreas,
                          onChanged: (list) => setState(() => _improvementAreas = list),
                          addHint: 'Add area to improve...',
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                PrimaryButton(
                  label: 'Save Profile',
                  isLoading: profileProvider.isLoading,
                  icon: Icons.check_circle_outline,
                  onPressed: _saveProfile,
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
