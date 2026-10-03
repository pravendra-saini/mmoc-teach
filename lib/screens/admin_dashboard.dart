import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'login_screen.dart';
import 'manage_courses_screen.dart';
import 'add_course_screen.dart';
import 'manage_videos_screen.dart';
import 'student_list_screen.dart';
import 'analytics_screen.dart';
import 'manage_quiz_screen.dart';
import 'notification_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  // ============================================================
  // CYBER TECH COLORS
  // ============================================================

  final Color backgroundColor = const Color(0xFF050816);
  final Color panelColor = const Color(0xFF0A1020);
  final Color panelColor2 = const Color(0xFF0E172B);

  final Color neonBlue = const Color(0xFF00B7FF);
  final Color neonPurple = const Color(0xFF8B5CF6);
  final Color neonCyan = const Color(0xFF00F5D4);
  final Color neonGreen = const Color(0xFF39FF88);
  final Color neonOrange = const Color(0xFFFF8A00);
  final Color neonPink = const Color(0xFFFF3CAC);

  final Color textWhite = const Color(0xFFF4F8FF);
  final Color textMuted = const Color(0xFF8B9BB8);
  final Color borderColor = const Color(0xFF172B4D);

  // ============================================================
  // LOGOUT
  // ============================================================

  Future<void> logout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: panelColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: neonBlue.withValues(alpha: 0.35),
            ),
          ),
          title: Text(
            "Logout",
            style: TextStyle(
              color: textWhite,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            "Are you sure you want to logout?",
            style: TextStyle(
              color: textMuted,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: Text(
                "Cancel",
                style: TextStyle(
                  color: textMuted,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text("Logout"),
            ),
          ],
        );
      },
    );

    if (shouldLogout != true) return;

    await FirebaseAuth.instance.signOut();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      ),
          (route) => false,
    );
  }

  // ============================================================
  // FIRESTORE COUNTS
  // ============================================================

  Stream<int> studentCount() {
    return FirebaseFirestore.instance
        .collection("users")
        .where("role", isEqualTo: "student")
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  Stream<int> courseCount() {
    return FirebaseFirestore.instance
        .collection("courses")
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  Stream<int> videoCount() {
    return FirebaseFirestore.instance
        .collection("videos")
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  Stream<int> quizCount() {
    return FirebaseFirestore.instance
        .collection("quizzes")
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // ============================================================
  // NAVIGATION HELPERS
  // ============================================================

  void openAddCourse() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AddCourseScreen(),
      ),
    );
  }

  void openEditCourse(
      String docId,
      Map<String, dynamic> course,
      ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddCourseScreen(
          docId: docId,
          course: course,
        ),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 800;

          if (isMobile) {
            return _buildMobileLayout();
          }

          return _buildDesktopLayout();
        },
      ),
    );
  }

  // ============================================================
  // DESKTOP
  // ============================================================

  Widget _buildDesktopLayout() {
    return Row(
      children: [
        _buildSidebar(),
        Expanded(
          child: _buildDashboardContent(),
        ),
      ],
    );
  }

  // ============================================================
  // MOBILE
  // ============================================================

  Widget _buildMobileLayout() {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: panelColor,
        foregroundColor: textWhite,
        elevation: 0,
        title: Row(
          children: [
            Icon(
              Icons.bolt,
              color: neonCyan,
              size: 23,
            ),
            const SizedBox(width: 7),
            Text(
              "MMOC TEACH",
              style: TextStyle(
                color: textWhite,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: "Notifications",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const NotificationScreen(),
                ),
              );
            },
            icon: Icon(
              Icons.notifications_outlined,
              color: neonCyan,
            ),
          ),
          IconButton(
            tooltip: "Logout",
            onPressed: logout,
            icon: const Icon(
              Icons.logout,
              color: Colors.white70,
            ),
          ),
        ],
      ),
      drawer: Drawer(
        backgroundColor: panelColor,
        child: _buildMobileDrawer(),
      ),
      body: _buildDashboardContent(),
    );
  }

  // ============================================================
  // SIDEBAR
  // ============================================================

  Widget _buildSidebar() {
    return Container(
      width: 255,
      decoration: BoxDecoration(
        color: panelColor,
        border: Border(
          right: BorderSide(
            color: borderColor,
          ),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 25),

            // LOGO
            Container(
              width: 78,
              height: 78,
              decoration: BoxDecoration(
                color: const Color(0xFF101A30),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: neonBlue.withValues(alpha: 0.5),
                ),
                boxShadow: [
                  BoxShadow(
                    color: neonBlue.withValues(alpha: 0.18),
                    blurRadius: 25,
                    spreadRadius: 1,
                  ),
                ],
              ),
              padding: const EdgeInsets.all(9),
              child: Image.asset(
                "assets/icons/app_logo.png",
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.school,
                    size: 43,
                    color: neonBlue,
                  );
                },
              ),
            ),

            const SizedBox(height: 15),

            Text(
              "MMOC TEACH",
              style: TextStyle(
                color: textWhite,
                fontSize: 21,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),

            const SizedBox(height: 5),

            Text(
              "ADMIN CONTROL CENTER",
              style: TextStyle(
                color: neonCyan,
                fontSize: 9,
                letterSpacing: 2,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 32),

            _sidebarItem(
              icon: Icons.dashboard_outlined,
              title: "Dashboard",
              selected: true,
              onTap: () {},
            ),

            _sidebarItem(
              icon: Icons.menu_book_outlined,
              title: "Manage Courses",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ManageCoursesScreen(),
                  ),
                );
              },
            ),

            _sidebarItem(
              icon: Icons.video_library_outlined,
              title: "Manage Videos",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ManageVideosScreen(),
                  ),
                );
              },
            ),

            _sidebarItem(
              icon: Icons.quiz_outlined,
              title: "Manage Quiz",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ManageQuizScreen(),
                  ),
                );
              },
            ),

            _sidebarItem(
              icon: Icons.people_outline,
              title: "Students",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const StudentListScreen(),
                  ),
                );
              },
            ),

            _sidebarItem(
              icon: Icons.bar_chart_outlined,
              title: "Analytics",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AnalyticsScreen(),
                  ),
                );
              },
            ),

            _sidebarItem(
              icon: Icons.notifications_outlined,
              title: "Notifications",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const NotificationScreen(),
                  ),
                );
              },
            ),

            const Spacer(),

            Padding(
              padding: const EdgeInsets.all(18),
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: logout,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 13,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: Colors.redAccent.withValues(alpha: 0.22),
                    ),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.logout,
                        color: Colors.redAccent,
                      ),
                      SizedBox(width: 12),
                      Text(
                        "Logout",
                        style: TextStyle(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.w600,
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
    );
  }

  // ============================================================
  // MOBILE DRAWER
  // ============================================================

  Widget _buildMobileDrawer() {
    return SafeArea(
      child: Column(
        children: [
          const SizedBox(height: 25),

          Container(
            width: 72,
            height: 72,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF101A30),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: neonBlue.withValues(alpha: 0.5),
              ),
            ),
            child: Image.asset(
              "assets/icons/app_logo.png",
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Icon(
                  Icons.school,
                  color: neonBlue,
                  size: 40,
                );
              },
            ),
          ),

          const SizedBox(height: 12),

          Text(
            "MMOC TEACH",
            style: TextStyle(
              color: textWhite,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            "ADMIN PANEL",
            style: TextStyle(
              color: neonCyan,
              fontSize: 9,
              letterSpacing: 2,
            ),
          ),

          const SizedBox(height: 28),

          _mobileDrawerItem(
            Icons.dashboard_outlined,
            "Dashboard",
                () => Navigator.pop(context),
            selected: true,
          ),

          _mobileDrawerItem(
            Icons.menu_book_outlined,
            "Manage Courses",
                () {
              Navigator.pop(context);

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ManageCoursesScreen(),
                ),
              );
            },
          ),

          _mobileDrawerItem(
            Icons.video_library_outlined,
            "Manage Videos",
                () {
              Navigator.pop(context);

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ManageVideosScreen(),
                ),
              );
            },
          ),

          _mobileDrawerItem(
            Icons.quiz_outlined,
            "Manage Quiz",
                () {
              Navigator.pop(context);

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ManageQuizScreen(),
                ),
              );
            },
          ),

          _mobileDrawerItem(
            Icons.people_outline,
            "Students",
                () {
              Navigator.pop(context);

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const StudentListScreen(),
                ),
              );
            },
          ),

          _mobileDrawerItem(
            Icons.bar_chart_outlined,
            "Analytics",
                () {
              Navigator.pop(context);

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AnalyticsScreen(),
                ),
              );
            },
          ),

          _mobileDrawerItem(
            Icons.notifications_outlined,
            "Notifications",
                () {
              Navigator.pop(context);

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const NotificationScreen(),
                ),
              );
            },
          ),

          const Spacer(),

          _mobileDrawerItem(
            Icons.logout,
            "Logout",
                () {
              Navigator.pop(context);
              logout();
            },
            logoutItem: true,
          ),

          const SizedBox(height: 15),
        ],
      ),
    );
  }

  // ============================================================
  // DASHBOARD CONTENT
  // ============================================================

  Widget _buildDashboardContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTopBar(),

          const SizedBox(height: 25),

          _buildWelcomeBanner(),

          const SizedBox(height: 25),

          _sectionHeading(
            "Platform Overview",
            "LIVE SYSTEM METRICS",
            Icons.analytics_outlined,
            neonCyan,
          ),

          const SizedBox(height: 15),

          _buildStatisticsGrid(),

          const SizedBox(height: 30),

          _buildMainDashboardGrid(),

          const SizedBox(height: 30),

          _buildQuickActions(),

          const SizedBox(height: 30),

          _buildPlatformHealth(),

          const SizedBox(height: 25),

          _buildFooter(),
        ],
      ),
    );
  }

  // ============================================================
  // TOP BAR
  // ============================================================

  Widget _buildTopBar() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "ADMIN DASHBOARD",
                style: TextStyle(
                  color: textWhite,
                  fontSize: 27,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                "Manage and monitor your learning platform",
                style: TextStyle(
                  color: textMuted,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),

        IconButton(
          tooltip: "Notifications",
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const NotificationScreen(),
              ),
            );
          },
          icon: Icon(
            Icons.notifications_none,
            color: neonCyan,
            size: 27,
          ),
        ),

        const SizedBox(width: 10),

        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            color: panelColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: borderColor,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 35,
                height: 35,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: neonPurple.withValues(alpha: 0.14),
                  border: Border.all(
                    color: neonPurple.withValues(alpha: 0.45),
                  ),
                ),
                child: Icon(
                  Icons.admin_panel_settings,
                  color: neonPurple,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                "Administrator",
                style: TextStyle(
                  color: textWhite,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // WELCOME BANNER
  // ============================================================

  Widget _buildWelcomeBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF0B1530),
            const Color(0xFF15102E),
            const Color(0xFF0B1D2D),
          ],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: neonBlue.withValues(alpha: 0.28),
        ),
        boxShadow: [
          BoxShadow(
            color: neonBlue.withValues(alpha: 0.10),
            blurRadius: 30,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "WELCOME BACK, ADMIN ⚡",
                  style: TextStyle(
                    color: textWhite,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Keep your students learning and your platform growing.",
                  style: TextStyle(
                    color: textMuted,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 18),

                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: neonBlue,
                    foregroundColor: Colors.black,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 13,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: openAddCourse,
                  icon: const Icon(
                    Icons.add,
                    size: 20,
                  ),
                  label: const Text(
                    "ADD NEW COURSE",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 15),

          Container(
            width: 105,
            height: 105,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: neonPurple.withValues(alpha: 0.08),
              border: Border.all(
                color: neonPurple.withValues(alpha: 0.22),
              ),
              boxShadow: [
                BoxShadow(
                  color: neonPurple.withValues(alpha: 0.18),
                  blurRadius: 35,
                ),
              ],
            ),
            child: Icon(
              Icons.school_outlined,
              size: 58,
              color: neonPurple,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SECTION HEADING
  // ============================================================

  Widget _sectionHeading(
      String title,
      String subtitle,
      IconData icon,
      Color color,
      ) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: color.withValues(alpha: 0.25),
            ),
          ),
          child: Icon(
            icon,
            color: color,
            size: 21,
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: textWhite,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                color: textMuted,
                fontSize: 9,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ============================================================
  // STATISTICS GRID
  // ============================================================

  Widget _buildStatisticsGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        int columns = 4;

        if (width < 900) {
          columns = 2;
        }

        return GridView.count(
          crossAxisCount: columns,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 15,
          mainAxisSpacing: 15,
          childAspectRatio: columns == 2 ? 1.75 : 2.15,
          children: [
            _statCard(
              title: "Students",
              label: "REGISTERED USERS",
              icon: Icons.people_alt_outlined,
              color: neonBlue,
              stream: studentCount(),
            ),
            _statCard(
              title: "Courses",
              label: "ACTIVE COURSES",
              icon: Icons.menu_book_outlined,
              color: neonPurple,
              stream: courseCount(),
            ),
            _statCard(
              title: "Videos",
              label: "VIDEO CONTENT",
              icon: Icons.video_library_outlined,
              color: neonCyan,
              stream: videoCount(),
            ),
            _statCard(
              title: "Quizzes",
              label: "QUIZ MODULES",
              icon: Icons.quiz_outlined,
              color: neonOrange,
              stream: quizCount(),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // STAT CARD
  // ============================================================

  Widget _statCard({
    required String title,
    required String label,
    required IconData icon,
    required Color color,
    required Stream<int> stream,
  }) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: panelColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: borderColor,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.07),
            blurRadius: 20,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 53,
            height: 53,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: color.withValues(alpha: 0.25),
              ),
            ),
            child: Icon(
              icon,
              color: color,
              size: 26,
            ),
          ),

          const SizedBox(width: 13),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                StreamBuilder<int>(
                  stream: stream,
                  builder: (context, snapshot) {
                    return Text(
                      "${snapshot.data ?? 0}",
                      style: TextStyle(
                        color: textWhite,
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                ),

                const SizedBox(height: 1),

                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: textWhite,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: textMuted,
                    fontSize: 8,
                    letterSpacing: 1,
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
  // MAIN DASHBOARD GRID
  // ============================================================

  Widget _buildMainDashboardGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmall = constraints.maxWidth < 900;

        if (isSmall) {
          return Column(
            children: [
              _buildRecentStudents(),
              const SizedBox(height: 20),
              _buildRecentCourses(),
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildRecentStudents(),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: _buildRecentCourses(),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // RECENT STUDENTS
  // ============================================================

  Widget _buildRecentStudents() {
    return _sectionCard(
      title: "Recent Students",
      subtitle: "LATEST REGISTRATIONS",
      icon: Icons.people_outline,
      color: neonBlue,
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("users")
            .where(
          "role",
          isEqualTo: "student",
        )
            .limit(5)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(25),
                child: CircularProgressIndicator(
                  color: neonBlue,
                  strokeWidth: 2,
                ),
              ),
            );
          }

          if (snapshot.hasError) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                "Unable to load students.",
                style: TextStyle(
                  color: Colors.redAccent,
                ),
              ),
            );
          }

          if (!snapshot.hasData ||
              snapshot.data!.docs.isEmpty) {
            return Padding(
              padding: const EdgeInsets.all(25),
              child: Center(
                child: Text(
                  "No students found",
                  style: TextStyle(
                    color: textMuted,
                  ),
                ),
              ),
            );
          }

          final students = snapshot.data!.docs;

          return Column(
            children: students.map((doc) {
              final data =
              doc.data() as Map<String, dynamic>;

              final name =
                  data["name"] ?? "No Name";

              final email =
                  data["email"] ?? "";

              return Container(
                margin: const EdgeInsets.only(
                  bottom: 8,
                ),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: panelColor2,
                  borderRadius: BorderRadius.circular(13),
                  border: Border.all(
                    color: borderColor,
                  ),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 21,
                      backgroundColor:
                      neonBlue.withValues(alpha: 0.10),
                      child: Text(
                        name.toString().isNotEmpty
                            ? name
                            .toString()[0]
                            .toUpperCase()
                            : "?",
                        style: TextStyle(
                          color: neonBlue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 11),
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Text(
                            name.toString(),
                            maxLines: 1,
                            overflow:
                            TextOverflow.ellipsis,
                            style: TextStyle(
                              color: textWhite,
                              fontWeight:
                              FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            email.toString(),
                            maxLines: 1,
                            overflow:
                            TextOverflow.ellipsis,
                            style: TextStyle(
                              color: textMuted,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }

  // ============================================================
  // RECENT COURSES + EDIT BUTTON
  // ============================================================

  Widget _buildRecentCourses() {
    return _sectionCard(
      title: "Recent Courses",
      subtitle: "COURSE MANAGEMENT",
      icon: Icons.menu_book_outlined,
      color: neonPurple,
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("courses")
            .orderBy(
          "createdAt",
          descending: true,
        )
            .limit(5)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(25),
                child: CircularProgressIndicator(
                  color: neonPurple,
                  strokeWidth: 2,
                ),
              ),
            );
          }

          if (snapshot.hasError) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                "Unable to load courses.",
                style: TextStyle(
                  color: Colors.redAccent,
                ),
              ),
            );
          }

          if (!snapshot.hasData ||
              snapshot.data!.docs.isEmpty) {
            return Padding(
              padding: const EdgeInsets.all(25),
              child: Center(
                child: Text(
                  "No courses found",
                  style: TextStyle(
                    color: textMuted,
                  ),
                ),
              ),
            );
          }

          final courses = snapshot.data!.docs;

          return Column(
            children: courses.map((doc) {
              final data =
              doc.data() as Map<String, dynamic>;

              final title =
                  data["title"] ?? "Untitled Course";

              final teacher =
                  data["teacher"] ?? "Teacher not available";

              return Container(
                margin: const EdgeInsets.only(
                  bottom: 9,
                ),
                padding: const EdgeInsets.all(11),
                decoration: BoxDecoration(
                  color: panelColor2,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: borderColor,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 45,
                      height: 45,
                      decoration: BoxDecoration(
                        color:
                        neonPurple.withValues(alpha: 0.10),
                        borderRadius:
                        BorderRadius.circular(12),
                        border: Border.all(
                          color:
                          neonPurple.withValues(alpha: 0.25),
                        ),
                      ),
                      child: Icon(
                        Icons.menu_book,
                        color: neonPurple,
                        size: 22,
                      ),
                    ),

                    const SizedBox(width: 11),

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Text(
                            title.toString(),
                            maxLines: 1,
                            overflow:
                            TextOverflow.ellipsis,
                            style: TextStyle(
                              color: textWhite,
                              fontWeight:
                              FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            teacher.toString(),
                            maxLines: 1,
                            overflow:
                            TextOverflow.ellipsis,
                            style: TextStyle(
                              color: textMuted,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 8),

                    // ============================
                    // EDIT COURSE BUTTON
                    // ============================

                    InkWell(
                      borderRadius:
                      BorderRadius.circular(11),
                      onTap: () {
                        openEditCourse(
                          doc.id,
                          data,
                        );
                      },
                      child: Container(
                        padding:
                        const EdgeInsets.symmetric(
                          horizontal: 11,
                          vertical: 9,
                        ),
                        decoration: BoxDecoration(
                          color:
                          neonBlue.withValues(alpha: 0.09),
                          borderRadius:
                          BorderRadius.circular(11),
                          border: Border.all(
                            color:
                            neonBlue.withValues(alpha: 0.30),
                          ),
                        ),
                        child: Row(
                          mainAxisSize:
                          MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.edit_outlined,
                              color: neonBlue,
                              size: 17,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              "EDIT",
                              style: TextStyle(
                                color: neonBlue,
                                fontSize: 10,
                                fontWeight:
                                FontWeight.bold,
                                letterSpacing: 0.7,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }

  // ============================================================
  // QUICK ACTIONS
  // ============================================================

  Widget _buildQuickActions() {
    return _sectionCard(
      title: "Quick Actions",
      subtitle: "ADMIN TOOLS",
      icon: Icons.flash_on_outlined,
      color: neonOrange,
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          _actionButton(
            icon: Icons.add_box_outlined,
            title: "Add Course",
            color: neonBlue,
            onTap: openAddCourse,
          ),

          _actionButton(
            icon: Icons.menu_book_outlined,
            title: "Manage Courses",
            color: neonPurple,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ManageCoursesScreen(),
                ),
              );
            },
          ),

          _actionButton(
            icon: Icons.video_library_outlined,
            title: "Manage Videos",
            color: neonCyan,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ManageVideosScreen(),
                ),
              );
            },
          ),

          _actionButton(
            icon: Icons.quiz_outlined,
            title: "Manage Quiz",
            color: neonOrange,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ManageQuizScreen(),
                ),
              );
            },
          ),

          _actionButton(
            icon: Icons.people_outline,
            title: "Students",
            color: neonPink,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const StudentListScreen(),
                ),
              );
            },
          ),

          _actionButton(
            icon: Icons.bar_chart_outlined,
            title: "Analytics",
            color: neonGreen,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AnalyticsScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ACTION BUTTON
  // ============================================================

  Widget _actionButton({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 13,
        ),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: color.withValues(alpha: 0.25),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: color,
              size: 21,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // PLATFORM HEALTH
  // ============================================================

  Widget _buildPlatformHealth() {
    return _sectionCard(
      title: "Platform Status",
      subtitle: "SYSTEM HEALTH MONITOR",
      icon: Icons.health_and_safety_outlined,
      color: neonGreen,
      child: Column(
        children: [
          _healthRow(
            icon: Icons.cloud_done_outlined,
            title: "Firebase",
            subtitle: "Database connected",
            color: neonGreen,
          ),

          Divider(
            height: 25,
            color: borderColor,
          ),

          _healthRow(
            icon: Icons.people_outline,
            title: "Student System",
            subtitle: "Student records active",
            color: neonBlue,
          ),

          Divider(
            height: 25,
            color: borderColor,
          ),

          _healthRow(
            icon: Icons.school_outlined,
            title: "Learning Platform",
            subtitle: "Courses and content available",
            color: neonOrange,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // HEALTH ROW
  // ============================================================

  Widget _healthRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          width: 45,
          height: 45,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: color.withValues(alpha: 0.20),
            ),
          ),
          child: Icon(
            icon,
            color: color,
          ),
        ),

        const SizedBox(width: 13),

        Expanded(
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: textWhite,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 3),

              Text(
                subtitle,
                style: TextStyle(
                  color: textMuted,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),

        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.6),
                blurRadius: 8,
              ),
            ],
          ),
        ),

        const SizedBox(width: 7),

        Text(
          "ONLINE",
          style: TextStyle(
            color: color,
            fontSize: 9,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // FOOTER
  // ============================================================

  Widget _buildFooter() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(
          bottom: 10,
        ),
        child: Text(
          "MMOC TEACH  •  ADMIN CONTROL CENTER",
          style: TextStyle(
            color: textMuted.withValues(alpha: 0.6),
            fontSize: 9,
            letterSpacing: 1.5,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // COMMON SECTION CARD
  // ============================================================

  Widget _sectionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: panelColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: borderColor,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.045),
            blurRadius: 25,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.08),
                  borderRadius:
                  BorderRadius.circular(12),
                  border: Border.all(
                    color:
                    color.withValues(alpha: 0.22),
                  ),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 21,
                ),
              ),

              const SizedBox(width: 12),

              Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: textWhite,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: textMuted,
                      fontSize: 8,
                      letterSpacing: 1.3,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 17),

          child,
        ],
      ),
    );
  }

  // ============================================================
  // SIDEBAR ITEM
  // ============================================================

  Widget _sidebarItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool selected = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 3,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(13),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 15,
            vertical: 13,
          ),
          decoration: BoxDecoration(
            color: selected
                ? neonBlue.withValues(alpha: 0.10)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(13),
            border: selected
                ? Border.all(
              color:
              neonBlue.withValues(alpha: 0.20),
            )
                : null,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color:
                selected ? neonBlue : textMuted,
                size: 21,
              ),

              const SizedBox(width: 13),

              Text(
                title,
                style: TextStyle(
                  color:
                  selected ? textWhite : textMuted,
                  fontWeight: selected
                      ? FontWeight.bold
                      : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // MOBILE DRAWER ITEM
  // ============================================================

  Widget _mobileDrawerItem(
      IconData icon,
      String title,
      VoidCallback onTap, {
        bool selected = false,
        bool logoutItem = false,
      }) {
    final itemColor =
    logoutItem
        ? Colors.redAccent
        : selected
        ? neonBlue
        : textMuted;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 2,
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(
          icon,
          color: itemColor,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: selected
                ? textWhite
                : itemColor,
            fontWeight: selected
                ? FontWeight.bold
                : FontWeight.w500,
          ),
        ),
        tileColor: selected
            ? neonBlue.withValues(alpha: 0.08)
            : null,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}