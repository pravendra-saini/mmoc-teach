import 'dart:math' as math;

import 'package:flutter/material.dart';

class ResultScreen extends StatelessWidget {
  final int score;
  final int total;

  const ResultScreen({
    super.key,
    required this.score,
    required this.total,
  });

  // ============================================================
  // CYBER-TECH THEME
  // ============================================================

  static const Color bg = Color(0xff020817);
  static const Color bg2 = Color(0xff061329);

  static const Color blue = Color(0xff06B6FF);
  static const Color blue2 = Color(0xff2563EB);

  static const Color purple = Color(0xff8B5CF6);
  static const Color purple2 = Color(0xff6D28D9);

  static const Color cyan = Color(0xff22D3EE);
  static const Color green = Color(0xff00E5A0);
  static const Color red = Color(0xffFF4D67);
  static const Color orange = Color(0xffFF9F1C);

  static const Color white = Color(0xffF8FAFF);
  static const Color muted = Color(0xff8EA4C2);
  static const Color card = Color(0xff07182F);
  static const Color card2 = Color(0xff091D38);
  static const Color line = Color(0xff12345A);

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final double percentage =
    total > 0 ? (score / total) * 100 : 0;

    final bool passed = percentage >= 40;

    final Color statusColor =
    passed ? green : red;

    final int incorrect =
    total > score ? total - score : 0;

    return Scaffold(
      backgroundColor: bg,

      body: Stack(
        children: [
          // ======================================================
          // BACKGROUND GLOW
          // ======================================================

          Positioned(
            top: -130,
            right: -100,
            child: _glowCircle(
              size: 290,
              color: purple,
            ),
          ),

          Positioned(
            top: 260,
            left: -170,
            child: _glowCircle(
              size: 320,
              color: blue,
            ),
          ),

          Positioned(
            bottom: -170,
            right: -100,
            child: _glowCircle(
              size: 330,
              color: cyan,
            ),
          ),

          // ======================================================
          // CONTENT
          // ======================================================

          SafeArea(
            child: Column(
              children: [
                _buildTopBar(context),

                Expanded(
                  child: SingleChildScrollView(
                    physics:
                    const BouncingScrollPhysics(),
                    padding:
                    const EdgeInsets.fromLTRB(
                      18,
                      8,
                      18,
                      30,
                    ),
                    child: Column(
                      children: [
                        _buildHero(
                          passed: passed,
                          percentage: percentage,
                          statusColor: statusColor,
                        ),

                        const SizedBox(height: 18),

                        _buildScorePanel(
                          percentage: percentage,
                          passed: passed,
                          statusColor: statusColor,
                        ),

                        const SizedBox(height: 14),

                        _buildStats(
                          score: score,
                          incorrect: incorrect,
                          total: total,
                        ),

                        const SizedBox(height: 14),

                        _buildPerformanceMessage(
                          passed: passed,
                          percentage: percentage,
                        ),

                        const SizedBox(height: 14),

                        _buildNextStep(
                          passed: passed,
                        ),

                        const SizedBox(height: 22),

                        _buildHomeButton(context),

                        const SizedBox(height: 18),

                        _buildFooter(),
                      ],
                    ),
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
  // TOP BAR
  // ============================================================

  Widget _buildTopBar(BuildContext context) {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
      ),
      decoration: BoxDecoration(
        color: bg.withValues(alpha: 0.94),
        border: const Border(
          bottom: BorderSide(
            color: line,
            width: 0.7,
          ),
        ),
      ),
      child: Row(
        children: [
          // ------------------------------------------------------
          // ICON
          // ------------------------------------------------------

          Container(
            width: 43,
            height: 43,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  blue2,
                  purple2,
                ],
              ),
              borderRadius:
              BorderRadius.circular(13),
              boxShadow: [
                BoxShadow(
                  color:
                  blue.withValues(alpha: 0.25),
                  blurRadius: 16,
                ),
              ],
            ),
            child: const Icon(
              Icons.analytics_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),

          const SizedBox(width: 12),

          // ------------------------------------------------------
          // TITLE
          // ------------------------------------------------------

          const Expanded(
            child: Column(
              mainAxisAlignment:
              MainAxisAlignment.center,
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  'QUIZ RESULT',
                  style: TextStyle(
                    color: white,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.8,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Performance analysis',
                  style: TextStyle(
                    color: muted,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // ------------------------------------------------------
          // STATUS DOT
          // ------------------------------------------------------

          Container(
            padding:
            const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 7,
            ),
            decoration: BoxDecoration(
              color:
              blue.withValues(alpha: 0.08),
              borderRadius:
              BorderRadius.circular(30),
              border: Border.all(
                color:
                blue.withValues(alpha: 0.28),
              ),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.bolt_rounded,
                  color: cyan,
                  size: 14,
                ),
                SizedBox(width: 4),
                Text(
                  'RESULT',
                  style: TextStyle(
                    color: cyan,
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.7,
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
  // HERO
  // ============================================================

  Widget _buildHero({
    required bool passed,
    required double percentage,
    required Color statusColor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        20,
        25,
        20,
        22,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xff071A38),
            const Color(0xff0A1230),
            passed
                ? const Color(0xff062C2B)
                : const Color(0xff271327),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius:
        BorderRadius.circular(27),
        border: Border.all(
          color:
          statusColor.withValues(alpha: 0.38),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color:
            statusColor.withValues(alpha: 0.12),
            blurRadius: 28,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        children: [
          // ------------------------------------------------------
          // STATUS ICON
          // ------------------------------------------------------

          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 105,
                height: 105,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: statusColor
                        .withValues(alpha: 0.15),
                    width: 2,
                  ),
                ),
              ),

              Container(
                width: 84,
                height: 84,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      statusColor
                          .withValues(alpha: 0.20),
                      statusColor
                          .withValues(alpha: 0.05),
                    ],
                  ),
                  border: Border.all(
                    color: statusColor
                        .withValues(alpha: 0.65),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: statusColor
                          .withValues(alpha: 0.30),
                      blurRadius: 22,
                    ),
                  ],
                ),
                child: Icon(
                  passed
                      ? Icons.emoji_events_rounded
                      : Icons.refresh_rounded,
                  color: passed
                      ? orange
                      : statusColor,
                  size: 42,
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          Text(
            passed
                ? 'QUIZ COMPLETED'
                : 'KEEP GOING',
            style: TextStyle(
              color: statusColor,
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
            ),
          ),

          const SizedBox(height: 7),

          Text(
            passed
                ? 'Excellent work!'
                : 'Your learning journey continues.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: white,
              fontSize: 25,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 7),

          Text(
            passed
                ? 'You successfully completed this quiz.'
                : 'Review your lessons and improve your score.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: muted,
              fontSize: 12.5,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 18),

          // ------------------------------------------------------
          // STATUS CHIP
          // ------------------------------------------------------

          Container(
            padding:
            const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 9,
            ),
            decoration: BoxDecoration(
              color:
              statusColor.withValues(alpha: 0.08),
              borderRadius:
              BorderRadius.circular(30),
              border: Border.all(
                color:
                statusColor.withValues(alpha: 0.35),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  passed
                      ? Icons.check_circle_rounded
                      : Icons.info_rounded,
                  color: statusColor,
                  size: 17,
                ),
                const SizedBox(width: 7),
                Text(
                  passed
                      ? 'PASS • GREAT WORK'
                      : 'KEEP PRACTICING',
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.7,
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
  // SCORE PANEL
  // ============================================================

  Widget _buildScorePanel({
    required double percentage,
    required bool passed,
    required Color statusColor,
  }) {
    final double progress =
    total > 0 ? score / total : 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: card,
        borderRadius:
        BorderRadius.circular(24),
        border: Border.all(
          color: line,
        ),
        boxShadow: [
          BoxShadow(
            color:
            Colors.black.withValues(alpha: 0.30),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // ------------------------------------------------------
          // SECTION TITLE
          // ------------------------------------------------------

          Row(
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: cyan,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color:
                      cyan.withValues(alpha: 0.8),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              const Text(
                'PERFORMANCE',
                style: TextStyle(
                  color: white,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.4,
                ),
              ),

              const Spacer(),

              Text(
                passed ? 'PASSED' : 'RETRY',
                style: TextStyle(
                  color: statusColor,
                  fontSize: 9.5,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // ------------------------------------------------------
          // SCORE RING
          // ------------------------------------------------------

          SizedBox(
            width: 180,
            height: 180,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 180,
                  height: 180,
                  child:
                  CircularProgressIndicator(
                    value: 1,
                    strokeWidth: 11,
                    color:
                    const Color(0xff102946),
                  ),
                ),

                SizedBox(
                  width: 180,
                  height: 180,
                  child:
                  CircularProgressIndicator(
                    value: progress.clamp(
                      0.0,
                      1.0,
                    ),
                    strokeWidth: 11,
                    strokeCap:
                    StrokeCap.round,
                    valueColor:
                    AlwaysStoppedAnimation<
                        Color>(
                      statusColor,
                    ),
                  ),
                ),

                Container(
                  width: 135,
                  height: 135,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: bg2,
                    border: Border.all(
                      color: statusColor
                          .withValues(alpha: 0.20),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment:
                    MainAxisAlignment.center,
                    children: [
                      Text(
                        '${percentage.toStringAsFixed(0)}%',
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 34,
                          fontWeight:
                          FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'SCORE',
                        style: TextStyle(
                          color: muted,
                          fontSize: 9,
                          fontWeight:
                          FontWeight.w800,
                          letterSpacing: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // ------------------------------------------------------
          // SCORE TEXT
          // ------------------------------------------------------

          Text(
            '$score / $total',
            style: const TextStyle(
              color: white,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 4),

          const Text(
            'Correct answers',
            style: TextStyle(
              color: muted,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 18),

          // ------------------------------------------------------
          // CYBER PROGRESS
          // ------------------------------------------------------

          ClipRRect(
            borderRadius:
            BorderRadius.circular(20),
            child: Stack(
              children: [
                Container(
                  height: 7,
                  width: double.infinity,
                  color: const Color(0xff102946),
                ),
                FractionallySizedBox(
                  widthFactor:
                  progress.clamp(0.0, 1.0),
                  child: Container(
                    height: 7,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          blue,
                          purple,
                          statusColor,
                        ],
                      ),
                    ),
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
  // STATS
  // ============================================================

  Widget _buildStats({
    required int score,
    required int incorrect,
    required int total,
  }) {
    return Row(
      children: [
        Expanded(
          child: _statCard(
            title: 'CORRECT',
            value: '$score',
            icon: Icons.check_circle_rounded,
            color: green,
          ),
        ),

        const SizedBox(width: 9),

        Expanded(
          child: _statCard(
            title: 'INCORRECT',
            value: '$incorrect',
            icon: Icons.close_rounded,
            color: red,
          ),
        ),

        const SizedBox(width: 9),

        Expanded(
          child: _statCard(
            title: 'TOTAL',
            value: '$total',
            icon: Icons.quiz_rounded,
            color: blue,
          ),
        ),
      ],
    );
  }

  Widget _statCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding:
      const EdgeInsets.symmetric(
        vertical: 15,
        horizontal: 6,
      ),
      decoration: BoxDecoration(
        color: card,
        borderRadius:
        BorderRadius.circular(18),
        border: Border.all(
          color: color.withValues(alpha: 0.20),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 35,
            height: 35,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.09),
              shape: BoxShape.circle,
              border: Border.all(
                color:
                color.withValues(alpha: 0.25),
              ),
            ),
            child: Icon(
              icon,
              color: color,
              size: 18,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            value,
            style: const TextStyle(
              color: white,
              fontSize: 19,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 2),

          Text(
            title,
            style: const TextStyle(
              color: muted,
              fontSize: 8.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.6,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PERFORMANCE MESSAGE
  // ============================================================

  Widget _buildPerformanceMessage({
    required bool passed,
    required double percentage,
  }) {
    final Color color =
    passed ? green : orange;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: card,
        borderRadius:
        BorderRadius.circular(20),
        border: Border.all(
          color: color.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Container(
            width: 43,
            height: 43,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  color.withValues(alpha: 0.18),
                  color.withValues(alpha: 0.05),
                ],
              ),
              borderRadius:
              BorderRadius.circular(13),
              border: Border.all(
                color:
                color.withValues(alpha: 0.30),
              ),
            ),
            child: Icon(
              passed
                  ? Icons.auto_awesome_rounded
                  : Icons.lightbulb_rounded,
              color: color,
              size: 21,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  passed
                      ? 'LEVEL UP! 🚀'
                      : 'KEEP LEARNING',
                  style: TextStyle(
                    color: color,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.6,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  passed
                      ? 'Great performance. Continue learning and complete the remaining lessons to unlock your certificate.'
                      : 'Review your lessons carefully and attempt the quiz again. Every attempt makes you better.',
                  style: const TextStyle(
                    color: muted,
                    fontSize: 11.5,
                    height: 1.5,
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
  // NEXT STEP
  // ============================================================

  Widget _buildNextStep({
    required bool passed,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xff081A35),
            Color(0xff10153B),
          ],
        ),
        borderRadius:
        BorderRadius.circular(20),
        border: Border.all(
          color: purple.withValues(alpha: 0.28),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 47,
            height: 47,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  blue2,
                  purple2,
                ],
              ),
              borderRadius:
              BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color:
                  purple.withValues(alpha: 0.20),
                  blurRadius: 15,
                ),
              ],
            ),
            child: Icon(
              passed
                  ? Icons.school_rounded
                  : Icons.menu_book_rounded,
              color: Colors.white,
              size: 23,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  passed
                      ? 'NEXT MISSION'
                      : 'IMPROVE YOUR SCORE',
                  style: const TextStyle(
                    color: white,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  passed
                      ? 'Continue your learning journey.'
                      : 'Review lessons and try the quiz again.',
                  style: const TextStyle(
                    color: muted,
                    fontSize: 10.5,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),

          Container(
            width: 31,
            height: 31,
            decoration: BoxDecoration(
              color:
              purple.withValues(alpha: 0.10),
              shape: BoxShape.circle,
              border: Border.all(
                color:
                purple.withValues(alpha: 0.30),
              ),
            ),
            child: const Icon(
              Icons.arrow_forward_rounded,
              color: purple,
              size: 17,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // HOME BUTTON
  // ============================================================

  Widget _buildHomeButton(
      BuildContext context,
      ) {
    return Container(
      width: double.infinity,
      height: 57,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            blue2,
            purple2,
          ],
        ),
        borderRadius:
        BorderRadius.circular(17),
        boxShadow: [
          BoxShadow(
            color:
            blue.withValues(alpha: 0.25),
            blurRadius: 22,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () {
          Navigator.popUntil(
            context,
                (route) => route.isFirst,
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(17),
          ),
        ),
        child: const Row(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            Icon(
              Icons.home_rounded,
              size: 21,
            ),
            SizedBox(width: 9),
            Text(
              'BACK TO HOME',
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.7,
              ),
            ),
            SizedBox(width: 8),
            Icon(
              Icons.arrow_forward_rounded,
              size: 19,
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // FOOTER
  // ============================================================

  Widget _buildFooter() {
    return Column(
      children: [
        Row(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                color: cyan,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color:
                    cyan.withValues(alpha: 0.7),
                    blurRadius: 8,
                  ),
                ],
              ),
            ),

            const SizedBox(width: 7),

            const Text(
              'MMOC TEACH',
              style: TextStyle(
                color: white,
                fontSize: 12,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
              ),
            ),

            const SizedBox(width: 7),

            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                color: purple,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color:
                    purple.withValues(alpha: 0.7),
                    blurRadius: 8,
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 5),

        const Text(
          'LEARN  •  GROW  •  SUCCEED',
          style: TextStyle(
            color: muted,
            fontSize: 8.5,
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // GLOW CIRCLE
  // ============================================================

  Widget _glowCircle({
    required double size,
    required Color color,
  }) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color.withValues(alpha: 0.07),
              color.withValues(alpha: 0.025),
              Colors.transparent,
            ],
            stops: const [
              0.0,
              0.45,
              1.0,
            ],
          ),
        ),
      ),
    );
  }
}