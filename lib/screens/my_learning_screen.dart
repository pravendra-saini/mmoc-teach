import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'certificate_screen.dart';

class MyLearningScreen extends StatelessWidget {
  const MyLearningScreen({super.key});

  // ============================================================
  // CYBER TECH THEME
  // ============================================================

  static const Color bg = Color(0xff050816);
  static const Color panel = Color(0xff0B1020);
  static const Color panel2 = Color(0xff10172A);

  static const Color neonBlue = Color(0xff00B7FF);
  static const Color neonPurple = Color(0xff8B5CF6);
  static const Color neonCyan = Color(0xff00F5D4);
  static const Color neonGreen = Color(0xff39FF88);
  static const Color neonOrange = Color(0xffFF8A00);

  static const Color textWhite = Color(0xffF8FAFF);
  static const Color textMuted = Color(0xff8D98B2);
  static const Color border = Color(0xff1C2742);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    // ==========================================================
    // LOGIN REQUIRED
    // ==========================================================

    if (user == null) {
      return const Scaffold(
        backgroundColor: bg,
        body: SafeArea(
          child: _CyberEmptyState(
            icon: Icons.lock_person_rounded,
            title: 'LOGIN REQUIRED',
            subtitle:
            'Sign in to access your learning dashboard.',
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('enrollments')
              .where(
            'uid',
            isEqualTo: user.uid,
          )
              .snapshots(),
          builder: (context, snapshot) {
            // ====================================================
            // LOADING
            // ====================================================

            if (snapshot.connectionState ==
                ConnectionState.waiting) {
              return const _CyberLoadingState();
            }

            // ====================================================
            // ERROR
            // ====================================================

            if (snapshot.hasError) {
              debugPrint(
                'MY LEARNING ERROR: ${snapshot.error}',
              );

              return const _CyberEmptyState(
                icon: Icons.cloud_off_rounded,
                title: 'CONNECTION ERROR',
                subtitle:
                'Unable to load your learning data. Please try again.',
                isError: true,
              );
            }

            // ====================================================
            // NO COURSES
            // ====================================================

            if (!snapshot.hasData ||
                snapshot.data!.docs.isEmpty) {
              return const _CyberEmptyState(
                icon: Icons.school_rounded,
                title: 'NO ACTIVE COURSES',
                subtitle:
                'Enroll in a course and your learning journey will appear here.',
              );
            }

            // ====================================================
            // COURSES
            // ====================================================

            final courses = snapshot.data!.docs;

            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // ==================================================
                // HEADER
                // ==================================================

                SliverToBoxAdapter(
                  child: _buildHeader(
                    context,
                    user,
                    courses.length,
                  ),
                ),

                // ==================================================
                // LEARNING OVERVIEW
                // ==================================================

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      16,
                      18,
                      16,
                      0,
                    ),
                    child: _buildLearningOverview(
                      courses.length,
                    ),
                  ),
                ),

                // ==================================================
                // SECTION HEADER
                // ==================================================

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      16,
                      28,
                      16,
                      14,
                    ),
                    child: _buildSectionHeader(
                      courses.length,
                    ),
                  ),
                ),

                // ==================================================
                // COURSE LIST
                // ==================================================

                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    16,
                    0,
                    16,
                    35,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                          (context, index) {
                        final rawData =
                        courses[index].data();

                        if (rawData
                        is! Map<String, dynamic>) {
                          return const SizedBox.shrink();
                        }

                        return Padding(
                          padding:
                          const EdgeInsets.only(
                            bottom: 18,
                          ),
                          child: _CyberCourseCard(
                            user: user,
                            data: rawData,
                          ),
                        );
                      },
                      childCount: courses.length,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader(
      BuildContext context,
      User user,
      int courseCount,
      ) {
    final firstName = _getFirstName(user);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        16,
        12,
        16,
        22,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xff070B19),
            Color(0xff0B1024),
            Color(0xff111330),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border(
          bottom: BorderSide(
            color: border,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // BACK BUTTON
              _topIconButton(
                icon: Icons.arrow_back_rounded,
                onTap: () {
                  Navigator.maybePop(context);
                },
              ),

              const SizedBox(width: 12),

              const Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      'MY LEARNING',
                      style: TextStyle(
                        color: textWhite,
                        fontSize: 19,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.1,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'STUDENT CONTROL PANEL',
                      style: TextStyle(
                        color: neonCyan,
                        fontSize: 8.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.7,
                      ),
                    ),
                  ],
                ),
              ),

              _neonSchoolIcon(),
            ],
          ),

          const SizedBox(height: 25),

          Text(
            'HEY, $firstName 👋',
            style: const TextStyle(
              color: neonBlue,
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
            ),
          ),

          const SizedBox(height: 7),

          Text(
            courseCount == 1
                ? 'Your learning mission is active.'
                : 'Your learning missions are active.',
            style: const TextStyle(
              color: textWhite,
              fontSize: 22,
              fontWeight: FontWeight.w900,
              height: 1.15,
            ),
          ),

          const SizedBox(height: 7),

          Text(
            courseCount == 1
                ? '1 course is currently connected to your account.'
                : '$courseCount courses are currently connected to your account.',
            style: const TextStyle(
              color: textMuted,
              fontSize: 11.5,
              height: 1.45,
            ),
          ),

          const SizedBox(height: 18),

          Row(
            children: [
              Expanded(
                child: _headerStat(
                  icon: Icons.menu_book_rounded,
                  value: '$courseCount',
                  label: 'ACTIVE COURSES',
                  color: neonBlue,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _headerStat(
                  icon: Icons.bolt_rounded,
                  value: 'LIVE',
                  label: 'LEARNING MODE',
                  color: neonGreen,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TOP BACK BUTTON
  // ============================================================

  Widget _topIconButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: panel2,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            borderRadius:
            BorderRadius.circular(14),
            border: Border.all(
              color: border,
            ),
          ),
          child: Icon(
            icon,
            color: textWhite,
            size: 20,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // SCHOOL ICON
  // ============================================================

  Widget _neonSchoolIcon() {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: neonPurple.withValues(
          alpha: 0.10,
        ),
        borderRadius:
        BorderRadius.circular(14),
        border: Border.all(
          color: neonPurple.withValues(
            alpha: 0.35,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: neonPurple.withValues(
              alpha: 0.16,
            ),
            blurRadius: 18,
          ),
        ],
      ),
      child: const Icon(
        Icons.school_rounded,
        color: neonPurple,
        size: 23,
      ),
    );
  }

  // ============================================================
  // HEADER STAT
  // ============================================================

  Widget _headerStat({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: panel.withValues(
          alpha: 0.85,
        ),
        borderRadius:
        BorderRadius.circular(14),
        border: Border.all(
          color: color.withValues(
            alpha: 0.22,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: color.withValues(
                alpha: 0.10,
              ),
              borderRadius:
              BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: color,
              size: 18,
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    color: textWhite,
                    fontSize: 13,
                    fontWeight:
                    FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  maxLines: 1,
                  overflow:
                  TextOverflow.ellipsis,
                  style: TextStyle(
                    color: color,
                    fontSize: 7.5,
                    fontWeight:
                    FontWeight.w800,
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
  // LEARNING OVERVIEW
  // ============================================================

  Widget _buildLearningOverview(
      int courseCount,
      ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: panel,
        borderRadius:
        BorderRadius.circular(20),
        border: Border.all(
          color: neonBlue.withValues(
            alpha: 0.18,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: neonBlue.withValues(
              alpha: 0.06,
            ),
            blurRadius: 22,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              gradient:
              const LinearGradient(
                colors: [
                  neonBlue,
                  neonPurple,
                ],
              ),
              borderRadius:
              BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: neonBlue.withValues(
                    alpha: 0.22,
                  ),
                  blurRadius: 15,
                ),
              ],
            ),
            child: const Icon(
              Icons.rocket_launch_rounded,
              color: Colors.white,
              size: 25,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                const Text(
                  'LEARNING OVERVIEW',
                  style: TextStyle(
                    color: textWhite,
                    fontSize: 13,
                    fontWeight:
                    FontWeight.w900,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  courseCount == 1
                      ? 'Stay consistent and complete your course.'
                      : 'Stay consistent and complete your courses.',
                  style: const TextStyle(
                    color: textMuted,
                    fontSize: 10.5,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: neonCyan.withValues(
                alpha: 0.08,
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.arrow_forward_rounded,
              color: neonCyan,
              size: 16,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SECTION HEADER
  // ============================================================

  Widget _buildSectionHeader(
      int count,
      ) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 31,
          decoration: BoxDecoration(
            gradient:
            const LinearGradient(
              colors: [
                neonBlue,
                neonPurple,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius:
            BorderRadius.circular(10),
          ),
        ),
        const SizedBox(width: 10),
        const Expanded(
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Text(
                'YOUR COURSES',
                style: TextStyle(
                  color: textWhite,
                  fontSize: 18,
                  fontWeight:
                  FontWeight.w900,
                  letterSpacing: 0.8,
                ),
              ),
              SizedBox(height: 3),
              Text(
                'TRACK YOUR PROGRESS',
                style: TextStyle(
                  color: textMuted,
                  fontSize: 8,
                  fontWeight:
                  FontWeight.w700,
                  letterSpacing: 1.3,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding:
          const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 7,
          ),
          decoration: BoxDecoration(
            color: neonBlue.withValues(
              alpha: 0.08,
            ),
            borderRadius:
            BorderRadius.circular(20),
            border: Border.all(
              color: neonBlue.withValues(
                alpha: 0.20,
              ),
            ),
          ),
          child: Text(
            '$count ACTIVE',
            style: const TextStyle(
              color: neonBlue,
              fontSize: 8,
              fontWeight:
              FontWeight.w900,
              letterSpacing: 0.6,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // FIRST NAME
  // ============================================================

  String _getFirstName(User user) {
    final displayName = user.displayName?.trim() ?? '';

    if (displayName.isNotEmpty) {
      final formatted = _formatName(displayName);
      final parts = formatted.split(RegExp(r'\s+'));

      // Prefer a real first-name token when the display name contains one.
      if (parts.isNotEmpty && parts.first.isNotEmpty) {
        // If the display name is one unbroken word, try the email next;
        // email names such as pravendra.saini@... provide a reliable split.
        final hasSeparator = RegExp(r'\s').hasMatch(formatted);
        final hasCamelCase = RegExp(r'[a-z][A-Z]').hasMatch(displayName);

        if (hasSeparator || hasCamelCase) {
          return parts.first.toUpperCase();
        }
      }
    }

    final email = user.email?.trim() ?? '';

    if (email.contains('@')) {
      final emailName = email.split('@').first;
      final formatted = _formatName(emailName);
      final first = formatted.split(RegExp(r'\s+')).first;

      if (first.isNotEmpty) {
        return first.toUpperCase();
      }
    }

    return 'STUDENT';
  }

  String _formatName(String value) {
    var result = value.trim();

    // Handles names such as "PravendraSaini".
    result = result.replaceAllMapped(
      RegExp(r'(?<=[a-z])(?=[A-Z])'),
          (_) => ' ',
    );

    // Handles names such as "Pravendra_Saini" or "Pravendra-Saini".
    result = result.replaceAll(RegExp(r'[_\-.]+'), ' ');
    result = result.replaceAll(RegExp(r'\s+'), ' ').trim();

    return result;
  }
}
// ==================================================================
// CYBER COURSE CARD
// ==================================================================

class _CyberCourseCard extends StatelessWidget {
  final User user;
  final Map<String, dynamic> data;

  const _CyberCourseCard({
    required this.user,
    required this.data,
  });

  static const Color panel = Color(0xff0B1020);
  static const Color panel2 = Color(0xff10172A);

  static const Color neonBlue = Color(0xff00B7FF);
  static const Color neonPurple = Color(0xff8B5CF6);
  static const Color neonCyan = Color(0xff00F5D4);
  static const Color neonGreen = Color(0xff39FF88);
  static const Color neonOrange = Color(0xffFF8A00);

  static const Color textWhite = Color(0xffF8FAFF);
  static const Color textMuted = Color(0xff8D98B2);
  static const Color border = Color(0xff1C2742);

  @override
  Widget build(BuildContext context) {
    final courseName =
    (data['courseName'] ?? '')
        .toString()
        .trim();

    final teacher =
    (data['teacher'] ?? '')
        .toString()
        .trim();

    final storedImage =
    (data['image'] ?? '')
        .toString()
        .trim();

    final image = _resolvedCourseImage(
      storedImage,
      courseName,
    );

    final displayCourseName =
    _prettyCourseName(courseName);

    final rawProgress = data['progress'];

    final int progress = rawProgress is num
        ? rawProgress.toInt().clamp(0, 100).toInt()
        : int.tryParse(
      rawProgress?.toString().trim() ?? '',
    )
        ?.clamp(0, 100)
        .toInt() ??
        0;

    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance
          .collection('quiz_results')
          .where(
        'uid',
        isEqualTo: user.uid,
      )
          .get(),
      builder: (
          context,
          quizSnapshot,
          ) {
        int score = 0;
        int total = 0;

        if (quizSnapshot.hasData &&
            quizSnapshot.data!.docs.isNotEmpty) {
          final targetKey = _normalizeCourseName(courseName);

          final docs = quizSnapshot.data!.docs.where((doc) {
            final raw = doc.data();

            if (raw is! Map<String, dynamic>) {
              return false;
            }

            final savedKey =
            raw['courseKey']?.toString().trim();

            if (savedKey != null && savedKey.isNotEmpty) {
              return _normalizeCourseName(savedKey) == targetKey;
            }

            final savedCourseName =
                raw['courseName']?.toString().trim() ?? '';

            return _normalizeCourseName(savedCourseName) == targetKey;
          }).toList();

          if (docs.isNotEmpty) {
            docs.sort((a, b) {
              final aData = a.data();
              final bData = b.data();

              final aTime = aData is Map<String, dynamic>
                  ? aData['submittedAt']
                  : null;
              final bTime = bData is Map<String, dynamic>
                  ? bData['submittedAt']
                  : null;

              DateTime? toDateTime(dynamic value) {
                if (value is Timestamp) return value.toDate();
                if (value is DateTime) return value;
                return null;
              }

              final aDate = toDateTime(aTime);
              final bDate = toDateTime(bTime);

              if (aDate == null && bDate == null) return 0;
              if (aDate == null) return 1;
              if (bDate == null) return -1;

              return bDate.compareTo(aDate);
            });

            final raw = docs.first.data();

            if (raw is Map<String, dynamic>) {
              final scoreValue = raw['score'];
              final totalValue = raw['total'];

              if (scoreValue is num) {
                score = scoreValue.toInt();
              }

              if (totalValue is num) {
                total = totalValue.toInt();
              }
            }
          }
        }

        final bool attempted =
            total > 0;

        final bool passed =
            attempted &&
                score >= 0 &&
                (score / total) >=
                    0.60;

        final bool completed =
            progress >= 100;

        final bool certificateUnlocked =
            completed && passed;

        return Container(
          decoration: BoxDecoration(
            color: panel,
            borderRadius:
            BorderRadius.circular(22),
            border: Border.all(
              color: certificateUnlocked
                  ? neonGreen.withValues(
                alpha: 0.35,
              )
                  : neonBlue.withValues(
                alpha: 0.16,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: certificateUnlocked
                    ? neonGreen.withValues(
                  alpha: 0.07,
                )
                    : neonBlue.withValues(
                  alpha: 0.045,
                ),
                blurRadius: 25,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              _buildCourseImage(
                image: image,
                courseName:
                courseName,
                completed:
                completed,
              ),

              Padding(
                padding:
                const EdgeInsets.fromLTRB(
                  15,
                  16,
                  15,
                  16,
                ),
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    // ==================================================
                    // TITLE
                    // ==================================================

                    Row(
                      crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                      children: [
                        Expanded(
                          child: Text(
                            displayCourseName.isEmpty
                                ? 'COURSE'
                                : displayCourseName,
                            maxLines: 2,
                            overflow:
                            TextOverflow
                                .ellipsis,
                            style:
                            const TextStyle(
                              color:
                              textWhite,
                              fontSize: 18,
                              fontWeight:
                              FontWeight
                                  .w900,
                              height: 1.25,
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 9,
                        ),
                        _statusBadge(
                          completed:
                          completed,
                          certificateUnlocked:
                          certificateUnlocked,
                        ),
                      ],
                    ),

                    // ==================================================
                    // TEACHER
                    // ==================================================

                    if (teacher.isNotEmpty) ...[
                      const SizedBox(
                        height: 8,
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.person_rounded,
                            color:
                            neonCyan,
                            size: 15,
                          ),
                          const SizedBox(
                            width: 6,
                          ),
                          Expanded(
                            child: Text(
                              teacher,
                              maxLines: 1,
                              overflow:
                              TextOverflow
                                  .ellipsis,
                              style:
                              const TextStyle(
                                color:
                                textMuted,
                                fontSize: 11,
                                fontWeight:
                                FontWeight
                                    .w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],

                    const SizedBox(
                      height: 19,
                    ),

                    // ==================================================
                    // PROGRESS
                    // ==================================================

                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'COURSE PROGRESS',
                            style:
                            TextStyle(
                              color:
                              textMuted,
                              fontSize: 9,
                              fontWeight:
                              FontWeight
                                  .w900,
                              letterSpacing:
                              1,
                            ),
                          ),
                        ),
                        Text(
                          '$progress%',
                          style: TextStyle(
                            color:
                            progress >=
                                100
                                ? neonGreen
                                : neonBlue,
                            fontSize: 15,
                            fontWeight:
                            FontWeight
                                .w900,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(
                      height: 9,
                    ),

                    Container(
                      height: 10,
                      decoration:
                      BoxDecoration(
                        color:
                        const Color(
                          0xff171E32,
                        ),
                        borderRadius:
                        BorderRadius
                            .circular(
                          20,
                        ),
                        border: Border.all(
                          color: border,
                        ),
                      ),
                      child:
                      ClipRRect(
                        borderRadius:
                        BorderRadius
                            .circular(
                          20,
                        ),
                        child:
                        LinearProgressIndicator(
                          value:
                          progress /
                              100,
                          minHeight: 10,
                          backgroundColor:
                          Colors
                              .transparent,
                          valueColor:
                          AlwaysStoppedAnimation<
                              Color>(
                            progress >=
                                100
                                ? neonGreen
                                : neonBlue,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 8,
                    ),

                    Row(
                      children: [
                        Icon(
                          progress >=
                              100
                              ? Icons
                              .check_circle_rounded
                              : Icons
                              .bolt_rounded,
                          color:
                          progress >=
                              100
                              ? neonGreen
                              : neonBlue,
                          size: 13,
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        Expanded(
                          child: Text(
                            progress >=
                                100
                                ? 'COURSE COMPLETED SUCCESSFULLY'
                                : '$progress% COMPLETE • KEEP GOING',
                            style:
                            TextStyle(
                              color: progress >=
                                  100
                                  ? neonGreen
                                  : textMuted,
                              fontSize: 8.5,
                              fontWeight:
                              FontWeight
                                  .w800,
                              letterSpacing:
                              0.5,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(
                      height: 17,
                    ),

                    // ==================================================
                    // QUIZ
                    // ==================================================

                    _quizScoreCard(
                      score: score,
                      total: total,
                      passed: passed,
                    ),

                    const SizedBox(
                      height: 15,
                    ),

                    // ==================================================
                    // CERTIFICATE
                    // ==================================================

                    if (certificateUnlocked)
                      _certificateButton(
                        context,
                        displayCourseName,
                      )
                    else
                      _certificateLockedCard(
                        completed:
                        completed,
                        passed: passed,
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ============================================================
  // COURSE IMAGE
  // ============================================================

  Widget _buildCourseImage({
    required String image,
    required String courseName,
    required bool completed,
  }) {
    return SizedBox(
      height: 185,
      width: double.infinity,
      child: ClipRRect(
        borderRadius:
        const BorderRadius.only(
          topLeft:
          Radius.circular(22),
          topRight:
          Radius.circular(22),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            _courseImageWidget(
              image,
              courseName,
            ),

            Positioned.fill(
              child: DecoratedBox(
                decoration:
                BoxDecoration(
                  gradient:
                  LinearGradient(
                    begin:
                    Alignment.topCenter,
                    end:
                    Alignment.bottomCenter,
                    colors: [
                      Colors.black
                          .withValues(
                        alpha: 0.03,
                      ),
                      Colors.black
                          .withValues(
                        alpha: 0.78,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            Positioned(
              top: 12,
              left: 12,
              child: _cornerLine(),
            ),

            Positioned(
              top: 12,
              right: 12,
              child: _cornerLine(
                flip: true,
              ),
            ),

            Positioned(
              left: 14,
              bottom: 13,
              right: 14,
              child: Row(
                children: [
                  Container(
                    padding:
                    const EdgeInsets
                        .symmetric(
                      horizontal: 9,
                      vertical: 6,
                    ),
                    decoration:
                    BoxDecoration(
                      color: Colors.black
                          .withValues(
                        alpha: 0.60,
                      ),
                      borderRadius:
                      BorderRadius
                          .circular(
                        9,
                      ),
                      border:
                      Border.all(
                        color: neonBlue
                            .withValues(
                          alpha: 0.35,
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisSize:
                      MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons
                              .play_circle_fill_rounded,
                          color:
                          neonBlue,
                          size: 15,
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        Text(
                          completed
                              ? 'COMPLETED'
                              : 'LEARNING',
                          style:
                          TextStyle(
                            color: completed
                                ? neonGreen
                                : textWhite,
                            fontSize: 8,
                            fontWeight:
                            FontWeight
                                .w900,
                            letterSpacing:
                            1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  if (completed)
                    Container(
                      width: 32,
                      height: 32,
                      decoration:
                      BoxDecoration(
                        color: neonGreen
                            .withValues(
                          alpha: 0.12,
                        ),
                        shape:
                        BoxShape.circle,
                        border:
                        Border.all(
                          color: neonGreen
                              .withValues(
                            alpha: 0.40,
                          ),
                        ),
                      ),
                      child:
                      const Icon(
                        Icons
                            .check_rounded,
                        color:
                        neonGreen,
                        size: 18,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cornerLine({
    bool flip = false,
  }) {
    return Transform(
      alignment:
      Alignment.center,
      transform:
      Matrix4.identity()
        ..scale(
          flip ? -1.0 : 1.0,
          1.0,
        ),
      child: Container(
        width: 34,
        height: 24,
        decoration:
        const BoxDecoration(
          border: Border(
            top: BorderSide(
              color: neonBlue,
              width: 2,
            ),
            left: BorderSide(
              color: neonBlue,
              width: 2,
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // IMAGE
  // ============================================================

  String _normalizeCourseName(String value) {
    return value
        .trim()
        .toLowerCase()
        .replaceAll('+', 'plus')
        .replaceAll(RegExp(r'[^a-z0-9]'), '');
  }

  String _resolvedCourseImage(
      String storedImage,
      String courseName,
      ) {
    final key = courseName
        .trim()
        .toLowerCase()
        .replaceAll('+', 'plus')
        .replaceAll(RegExp(r'[^a-z0-9]'), '');

    // Known local course artwork takes priority over an incorrect
    // image value saved in an older enrollment document.
    const localImages = <String, String>{
      'flutter': 'assets/images/flutter.jpg',
      'python': 'assets/images/python.jpg',
      'java': 'assets/images/java.jpg',
      'javascript': 'assets/images/javascript.jpg',
      'kotlin': 'assets/images/kotlin.jpg',
      'swift': 'assets/images/swift.jpg',
      'php': 'assets/images/php.jpg',
      'sql': 'assets/images/sql.jpg',
      'nodejs': 'assets/images/nodejs.jpg',
      'node': 'assets/images/nodejs.jpg',
      'go': 'assets/images/go.jpg',
      'rust': 'assets/images/rust.jpg',
      'matlab': 'assets/images/matlab.jpg',
      'r': 'assets/images/r.jpg',
      'rlanguage': 'assets/images/r.jpg',
      'cpp': 'assets/images/cpp.jpg',
      'cplusplus': 'assets/images/cpp.jpg',
      'clanguage': 'assets/images/c.jpg',
      'c': 'assets/images/c.jpg',
      'dbms': 'assets/images/dbms.jpg',
      'dsa': 'assets/images/dsa.jpg',
      'cybersecurity': 'assets/images/cyber_security.jpg',
      'ethicalhacking': 'assets/images/ethical_hacking.jpg',
      'computernetworks': 'assets/images/computer_networks.jpg',
      'operatingsystem': 'assets/images/operating_system.jpg',
    };

    return localImages[key] ?? storedImage;
  }

  String _prettyCourseName(String value) {
    final key = _normalizeCourseName(value);

    const names = <String, String>{
      'clanguage': 'C Language',
      'c': 'C Language',
      'cpp': 'C++',
      'cplusplus': 'C++',
      'computernetworks': 'Computer Networks',
      'cybersecurity': 'Cyber Security',
      'ethicalhacking': 'Ethical Hacking',
      'operatingsystem': 'Operating System',
      'dbms': 'DBMS',
      'dsa': 'DSA',
      'javascript': 'JavaScript',
      'nodejs': 'NodeJS',
      'node': 'NodeJS',
      'rlanguage': 'R Language',
      'r': 'R Language',
      'matlab': 'MATLAB',
      'sql': 'SQL',
      'php': 'PHP',
      'kotlin': 'Kotlin',
      'swift': 'Swift',
      'flutter': 'Flutter',
      'python': 'Python',
      'java': 'Java',
      'go': 'Go',
      'rust': 'Rust',
    };

    if (names.containsKey(key)) {
      return names[key]!;
    }

    final cleaned = value
        .trim()
        .replaceAll('_', ' ')
        .replaceAll('-', ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    if (cleaned.isEmpty) return '';

    return cleaned.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() +
          word.substring(1).toLowerCase();
    }).join(' ');
  }

  Widget _courseImageWidget(
      String image,
      String courseName,
      ) {
    if (image.isEmpty) {
      return _imagePlaceholder(
        courseName,
      );
    }

    if (image.startsWith(
      'http://',
    ) ||
        image.startsWith(
          'https://',
        )) {
      return Image.network(
        image,
        fit: BoxFit.cover,
        loadingBuilder: (
            context,
            child,
            progress,
            ) {
          if (progress == null) {
            return child;
          }

          return _imagePlaceholder(
            courseName,
          );
        },
        errorBuilder: (
            context,
            error,
            stackTrace,
            ) {
          return _imagePlaceholder(
            courseName,
          );
        },
      );
    }

    return Image.asset(
      image,
      fit: BoxFit.cover,
      errorBuilder: (
          context,
          error,
          stackTrace,
          ) {
        return _imagePlaceholder(
          courseName,
        );
      },
    );
  }

  Widget _imagePlaceholder(
      String courseName,
      ) {
    return Container(
      decoration:
      const BoxDecoration(
        gradient:
        LinearGradient(
          colors: [
            Color(0xff09132A),
            Color(0xff111735),
            Color(0xff15112D),
          ],
          begin:
          Alignment.topLeft,
          end:
          Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -30,
            top: -30,
            child: Container(
              width: 130,
              height: 130,
              decoration:
              BoxDecoration(
                shape:
                BoxShape.circle,
                color: neonBlue
                    .withValues(
                  alpha: 0.08,
                ),
              ),
            ),
          ),

          Positioned(
            left: -35,
            bottom: -45,
            child: Container(
              width: 140,
              height: 140,
              decoration:
              BoxDecoration(
                shape:
                BoxShape.circle,
                color: neonPurple
                    .withValues(
                  alpha: 0.08,
                ),
              ),
            ),
          ),

          Center(
            child: Column(
              mainAxisAlignment:
              MainAxisAlignment
                  .center,
              children: [
                Container(
                  width: 62,
                  height: 62,
                  decoration:
                  BoxDecoration(
                    color: neonBlue
                        .withValues(
                      alpha: 0.08,
                    ),
                    borderRadius:
                    BorderRadius
                        .circular(
                      18,
                    ),
                    border:
                    Border.all(
                      color: neonBlue
                          .withValues(
                        alpha: 0.30,
                      ),
                    ),
                  ),
                  child:
                  const Icon(
                    Icons
                        .school_rounded,
                    color:
                    neonBlue,
                    size: 31,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Padding(
                  padding:
                  const EdgeInsets
                      .symmetric(
                    horizontal: 30,
                  ),
                  child: Text(
                    courseName
                        .isEmpty
                        ? 'MMOC TEACH'
                        : courseName
                        .toUpperCase(),
                    maxLines: 1,
                    overflow:
                    TextOverflow
                        .ellipsis,
                    textAlign:
                    TextAlign
                        .center,
                    style:
                    const TextStyle(
                      color:
                      textWhite,
                      fontSize: 12,
                      fontWeight:
                      FontWeight
                          .w900,
                      letterSpacing:
                      0.8,
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
  // STATUS BADGE
  // ============================================================

  Widget _statusBadge({
    required bool completed,
    required bool certificateUnlocked,
  }) {
    final Color color =
    certificateUnlocked ||
        completed
        ? neonGreen
        : neonBlue;

    final String label =
    certificateUnlocked
        ? 'COMPLETED'
        : completed
        ? 'FINISHED'
        : 'IN PROGRESS';

    return Container(
      padding:
      const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 6,
      ),
      decoration:
      BoxDecoration(
        color: color.withValues(
          alpha: 0.08,
        ),
        borderRadius:
        BorderRadius.circular(
          20,
        ),
        border: Border.all(
          color: color.withValues(
            alpha: 0.22,
          ),
        ),
      ),
      child: Row(
        mainAxisSize:
        MainAxisSize.min,
        children: [
          Icon(
            certificateUnlocked ||
                completed
                ? Icons
                .check_circle_rounded
                : Icons
                .timelapse_rounded,
            color: color,
            size: 12,
          ),
          const SizedBox(
            width: 4,
          ),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 7.5,
              fontWeight:
              FontWeight.w900,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // QUIZ SCORE
  // ============================================================

  Widget _quizScoreCard({
    required int score,
    required int total,
    required bool passed,
  }) {
    final bool attempted =
        total > 0;

    final int percentage =
    attempted
        ? ((score / total) * 100)
        .round()
        .clamp(0, 100)
        : 0;

    final Color accent =
    attempted
        ? passed
        ? neonGreen
        : neonOrange
        : neonPurple;

    return Container(
      width: double.infinity,
      padding:
      const EdgeInsets.all(13),
      decoration:
      BoxDecoration(
        color: panel2,
        borderRadius:
        BorderRadius.circular(
          16,
        ),
        border: Border.all(
          color: accent.withValues(
            alpha: 0.18,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 43,
            height: 43,
            decoration:
            BoxDecoration(
              color: accent.withValues(
                alpha: 0.08,
              ),
              borderRadius:
              BorderRadius.circular(
                13,
              ),
              border: Border.all(
                color:
                accent.withValues(
                  alpha: 0.20,
                ),
              ),
            ),
            child: Icon(
              Icons.quiz_rounded,
              color: accent,
              size: 21,
            ),
          ),
          const SizedBox(
            width: 11,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment
                  .start,
              children: [
                const Text(
                  'QUIZ PERFORMANCE',
                  style: TextStyle(
                    color:
                    textWhite,
                    fontSize: 10.5,
                    fontWeight:
                    FontWeight.w900,
                    letterSpacing:
                    0.7,
                  ),
                ),
                const SizedBox(
                  height: 4,
                ),
                Text(
                  attempted
                      ? passed
                      ? 'PASSED • CERTIFICATE ELIGIBLE'
                      : 'TRY AGAIN • TARGET 60%'
                      : 'QUIZ NOT ATTEMPTED',
                  style:
                  TextStyle(
                    color:
                    accent,
                    fontSize: 8,
                    fontWeight:
                    FontWeight
                        .w800,
                    letterSpacing:
                    0.25,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            width: 8,
          ),
          if (attempted)
            Column(
              crossAxisAlignment:
              CrossAxisAlignment
                  .end,
              children: [
                Text(
                  '$score/$total',
                  style:
                  TextStyle(
                    color:
                    accent,
                    fontSize: 16,
                    fontWeight:
                    FontWeight
                        .w900,
                  ),
                ),
                Text(
                  '$percentage%',
                  style:
                  const TextStyle(
                    color:
                    textMuted,
                    fontSize: 9,
                    fontWeight:
                    FontWeight
                        .w700,
                  ),
                ),
              ],
            )
          else
            const Icon(
              Icons
                  .hourglass_empty_rounded,
              color:
              textMuted,
              size: 17,
            ),
        ],
      ),
    );
  }

  // ============================================================
  // CERTIFICATE BUTTON
  // ============================================================

  Widget _certificateButton(
      BuildContext context,
      String courseName,
      ) {
    final studentName =
    user.displayName
        ?.trim()
        .isNotEmpty ==
        true
        ? user.displayName!.trim()
        : 'Student';

    return SizedBox(
      width: double.infinity,
      height: 53,
      child:
      ElevatedButton.icon(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  CertificateScreen(
                    courseName:
                    courseName,
                    studentName:
                    studentName,
                  ),
            ),
          );
        },
        icon: const Icon(
          Icons
              .workspace_premium_rounded,
          color: Colors.white,
          size: 20,
        ),
        label: const Text(
          'ACCESS CERTIFICATE',
          style: TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight:
            FontWeight.w900,
            letterSpacing: 0.8,
          ),
        ),
        style:
        ElevatedButton.styleFrom(
          backgroundColor:
          neonGreen,
          foregroundColor:
          Colors.white,
          elevation: 0,
          shadowColor:
          neonGreen,
          shape:
          RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(
              15,
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // LOCKED CERTIFICATE
  // ============================================================

  Widget _certificateLockedCard({
    required bool completed,
    required bool passed,
  }) {
    String message;

    if (!completed && !passed) {
      message =
      'Complete the course and pass the quiz with at least 60%.';
    } else if (!completed) {
      message =
      'Complete the course 100% to unlock your certificate.';
    } else {
      message =
      'Pass the quiz with at least 60% to unlock your certificate.';
    }

    return Container(
      width: double.infinity,
      padding:
      const EdgeInsets.all(13),
      decoration:
      BoxDecoration(
        color: neonOrange
            .withValues(
          alpha: 0.055,
        ),
        borderRadius:
        BorderRadius.circular(
          15,
        ),
        border: Border.all(
          color: neonOrange
              .withValues(
            alpha: 0.18,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment
            .start,
        children: [
          Container(
            width: 35,
            height: 35,
            decoration:
            BoxDecoration(
              color: neonOrange
                  .withValues(
                alpha: 0.09,
              ),
              borderRadius:
              BorderRadius.circular(
                10,
              ),
            ),
            child: const Icon(
              Icons.lock_rounded,
              color:
              neonOrange,
              size: 17,
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment
                  .start,
              children: [
                const Text(
                  'CERTIFICATE LOCKED',
                  style:
                  TextStyle(
                    color:
                    neonOrange,
                    fontSize: 10,
                    fontWeight:
                    FontWeight
                        .w900,
                    letterSpacing:
                    0.7,
                  ),
                ),
                const SizedBox(
                  height: 4,
                ),
                Text(
                  message,
                  style:
                  const TextStyle(
                    color:
                    textMuted,
                    fontSize: 9.5,
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
}
// ==================================================================
// LOADING STATE
// ==================================================================

class _CyberLoadingState
    extends StatelessWidget {
  const _CyberLoadingState();

  static const Color bg =
  Color(0xff050816);

  static const Color neonBlue =
  Color(0xff00B7FF);

  @override
  Widget build(
      BuildContext context,
      ) {
    return Container(
      color: bg,
      child: Center(
        child: Column(
          mainAxisSize:
          MainAxisSize.min,
          children: [
            Container(
              width: 58,
              height: 58,
              decoration:
              BoxDecoration(
                color:
                neonBlue.withValues(
                  alpha: 0.08,
                ),
                shape:
                BoxShape.circle,
                border:
                Border.all(
                  color:
                  neonBlue.withValues(
                    alpha: 0.25,
                  ),
                ),
              ),
              child:
              const Padding(
                padding:
                EdgeInsets.all(17),
                child:
                CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color:
                  neonBlue,
                ),
              ),
            ),
            const SizedBox(
              height: 16,
            ),
            const Text(
              'SYNCING LEARNING DATA...',
              style:
              TextStyle(
                color:
                neonBlue,
                fontSize: 9,
                fontWeight:
                FontWeight
                    .w900,
                letterSpacing:
                1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================================================================
// EMPTY / ERROR / LOGIN REQUIRED
// ==================================================================

class _CyberEmptyState
    extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isError;

  const _CyberEmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.isError = false,
  });

  static const Color bg =
  Color(0xff050816);

  static const Color panel =
  Color(0xff0B1020);

  static const Color panel2 =
  Color(0xff10172A);

  static const Color neonBlue =
  Color(0xff00B7FF);

  static const Color neonPurple =
  Color(0xff8B5CF6);

  static const Color neonGreen =
  Color(0xff39FF88);

  static const Color neonOrange =
  Color(0xffFF8A00);

  static const Color textWhite =
  Color(0xffF8FAFF);

  static const Color textMuted =
  Color(0xff8D98B2);

  @override
  Widget build(
      BuildContext context,
      ) {
    final accent =
    isError
        ? neonOrange
        : neonBlue;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Stack(
          children: [
            // ======================================================
            // BACKGROUND GLOW
            // ======================================================

            Positioned(
              top: -120,
              right: -100,
              child: Container(
                width: 300,
                height: 300,
                decoration:
                BoxDecoration(
                  shape:
                  BoxShape.circle,
                  color:
                  neonPurple
                      .withValues(
                    alpha: 0.05,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color:
                      neonPurple
                          .withValues(
                        alpha: 0.08,
                      ),
                      blurRadius:
                      100,
                      spreadRadius:
                      20,
                    ),
                  ],
                ),
              ),
            ),

            Positioned(
              bottom: -140,
              left: -100,
              child: Container(
                width: 300,
                height: 300,
                decoration:
                BoxDecoration(
                  shape:
                  BoxShape.circle,
                  color:
                  neonBlue
                      .withValues(
                    alpha: 0.04,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color:
                      neonBlue
                          .withValues(
                        alpha: 0.07,
                      ),
                      blurRadius:
                      100,
                      spreadRadius:
                      20,
                    ),
                  ],
                ),
              ),
            ),

            // ======================================================
            // CONTENT
            // ======================================================

            SingleChildScrollView(
              physics:
              const BouncingScrollPhysics(),
              padding:
              const EdgeInsets.fromLTRB(
                20,
                16,
                20,
                30,
              ),
              child: Column(
                children: [
                  // ==================================================
                  // TOP BAR WITH BACK BUTTON
                  // ==================================================

                  Row(
                    children: [
                      Material(
                        color: panel2,
                        borderRadius:
                        BorderRadius
                            .circular(
                          14,
                        ),
                        child: InkWell(
                          borderRadius:
                          BorderRadius
                              .circular(
                            14,
                          ),
                          onTap: () {
                            Navigator
                                .maybePop(
                              context,
                            );
                          },
                          child:
                          Container(
                            width: 44,
                            height: 44,
                            decoration:
                            BoxDecoration(
                              borderRadius:
                              BorderRadius
                                  .circular(
                                14,
                              ),
                              border:
                              Border.all(
                                color:
                                neonBlue
                                    .withValues(
                                  alpha:
                                  0.25,
                                ),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                  neonBlue
                                      .withValues(
                                    alpha:
                                    0.06,
                                  ),
                                  blurRadius:
                                  15,
                                ),
                              ],
                            ),
                            child:
                            const Icon(
                              Icons
                                  .arrow_back_rounded,
                              color:
                              textWhite,
                              size: 20,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(
                        width: 12,
                      ),

                      Expanded(
                        child:
                        Column(
                          crossAxisAlignment:
                          CrossAxisAlignment
                              .start,
                          children: [
                            const Text(
                              'MY LEARNING',
                              style:
                              TextStyle(
                                color:
                                textWhite,
                                fontSize:
                                17,
                                fontWeight:
                                FontWeight
                                    .w900,
                                letterSpacing:
                                1,
                              ),
                            ),
                            const SizedBox(
                              height: 3,
                            ),
                            Text(
                              isError
                                  ? 'SYSTEM STATUS'
                                  : 'LEARNING CONTROL PANEL',
                              style:
                              TextStyle(
                                color:
                                accent,
                                fontSize:
                                7.5,
                                fontWeight:
                                FontWeight
                                    .w900,
                                letterSpacing:
                                1.4,
                              ),
                            ),
                          ],
                        ),
                      ),

                      Container(
                        width: 42,
                        height: 42,
                        decoration:
                        BoxDecoration(
                          color:
                          accent
                              .withValues(
                            alpha:
                            0.07,
                          ),
                          borderRadius:
                          BorderRadius
                              .circular(
                            13,
                          ),
                          border:
                          Border.all(
                            color:
                            accent
                                .withValues(
                              alpha:
                              0.22,
                            ),
                          ),
                        ),
                        child:
                        Icon(
                          isError
                              ? Icons
                              .cloud_off_rounded
                              : Icons
                              .school_rounded,
                          color:
                          accent,
                          size: 20,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 100,
                  ),

                  // ==================================================
                  // MAIN ICON
                  // ==================================================

                  Container(
                    width: 125,
                    height: 125,
                    decoration:
                    BoxDecoration(
                      color: panel,
                      shape:
                      BoxShape.circle,
                      border:
                      Border.all(
                        color:
                        accent
                            .withValues(
                          alpha:
                          0.30,
                        ),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color:
                          accent
                              .withValues(
                            alpha:
                            0.10,
                          ),
                          blurRadius:
                          30,
                          spreadRadius:
                          3,
                        ),
                      ],
                    ),
                    child:
                    Stack(
                      alignment:
                      Alignment
                          .center,
                      children: [
                        Container(
                          width: 95,
                          height: 95,
                          decoration:
                          BoxDecoration(
                            color:
                            accent
                                .withValues(
                              alpha:
                              0.06,
                            ),
                            shape:
                            BoxShape
                                .circle,
                          ),
                        ),
                        Icon(
                          icon,
                          color:
                          accent,
                          size: 48,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(
                    height: 26,
                  ),

                  // ==================================================
                  // TITLE
                  // ==================================================

                  Text(
                    title,
                    textAlign:
                    TextAlign.center,
                    style:
                    const TextStyle(
                      color:
                      textWhite,
                      fontSize: 21,
                      fontWeight:
                      FontWeight.w900,
                      letterSpacing: 1,
                    ),
                  ),

                  const SizedBox(
                    height: 10,
                  ),

                  // ==================================================
                  // SUBTITLE
                  // ==================================================

                  Text(
                    subtitle,
                    textAlign:
                    TextAlign.center,
                    style:
                    const TextStyle(
                      color:
                      textMuted,
                      fontSize: 12,
                      height: 1.6,
                    ),
                  ),

                  const SizedBox(
                    height: 22,
                  ),

                  // ==================================================
                  // STATUS CHIP
                  // ==================================================

                  Container(
                    padding:
                    const EdgeInsets
                        .symmetric(
                      horizontal: 14,
                      vertical: 9,
                    ),
                    decoration:
                    BoxDecoration(
                      color:
                      accent
                          .withValues(
                        alpha: 0.07,
                      ),
                      borderRadius:
                      BorderRadius
                          .circular(
                        20,
                      ),
                      border:
                      Border.all(
                        color:
                        accent
                            .withValues(
                          alpha: 0.18,
                        ),
                      ),
                    ),
                    child:
                    Row(
                      mainAxisSize:
                      MainAxisSize
                          .min,
                      children: [
                        Icon(
                          isError
                              ? Icons
                              .refresh_rounded
                              : Icons
                              .bolt_rounded,
                          color:
                          accent,
                          size: 14,
                        ),
                        const SizedBox(
                          width: 6,
                        ),
                        Text(
                          isError
                              ? 'SYSTEM RETRY LATER'
                              : 'START YOUR LEARNING MISSION',
                          style:
                          TextStyle(
                            color:
                            accent,
                            fontSize:
                            8.5,
                            fontWeight:
                            FontWeight
                                .w900,
                            letterSpacing:
                            0.7,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(
                    height: 30,
                  ),

                  // ==================================================
                  // CYBER DOTS
                  // ==================================================

                  Row(
                    mainAxisAlignment:
                    MainAxisAlignment
                        .center,
                    children: [
                      _dot(
                        neonBlue,
                      ),
                      const SizedBox(
                        width: 6,
                      ),
                      _dot(
                        neonPurple,
                      ),
                      const SizedBox(
                        width: 6,
                      ),
                      _dot(
                        neonGreen,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dot(
      Color color,
      ) {
    return Container(
      width: 6,
      height: 6,
      decoration:
      BoxDecoration(
        color: color,
        shape:
        BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color:
            color.withValues(
              alpha: 0.5,
            ),
            blurRadius: 8,
          ),
        ],
      ),
    );
  }
}
