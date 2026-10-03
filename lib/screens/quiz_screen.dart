import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../data/default_quiz_data.dart';

class QuizScreen extends StatefulWidget {
  final String courseName;

  const QuizScreen({
    super.key,
    required this.courseName,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  // ============================================================
  // CYBER TECH THEME
  // ============================================================

  static const Color bg = Color(0xff030712);
  static const Color surface = Color(0xff08111F);
  static const Color surface2 = Color(0xff0C1728);
  static const Color surface3 = Color(0xff101D32);

  static const Color blue = Color(0xff168CFF);
  static const Color cyan = Color(0xff00E5FF);
  static const Color purple = Color(0xff7C3AED);
  static const Color neonPurple = Color(0xffA855F7);

  static const Color green = Color(0xff00E5A0);
  static const Color orange = Color(0xffFF9F43);
  static const Color red = Color(0xffFF4D6D);

  static const Color textPrimary = Color(0xffF5F7FF);
  static const Color textSecondary = Color(0xff8EA0BA);
  static const Color muted = Color(0xff52627A);
  static const Color border = Color(0xff1A2B45);

  // ============================================================
  // STATE
  // ============================================================

  final Map<int, String> selectedAnswers = {};

  bool isSubmitting = false;

  // ============================================================
  // NORMALIZE COURSE NAME
  // ============================================================

  String normalizeCourseName(String value) {
    return value
        .trim()
        .toLowerCase()
        .replaceAll('+', 'plus')
        .replaceAll(RegExp(r'[^a-z0-9]'), '');
  }

  // ============================================================
  // CURRENT COURSE KEY
  // ============================================================

  String get normalizedCourseName {
    return normalizeCourseName(widget.courseName);
  }

  // ============================================================
  // QUIZ KEY ALIAS
  // ============================================================

  String get quizDataKey {
    final key = normalizedCourseName;

    // Supports both common keys used for C++.
    if (key == 'cplusplus') return 'cpp';

    return key;
  }

  // ============================================================
  // LOCAL QUIZ QUESTIONS
  // ============================================================

  List<Map<String, dynamic>> getQuizQuestions() {
    final rawCourse = widget.courseName.trim();

    if (rawCourse.isEmpty) {
      debugPrint('QUIZ ERROR: Course name is empty');
      return <Map<String, dynamic>>[];
    }

    final target = normalizeCourseName(rawCourse);

    // Keep aliases flexible because course titles can come from Firestore.
    final aliases = <String>{target};

    void addAliases(List<String> values) {
      for (final value in values) {
        aliases.add(normalizeCourseName(value));
      }
    }

    if (target == 'c' ||
        target == 'clanguage' ||
        target == 'clang' ||
        target == 'cprogramming') {
      addAliases(['c', 'C Language', 'clanguage', 'c programming']);
    }

    if (target == 'cpp' || target == 'cplusplus' || target == 'cplus') {
      addAliases(['cpp', 'c++', 'cplusplus', 'cplus', 'c++ programming']);
    }

    if (target == 'computernetwork' || target == 'computernetworks') {
      addAliases(['computernetwork', 'computernetworks', 'computer networks']);
    }

    if (target == 'cybersecurity' ||
        target == 'cybersecurityandethicalhacking') {
      addAliases([
        'cybersecurity',
        'cyber security',
        'cybersecurity and ethical hacking'
      ]);
    }

    if (target == 'ethicalhacking') {
      addAliases(['ethicalhacking', 'ethical hacking']);
    }

    if (target == 'node' || target == 'nodejs' || target == 'nodejavascript') {
      addAliases(['node', 'nodejs', 'node js', 'node javascript']);
    }

    if (target == 'os' || target == 'operatingsystem') {
      addAliases(['os', 'operatingsystem', 'operating system']);
    }

    if (target == 'r' || target == 'rlanguage' || target == 'rprogramming') {
      addAliases(['r', 'rlanguage', 'r language', 'r programming']);
    }

    if (target == 'flutterdevelopment' || target == 'flutterappdevelopment') {
      addAliases(
          ['flutter', 'flutter development', 'flutter app development']);
    }

    if (target == 'pythonprogramming') {
      addAliases(['python', 'python programming']);
    }

    if (target == 'javaprogramming') {
      addAliases(['java', 'java programming']);
    }

    if (target == 'javascriptprogramming') {
      addAliases(['javascript', 'javascript programming']);
    }

    if (target == 'djangodevelopment') {
      addAliases(['django', 'django development']);
    }

    // Safely convert the value returned by defaultQuizData.
    List<Map<String, dynamic>> convertQuestions(dynamic value) {
      if (value is! List) {
        return <Map<String, dynamic>>[];
      }

      final result = <Map<String, dynamic>>[];

      for (final item in value) {
        if (item is Map) {
          result.add(Map<String, dynamic>.from(item));
        }
      }

      return result;
    }

    // 1. Exact normalized match.
    for (final entry in defaultQuizData.entries) {
      final entryKey = normalizeCourseName(entry.key);

      if (aliases.contains(entryKey)) {
        final questions = convertQuestions(entry.value);

        debugPrint(
          'QUIZ LOADED: course="$rawCourse" key="${entry.key}" questions=${questions.length}',
        );

        return questions;
      }
    }

    // 2. Partial match for titles such as "Python Programming Course".
    for (final entry in defaultQuizData.entries) {
      final entryKey = normalizeCourseName(entry.key);

      if (entryKey.isEmpty) continue;

      if (target.contains(entryKey) || entryKey.contains(target)) {
        final questions = convertQuestions(entry.value);

        if (questions.isNotEmpty) {
          debugPrint(
            'QUIZ PARTIAL MATCH: course="$rawCourse" key="${entry.key}" questions=${questions.length}',
          );
          return questions;
        }
      }
    }

    debugPrint(
      'QUIZ DATA NOT FOUND: course="$rawCourse" normalized="$target" availableKeys=${defaultQuizData.keys.toList()}',
    );

    return <Map<String, dynamic>>[];
  }

  // ============================================================
  // SUBMIT QUIZ
  // ============================================================

  Future<void> submitQuiz(
      List<Map<String, dynamic>> quizzes,
      ) async {
    if (isSubmitting) return;

    if (quizzes.isEmpty) {
      showMessage(
        'No questions available for this quiz.',
        isError: true,
      );
      return;
    }

    // ----------------------------------------------------------
    // CHECK UNANSWERED
    // ----------------------------------------------------------

    final unansweredQuestions = <int>[];

    for (int i = 0; i < quizzes.length; i++) {
      final answer = selectedAnswers[i]?.trim() ?? '';

      if (answer.isEmpty) {
        unansweredQuestions.add(i + 1);
      }
    }

    if (unansweredQuestions.isNotEmpty) {
      if (!mounted) return;

      showIncompleteDialog(unansweredQuestions);

      return;
    }

    // ----------------------------------------------------------
    // CURRENT USER
    // ----------------------------------------------------------

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      if (!mounted) return;

      showMessage(
        'Please login again before submitting the quiz.',
        isError: true,
      );

      return;
    }

    setState(() {
      isSubmitting = true;
    });

    try {
      int score = 0;

      // --------------------------------------------------------
      // CALCULATE SCORE
      // --------------------------------------------------------

      for (int i = 0; i < quizzes.length; i++) {
        final data = quizzes[i];

        final selectedAnswer = selectedAnswers[i]?.trim() ?? '';

        final correctAnswer = (data['answer'] ?? '').toString().trim();

        if (selectedAnswer.isNotEmpty &&
            correctAnswer.isNotEmpty &&
            selectedAnswer.toLowerCase() == correctAnswer.toLowerCase()) {
          score++;
        }
      }

      // --------------------------------------------------------
      // SAVE RESULT TO FIRESTORE
      // --------------------------------------------------------

      await FirebaseFirestore.instance.collection('quiz_results').add({
        'uid': user.uid,
        'email': user.email ?? '',
        'courseName': widget.courseName.trim(),
        'courseKey': normalizedCourseName,
        'score': score,
        'total': quizzes.length,
        'percentage':
        quizzes.isEmpty ? 0 : ((score / quizzes.length) * 100).round(),
        'submittedAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      setState(() {
        isSubmitting = false;
      });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => QuizReviewScreen(
            courseName: widget.courseName.trim(),
            questions: quizzes,
            selectedAnswers: Map<int, String>.from(selectedAnswers),
            score: score,
          ),
        ),
      );
    } catch (e) {
      debugPrint('Quiz Submit Error: $e');

      if (!mounted) return;

      setState(() {
        isSubmitting = false;
      });

      showMessage(
        'Unable to submit quiz. Please try again.',
        isError: true,
      );
    }
  }

  // ============================================================
  // INCOMPLETE QUIZ DIALOG
  // ============================================================

  void showIncompleteDialog(
      List<int> unansweredQuestions,
      ) {
    showDialog(
      context: context,
      barrierDismissible: !isSubmitting,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(
              color: orange.withValues(alpha: 0.35),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(21, 23, 21, 21),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: orange.withValues(alpha: 0.09),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: orange.withValues(alpha: 0.30),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: orange.withValues(alpha: 0.12),
                        blurRadius: 22,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.assignment_late_rounded,
                    color: orange,
                    size: 34,
                  ),
                ),
                const SizedBox(height: 17),
                const Text(
                  'QUIZ INCOMPLETE',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: textPrimary,
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Every question must be answered before submission.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: textSecondary,
                    fontSize: 11.5,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 17),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: orange.withValues(alpha: 0.055),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: orange.withValues(alpha: 0.20),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            color: orange,
                            size: 17,
                          ),
                          SizedBox(width: 7),
                          Text(
                            'UNANSWERED QUESTIONS',
                            style: TextStyle(
                              color: orange,
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        unansweredQuestions
                            .map((number) => 'Q$number')
                            .join('   •   '),
                        style: const TextStyle(
                          color: textPrimary,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 19),
                SizedBox(
                  width: double.infinity,
                  height: 51,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(dialogContext);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: blue,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'CONTINUE QUIZ',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.7,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void showMessage(
      String message, {
        bool isError = false,
      }) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(15),
          backgroundColor:
          isError ? const Color(0xff551322) : const Color(0xff064E3B),
          elevation: 0,
          duration: const Duration(seconds: 3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(
              color: isError
                  ? red.withValues(alpha: 0.35)
                  : green.withValues(alpha: 0.35),
            ),
          ),
          content: Row(
            children: [
              Icon(
                isError
                    ? Icons.error_outline_rounded
                    : Icons.check_circle_outline_rounded,
                color: isError ? red : green,
                size: 20,
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
  }

  // ============================================================
  // CYBER BACKGROUND
  // ============================================================

  Widget buildCyberBackground() {
    return ClipRect(
      child: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xff030712),
                  Color(0xff06101D),
                  Color(0xff030611),
                ],
              ),
            ),
          ),
          Positioned(
            top: -120,
            right: -90,
            child: Container(
              width: 270,
              height: 270,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: purple.withValues(alpha: 0.075),
              ),
            ),
          ),
          Positioned(
            top: 280,
            left: -150,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: blue.withValues(alpha: 0.055),
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            right: -80,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: cyan.withValues(alpha: 0.035),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // APP BAR
  // ============================================================

  PreferredSizeWidget buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: bg.withValues(alpha: 0.97),
      foregroundColor: textPrimary,
      centerTitle: false,
      titleSpacing: 8,
      leading: IconButton(
        onPressed: isSubmitting
            ? null
            : () {
          Navigator.pop(context);
        },
        icon: Container(
          width: 37,
          height: 37,
          decoration: BoxDecoration(
            color: surface2,
            borderRadius: BorderRadius.circular(11),
            border: Border.all(color: border),
          ),
          child: const Icon(
            Icons.arrow_back_rounded,
            color: cyan,
            size: 19,
          ),
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.courseName.trim().isEmpty
                ? 'QUIZ'
                : 'QUIZ • ${widget.courseName.trim()}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: textPrimary,
              fontSize: 15.5,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            'KNOWLEDGE ASSESSMENT',
            style: TextStyle(
              color: cyan,
              fontSize: 7.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.1,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // STATUS BAR
  // ============================================================

  Widget buildStatusBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 9, 16, 0),
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 9,
      ),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: green,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: green.withValues(alpha: 0.60),
                  blurRadius: 8,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            'ASSESSMENT ONLINE',
            style: TextStyle(
              color: textSecondary,
              fontSize: 8.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
            ),
          ),
          const Spacer(),
          const Icon(
            Icons.timer_outlined,
            color: cyan,
            size: 13,
          ),
          const SizedBox(width: 5),
          const Text(
            'NO TIME LIMIT',
            style: TextStyle(
              color: cyan,
              fontSize: 7.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.6,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // QUIZ HEADER
  // ============================================================

  Widget quizHeader(int totalQuestions) {
    final answeredCount = selectedAnswers.length;

    final progress = totalQuestions <= 0
        ? 0.0
        : (answeredCount / totalQuestions).clamp(0.0, 1.0);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 8),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xff0B1D3B),
            Color(0xff101536),
            Color(0xff171035),
          ],
        ),
        borderRadius: BorderRadius.circular(23),
        border: Border.all(
          color: blue.withValues(alpha: 0.32),
        ),
        boxShadow: [
          BoxShadow(
            color: blue.withValues(alpha: 0.08),
            blurRadius: 25,
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -25,
            top: -30,
            child: Container(
              width: 115,
              height: 115,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: cyan.withValues(alpha: 0.08),
                ),
              ),
            ),
          ),
          Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [blue, purple],
                      ),
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: blue.withValues(alpha: 0.25),
                          blurRadius: 18,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.quiz_rounded,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'QUIZ MODE',
                          style: TextStyle(
                            color: textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.7,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Answer all questions to complete',
                          style: TextStyle(
                            color: textSecondary,
                            fontSize: 9.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 11,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.20),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: cyan.withValues(alpha: 0.20),
                      ),
                    ),
                    child: Text(
                      '$answeredCount/$totalQuestions',
                      style: const TextStyle(
                        color: cyan,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  const Text(
                    'PROGRESS',
                    style: TextStyle(
                      color: muted,
                      fontSize: 7.5,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Container(
                      height: 7,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.28),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 7,
                          backgroundColor: Colors.transparent,
                          valueColor: const AlwaysStoppedAnimation(cyan),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 9),
                  Text(
                    '${(progress * 100).round()}%',
                    style: const TextStyle(
                      color: cyan,
                      fontSize: 8.5,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 11),
              Row(
                children: [
                  Icon(
                    answeredCount == totalQuestions
                        ? Icons.check_circle_rounded
                        : Icons.radio_button_checked,
                    size: 13,
                    color: answeredCount == totalQuestions
                        ? green
                        : textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    answeredCount == totalQuestions
                        ? 'ALL QUESTIONS ANSWERED'
                        : '$answeredCount ANSWERED • '
                        '${totalQuestions - answeredCount} REMAINING',
                    style: TextStyle(
                      color: answeredCount == totalQuestions
                          ? green
                          : textSecondary,
                      fontSize: 7.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // QUESTION CARD
  // ============================================================

  Widget questionCard(
      int index,
      Map<String, dynamic> data,
      ) {
    final question = (data['question'] ?? '').toString().trim();

    final options = [
      (data['option1'] ?? '').toString().trim(),
      (data['option2'] ?? '').toString().trim(),
      (data['option3'] ?? '').toString().trim(),
      (data['option4'] ?? '').toString().trim(),
    ];

    final validOptions = options.where((option) => option.isNotEmpty).toList();

    final selectedAnswer = selectedAnswers[index];

    final isAnswered =
        selectedAnswer != null && selectedAnswer.trim().isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(21),
        border: Border.all(
          color: isAnswered ? cyan.withValues(alpha: 0.38) : border,
          width: isAnswered ? 1.15 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isAnswered
                ? cyan.withValues(alpha: 0.045)
                : Colors.black.withValues(alpha: 0.16),
            blurRadius: 20,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(15, 16, 13, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    gradient: isAnswered
                        ? const LinearGradient(colors: [blue, purple])
                        : const LinearGradient(colors: [surface3, surface2]),
                    borderRadius: BorderRadius.circular(11),
                    border: Border.all(
                      color:
                      isAnswered ? cyan.withValues(alpha: 0.28) : border,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      color: isAnswered ? Colors.white : cyan,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'QUESTION ${index + 1}',
                        style: TextStyle(
                          color: isAnswered ? cyan : muted,
                          fontSize: 7.5,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        question.isEmpty ? 'Question ${index + 1}' : question,
                        style: const TextStyle(
                          color: textPrimary,
                          fontSize: 14,
                          height: 1.45,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 5),
                if (isAnswered)
                  const Icon(
                    Icons.check_circle_rounded,
                    color: green,
                    size: 19,
                  ),
              ],
            ),
            const SizedBox(height: 14),
            if (validOptions.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(13),
                decoration: BoxDecoration(
                  color: red.withValues(alpha: 0.055),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: red.withValues(alpha: 0.22),
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: red,
                      size: 17,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'No options available for this question.',
                        style: TextStyle(
                          color: red,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else
              ...validOptions.asMap().entries.map(
                    (entry) {
                  final optionIndex = entry.key;

                  final option = entry.value;

                  final isSelected = selectedAnswer == option;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(15),
                      onTap: isSubmitting
                          ? null
                          : () {
                        setState(() {
                          selectedAnswers[index] = option;
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 11,
                          vertical: 11,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? blue.withValues(alpha: 0.09)
                              : const Color(0xff0A1322),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: isSelected
                                ? cyan.withValues(alpha: 0.65)
                                : border,
                            width: isSelected ? 1.2 : 1,
                          ),
                          boxShadow: isSelected
                              ? [
                            BoxShadow(
                              color: cyan.withValues(alpha: 0.055),
                              blurRadius: 14,
                            ),
                          ]
                              : null,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 31,
                              height: 31,
                              decoration: BoxDecoration(
                                color: isSelected ? blue : surface3,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected ? cyan : border,
                                ),
                                boxShadow: isSelected
                                    ? [
                                  BoxShadow(
                                    color: blue.withValues(alpha: 0.25),
                                    blurRadius: 10,
                                  ),
                                ]
                                    : null,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                String.fromCharCode(65 + optionIndex),
                                style: TextStyle(
                                  color:
                                  isSelected ? Colors.white : textSecondary,
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                            const SizedBox(width: 11),
                            Expanded(
                              child: Text(
                                option,
                                style: TextStyle(
                                  color: isSelected
                                      ? textPrimary
                                      : const Color(0xffB5C1D3),
                                  fontSize: 12.5,
                                  height: 1.4,
                                  fontWeight: isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                ),
                              ),
                            ),
                            if (isSelected)
                              const Icon(
                                Icons.check_circle_rounded,
                                color: green,
                                size: 19,
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // EMPTY STATE
  // ============================================================

  Widget emptyQuizState() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: SizedBox(
        height: 560,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 105,
                  height: 105,
                  decoration: BoxDecoration(
                    color: blue.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: blue.withValues(alpha: 0.22),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: blue.withValues(alpha: 0.10),
                        blurRadius: 35,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.quiz_outlined,
                    color: cyan,
                    size: 50,
                  ),
                ),
                const SizedBox(height: 22),
                const Text(
                  'NO QUIZ AVAILABLE',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: textPrimary,
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 9),
                Text(
                  'There is currently no quiz available '
                      'for "${widget.courseName.trim()}".',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: textSecondary,
                    fontSize: 12,
                    height: 1.55,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: border),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        color: cyan,
                        size: 16,
                      ),
                      SizedBox(width: 7),
                      Text(
                        'QUIZ NOT CONFIGURED',
                        style: TextStyle(
                          color: textSecondary,
                          fontSize: 8.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.7,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // LOADING STATE
  // ============================================================

  Widget loadingState() {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
      children: [
        Container(
          height: 145,
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(23),
            border: Border.all(color: border),
          ),
        ),
        const SizedBox(height: 14),
        ...List.generate(
          4,
              (index) {
            return Container(
              height: 190,
              margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(
                color: surface,
                borderRadius: BorderRadius.circular(21),
                border: Border.all(color: border),
              ),
            );
          },
        ),
      ],
    );
  }

  // ============================================================
  // SUBMIT AREA
  // ============================================================

  Widget buildSubmitArea(
      List<Map<String, dynamic>> quizzes,
      ) {
    final allAnswered = quizzes.isNotEmpty &&
        List<bool>.generate(
          quizzes.length,
              (index) => selectedAnswers[index]?.trim().isNotEmpty ?? false,
        ).every((answered) => answered);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 11, 16, 13),
      decoration: BoxDecoration(
        color: bg.withValues(alpha: 0.97),
        border: const Border(
          top: BorderSide(color: border),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  allAnswered
                      ? Icons.check_circle_rounded
                      : Icons.info_outline_rounded,
                  size: 14,
                  color: allAnswered ? green : textSecondary,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    allAnswered
                        ? 'ALL QUESTIONS ANSWERED • READY TO SUBMIT'
                        : '${quizzes.length - selectedAnswers.length} '
                        'QUESTION(S) REMAINING',
                    style: TextStyle(
                      color: allAnswered ? green : textSecondary,
                      fontSize: 7.5,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 9),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: isSubmitting ? null : () => submitQuiz(quizzes),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  disabledBackgroundColor: Colors.transparent,
                  elevation: 0,
                  shadowColor: Colors.transparent,
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Ink(
                  decoration: BoxDecoration(
                    gradient: isSubmitting
                        ? const LinearGradient(
                      colors: [
                        Color(0xff172235),
                        Color(0xff111827),
                      ],
                    )
                        : const LinearGradient(
                      colors: [
                        Color(0xff008CFF),
                        Color(0xff7C3AED),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSubmitting
                          ? border
                          : cyan.withValues(alpha: 0.38),
                    ),
                    boxShadow: isSubmitting
                        ? null
                        : [
                      BoxShadow(
                        color: blue.withValues(alpha: 0.18),
                        blurRadius: 20,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Center(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 180),
                      child: isSubmitting
                          ? const Row(
                        key: ValueKey('loading'),
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 19,
                            height: 19,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: cyan,
                            ),
                          ),
                          SizedBox(width: 10),
                          Text(
                            'SUBMITTING...',
                            style: TextStyle(
                              color: textPrimary,
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      )
                          : const Row(
                        key: ValueKey('submit'),
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.check_circle_outline_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'SUBMIT QUIZ',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final quizzes = getQuizQuestions();

    return PopScope(
      canPop: !isSubmitting,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && isSubmitting) {
          showMessage(
            'Please wait while the quiz is being submitted.',
            isError: true,
          );
        }
      },
      child: Scaffold(
        backgroundColor: bg,
        appBar: buildAppBar(),
        body: Stack(
          children: [
            Positioned.fill(
              child: IgnorePointer(
                child: buildCyberBackground(),
              ),
            ),
            Column(
              children: [
                buildStatusBar(),
                Expanded(
                  child: quizzes.isEmpty
                      ? emptyQuizState()
                      : ListView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 7, 16, 25),
                    children: [
                      quizHeader(quizzes.length),
                      const SizedBox(height: 7),
                      for (int i = 0; i < quizzes.length; i++)
                        questionCard(i, quizzes[i]),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
                if (quizzes.isNotEmpty) buildSubmitArea(quizzes),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ================================================================
// QUIZ REVIEW SCREEN (wrong answers + correct answers)
// ================================================================

class QuizReviewScreen extends StatelessWidget {
  final String courseName;
  final List<Map<String, dynamic>> questions;
  final Map<int, String> selectedAnswers;
  final int score;

  const QuizReviewScreen({
    super.key,
    required this.courseName,
    required this.questions,
    required this.selectedAnswers,
    required this.score,
  });

  static const Color bg = Color(0xff030712);
  static const Color surface = Color(0xff08111F);
  static const Color blue = Color(0xff168CFF);
  static const Color cyan = Color(0xff00E5FF);
  static const Color purple = Color(0xff7C3AED);
  static const Color green = Color(0xff00E5A0);
  static const Color red = Color(0xffFF4D6D);
  static const Color textPrimary = Color(0xffF5F7FF);
  static const Color textSecondary = Color(0xff8EA0BA);
  static const Color border = Color(0xff1A2B45);

  bool _isCorrect(int index) {
    final selected = (selectedAnswers[index] ?? '').trim().toLowerCase();
    final correct =
    (questions[index]['answer'] ?? '').toString().trim().toLowerCase();
    return selected.isNotEmpty && selected == correct;
  }

  @override
  Widget build(BuildContext context) {
    final total = questions.length;
    final wrong = total - score;
    final percentage = total == 0 ? 0 : ((score / total) * 100).round();

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        foregroundColor: textPrimary,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'QUIZ REVIEW',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                children: [
                  _summaryCard(percentage, wrong, total),
                  const SizedBox(height: 16),
                  for (int i = 0; i < questions.length; i++)
                    _questionCard(i),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'BACK TO COURSE',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryCard(int percentage, int wrong, int total) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xff0B1D3B), Color(0xff171035)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: blue.withValues(alpha: 0.32)),
      ),
      child: Column(
        children: [
          Text(
            '$percentage%',
            style: const TextStyle(
              color: cyan,
              fontSize: 40,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            courseName.toUpperCase(),
            style: const TextStyle(
              color: textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _stat('SAHI', '$score', green),
              _stat('GALAT', '$wrong', red),
              _stat('TOTAL', '$total', cyan),
            ],
          ),
        ],
      ),
    );
  }

  Widget _stat(String label, String value, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              color: textSecondary,
              fontSize: 9,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _questionCard(int index) {
    final data = questions[index];
    final question = (data['question'] ?? '').toString().trim();
    final correctAnswer = (data['answer'] ?? '').toString().trim();
    final selected = (selectedAnswers[index] ?? '').trim();
    final correct = _isCorrect(index);
    final color = correct ? green : red;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.40)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                correct ? Icons.check_circle_rounded : Icons.cancel_rounded,
                color: color,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'QUESTION ${index + 1}',
                style: TextStyle(
                  color: color,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          Text(
            question,
            style: const TextStyle(
              color: textPrimary,
              fontSize: 14,
              height: 1.45,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          if (!correct)
            _answerBox(
              'TUMHARA JAWAB',
              selected.isEmpty ? 'Answer nahi diya' : selected,
              red,
            ),
          if (!correct) const SizedBox(height: 8),
          _answerBox('SAHI JAWAB', correctAnswer, green),
        ],
      ),
    );
  }

  Widget _answerBox(String label, String text, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 9,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            text,
            style: const TextStyle(
              color: textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}