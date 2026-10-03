import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AddQuizScreen extends StatefulWidget {
  const AddQuizScreen({super.key});

  @override
  State<AddQuizScreen> createState() => _AddQuizScreenState();
}

class _AddQuizScreenState extends State<AddQuizScreen> {
  // ============================================================
  // CONTROLLERS
  // ============================================================

  final TextEditingController courseController = TextEditingController();
  final TextEditingController questionController = TextEditingController();

  final TextEditingController option1Controller = TextEditingController();
  final TextEditingController option2Controller = TextEditingController();
  final TextEditingController option3Controller = TextEditingController();
  final TextEditingController option4Controller = TextEditingController();

  // ============================================================
  // COLORS
  // ============================================================

  static const Color bgColor = Color(0xFF050816);
  static const Color panelColor = Color(0xFF0B1020);
  static const Color panelColor2 = Color(0xFF10172A);

  static const Color neonBlue = Color(0xFF00B7FF);
  static const Color neonPurple = Color(0xFF8B5CF6);
  static const Color neonCyan = Color(0xFF00F5D4);
  static const Color neonGreen = Color(0xFF39FF88);
  static const Color neonOrange = Color(0xFFFF8A00);
  static const Color neonPink = Color(0xFFFF3CAC);

  static const Color textWhite = Color(0xFFF8FAFF);
  static const Color textMuted = Color(0xFF8D98B2);
  static const Color borderColor = Color(0xFF1C2742);

  // ============================================================
  // STATE
  // ============================================================

  String correctAnswer = '';
  bool isLoading = false;

  final List<Map<String, dynamic>> questions = [];

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    courseController.dispose();
    questionController.dispose();
    option1Controller.dispose();
    option2Controller.dispose();
    option3Controller.dispose();
    option4Controller.dispose();

    super.dispose();
  }

  // ============================================================
  // NORMALIZE COURSE NAME
  // ============================================================

  String _normalizeCourseName(String value) {
    return value
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'\s+'), ' ');
  }

  // ============================================================
  // CLEAR QUESTION
  // ============================================================

  void _clearQuestionFields() {
    questionController.clear();
    option1Controller.clear();
    option2Controller.clear();
    option3Controller.clear();
    option4Controller.clear();

    setState(() {
      correctAnswer = '';
    });
  }

  // ============================================================
  // ADD QUESTION TO LOCAL LIST
  // ============================================================

  void _addQuestion() {
    final course = courseController.text.trim();
    final question = questionController.text.trim();
    final option1 = option1Controller.text.trim();
    final option2 = option2Controller.text.trim();
    final option3 = option3Controller.text.trim();
    final option4 = option4Controller.text.trim();

    if (course.isEmpty ||
        question.isEmpty ||
        option1.isEmpty ||
        option2.isEmpty ||
        option3.isEmpty ||
        option4.isEmpty ||
        correctAnswer.isEmpty) {
      _showSnackBar(
        'Please fill all fields before adding the question.',
        neonOrange,
      );
      return;
    }

    final options = [
      option1,
      option2,
      option3,
      option4,
    ];

    // Prevent duplicate options.
    final normalizedOptions = options
        .map((e) => e.toLowerCase())
        .toSet();

    if (normalizedOptions.length != 4) {
      _showSnackBar(
        'All four options must be different.',
        neonOrange,
      );
      return;
    }

    final questionData = <String, dynamic>{
      'question': question,
      'option1': option1,
      'option2': option2,
      'option3': option3,
      'option4': option4,
      'answer': correctAnswer,
    };

    setState(() {
      questions.add(questionData);
    });

    _clearQuestionFields();

    _showSnackBar(
      'Question ${questions.length} added.',
      neonGreen,
    );
  }

  // ============================================================
  // REMOVE QUESTION
  // ============================================================

  void _removeQuestion(int index) {
    setState(() {
      questions.removeAt(index);
    });

    _showSnackBar(
      'Question removed.',
      neonOrange,
    );
  }

  // ============================================================
  // SAVE COMPLETE QUIZ
  // ============================================================

  Future<void> saveQuiz() async {
    // If fields contain a question, automatically add it first.
    final hasUnsavedQuestion =
        questionController.text.trim().isNotEmpty ||
            option1Controller.text.trim().isNotEmpty ||
            option2Controller.text.trim().isNotEmpty ||
            option3Controller.text.trim().isNotEmpty ||
            option4Controller.text.trim().isNotEmpty;

    if (hasUnsavedQuestion) {
      final course = courseController.text.trim();
      final question = questionController.text.trim();
      final option1 = option1Controller.text.trim();
      final option2 = option2Controller.text.trim();
      final option3 = option3Controller.text.trim();
      final option4 = option4Controller.text.trim();

      if (course.isEmpty ||
          question.isEmpty ||
          option1.isEmpty ||
          option2.isEmpty ||
          option3.isEmpty ||
          option4.isEmpty ||
          correctAnswer.isEmpty) {
        _showSnackBar(
          'Complete the current question first.',
          neonOrange,
        );
        return;
      }

      final options = [
        option1,
        option2,
        option3,
        option4,
      ];

      if (options.map((e) => e.toLowerCase()).toSet().length != 4) {
        _showSnackBar(
          'All four options must be different.',
          neonOrange,
        );
        return;
      }

      questions.add({
        'question': question,
        'option1': option1,
        'option2': option2,
        'option3': option3,
        'option4': option4,
        'answer': correctAnswer,
      });

      _clearQuestionFields();
    }

    if (courseController.text.trim().isEmpty) {
      _showSnackBar(
        'Please enter the course name.',
        neonOrange,
      );
      return;
    }

    if (questions.isEmpty) {
      _showSnackBar(
        'Please add at least one question.',
        neonOrange,
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final courseName = _normalizeCourseName(
        courseController.text,
      );

      final firestore = FirebaseFirestore.instance;

      // ========================================================
      // CREATE ONE QUIZ DOCUMENT FOR THE COURSE
      // ========================================================

      final quizRef = firestore.collection('quizzes').doc();

      await quizRef.set({
        'courseName': courseName,
        'questionCount': questions.length,
        'questions': questions,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // ========================================================
      // ALSO SAVE EACH QUESTION INDIVIDUALLY
      //
      // This keeps compatibility with the old quiz structure.
      // ========================================================

      final batch = firestore.batch();

      for (final question in questions) {
        final questionRef = firestore
            .collection('quizzes')
            .doc(quizRef.id)
            .collection('questions')
            .doc();

        batch.set(questionRef, {
          ...question,
          'courseName': courseName,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();

      if (!mounted) return;

      setState(() {
        isLoading = false;
        questions.clear();
        correctAnswer = '';
      });

      courseController.clear();
      _clearQuestionFields();

      _showSnackBar(
        'Quiz saved successfully with ${questions.length == 0 ? 'all' : ''} questions.',
        neonGreen,
      );

      // Go back to Manage Quiz screen after successful save.
      await Future.delayed(const Duration(milliseconds: 700));

      if (!mounted) return;

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      _showSnackBar(
        'Failed to save quiz: $e',
        Colors.redAccent,
      );
    }
  }

  // ============================================================
  // SNACKBAR
  // ============================================================

  void _showSnackBar(String message, Color color) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: panelColor2,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(
              color: color.withValues(alpha: 0.45),
            ),
          ),
          content: Row(
            children: [
              Icon(
                Icons.bolt_rounded,
                color: color,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: textWhite,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
  }

  // ============================================================
  // TEXT FIELD
  // ============================================================

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(
        color: textWhite,
        fontSize: 15,
      ),
      cursorColor: neonBlue,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          color: textMuted,
        ),
        prefixIcon: Icon(
          icon,
          color: neonBlue,
        ),
        filled: true,
        fillColor: panelColor2,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: borderColor,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: neonBlue,
            width: 1.5,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // CORRECT ANSWER DROPDOWN
  // ============================================================

  Widget _buildCorrectAnswerDropdown() {
    final options = [
      option1Controller.text.trim(),
      option2Controller.text.trim(),
      option3Controller.text.trim(),
      option4Controller.text.trim(),
    ];

    final validOptions = options
        .where((option) => option.isNotEmpty)
        .toList();

    final selectedValue =
    validOptions.contains(correctAnswer)
        ? correctAnswer
        : null;

    return DropdownButtonFormField<String>(
      value: selectedValue,
      dropdownColor: panelColor2,
      iconEnabledColor: neonGreen,
      style: const TextStyle(
        color: textWhite,
        fontSize: 14,
      ),
      decoration: InputDecoration(
        labelText: 'Correct Answer',
        labelStyle: const TextStyle(
          color: textMuted,
        ),
        prefixIcon: const Icon(
          Icons.check_circle_outline_rounded,
          color: neonGreen,
        ),
        filled: true,
        fillColor: panelColor2,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: borderColor,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: neonGreen,
            width: 1.5,
          ),
        ),
      ),
      hint: const Text(
        'Select correct option',
        style: TextStyle(
          color: textMuted,
        ),
      ),
      items: List.generate(
        validOptions.length,
            (index) {
          final option = validOptions[index];

          return DropdownMenuItem<String>(
            value: option,
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 280,
              ),
              child: Text(
                option,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: textWhite,
                ),
              ),
            ),
          );
        },
      ),
      onChanged: (value) {
        setState(() {
          correctAnswer = value ?? '';
        });
      },
    );
  }

  // ============================================================
  // QUESTION PREVIEW CARD
  // ============================================================

  Widget _buildQuestionCard(
      Map<String, dynamic> question,
      int index,
      ) {
    final answer = question['answer'] ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: panelColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: neonPurple.withValues(alpha: 0.35),
        ),
        boxShadow: [
          BoxShadow(
            color: neonPurple.withValues(alpha: 0.07),
            blurRadius: 18,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: neonPurple.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: neonPurple.withValues(alpha: 0.35),
                  ),
                ),
                child: Text(
                  'Q${index + 1}',
                  style: const TextStyle(
                    color: neonPurple,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Spacer(),
              IconButton(
                tooltip: 'Remove question',
                onPressed: () => _removeQuestion(index),
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  color: Colors.redAccent,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Text(
            question['question'] ?? '',
            style: const TextStyle(
              color: textWhite,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              height: 1.35,
            ),
          ),

          const SizedBox(height: 14),

          _buildOptionPreview(
            'A',
            question['option1'] ?? '',
            answer,
          ),
          _buildOptionPreview(
            'B',
            question['option2'] ?? '',
            answer,
          ),
          _buildOptionPreview(
            'C',
            question['option3'] ?? '',
            answer,
          ),
          _buildOptionPreview(
            'D',
            question['option4'] ?? '',
            answer,
          ),
        ],
      ),
    );
  }

  Widget _buildOptionPreview(
      String label,
      String text,
      String answer,
      ) {
    final isCorrect = text == answer;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: isCorrect
            ? neonGreen.withValues(alpha: 0.08)
            : Colors.white.withValues(alpha: 0.025),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCorrect
              ? neonGreen.withValues(alpha: 0.45)
              : borderColor,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isCorrect
                  ? neonGreen.withValues(alpha: 0.16)
                  : neonBlue.withValues(alpha: 0.10),
            ),
            child: Text(
              label,
              style: TextStyle(
                color: isCorrect ? neonGreen : neonBlue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: textWhite,
                fontSize: 13,
              ),
            ),
          ),
          if (isCorrect)
            const Icon(
              Icons.check_circle_rounded,
              color: neonGreen,
              size: 19,
            ),
        ],
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,

      appBar: AppBar(
        backgroundColor: bgColor,
        foregroundColor: textWhite,
        elevation: 0,
        centerTitle: false,
        title: const Row(
          children: [
            Icon(
              Icons.quiz_rounded,
              color: neonCyan,
            ),
            SizedBox(width: 10),
            Text(
              'Quiz Builder',
              style: TextStyle(
                color: textWhite,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            18,
            10,
            18,
            30,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ==================================================
              // HEADER
              // ==================================================

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF111A35),
                      Color(0xFF0A1020),
                    ],
                  ),
                  border: Border.all(
                    color: neonBlue.withValues(alpha: 0.35),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: neonBlue.withValues(alpha: 0.08),
                      blurRadius: 25,
                    ),
                  ],
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.auto_awesome_rounded,
                      color: neonBlue,
                      size: 30,
                    ),
                    SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Create New Quiz',
                            style: TextStyle(
                              color: textWhite,
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            'Build questions and save them automatically.',
                            style: TextStyle(
                              color: textMuted,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              // ==================================================
              // COURSE
              // ==================================================

              _buildTextField(
                controller: courseController,
                label: 'Course Name',
                icon: Icons.menu_book_rounded,
              ),

              const SizedBox(height: 22),

              // ==================================================
              // QUESTION
              // ==================================================

              const Text(
                'QUESTION',
                style: TextStyle(
                  color: neonCyan,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.4,
                ),
              ),

              const SizedBox(height: 10),

              _buildTextField(
                controller: questionController,
                label: 'Question',
                icon: Icons.help_outline_rounded,
                maxLines: 4,
              ),

              const SizedBox(height: 20),

              // ==================================================
              // OPTIONS
              // ==================================================

              const Text(
                'OPTIONS',
                style: TextStyle(
                  color: neonPurple,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.4,
                ),
              ),

              const SizedBox(height: 10),

              _buildTextField(
                controller: option1Controller,
                label: 'Option 1',
                icon: Icons.looks_one_rounded,
              ),

              const SizedBox(height: 12),

              _buildTextField(
                controller: option2Controller,
                label: 'Option 2',
                icon: Icons.looks_two_rounded,
              ),

              const SizedBox(height: 12),

              _buildTextField(
                controller: option3Controller,
                label: 'Option 3',
                icon: Icons.looks_3_rounded,
              ),

              const SizedBox(height: 12),

              _buildTextField(
                controller: option4Controller,
                label: 'Option 4',
                icon: Icons.looks_4_rounded,
              ),

              const SizedBox(height: 20),

              // ==================================================
              // CORRECT ANSWER
              // ==================================================

              _buildCorrectAnswerDropdown(),

              const SizedBox(height: 18),

              // ==================================================
              // ADD QUESTION BUTTON
              // ==================================================

              SizedBox(
                width: double.infinity,
                height: 54,
                child: OutlinedButton.icon(
                  onPressed: isLoading
                      ? null
                      : _addQuestion,
                  icon: const Icon(
                    Icons.add_circle_outline_rounded,
                  ),
                  label: const Text(
                    'Add Question',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: neonBlue,
                    side: BorderSide(
                      color: neonBlue.withValues(alpha: 0.6),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 26),

              // ==================================================
              // ADDED QUESTIONS
              // ==================================================

              if (questions.isNotEmpty) ...[
                Row(
                  children: [
                    const Text(
                      'QUIZ QUESTIONS',
                      style: TextStyle(
                        color: neonGreen,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.4,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: neonGreen.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: neonGreen.withValues(alpha: 0.30),
                        ),
                      ),
                      child: Text(
                        '${questions.length} Questions',
                        style: const TextStyle(
                          color: neonGreen,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                ...List.generate(
                  questions.length,
                      (index) => _buildQuestionCard(
                    questions[index],
                    index,
                  ),
                ),

                const SizedBox(height: 8),
              ],

              // ==================================================
              // SAVE QUIZ
              // ==================================================

              SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton.icon(
                  onPressed: isLoading
                      ? null
                      : saveQuiz,
                  icon: isLoading
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: bgColor,
                    ),
                  )
                      : const Icon(
                    Icons.cloud_upload_rounded,
                  ),
                  label: Text(
                    isLoading
                        ? 'Saving Quiz...'
                        : 'Save Quiz',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: neonCyan,
                    foregroundColor: bgColor,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(17),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 14),

              Center(
                child: Text(
                  '${questions.length} question${questions.length == 1 ? '' : 's'} ready to save',
                  style: const TextStyle(
                    color: textMuted,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}