import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ReviewScreen extends StatefulWidget {
  final String courseName;

  const ReviewScreen({
    super.key,
    required this.courseName,
  });

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  // ============================================================
  // CYBER TECH THEME
  // ============================================================

  static const Color bg = Color(0xff050816);
  static const Color surface = Color(0xff0B1020);
  static const Color surface2 = Color(0xff10172B);

  static const Color blue = Color(0xff00A8FF);
  static const Color cyan = Color(0xff00E5FF);
  static const Color purple = Color(0xff8B5CF6);
  static const Color green = Color(0xff00F5A0);
  static const Color orange = Color(0xffFF9F43);
  static const Color red = Color(0xffFF4D6D);

  static const Color textPrimary = Color(0xffF5F7FF);
  static const Color textSecondary = Color(0xff94A3B8);
  static const Color border = Color(0xff1C2942);
  static const Color starColor = Color(0xffFFC857);

  // ============================================================
  // CONTROLLER
  // ============================================================

  final TextEditingController reviewController =
  TextEditingController();

  // ============================================================
  // STATE
  // ============================================================

  int rating = 5;
  bool isLoading = false;

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    reviewController.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

  // ============================================================
  // SUBMIT REVIEW
  // ============================================================

  Future<void> submitReview() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      showMessage(
        'Please login again',
        isError: true,
      );
      return;
    }

    final reviewText = reviewController.text.trim();

    if (reviewText.isEmpty) {
      showMessage(
        'Please write your review',
        isError: true,
      );
      return;
    }

    if (reviewText.length < 5) {
      showMessage(
        'Please write a little more about the course',
        isError: true,
      );
      return;
    }

    if (isLoading) return;

    setState(() {
      isLoading = true;
    });

    try {
      String studentName = 'Student';

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        final data = userDoc.data();

        if (data != null) {
          final firestoreName =
          (data['name'] ?? '').toString().trim();

          if (firestoreName.isNotEmpty) {
            studentName = firestoreName;
          }
        }
      }

      if (studentName == 'Student') {
        final authName =
        (user.displayName ?? '').trim();

        if (authName.isNotEmpty) {
          studentName = authName;
        }
      }

      await FirebaseFirestore.instance
          .collection('reviews')
          .add({
        'uid': user.uid,
        'studentName': studentName,
        'courseName': widget.courseName.trim(),
        'rating': rating,
        'review': reviewText,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      showMessage(
        'Review submitted successfully',
      );

      await Future.delayed(
        const Duration(milliseconds: 600),
      );

      if (!mounted) return;

      Navigator.pop(context);
    } catch (e) {
      debugPrint('Review Submit Error: $e');

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      showMessage(
        'Unable to submit review. Please try again.',
        isError: true,
      );
    }
  }

  // ============================================================
  // RATING STAR
  // ============================================================

  Widget buildStar(int index) {
    final selected = index <= rating;

    return GestureDetector(
      onTap: isLoading
          ? null
          : () {
        setState(() {
          rating = index;
        });
      },
      child: AnimatedScale(
        scale: selected ? 1.12 : 1.0,
        duration: const Duration(milliseconds: 180),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          transitionBuilder: (child, animation) {
            return ScaleTransition(
              scale: animation,
              child: child,
            );
          },
          child: Container(
            key: ValueKey('$index-$selected'),
            width: 51,
            height: 51,
            margin: const EdgeInsets.symmetric(
              horizontal: 3,
            ),
            decoration: BoxDecoration(
              color: selected
                  ? starColor.withValues(alpha: 0.10)
                  : Colors.transparent,
              shape: BoxShape.circle,
              border: Border.all(
                color: selected
                    ? starColor.withValues(alpha: 0.35)
                    : border,
              ),
              boxShadow: selected
                  ? [
                BoxShadow(
                  color:
                  starColor.withValues(alpha: 0.20),
                  blurRadius: 15,
                  spreadRadius: 1,
                ),
              ]
                  : null,
            ),
            child: Icon(
              selected
                  ? Icons.star_rounded
                  : Icons.star_border_rounded,
              color: selected
                  ? starColor
                  : textSecondary,
              size: 29,
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // RATING TEXT
  // ============================================================

  String getRatingText() {
    switch (rating) {
      case 1:
        return 'VERY POOR';
      case 2:
        return 'POOR';
      case 3:
        return 'GOOD';
      case 4:
        return 'VERY GOOD';
      case 5:
        return 'EXCELLENT';
      default:
        return 'EXCELLENT';
    }
  }

  // ============================================================
  // RATING DESCRIPTION
  // ============================================================

  String getRatingDescription() {
    switch (rating) {
      case 1:
        return 'We are sorry the course did not meet your expectations.';
      case 2:
        return 'Your feedback can help us improve this course.';
      case 3:
        return 'Thanks! Your feedback helps us improve.';
      case 4:
        return 'Great! We are glad you enjoyed the course.';
      case 5:
        return 'Awesome! We are happy you loved the course.';
      default:
        return 'Share your experience with other students.';
    }
  }

  // ============================================================
  // SNACKBAR
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
          margin: const EdgeInsets.all(16),
          backgroundColor:
          isError ? const Color(0xff7F1D1D) : const Color(0xff064E3B),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(
              color: isError
                  ? red.withValues(alpha: 0.45)
                  : green.withValues(alpha: 0.45),
            ),
          ),
          content: Row(
            children: [
              Icon(
                isError
                    ? Icons.error_outline_rounded
                    : Icons.check_circle_outline_rounded,
                color: isError ? red : green,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
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
  // CYBER BACKGROUND
  // ============================================================

  Widget buildBackground() {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xff050816),
                Color(0xff070B19),
                Color(0xff03050D),
              ],
            ),
          ),
        ),

        Positioned(
          top: -130,
          right: -100,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: purple.withValues(alpha: 0.08),
              boxShadow: [
                BoxShadow(
                  color: purple.withValues(alpha: 0.10),
                  blurRadius: 100,
                  spreadRadius: 30,
                ),
              ],
            ),
          ),
        ),

        Positioned(
          top: 300,
          left: -150,
          child: Container(
            width: 280,
            height: 280,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: blue.withValues(alpha: 0.06),
              boxShadow: [
                BoxShadow(
                  color: blue.withValues(alpha: 0.08),
                  blurRadius: 100,
                  spreadRadius: 20,
                ),
              ],
            ),
          ),
        ),

        Positioned(
          bottom: -130,
          right: -80,
          child: Container(
            width: 260,
            height: 260,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: cyan.withValues(alpha: 0.045),
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // APP BAR
  // ============================================================

  PreferredSizeWidget buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: bg.withValues(alpha: 0.96),
      foregroundColor: textPrimary,
      centerTitle: false,
      titleSpacing: 18,
      leading: IconButton(
        onPressed: () {
          Navigator.pop(context);
        },
        icon: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: surface2,
            borderRadius: BorderRadius.circular(11),
            border: Border.all(
              color: border,
            ),
          ),
          child: const Icon(
            Icons.arrow_back_rounded,
            color: cyan,
            size: 20,
          ),
        ),
      ),
      title: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'REVIEW CENTER',
            style: TextStyle(
              color: textPrimary,
              fontSize: 17,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.8,
            ),
          ),
          SizedBox(height: 2),
          Text(
            'STUDENT FEEDBACK SYSTEM',
            style: TextStyle(
              color: cyan,
              fontSize: 8.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TOP STATUS BAR
  // ============================================================

  Widget buildStatusBar() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 13,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: border,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 9,
            height: 9,
            decoration: BoxDecoration(
              color: green,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: green.withValues(alpha: 0.65),
                  blurRadius: 8,
                ),
              ],
            ),
          ),
          const SizedBox(width: 9),
          const Text(
            'FEEDBACK CHANNEL ONLINE',
            style: TextStyle(
              color: textSecondary,
              fontSize: 9.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.7,
            ),
          ),
          const Spacer(),
          Icon(
            Icons.lock_outline_rounded,
            size: 13,
            color: green.withValues(alpha: 0.85),
          ),
          const SizedBox(width: 5),
          const Text(
            'SECURE',
            style: TextStyle(
              color: green,
              fontSize: 8.5,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // HERO CARD
  // ============================================================

  Widget buildHero() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xff101B3A),
            Color(0xff0B1025),
            Color(0xff11102B),
          ],
        ),
        border: Border.all(
          color: blue.withValues(alpha: 0.35),
        ),
        boxShadow: [
          BoxShadow(
            color: blue.withValues(alpha: 0.08),
            blurRadius: 25,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -25,
            top: -35,
            child: Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: purple.withValues(alpha: 0.12),
                  width: 2,
                ),
              ),
            ),
          ),

          Positioned(
            right: 15,
            top: 5,
            child: Container(
              width: 75,
              height: 75,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: cyan.withValues(alpha: 0.08),
                ),
              ),
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          blue,
                          purple,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(17),
                      boxShadow: [
                        BoxShadow(
                          color: blue.withValues(alpha: 0.25),
                          blurRadius: 20,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.rate_review_rounded,
                      color: Colors.white,
                      size: 29,
                    ),
                  ),

                  const SizedBox(width: 14),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'SHARE YOUR EXPERIENCE',
                          style: TextStyle(
                            color: textPrimary,
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Your feedback helps us build a better learning system.',
                          style: TextStyle(
                            color:
                            textSecondary.withValues(alpha: 0.95),
                            fontSize: 10.5,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(13),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: border,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.school_rounded,
                      color: cyan,
                      size: 17,
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Text(
                        widget.courseName.trim().isEmpty
                            ? 'Selected Course'
                            : widget.courseName.trim(),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: textPrimary,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SECTION HEADER
  // ============================================================

  Widget buildSectionHeader({
    required String number,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          width: 39,
          height: 39,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(11),
            border: Border.all(
              color: color.withValues(alpha: 0.28),
            ),
          ),
          child: Icon(
            icon,
            color: color,
            size: 20,
          ),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'MODULE $number',
                    style: TextStyle(
                      color: color,
                      fontSize: 8.5,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(width: 7),
                  Container(
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 3),
              Text(
                title,
                style: const TextStyle(
                  color: textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  color: textSecondary,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // RATING CARD
  // ============================================================

  Widget buildRatingCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: purple.withValues(alpha: 0.25),
        ),
        boxShadow: [
          BoxShadow(
            color: purple.withValues(alpha: 0.055),
            blurRadius: 22,
          ),
        ],
      ),
      child: Column(
        children: [
          buildSectionHeader(
            number: '01',
            title: 'Rate This Course',
            subtitle: 'Select a rating based on your experience',
            icon: Icons.star_rounded,
            color: starColor,
          ),

          const SizedBox(height: 22),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              buildStar(1),
              buildStar(2),
              buildStar(3),
              buildStar(4),
              buildStar(5),
            ],
          ),

          const SizedBox(height: 17),

          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Container(
              key: ValueKey(rating),
              padding: const EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 7,
              ),
              decoration: BoxDecoration(
                color: starColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: starColor.withValues(alpha: 0.22),
                ),
              ),
              child: Text(
                getRatingText(),
                style: const TextStyle(
                  color: starColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.4,
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),

          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Text(
              getRatingDescription(),
              key: ValueKey(
                'description-$rating',
              ),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: textSecondary,
                fontSize: 10.5,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // REVIEW INPUT
  // ============================================================

  Widget buildReviewInput() {
    final characterCount =
        reviewController.text.length;

    final hasEnoughText = characterCount >= 5;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: blue.withValues(alpha: 0.25),
        ),
        boxShadow: [
          BoxShadow(
            color: blue.withValues(alpha: 0.045),
            blurRadius: 22,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildSectionHeader(
            number: '02',
            title: 'Write Your Review',
            subtitle: 'Tell us what you think about this course',
            icon: Icons.edit_note_rounded,
            color: cyan,
          ),

          const SizedBox(height: 18),

          Container(
            decoration: BoxDecoration(
              color: const Color(0xff070C18),
              borderRadius: BorderRadius.circular(17),
              border: Border.all(
                color: border,
              ),
            ),
            child: TextField(
              controller: reviewController,
              maxLines: 7,
              minLines: 5,
              maxLength: 1000,
              enabled: !isLoading,
              textCapitalization:
              TextCapitalization.sentences,
              textInputAction:
              TextInputAction.newline,
              style: const TextStyle(
                color: textPrimary,
                fontSize: 13,
                height: 1.55,
                fontWeight: FontWeight.w500,
              ),
              cursorColor: cyan,
              decoration: InputDecoration(
                hintText:
                'Write your learning experience here...\n\n'
                    'What did you like?\n'
                    'What could be improved?',
                hintStyle: const TextStyle(
                  color: Color(0xff52617A),
                  fontSize: 12,
                  height: 1.5,
                ),
                counterText: '',
                contentPadding: const EdgeInsets.all(16),
                prefixIcon: const Padding(
                  padding: EdgeInsets.only(
                    left: 14,
                    right: 8,
                    bottom: 80,
                  ),
                  child: Icon(
                    Icons.terminal_rounded,
                    color: blue,
                    size: 18,
                  ),
                ),
                prefixIconConstraints:
                const BoxConstraints(
                  minWidth: 42,
                ),
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
              ),
            ),
          ),

          const SizedBox(height: 10),

          Row(
            children: [
              Icon(
                hasEnoughText
                    ? Icons.check_circle_rounded
                    : Icons.info_outline_rounded,
                size: 14,
                color: hasEnoughText
                    ? green
                    : textSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                hasEnoughText
                    ? 'REVIEW READY'
                    : 'MINIMUM 5 CHARACTERS',
                style: TextStyle(
                  color: hasEnoughText
                      ? green
                      : textSecondary,
                  fontSize: 8.5,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.8,
                ),
              ),
              const Spacer(),
              Text(
                '$characterCount / 1000',
                style: const TextStyle(
                  color: textSecondary,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // FEEDBACK INFO
  // ============================================================

  Widget buildInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            purple.withValues(alpha: 0.09),
            blue.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: purple.withValues(alpha: 0.20),
        ),
      ),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: purple.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(11),
              border: Border.all(
                color: purple.withValues(alpha: 0.20),
              ),
            ),
            child: const Icon(
              Icons.lightbulb_outline_rounded,
              color: purple,
              size: 19,
            ),
          ),
          const SizedBox(width: 11),
          const Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  'FEEDBACK PROTOCOL',
                  style: TextStyle(
                    color: purple,
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Be honest and helpful. Your feedback can help '
                      'other students and improve the learning experience.',
                  style: TextStyle(
                    color: textSecondary,
                    fontSize: 10.5,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SUBMIT BUTTON
  // ============================================================

  Widget buildSubmitButton() {
    final canSubmit =
        reviewController.text.trim().length >= 5 &&
            !isLoading;

    return SizedBox(
      width: double.infinity,
      height: 58,
      child: ElevatedButton(
        onPressed: canSubmit
            ? submitReview
            : (isLoading ? null : submitReview),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          disabledBackgroundColor:
          Colors.transparent,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(17),
          ),
        ),
        child: Ink(
          decoration: BoxDecoration(
            gradient: canSubmit
                ? const LinearGradient(
              colors: [
                Color(0xff008CFF),
                Color(0xff6C4BFF),
              ],
            )
                : const LinearGradient(
              colors: [
                Color(0xff1A2437),
                Color(0xff111827),
              ],
            ),
            borderRadius: BorderRadius.circular(17),
            border: Border.all(
              color: canSubmit
                  ? blue.withValues(alpha: 0.55)
                  : border,
            ),
            boxShadow: canSubmit
                ? [
              BoxShadow(
                color: blue.withValues(alpha: 0.18),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ]
                : null,
          ),
          child: Center(
            child: AnimatedSwitcher(
              duration: const Duration(
                milliseconds: 180,
              ),
              child: isLoading
                  ? const Row(
                key: ValueKey('loading'),
                mainAxisAlignment:
                MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child:
                    CircularProgressIndicator(
                      strokeWidth: 2,
                      color: cyan,
                    ),
                  ),
                  SizedBox(width: 11),
                  Text(
                    'SUBMITTING...',
                    style: TextStyle(
                      color: textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              )
                  : Row(
                key: const ValueKey('submit'),
                mainAxisAlignment:
                MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.send_rounded,
                    size: 19,
                    color: canSubmit
                        ? Colors.white
                        : textSecondary,
                  ),
                  const SizedBox(width: 9),
                  Text(
                    'SUBMIT REVIEW',
                    style: TextStyle(
                      color: canSubmit
                          ? Colors.white
                          : textSecondary,
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
    );
  }

  // ============================================================
  // FOOTER
  // ============================================================

  Widget buildFooter() {
    return Column(
      children: [
        Row(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: cyan,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color:
                    cyan.withValues(alpha: 0.5),
                    blurRadius: 7,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'MMOC TEACH',
              style: TextStyle(
                color: textPrimary,
                fontSize: 9.5,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.3,
              ),
            ),
            const SizedBox(width: 7),
            const Text(
              '•',
              style: TextStyle(
                color: textSecondary,
              ),
            ),
            const SizedBox(width: 7),
            const Text(
              'LEARN • GROW • SUCCEED',
              style: TextStyle(
                color: textSecondary,
                fontSize: 8.5,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.7,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          'YOUR VOICE HELPS US EVOLVE',
          style: TextStyle(
            color: Color(0xff52617A),
            fontSize: 7.5,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    reviewController.dispose();
    super.dispose();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: buildAppBar(),
      body: Stack(
        children: [
          buildBackground(),

          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                16,
                10,
                16,
                35,
              ),
              child: Column(
                children: [
                  buildStatusBar(),

                  const SizedBox(height: 15),

                  buildHero(),

                  const SizedBox(height: 18),

                  buildRatingCard(),

                  const SizedBox(height: 16),

                  buildReviewInput(),

                  const SizedBox(height: 14),

                  buildInfoCard(),

                  const SizedBox(height: 20),

                  buildSubmitButton(),

                  const SizedBox(height: 17),

                  buildFooter(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}