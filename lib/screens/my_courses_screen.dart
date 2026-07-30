import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/course_model.dart';
import 'course_details_screen.dart';
import 'certificate_screen.dart';

class MyCoursesScreen extends StatelessWidget {
  const MyCoursesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff1565C0),
        foregroundColor: Colors.white,
        title: const Text("My Courses"),
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("enrollments")
            .where("uid", isEqualTo: user!.uid)
            .snapshots(),

        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "No Courses Enrolled",
                style: TextStyle(fontSize: 20),
              ),
            );
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(15),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data =
                  docs[index].data() as Map<String, dynamic>;

              return Card(
                margin: const EdgeInsets.only(bottom: 15),
                elevation: 4,

                child: ListTile(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CourseDetailsScreen(
                          course: CourseModel(
                            title: data["courseName"],
                            teacher: data["teacher"],
                            duration: data["duration"],
                            image: data["image"],
                            rating:
                                (data["rating"] as num).toDouble(),
                          ),
                        ),
                      ),
                    );
                  },

                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      data["image"],
                      width: 70,
                      height: 70,
                      fit: BoxFit.cover,
                    ),
                  ),

                  title: Text(
                    data["courseName"],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  subtitle: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [

                      const SizedBox(height: 5),

                      Text(data["teacher"]),

                      Text(data["duration"]),

                      const SizedBox(height: 10),

                      LinearProgressIndicator(
                        value:
                            ((data["progress"] ?? 0) as num)
                                    .toDouble() /
                                100,
                        minHeight: 8,
                        backgroundColor:
                            Colors.grey.shade300,
                        color: Colors.green,
                      ),

                      const SizedBox(height: 5),

                      Text(
                        "${data["progress"] ?? 0}% Completed",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

trailing: (data["progress"] ?? 0) == 100
    ? IconButton(
        icon: const Icon(
          Icons.workspace_premium,
          color: Colors.orange,
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CertificateScreen(
                courseName: data["courseName"],
                studentName:
                    user.email ?? "MMOC Teach Student",
              ),
            ),
          );
        },
      )
    : const Tooltip(
        message: "Complete the course to unlock certificate",
        child: Icon(
          Icons.lock,
          color: Colors.grey,
        ),
      ),
    
                ),
              );
            },
          );
        },
      ),
    );
  }
}