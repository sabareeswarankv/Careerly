import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../models/resume.dart';
import '../../providers/auth_provider.dart';
import '../../providers/profile_provider.dart';
import '../../providers/resume_provider.dart';
import '../../widgets/app_text_field.dart';

class AtsAnalyzerScreen extends StatefulWidget {
  const AtsAnalyzerScreen({super.key});

  @override
  State<AtsAnalyzerScreen> createState() => _AtsAnalyzerScreenState();
}

class _AtsAnalyzerScreenState extends State<AtsAnalyzerScreen> {
  final _roleController = TextEditingController();
  final _jdController = TextEditingController();
  final _resumeController = TextEditingController();

  int _inputModeIndex = 0;
  String? _uploadedFileName;
  int? _uploadedFileSize;
  bool _isExtractingFile = false;

  final List<String> _popularRoles = [
    'Full Stack Developer',
    'Software Development Engineer',
    'Frontend Developer',
    'Backend Engineer',
    'Data Scientist',
    'DevOps Engineer',
  ];

  @override
  void initState() {
    super.initState();
    final profile = context.read<ProfileProvider>().profile;
    if (profile != null) {
      if (profile.careerGoal.isNotEmpty) {
        _roleController.text = profile.careerGoal;
      } else if (profile.preferredRoles.isNotEmpty) {
        _roleController.text = profile.preferredRoles.first;
      } else {
        _roleController.text = 'Full Stack Developer';
      }
    } else {
      _roleController.text = 'Full Stack Developer';
    }
  }

  @override
  void dispose() {
    _roleController.dispose();
    _jdController.dispose();
    _resumeController.dispose();
    super.dispose();
  }

  void _autofillFromProfile() {
    final profile = context.read<ProfileProvider>().profile;
    if (profile == null) return;

    final buffer = StringBuffer();
    buffer.writeln(profile.fullName);
    buffer.writeln('Education: ${profile.degree} in ${profile.department} (CGPA: ${profile.cgpa}/10.0, Semester ${profile.semester})');
    if (profile.skills.isNotEmpty) {
      buffer.writeln('Technical Skills: ${profile.skills.join(', ')}');
    }
    if (profile.nonTechnicalSkills.isNotEmpty) {
      buffer.writeln('Core Competencies: ${profile.nonTechnicalSkills.join(', ')}');
    }
    if (profile.interests.isNotEmpty) {
      buffer.writeln('Domain Interests: ${profile.interests.join(', ')}');
    }
    buffer.writeln('Project: Developed student career guidance platform utilizing Flutter, FastAPI backend, and Gemini AI integration with responsive dashboard.');
    buffer.writeln('Experience: Built automated placement tracking system and modular RESTful APIs with Firebase authentication.');

    setState(() {
      _resumeController.text = buffer.toString();
    });
  }

  Future<void> _handleFilePick() async {
    final authProvider = context.read<AuthProvider>();
    final resumeProvider = context.read<ResumeProvider>();
    final messenger = ScaffoldMessenger.of(context);

    try {
      final files = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'txt'],
      );

      if (files.isEmpty) return;
      final file = files.first;

      setState(() {
        _isExtractingFile = true;
        _uploadedFileName = file.name;
      });

      final bytes = await file.readAsBytes();
      final fileSize = file.lengthSync() ?? bytes.length;

      setState(() {
        _uploadedFileSize = fileSize;
      });

      String extractedText = '';
      if (file.name.toLowerCase().endsWith('.txt')) {
        try {
          extractedText = utf8.decode(bytes);
        } catch (_) {
          extractedText = latin1.decode(bytes);
        }
      } else {
        final token = await authProvider.getIdToken();
        final text = await resumeProvider.extractFileText(
          bytes: bytes,
          fileName: file.name,
          authToken: token,
        );
        extractedText = text ?? '';
      }

      if (!mounted) return;
      setState(() {
        _isExtractingFile = false;
        if (extractedText.isNotEmpty) {
          _resumeController.text = extractedText;
        }
      });

      if (extractedText.isEmpty) {
        messenger.showSnackBar(
          const SnackBar(content: Text('Could not read text from document. Please verify it contains selectable text.')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isExtractingFile = false);
      messenger.showSnackBar(
        SnackBar(content: Text('Error reading document: $e')),
      );
    }
  }

  void _clearUploadedFile() {
    setState(() {
      _uploadedFileName = null;
      _uploadedFileSize = null;
      _resumeController.clear();
    });
  }

  Future<void> _handleAnalyze() async {
    final role = _roleController.text.trim();
    final resume = _resumeController.text.trim();

    if (role.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please specify a target role.')),
      );
      return;
    }

    if (resume.isEmpty || resume.length < 30) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_inputModeIndex == 0
              ? 'Please upload a PDF or TXT resume document with selectable text.'
              : 'Please paste or write your resume text (at least 30 characters).'),
        ),
      );
      return;
    }

    final token = await context.read<AuthProvider>().getIdToken();
    if (!mounted) return;

    await context.read<ResumeProvider>().analyzeResume(
      resumeText: resume,
      targetRole: role,
      jobDescription: _jdController.text.trim(),
      authToken: token,
    );
  }

  @override
  Widget build(BuildContext context) {
    final resumeProvider = context.watch<ResumeProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Resume ATS Matcher'),
        actions: [
          if (resumeProvider.atsResult != null)
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              tooltip: 'New Analysis',
              onPressed: () {
                resumeProvider.clearResult();
              },
            ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 860),
          child: resumeProvider.atsResult == null
              ? _buildInputView(resumeProvider)
              : _buildResultsView(resumeProvider.atsResult!, resumeProvider),
        ),
      ),
    );
  }

  Widget _buildInputView(ResumeProvider provider) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0EA5E9), Color(0xFF2563EB)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(40),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.description_outlined, color: Colors.white, size: 30),
              ),
              const SizedBox(width: 18),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Applicant Tracking System (ATS) Scanner',
                      style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: Colors.white),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Benchmark your resume against industry role requirements, detect keyword gaps, and get STAR-optimized bullet points.',
                      style: TextStyle(fontSize: 13, color: Colors.white70, height: 1.4),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),

        if (provider.errorMessage != null) ...[
          Container(
            padding: const EdgeInsets.all(14),
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: AppTheme.error.withAlpha(20),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.error.withAlpha(60)),
            ),
            child: Row(
              children: [
                const Icon(Icons.error_outline, color: AppTheme.error, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    provider.errorMessage!,
                    style: const TextStyle(color: AppTheme.error, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        ],

        Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Role & Resume Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                const SizedBox(height: 18),

                AppTextField(
                  label: 'Target Job Role',
                  hint: 'e.g. Full Stack Developer, Data Scientist',
                  controller: _roleController,
                  prefixIcon: const Icon(Icons.badge_outlined, color: AppTheme.slate400),
                ),
                const SizedBox(height: 12),

                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _popularRoles.map((role) {
                    final isSelected = _roleController.text == role;
                    return ActionChip(
                      label: Text(role, style: TextStyle(fontSize: 12, color: isSelected ? Colors.white : AppTheme.slate700)),
                      backgroundColor: isSelected ? AppTheme.primary : AppTheme.slate100,
                      onPressed: () {
                        setState(() => _roleController.text = role);
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),

                const Text('Resume Input Method', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 10),

                Container(
                  decoration: BoxDecoration(
                    color: AppTheme.slate100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.all(4),
                  child: Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: () => setState(() => _inputModeIndex = 0),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: _inputModeIndex == 0 ? Colors.white : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: _inputModeIndex == 0
                                  ? [
                                      BoxShadow(
                                        color: Colors.black.withAlpha(15),
                                        blurRadius: 4,
                                        offset: const Offset(0, 1),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.upload_file_outlined,
                                  size: 18,
                                  color: _inputModeIndex == 0 ? AppTheme.primary : AppTheme.slate600,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Upload Resume File (PDF / TXT)',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: _inputModeIndex == 0 ? FontWeight.w700 : FontWeight.w500,
                                    color: _inputModeIndex == 0 ? AppTheme.primary : AppTheme.slate600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: () => setState(() => _inputModeIndex = 1),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: _inputModeIndex == 1 ? Colors.white : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: _inputModeIndex == 1
                                  ? [
                                      BoxShadow(
                                        color: Colors.black.withAlpha(15),
                                        blurRadius: 4,
                                        offset: const Offset(0, 1),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.edit_note_outlined,
                                  size: 18,
                                  color: _inputModeIndex == 1 ? AppTheme.primary : AppTheme.slate600,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Paste Resume Text',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: _inputModeIndex == 1 ? FontWeight.w700 : FontWeight.w500,
                                    color: _inputModeIndex == 1 ? AppTheme.primary : AppTheme.slate600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                if (_inputModeIndex == 0) ...[
                  if (_uploadedFileName == null)
                    InkWell(
                      onTap: _isExtractingFile ? null : _handleFilePick,
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
                        decoration: BoxDecoration(
                          color: AppTheme.slate50,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: AppTheme.slate200,
                          ),
                        ),
                        child: Column(
                          children: [
                            if (_isExtractingFile) ...[
                              const SizedBox(
                                width: 32,
                                height: 32,
                                child: CircularProgressIndicator(strokeWidth: 2.5),
                              ),
                              const SizedBox(height: 14),
                              const Text(
                                'Reading document and parsing text...',
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.slate700),
                              ),
                            ] else ...[
                              Container(
                                width: 54,
                                height: 54,
                                decoration: BoxDecoration(
                                  color: AppTheme.primary.withAlpha(20),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.cloud_upload_outlined, color: AppTheme.primary, size: 28),
                              ),
                              const SizedBox(height: 14),
                              const Text(
                                'Click to browse and upload resume',
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.slate800),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                'Supported formats: PDF (.pdf), Plain Text (.txt) - Maximum 10MB',
                                style: TextStyle(fontSize: 12, color: AppTheme.slate500),
                              ),
                            ],
                          ],
                        ),
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.slate50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.slate200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: _uploadedFileName!.toLowerCase().endsWith('.pdf')
                                      ? const Color(0xFFEF4444).withAlpha(25)
                                      : AppTheme.primary.withAlpha(25),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  _uploadedFileName!.toLowerCase().endsWith('.pdf')
                                      ? Icons.picture_as_pdf_outlined
                                      : Icons.description_outlined,
                                  color: _uploadedFileName!.toLowerCase().endsWith('.pdf')
                                      ? const Color(0xFFEF4444)
                                      : AppTheme.primary,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _uploadedFileName!,
                                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${((_uploadedFileSize ?? 0) / 1024).toStringAsFixed(1)} KB • ${_resumeController.text.length} characters parsed',
                                      style: const TextStyle(fontSize: 12, color: AppTheme.slate500),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close, size: 20, color: AppTheme.slate500),
                                tooltip: 'Remove File',
                                onPressed: _clearUploadedFile,
                              ),
                            ],
                          ),
                          if (_resumeController.text.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            const Divider(height: 1),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Extracted Document Content:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.slate600)),
                                TextButton.icon(
                                  icon: const Icon(Icons.refresh, size: 14),
                                  label: const Text('Change File', style: TextStyle(fontSize: 12)),
                                  onPressed: _handleFilePick,
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Container(
                              height: 110,
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppTheme.slate200),
                              ),
                              child: SingleChildScrollView(
                                child: Text(
                                  _resumeController.text,
                                  style: const TextStyle(fontSize: 11.5, color: AppTheme.slate700, height: 1.3),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                ] else ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Resume Content / Text', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      TextButton.icon(
                        icon: const Icon(Icons.badge_outlined, size: 16, color: AppTheme.primary),
                        label: const Text('Auto-fill from Profile', style: TextStyle(fontSize: 12)),
                        onPressed: _autofillFromProfile,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  TextField(
                    controller: _resumeController,
                    maxLines: 8,
                    decoration: const InputDecoration(
                      hintText: 'Paste your resume bullet points, education, technical skills, and project summaries here...',
                    ),
                  ),
                ],
                const SizedBox(height: 20),

                const Text('Optional: Job Posting Description', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                TextField(
                  controller: _jdController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    hintText: 'Paste target job description or requirements for exact keyword matching (optional)...',
                  ),
                ),
                const SizedBox(height: 28),

                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: (provider.isAnalyzing || _isExtractingFile) ? null : _handleAnalyze,
                    child: provider.isAnalyzing
                        ? const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              ),
                              SizedBox(width: 12),
                              Text('Running ATS Matcher & Keyword Gap Analysis...'),
                            ],
                          )
                        : const Text('Scan & Match Resume (ATS)'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResultsView(AtsAnalyzeResponse result, ResumeProvider provider) {
    Color scoreColor = AppTheme.success;
    if (result.atsScore < 60) {
      scoreColor = AppTheme.error;
    } else if (result.atsScore < 80) {
      scoreColor = const Color(0xFFF59E0B);
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: scoreColor.withAlpha(20),
                        border: Border.all(color: scoreColor, width: 3),
                      ),
                      child: Center(
                        child: Text(
                          '${result.atsScore}%',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: scoreColor,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: scoreColor.withAlpha(25),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              result.verdict.toUpperCase(),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: scoreColor,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Target Role: ${_roleController.text}',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            result.executiveSummary,
                            style: const TextStyle(fontSize: 13, color: AppTheme.slate600, height: 1.4),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.check_circle_outline, color: AppTheme.success, size: 20),
                          SizedBox(width: 8),
                          Text('Matching Keywords', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                        ],
                      ),
                      const SizedBox(height: 14),
                      if (result.matchingSkills.isEmpty)
                        const Text('No direct keyword matches found.', style: TextStyle(fontSize: 13, color: AppTheme.slate500))
                      else
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: result.matchingSkills.map((s) => Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: AppTheme.success.withAlpha(20),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: AppTheme.success.withAlpha(60)),
                                ),
                                child: Text(s, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.success)),
                              )).toList(),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.warning_amber_rounded, color: AppTheme.error, size: 20),
                          SizedBox(width: 8),
                          Text('Missing Critical Keywords', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                        ],
                      ),
                      const SizedBox(height: 14),
                      if (result.missingCriticalSkills.isEmpty)
                        const Text('None missing! High keyword match.', style: TextStyle(fontSize: 13, color: AppTheme.success))
                      else
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: result.missingCriticalSkills.map((s) => Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: AppTheme.error.withAlpha(20),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: AppTheme.error.withAlpha(60)),
                                ),
                                child: Text(s, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.error)),
                              )).toList(),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        if (result.bulletOptimizations.isNotEmpty) ...[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.fact_check_outlined, color: AppTheme.primary, size: 20),
                      SizedBox(width: 8),
                      Text('STAR Bullet Point Optimizations', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Transform passive statements into high-impact, metrics-driven bullets favored by ATS parsers and recruiters:',
                    style: TextStyle(fontSize: 12, color: AppTheme.slate500),
                  ),
                  const SizedBox(height: 16),
                  ...result.bulletOptimizations.map((b) => Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.slate50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.slate200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppTheme.slate200,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text('Original', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.slate600)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(b.originalText, style: const TextStyle(fontSize: 13, color: AppTheme.slate600)),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppTheme.success.withAlpha(20),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text('Optimized (STAR)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.success)),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.copy_rounded, size: 16, color: AppTheme.slate500),
                                  tooltip: 'Copy Optimized Bullet',
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  onPressed: () {
                                    Clipboard.setData(ClipboardData(text: b.optimizedText));
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Optimized bullet copied to clipboard!')),
                                    );
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(b.optimizedText, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.slate900)),
                            const SizedBox(height: 8),
                            Text('Recruiter Note: ${b.reason}', style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: AppTheme.slate500)),
                          ],
                        ),
                      )),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],

        if (result.formattingFeedback.isNotEmpty) ...[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.format_list_bulleted, color: Color(0xFF6366F1), size: 20),
                      SizedBox(width: 8),
                      Text('ATS Formatting & Readability Recommendations', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                    ],
                  ),
                  const SizedBox(height: 14),
                  ...result.formattingFeedback.map((tip) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.arrow_right, color: AppTheme.primary, size: 20),
                            const SizedBox(width: 6),
                            Expanded(child: Text(tip, style: const TextStyle(fontSize: 13, height: 1.4))),
                          ],
                        ),
                      )),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],

        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton.icon(
            icon: const Icon(Icons.edit_note),
            label: const Text('Edit Resume & Re-Scan'),
            onPressed: () {
              provider.clearResult();
            },
          ),
        ),
      ],
    );
  }
}
