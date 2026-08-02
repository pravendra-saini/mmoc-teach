import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'login_screen.dart';
import 'manage_courses_screen.dart';
import 'add_course_screen.dart';
import 'student_list_screen.dart';
import 'analytics_screen.dart';
import 'add_quiz_screen.dart';
import 'manage_quiz_screen.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  Future<void> logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F7FB),

      appBar: AppBar(
        title: const Text("Admin Dashboard"),
        backgroundColor: const Color(0xff1565C0),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => logout(context),
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
          children: [
            dashboardCard(
              context,
              Icons.menu_book,
              "Manage Courses",
            ),

            dashboardCard(
              context,
              Icons.add_box,
              "Add Course",
            ),

            dashboardCard(
              context,
              Icons.video_library,
              "Add Videos",
            ),

            dashboardCard(
              context,
              Icons.people,
              "Students",
            ),

            dashboardCard(
              context,
              Icons.bar_chart,
              "Analytics",
            ),

            dashboardCard(
              context,
              Icons.quiz,
              "Manage Quiz",
            ),
          ],
        ),
      ),
    );
  }

  Widget dashboardCard(
    BuildContext context,
    IconData icon,
    String title,
  ) {
    return Card(
      elevation: 6,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {

          if (title == "Manage Courses") {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const ManageCoursesScreen(),
              ),
            );
          }

          else if (title == "Add Course") {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const AddCourseScreen(),
              ),
            );
          }

          else if (title == "Add Videos") {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const ManageCoursesScreen(),
              ),
            );
          }

          else if (title == "Students") {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const StudentListScreen(),
              ),
            );
          }

          else if (title == "Analytics") {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const AnalyticsScreen(),
              ),
            );
          }

          else if (title == "Manage Quiz") {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const ManageQuizScreen(),
              ),
            );
          }

          else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("$title Coming Soon"),
              ),
            );
          }
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            Icon(
              icon,
              size: 55,
              color: Colors.blue,
            ),

            const SizedBox(height: 15),

            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}