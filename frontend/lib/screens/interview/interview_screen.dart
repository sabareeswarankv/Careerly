import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../models/interview.dart';
import '../../providers/auth_provider.dart';
import '../../providers/interview_provider.dart';
import '../../providers/profile_provider.dart';
import '../../widgets/app_text_field.dart';

class InterviewScreen extends StatefulWidget {
  const InterviewScreen({super.key});

  @override
  State<InterviewScreen> createState() => _InterviewScreenState();
}

class _InterviewScreenState extends State<InterviewScreen> {
  final _roleController = TextEditingController();
  final _skillsController = TextEditingController();
  final _answerController = TextEditingController();
  String _selectedFocus = 'Mixed';
  String _selectedLevel = 'Fresher / Entry-Level';
  final List<String> _skillTags = [];

  final List<String> _popularRoles = [
    'Software Development Engineer',
    'Full Stack Developer',
    'Frontend Developer',
    'Data Analyst',
    'AI / Machine Learning Engineer',
    'Cloud / DevOps Engineer',
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
        _roleController.text = 'Software Development Engineer';
      }
      if (profile.skills.isNotEmpty) {
        _skillTags.addAll(profile.skills.take(5));
      }
    } else {
      _roleController.text = 'Software Development Engineer';
      _skillTags.addAll(['Python', 'Data Structures', 'SQL']);
    }
  }

  @override
  void dispose() {
    _roleController.dispose();
    _skillsController.dispose();
    _answerController.dispose();
    super.dispose();
  }

  Future<void> _handleStartInterview() async {
    final role = _roleController.text.trim();
    if (role.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please specify a target role for the interview.')),
      );
      return;
    }

    final token = await context.read<AuthProvider>().getIdToken();
    if (!mounted) return;

    final success = await context.read<InterviewProvider>().startInterview(
      role: role,
      experienceLevel: _selectedLevel,
      interviewType: _selectedFocus,
      skills: _skillTags,
      numQuestions: 4,
      authToken: token,
    );

    if (success) {
      _answerController.clear();
    }
  }

  Future<void> _handleSubmitAnswer() async {
    final answer = _answerController.text.trim();
    if (answer.isEmpty || answer.length < 15) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please type a more comprehensive answer to evaluate.')),
      );
      return;
    }

    final token = await context.read<AuthProvider>().getIdToken();
    if (!mounted) return;

    await context.read<InterviewProvider>().submitAnswer(
      studentAnswer: answer,
      authToken: token,
    );
  }

  @override
  Widget build(BuildContext context) {
    final interviewProvider = context.watch<InterviewProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Mock Interviewer'),
        actions: [
          if (interviewProvider.session != null)
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              tooltip: 'New Session',
              onPressed: () {
                _answerController.clear();
                interviewProvider.resetSession();
              },
            ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 860),
          child: interviewProvider.session == null
              ? _buildSetupView(interviewProvider)
              : _buildActiveInterviewView(interviewProvider),
        ),
      ),
    );
  }

  Widget _buildSetupView(InterviewProvider provider) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppTheme.primary, Color(0xFF6366F1)],
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
                child: const Icon(Icons.record_voice_over_outlined, color: Colors.white, size: 30),
              ),
              const SizedBox(width: 18),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI Placement Interview Simulator',
                      style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: Colors.white),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Simulate real technical and behavioral rounds tailored to your profile with instant scoring & feedback.',
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
                const Text(
                  'Interview Configuration',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 18),

                AppTextField(
                  label: 'Target Job Role',
                  hint: 'e.g. Full Stack Developer, Data Engineer',
                  controller: _roleController,
                  prefixIcon: const Icon(Icons.work_outline, color: AppTheme.slate400),
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
                const SizedBox(height: 22),

                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Interview Focus', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppTheme.slate200),
                            ),
                            child: DropdownButton<String>(
                              value: _selectedFocus,
                              isExpanded: true,
                              underline: const SizedBox(),
                              items: ['Mixed', 'Technical', 'HR & Behavioral']
                                  .map((f) => DropdownMenuItem(value: f, child: Text(f, style: const TextStyle(fontSize: 13))))
                                  .toList(),
                              onChanged: (val) {
                                if (val != null) setState(() => _selectedFocus = val);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Candidate Level', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppTheme.slate200),
                            ),
                            child: DropdownButton<String>(
                              value: _selectedLevel,
                              isExpanded: true,
                              underline: const SizedBox(),
                              items: ['Fresher / Entry-Level', 'Internship', 'Junior Engineer']
                                  .map((l) => DropdownMenuItem(value: l, child: Text(l, style: const TextStyle(fontSize: 13))))
                                  .toList(),
                              onChanged: (val) {
                                if (val != null) setState(() => _selectedLevel = val);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),

                const Text('Skills & Tech Stack', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: AppTextField(
                        label: 'Add Skill',
                        hint: 'e.g. React, Java, System Design',
                        controller: _skillsController,
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14)),
                      onPressed: () {
                        final s = _skillsController.text.trim();
                        if (s.isNotEmpty && !_skillTags.contains(s)) {
                          setState(() {
                            _skillTags.add(s);
                            _skillsController.clear();
                          });
                        }
                      },
                      child: const Text('Add'),
                    ),
                  ],
                ),
                if (_skillTags.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _skillTags.map((tag) {
                      return Chip(
                        label: Text(tag, style: const TextStyle(fontSize: 12)),
                        onDeleted: () => setState(() => _skillTags.remove(tag)),
                      );
                    }).toList(),
                  ),
                ],
                const SizedBox(height: 32),

                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: provider.isLoading ? null : _handleStartInterview,
                    child: provider.isLoading
                        ? const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              ),
                              SizedBox(width: 12),
                              Text('Generating Interview Round...'),
                            ],
                          )
                        : const Text('Start AI Mock Interview'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActiveInterviewView(InterviewProvider provider) {
    final question = provider.currentQuestion;
    final evaluation = provider.currentEvaluation;
    final total = provider.totalCount;
    final index = provider.currentQuestionIndex;

    if (question == null) {
      return const Center(child: Text('No questions available.'));
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  provider.session!.role,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
                Text(
                  'Question ${index + 1} of $total',
                  style: const TextStyle(fontSize: 13, color: AppTheme.slate500),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.primary.withAlpha(25),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                question.category,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.primary),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        Row(
          children: List.generate(total, (i) {
            final isSelected = i == index;
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  _answerController.clear();
                  provider.goToQuestion(i);
                },
                child: Container(
                  height: 6,
                  margin: EdgeInsets.only(right: i == total - 1 ? 0 : 6),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.primary
                        : (i < provider.completedCount ? AppTheme.success : AppTheme.slate200),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 24),

        Card(
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withAlpha(20),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.help_outline, color: AppTheme.primary, size: 20),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        question.question,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, height: 1.4),
                      ),
                    ),
                  ],
                ),
                if (question.contextHint.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.slate50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppTheme.slate200),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.lightbulb_outline, size: 18, color: Color(0xFFF59E0B)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Interviewer Tip: ${question.contextHint}',
                            style: const TextStyle(fontSize: 12, color: AppTheme.slate700, height: 1.4),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),

        if (evaluation == null) ...[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Your Response', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  const Text(
                    'Structure your response clearly. For technical questions, mention core mechanisms; for behavioral, use the STAR format.',
                    style: TextStyle(fontSize: 12, color: AppTheme.slate500),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _answerController,
                    maxLines: 7,
                    decoration: const InputDecoration(
                      hintText: 'Type your interview response here in detail...',
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: provider.isEvaluating ? null : _handleSubmitAnswer,
                      child: provider.isEvaluating
                          ? const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                ),
                                SizedBox(width: 12),
                                Text('Evaluating with AI Engine...'),
                              ],
                            )
                          : const Text('Submit Answer for Evaluation'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ] else ...[
          _buildEvaluationCard(evaluation, provider, index, total),
        ],
      ],
    );
  }

  Widget _buildEvaluationCard(
    InterviewEvaluateResponse evaluation,
    InterviewProvider provider,
    int index,
    int total,
  ) {
    Color scoreColor = AppTheme.success;
    if (evaluation.score < 60) {
      scoreColor = AppTheme.error;
    } else if (evaluation.score < 80) {
      scoreColor = const Color(0xFFF59E0B);
    }

    return Column(
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: scoreColor.withAlpha(25),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${evaluation.score} / 100',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: scoreColor),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppTheme.slate100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            evaluation.verdict,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.slate800),
                          ),
                        ),
                      ],
                    ),
                    const Icon(Icons.check_circle, color: AppTheme.success, size: 28),
                  ],
                ),
                const SizedBox(height: 20),

                if (evaluation.strengths.isNotEmpty) ...[
                  const Text('Key Strengths', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.success)),
                  const SizedBox(height: 8),
                  ...evaluation.strengths.map((s) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.check_rounded, color: AppTheme.success, size: 18),
                            const SizedBox(width: 8),
                            Expanded(child: Text(s, style: const TextStyle(fontSize: 13, height: 1.4))),
                          ],
                        ),
                      )),
                  const SizedBox(height: 14),
                ],

                if (evaluation.areasForImprovement.isNotEmpty) ...[
                  const Text('Areas for Improvement', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFFF59E0B))),
                  const SizedBox(height: 8),
                  ...evaluation.areasForImprovement.map((a) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.arrow_forward_rounded, color: Color(0xFFF59E0B), size: 18),
                            const SizedBox(width: 8),
                            Expanded(child: Text(a, style: const TextStyle(fontSize: 13, height: 1.4))),
                          ],
                        ),
                      )),
                  const SizedBox(height: 14),
                ],

                if (evaluation.suggestedIdealAnswer.isNotEmpty) ...[
                  ExpansionTile(
                    title: const Text('Ideal Model Answer', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.primary)),
                    tilePadding: EdgeInsets.zero,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppTheme.slate50,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppTheme.slate200),
                        ),
                        child: Text(
                          evaluation.suggestedIdealAnswer,
                          style: const TextStyle(fontSize: 13, height: 1.5, color: AppTheme.slate800),
                        ),
                      ),
                    ],
                  ),
                ],

                if (evaluation.communicationTips.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  const Text('Delivery & Communication Tips', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.slate700)),
                  const SizedBox(height: 6),
                  ...evaluation.communicationTips.map((tip) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text('• $tip', style: const TextStyle(fontSize: 12, color: AppTheme.slate600)),
                      )),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),

        Row(
          children: [
            if (index > 0)
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    _answerController.clear();
                    provider.goToQuestion(index - 1);
                  },
                  child: const Text('Previous Question'),
                ),
              ),
            if (index > 0) const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  if (index < total - 1) {
                    _answerController.clear();
                    provider.goToQuestion(index + 1);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Interview round completed! Great job!')),
                    );
                  }
                },
                child: Text(index < total - 1 ? 'Next Question' : 'Finish Round'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
