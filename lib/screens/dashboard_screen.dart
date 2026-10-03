import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  // ============================================================
  // CYBER TECH COLORS
  // ============================================================

  static const Color cyberBlack = Color(0xff050711);
  static const Color cyberNavy = Color(0xff080D1C);
  static const Color panel = Color(0xff0D1426);
  static const Color panelLight = Color(0xff121B31);

  static const Color neonBlue = Color(0xff00A8FF);
  static const Color electricBlue = Color(0xff2F6BFF);
  static const Color neonPurple = Color(0xff9B5CFF);
  static const Color neonCyan = Color(0xff00F0FF);
  static const Color neonGreen = Color(0xff00F5A0);
  static const Color neonOrange = Color(0xffff9D2E);
  static const Color neonPink = Color(0xffff3CAC);

  static const Color textPrimary = Color(0xffF4F7FF);
  static const Color textSecondary = Color(0xff8D9AB8);
  static const Color textMuted = Color(0xff56627D);

  static const Color border = Color(0xff1B2945);

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return _loginRequiredScreen();
    }

    return Scaffold(
      backgroundColor: cyberBlack,
      appBar: _buildAppBar(),
      body: FutureBuilder<List<QuerySnapshot>>(
        future: _loadDashboardData(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _loadingState();
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return _errorState();
          }

          final List<QueryDocumentSnapshot> wishlist =
              snapshot.data![0].docs;

          final List<QueryDocumentSnapshot> enrollments =
              snapshot.data![1].docs;

          int certificates = 0;
          double totalProgress = 0;

          for (final QueryDocumentSnapshot doc in enrollments) {
            final Map<String, dynamic> data =
            doc.data() as Map<String, dynamic>;

            final dynamic progressValue = data["progress"];

            final int progress = progressValue is num
                ? progressValue.toInt().clamp(0, 100).toInt()
                : 0;

            totalProgress += progress;

            if (progress >= 100) {
              certificates++;
            }
          }

          final double avgProgress = enrollments.isNotEmpty
              ? totalProgress / enrollments.length
              : 0;

          final int progressPercent =
          avgProgress.round().clamp(0, 100).toInt();

          return RefreshIndicator(
            color: neonBlue,
            backgroundColor: panel,
            onRefresh: () async {
              await _loadDashboardData(user.uid);
            },
            child: Stack(
              children: [
                Positioned.fill(
                  child: IgnorePointer(
                    child: CustomPaint(
                      painter: _CyberGridPainter(),
                    ),
                  ),
                ),
                SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  padding: const EdgeInsets.fromLTRB(
                    18,
                    18,
                    18,
                    40,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSystemHeader(user),

                      const SizedBox(height: 22),

                      _buildStatsGrid(
                        wishlistCount: wishlist.length,
                        courseCount: enrollments.length,
                        certificateCount: certificates,
                        progressPercent: progressPercent,
                      ),

                      const SizedBox(height: 28),

                      _buildSectionHeader(
                        tag: "01",
                        title: "LEARNING CORE",
                        subtitle: "Overall course completion status",
                        icon: Icons.auto_graph_rounded,
                        color: neonBlue,
                      ),

                      const SizedBox(height: 13),

                      _buildProgressCard(
                        avgProgress: avgProgress,
                        progressPercent: progressPercent,
                        courseCount: enrollments.length,
                      ),

                      const SizedBox(height: 28),

                      _buildSectionHeader(
                        tag: "02",
                        title: "ACHIEVEMENT HUB",
                        subtitle: "Your unlocked learning milestones",
                        icon: Icons.workspace_premium_rounded,
                        color: neonOrange,
                      ),

                      const SizedBox(height: 13),

                      _buildAchievementCard(
                        certificates: certificates,
                      ),

                      const SizedBox(height: 28),

                      _buildSectionHeader(
                        tag: "03",
                        title: "SYSTEM BOOST",
                        subtitle: "Keep your learning momentum active",
                        icon: Icons.rocket_launch_rounded,
                        color: neonPurple,
                      ),

                      const SizedBox(height: 13),

                      _buildMotivationCard(),

                      const SizedBox(height: 28),

                      _buildLearningTips(),

                      const SizedBox(height: 28),

                      _buildSystemStatus(),

                      const SizedBox(height: 28),

                      _buildFooter(),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ============================================================
  // APP BAR
  // ============================================================

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: cyberBlack,
      surfaceTintColor: Colors.transparent,
      centerTitle: false,
      titleSpacing: 18,
      leadingWidth: 0,
      leading: const SizedBox.shrink(),
      title: Row(
        children: [
          Container(
            height: 38,
            width: 38,
            decoration: BoxDecoration(
              color: neonBlue.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(11),
              border: Border.all(
                color: neonBlue.withValues(alpha: 0.35),
              ),
              boxShadow: [
                BoxShadow(
                  color: neonBlue.withValues(alpha: 0.15),
                  blurRadius: 14,
                ),
              ],
            ),
            child: const Icon(
              Icons.dashboard_customize_rounded,
              color: neonBlue,
              size: 21,
            ),
          ),
          const SizedBox(width: 11),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "MMOC // DASHBOARD",
                style: TextStyle(
                  color: textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.8,
                ),
              ),
              SizedBox(height: 2),
              Text(
                "STUDENT CONTROL CENTER",
                style: TextStyle(
                  color: textMuted,
                  fontSize: 8,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SYSTEM HEADER
  // ============================================================

  Widget _buildSystemHeader(User user) {
    final String name =
    user.displayName?.trim().isNotEmpty == true
        ? user.displayName!.trim()
        : "STUDENT";

    final String email = user.email ?? "";

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xff0B1730),
            Color(0xff10132C),
            Color(0xff17102F),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: neonBlue.withValues(alpha: 0.32),
        ),
        boxShadow: [
          BoxShadow(
            color: neonBlue.withValues(alpha: 0.10),
            blurRadius: 30,
            spreadRadius: 1,
          ),
          BoxShadow(
            color: neonPurple.withValues(alpha: 0.08),
            blurRadius: 40,
            offset: const Offset(15, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -35,
            top: -35,
            child: Container(
              height: 130,
              width: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: neonPurple.withValues(alpha: 0.10),
                  width: 18,
                ),
              ),
            ),
          ),
          Positioned(
            right: 20,
            bottom: 5,
            child: Icon(
              Icons.memory_rounded,
              color: neonCyan.withValues(alpha: 0.07),
              size: 90,
            ),
          ),
          Column(
            children: [
              Row(
                children: [
                  _buildAvatar(user),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              height: 7,
                              width: 7,
                              decoration: const BoxDecoration(
                                color: neonGreen,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: neonGreen,
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 7),
                            const Text(
                              "SYSTEM ONLINE",
                              style: TextStyle(
                                color: neonGreen,
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 7),
                        Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: textPrimary,
                            fontSize: 21,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        if (email.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            email,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: textSecondary,
                              fontSize: 10.5,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 13,
                  vertical: 11,
                ),
                decoration: BoxDecoration(
                  color: cyberBlack.withValues(alpha: 0.42),
                  borderRadius: BorderRadius.circular(13),
                  border: Border.all(
                    color: neonPurple.withValues(alpha: 0.20),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.terminal_rounded,
                      color: neonPurple,
                      size: 17,
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Text(
                        "> Keep learning. Keep building. Keep evolving.",
                        style: TextStyle(
                          color: textPrimary.withValues(alpha: 0.82),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.15,
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

  Widget _buildAvatar(User user) {
    return Container(
      height: 68,
      width: 68,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [
            neonBlue,
            neonPurple,
            neonCyan,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: neonBlue.withValues(alpha: 0.25),
            blurRadius: 18,
          ),
        ],
      ),
      child: Container(
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: cyberNavy,
        ),
        child: ClipOval(
          child: user.photoURL != null &&
              user.photoURL!.trim().isNotEmpty
              ? Image.network(
            user.photoURL!,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) {
              return const Icon(
                Icons.person_rounded,
                color: neonBlue,
                size: 34,
              );
            },
          )
              : const Icon(
            Icons.person_rounded,
            color: neonBlue,
            size: 34,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // STATS
  // ============================================================

  Widget _buildStatsGrid({
    required int wishlistCount,
    required int courseCount,
    required int certificateCount,
    required int progressPercent,
  }) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _statCard(
                code: "WL",
                title: "WISHLIST",
                value: "$wishlistCount",
                icon: Icons.favorite_rounded,
                color: neonPink,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _statCard(
                code: "CR",
                title: "COURSES",
                value: "$courseCount",
                icon: Icons.school_rounded,
                color: neonBlue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _statCard(
                code: "XP",
                title: "CERTIFICATES",
                value: "$certificateCount",
                icon: Icons.workspace_premium_rounded,
                color: neonOrange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _statCard(
                code: "AVG",
                title: "AVG PROGRESS",
                value: "$progressPercent%",
                icon: Icons.trending_up_rounded,
                color: neonGreen,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _statCard({
    required String code,
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: panel,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(
          color: color.withValues(alpha: 0.22),
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.06),
            blurRadius: 18,
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -8,
            top: -9,
            child: Text(
              code,
              style: TextStyle(
                color: color.withValues(alpha: 0.07),
                fontSize: 28,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: color.withValues(alpha: 0.20),
                      ),
                    ),
                    child: Icon(
                      icon,
                      color: color,
                      size: 20,
                    ),
                  ),
                  Icon(
                    Icons.arrow_outward_rounded,
                    color: color.withValues(alpha: 0.45),
                    size: 16,
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Text(
                value,
                style: const TextStyle(
                  color: textPrimary,
                  fontSize: 23,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                title,
                style: const TextStyle(
                  color: textSecondary,
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.7,
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

  Widget _buildSectionHeader({
    required String tag,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          height: 43,
          width: 43,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.09),
            borderRadius: BorderRadius.circular(13),
            border: Border.all(
              color: color.withValues(alpha: 0.25),
            ),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.08),
                blurRadius: 15,
              ),
            ],
          ),
          child: Icon(
            icon,
            color: color,
            size: 21,
          ),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    tag,
                    style: TextStyle(
                      color: color,
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(width: 7),
                  Container(
                    height: 1,
                    width: 18,
                    color: color.withValues(alpha: 0.4),
                  ),
                  const SizedBox(width: 7),
                  Text(
                    title,
                    style: const TextStyle(
                      color: textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.7,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 3),
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
  // PROGRESS CARD
  // ============================================================

  Widget _buildProgressCard({
    required double avgProgress,
    required int progressPercent,
    required int courseCount,
  }) {
    final bool hasCourses = courseCount > 0;

    final Color progressColor =
    progressPercent >= 100 ? neonGreen : neonBlue;

    final double progressFactor =
    (avgProgress / 100).clamp(0.0, 1.0).toDouble();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: panel,
        borderRadius: BorderRadius.circular(23),
        border: Border.all(
          color: progressColor.withValues(alpha: 0.24),
        ),
        boxShadow: [
          BoxShadow(
            color: progressColor.withValues(alpha: 0.07),
            blurRadius: 25,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              _buildProgressRing(
                progress: progressFactor,
                percent: progressPercent,
                color: progressColor,
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "OVERALL COMPLETION",
                      style: TextStyle(
                        color: textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      hasCourses
                          ? "$courseCount active course${courseCount == 1 ? '' : 's'}"
                          : "No active courses",
                      style: const TextStyle(
                        color: textSecondary,
                        fontSize: 10.5,
                      ),
                    ),
                    const SizedBox(height: 11),
                    Row(
                      children: [
                        Container(
                          height: 6,
                          width: 6,
                          decoration: BoxDecoration(
                            color: progressColor,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: progressColor,
                                blurRadius: 7,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 7),
                        Text(
                          progressPercent >= 100
                              ? "MISSION COMPLETE"
                              : hasCourses
                              ? "MISSION ACTIVE"
                              : "WAITING FOR START",
                          style: TextStyle(
                            color: progressColor,
                            fontSize: 8.5,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 21),
          Row(
            mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "PROGRESS",
                style: TextStyle(
                  color: textMuted,
                  fontSize: 8,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                ),
              ),
              Text(
                "$progressPercent / 100",
                style: TextStyle(
                  color: progressColor,
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          Container(
            height: 9,
            width: double.infinity,
            decoration: BoxDecoration(
              color: cyberBlack,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: border,
              ),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progressFactor,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      electricBlue,
                      progressColor,
                      neonCyan,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color:
                      progressColor.withValues(alpha: 0.45),
                      blurRadius: 9,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 11),
          Row(
            mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
            children: [
              Text(
                hasCourses
                    ? "Learning database synced"
                    : "Enroll in a course to begin",
                style: const TextStyle(
                  color: textSecondary,
                  fontSize: 9.5,
                ),
              ),
              Icon(
                hasCourses
                    ? Icons.sync_rounded
                    : Icons.play_arrow_rounded,
                color:
                hasCourses ? neonCyan : neonBlue,
                size: 15,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressRing({
    required double progress,
    required int percent,
    required Color color,
  }) {
    return SizedBox(
      height: 91,
      width: 91,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size(91, 91),
            painter: _ProgressRingPainter(
              progress:
              progress.clamp(0.0, 1.0).toDouble(),
              color: color,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "$percent%",
                style: TextStyle(
                  color: color,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const Text(
                "SYNC",
                style: TextStyle(
                  color: textMuted,
                  fontSize: 7,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ACHIEVEMENT
  // ============================================================

  Widget _buildAchievementCard({
    required int certificates,
  }) {
    final bool hasCertificate = certificates > 0;

    final Color color =
    hasCertificate ? neonOrange : neonPurple;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.10),
            panel,
            color.withValues(alpha: 0.04),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: color.withValues(alpha: 0.28),
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.07),
            blurRadius: 24,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 62,
            width: 62,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.09),
              border: Border.all(
                color: color.withValues(alpha: 0.35),
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.18),
                  blurRadius: 18,
                ),
              ],
            ),
            child: Icon(
              hasCertificate
                  ? Icons.workspace_premium_rounded
                  : Icons.lock_open_rounded,
              color: color,
              size: 29,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  hasCertificate
                      ? "$certificates CERTIFICATE${certificates == 1 ? '' : 'S'} UNLOCKED"
                      : "FIRST CERTIFICATE LOCKED",
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  hasCertificate
                      ? "Excellent work. Continue completing courses to unlock more achievements."
                      : "Complete your first course and unlock your certificate.",
                  style: const TextStyle(
                    color: textSecondary,
                    fontSize: 10.5,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            color: color.withValues(alpha: 0.7),
            size: 22,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // MOTIVATION
  // ============================================================

  Widget _buildMotivationCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xff11132B),
            Color(0xff0C1830),
            Color(0xff10152A),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(23),
        border: Border.all(
          color: neonPurple.withValues(alpha: 0.30),
        ),
        boxShadow: [
          BoxShadow(
            color: neonPurple.withValues(alpha: 0.10),
            blurRadius: 28,
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -10,
            top: -20,
            child: Icon(
              Icons.bolt_rounded,
              color: neonPurple.withValues(alpha: 0.07),
              size: 100,
            ),
          ),
          Column(
            children: [
              Container(
                height: 58,
                width: 58,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: neonPurple.withValues(alpha: 0.10),
                  border: Border.all(
                    color: neonPurple.withValues(alpha: 0.30),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color:
                      neonPurple.withValues(alpha: 0.20),
                      blurRadius: 20,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.bolt_rounded,
                  color: neonPurple,
                  size: 30,
                ),
              ),
              const SizedBox(height: 15),
              const Text(
                "LEVEL UP EVERY DAY",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: textPrimary,
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.7,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Consistency creates skill. Keep completing lessons, testing your knowledge and building your future.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: textSecondary,
                  fontSize: 10.5,
                  height: 1.55,
                ),
              ),
              const SizedBox(height: 15),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 13,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: neonPurple.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: neonPurple.withValues(alpha: 0.18),
                  ),
                ),
                child: const Text(
                  "// PROGRESS > PERFECTION",
                  style: TextStyle(
                    color: neonPurple,
                    fontSize: 8.5,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.7,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // LEARNING TIPS
  // ============================================================

  Widget _buildLearningTips() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: panel,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: neonCyan.withValues(alpha: 0.20),
        ),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 38,
                width: 38,
                decoration: BoxDecoration(
                  color: neonCyan.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(11),
                  border: Border.all(
                    color: neonCyan.withValues(alpha: 0.22),
                  ),
                ),
                child: const Icon(
                  Icons.tips_and_updates_rounded,
                  color: neonCyan,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              const Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    "LEARNING PROTOCOL",
                    style: TextStyle(
                      color: textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.7,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    "Recommended learning sequence",
                    style: TextStyle(
                      color: textMuted,
                      fontSize: 9,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 17),
          _tipItem(
            number: "01",
            color: neonBlue,
            text:
            "Complete lessons regularly instead of studying everything at once.",
          ),
          _tipItem(
            number: "02",
            color: neonPurple,
            text:
            "Practice quizzes after finishing your course lessons.",
          ),
          _tipItem(
            number: "03",
            color: neonGreen,
            text:
            "Complete courses to unlock your certificates.",
          ),
        ],
      ),
    );
  }

  Widget _tipItem({
    required String number,
    required Color color,
    required String text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Container(
            height: 29,
            width: 29,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: color.withValues(alpha: 0.25),
              ),
            ),
            child: Text(
              number,
              style: TextStyle(
                color: color,
                fontSize: 8,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: textSecondary,
                fontSize: 10.5,
                height: 1.45,
              ),
            ),
          ),
          const SizedBox(width: 7),
          Icon(
            Icons.arrow_forward_ios_rounded,
            color: color.withValues(alpha: 0.45),
            size: 11,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SYSTEM STATUS
  // ============================================================

  Widget _buildSystemStatus() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),
      decoration: BoxDecoration(
        color: cyberBlack,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: border,
        ),
      ),
      child: Row(
        children: [
          Container(
            height: 9,
            width: 9,
            decoration: const BoxDecoration(
              color: neonGreen,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: neonGreen,
                  blurRadius: 8,
                ),
              ],
            ),
          ),
          const SizedBox(width: 9),
          const Expanded(
            child: Text(
              "FIREBASE DATA SYNC ACTIVE",
              style: TextStyle(
                color: textSecondary,
                fontSize: 8.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
              ),
            ),
          ),
          const Text(
            "ONLINE",
            style: TextStyle(
              color: neonGreen,
              fontSize: 8,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // FOOTER
  // ============================================================

  Widget _buildFooter() {
    return const Center(
      child: Column(
        children: [
          Text(
            "MMOC // TEACH",
            style: TextStyle(
              color: neonBlue,
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
            ),
          ),
          SizedBox(height: 5),
          Text(
            "LEARN • GROW • SUCCEED",
            style: TextStyle(
              color: textMuted,
              fontSize: 8,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
          SizedBox(height: 7),
          Text(
            "STUDENT CONTROL CENTER",
            style: TextStyle(
              color: Color(0xff303C58),
              fontSize: 7,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // FIRESTORE
  // ============================================================

  Future<List<QuerySnapshot>> _loadDashboardData(
      String uid,
      ) async {
    return Future.wait([
      FirebaseFirestore.instance
          .collection("wishlist")
          .where("uid", isEqualTo: uid)
          .get(),
      FirebaseFirestore.instance
          .collection("enrollments")
          .where("uid", isEqualTo: uid)
          .get(),
    ]);
  }

  // ============================================================
  // LOGIN REQUIRED
  // ============================================================

  Widget _loginRequiredScreen() {
    return Scaffold(
      backgroundColor: cyberBlack,
      appBar: _buildAppBar(),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Container(
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: panel,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: neonBlue.withValues(alpha: 0.25),
              ),
              boxShadow: [
                BoxShadow(
                  color: neonBlue.withValues(alpha: 0.08),
                  blurRadius: 25,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 82,
                  width: 82,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: neonBlue.withValues(alpha: 0.08),
                    border: Border.all(
                      color: neonBlue.withValues(alpha: 0.30),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: neonBlue.withValues(alpha: 0.15),
                        blurRadius: 22,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.lock_person_rounded,
                    color: neonBlue,
                    size: 37,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "ACCESS DENIED",
                  style: TextStyle(
                    color: textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Authentication required to access your student dashboard.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: textSecondary,
                    fontSize: 11,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 15),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: neonPink.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(9),
                    border: Border.all(
                      color: neonPink.withValues(alpha: 0.20),
                    ),
                  ),
                  child: const Text(
                    "AUTH_REQUIRED // 401",
                    style: TextStyle(
                      color: neonPink,
                      fontSize: 8,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.8,
                    ),
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
  // LOADING
  // ============================================================

  Widget _loadingState() {
    return Stack(
      children: [
        Positioned.fill(
          child: CustomPaint(
            painter: _CyberGridPainter(),
          ),
        ),
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 70,
                width: 70,
                child: CustomPaint(
                  painter: _LoadingRingPainter(),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                "SYNCING DATA...",
                style: TextStyle(
                  color: neonBlue,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.4,
                ),
              ),
              const SizedBox(height: 7),
              const Text(
                "Connecting to learning database",
                style: TextStyle(
                  color: textMuted,
                  fontSize: 9,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // ERROR
  // ============================================================

  Widget _errorState() {
    return Stack(
      children: [
        Positioned.fill(
          child: CustomPaint(
            painter: _CyberGridPainter(),
          ),
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.all(30),
            child: Container(
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: panel,
                borderRadius: BorderRadius.circular(23),
                border: Border.all(
                  color: neonPink.withValues(alpha: 0.25),
                ),
                boxShadow: [
                  BoxShadow(
                    color: neonPink.withValues(alpha: 0.08),
                    blurRadius: 25,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 76,
                    width: 76,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: neonPink.withValues(alpha: 0.08),
                      border: Border.all(
                        color: neonPink.withValues(alpha: 0.25),
                      ),
                    ),
                    child: const Icon(
                      Icons.cloud_off_rounded,
                      size: 35,
                      color: neonPink,
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    "SYNC ERROR",
                    style: TextStyle(
                      color: textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Unable to retrieve dashboard data. Check your internet connection and try again.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: textSecondary,
                      fontSize: 11,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    "FIREBASE CONNECTION INTERRUPTED",
                    style: TextStyle(
                      color: neonPink,
                      fontSize: 8,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================
// CYBER GRID PAINTER
// ============================================================

class _CyberGridPainter extends CustomPainter {
  @override
  void paint(
      Canvas canvas,
      Size size,
      ) {
    final Paint gridPaint = Paint()
      ..color =
      const Color(0xff16213A).withValues(alpha: 0.34)
      ..strokeWidth = 0.5;

    const double spacing = 28;

    for (double x = 0; x <= size.width; x += spacing) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        gridPaint,
      );
    }

    for (double y = 0; y <= size.height; y += spacing) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        gridPaint,
      );
    }

    final Paint dotPaint = Paint()
      ..color =
      const Color(0xff00A8FF).withValues(alpha: 0.16);

    for (double x = 14; x < size.width; x += 56) {
      for (double y = 14; y < size.height; y += 56) {
        canvas.drawCircle(
          Offset(x, y),
          1,
          dotPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(
      covariant CustomPainter oldDelegate,
      ) {
    return false;
  }
}

// ============================================================
// PROGRESS RING PAINTER
// ============================================================

class _ProgressRingPainter extends CustomPainter {
  final double progress;
  final Color color;

  _ProgressRingPainter({
    required this.progress,
    required this.color,
  });

  @override
  void paint(
      Canvas canvas,
      Size size,
      ) {
    final Offset center = Offset(
      size.width / 2,
      size.height / 2,
    );

    final double radius =
        math.min(size.width, size.height) / 2 - 6;

    final Paint backgroundPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xff1B2945);

    canvas.drawCircle(
      center,
      radius,
      backgroundPaint,
    );

    final Paint progressPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..color = color
      ..maskFilter = const MaskFilter.blur(
        BlurStyle.normal,
        2,
      );

    canvas.drawArc(
      Rect.fromCircle(
        center: center,
        radius: radius,
      ),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      progressPaint,
    );

    final Paint sharpPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..color = color;

    canvas.drawArc(
      Rect.fromCircle(
        center: center,
        radius: radius,
      ),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      sharpPaint,
    );
  }

  @override
  bool shouldRepaint(
      covariant _ProgressRingPainter oldDelegate,
      ) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color;
  }
}

// ============================================================
// LOADING RING PAINTER
// ============================================================

class _LoadingRingPainter extends CustomPainter {
  @override
  void paint(
      Canvas canvas,
      Size size,
      ) {
    final Offset center = Offset(
      size.width / 2,
      size.height / 2,
    );

    final double radius =
        math.min(size.width, size.height) / 2 - 5;

    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round
      ..color = DashboardScreen.neonBlue;

    canvas.drawArc(
      Rect.fromCircle(
        center: center,
        radius: radius,
      ),
      -math.pi / 2,
      math.pi * 1.45,
      false,
      paint,
    );

    final Paint innerPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color =
      DashboardScreen.neonPurple.withValues(alpha: 0.35);

    canvas.drawCircle(
      center,
      radius - 9,
      innerPaint,
    );
  }

  @override
  bool shouldRepaint(
      covariant CustomPainter oldDelegate,
      ) {
    return false;
  }
}