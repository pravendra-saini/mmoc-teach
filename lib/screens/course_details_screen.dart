import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/course_model.dart';
import 'course_videos_screen.dart';
import 'review_screen.dart';
import 'quiz_screen.dart';
import 'certificate_screen.dart';

class CourseDetailsScreen extends StatefulWidget {
  final CourseModel course;

  const CourseDetailsScreen({
    super.key,
    required this.course,
  });

  @override
  State<CourseDetailsScreen> createState() =>
      _CourseDetailsScreenState();
}

class _CourseDetailsScreenState
    extends State<CourseDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    final course = widget.course;

    return Scaffold(
      backgroundColor: const Color(0xffF5F7FB),

      appBar: AppBar(
        backgroundColor: const Color(0xff1565C0),
        foregroundColor: Colors.white,
        title: Text(course.title),
      ),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Course Image
            ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
              child: Image.asset(
                course.image,
                width: double.infinity,
                height: 220,
                fit: BoxFit.cover,
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [

                  Text(
                    course.title,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 15),

                  Row(
                    children: [

                      const Icon(
                        Icons.star,
                        color: Colors.orange,
                      ),

                      const SizedBox(width: 8),

                      Text(
                        "${course.rating} Rating",
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),

                    ],
                  ),

                  const SizedBox(height: 15),

                  Text(
                    "Teacher : ${course.teacher}",
                    style: const TextStyle(
                      fontSize: 18,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    "Duration : ${course.duration}",
                    style: const TextStyle(
                      fontSize: 18,
                    ),
                  ),

                  const SizedBox(height: 25),

                  const Text(
                    "About Course",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    "Learn this complete course from beginner to advanced level with practical examples, projects and quizzes.",
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.6,
                    ),
                  ),

                  const SizedBox(height: 30),

                                    // =========================
                  // WATCH VIDEO LESSONS
                  // =========================

                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.play_circle_fill),
                      label: const Text(
                        "Watch Video Lessons",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepOrange,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CourseVideosScreen(
                              courseName:
                                  course.title.trim().toLowerCase(),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 20),

                  // =========================
                  // REVIEW
                  // =========================

                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.rate_review),
                      label: const Text(
                        "Write Review",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ReviewScreen(
                              courseName: course.title,
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 20),

                  // =========================
                  // QUIZ
                  // =========================

                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.quiz),
                      label: const Text(
                        "Take Quiz",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => QuizScreen(
                              courseName:
                                  course.title.trim().toLowerCase(),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 25),

                  // =========================
                  // COURSE PROGRESS
                  // =========================

                  StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection("enrollments")
                        .doc(
                          "${FirebaseAuth.instance.currentUser?.uid}_${course.title}",
                        )
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData ||
                          !snapshot.data!.exists) {
                        return const SizedBox();
                      }

                      final data = snapshot.data!.data()
                          as Map<String, dynamic>;

                      final progress =
                          (data["progress"] ?? 0) as int;

                      return Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [

                          const Text(
                            "Course Progress",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 10),

                          LinearProgressIndicator(
                            value: progress / 100,
                            minHeight: 10,
                            backgroundColor:
                                Colors.grey.shade300,
                            color: Colors.green,
                          ),

                          const SizedBox(height: 10),

                          Text(
                            "$progress% Completed",
                            style: const TextStyle(
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),

                          if (progress == 100)
                            Padding(
                              padding:
                                  const EdgeInsets.only(
                                      top: 15),
                              child: SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  icon: const Icon(
                                      Icons.workspace_premium),
                                  style:
                                      ElevatedButton.styleFrom(
                                    backgroundColor:
                                        Colors.orange,
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            CertificateScreen(
                                          courseName:
                                              course.title,
                                          studentName:
                                              FirebaseAuth
                                                      .instance
                                                      .currentUser
                                                      ?.email ??
                                                  "Student",
                                        ),
                                      ),
                                    );
                                  },
                                  label: const Text(
                                    "Download Certificate",
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 25),

                                    // =========================
                  // ADD TO WISHLIST
                  // =========================

                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.favorite),
                      label: const Text(
                        "Add to Wishlist",
                        style: TextStyle(fontSize: 18),
                      ),
                      onPressed: () async {
                        final user =
                            FirebaseAuth.instance.currentUser;

                        if (user == null) return;

                        final doc = FirebaseFirestore.instance
                            .collection("wishlist")
                            .doc("${user.uid}_${course.title}");

                        final already = await doc.get();

                        if (already.exists) {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(
                            const SnackBar(
                              content:
                                  Text("Already in Wishlist"),
                            ),
                          );
                          return;
                        }

                        await doc.set({
                          "uid": user.uid,
                          "email": user.email,
                          "courseName": course.title,
                          "teacher": course.teacher,
                          "duration": course.duration,
                          "rating": course.rating,
                          "image": course.image,
                          "addedAt": Timestamp.now(),
                        });

                        if (!context.mounted) return;

                        ScaffoldMessenger.of(context)
                            .showSnackBar(
                          const SnackBar(
                            content:
                                Text("Added to Wishlist ❤️"),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 20),

                  // =========================
                  // ENROLL BUTTON
                  // =========================

                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color(0xff1565C0),
                      ),
                      onPressed: () async {
                        final user =
                            FirebaseAuth.instance.currentUser;

                        if (user == null) return;

                        final doc = FirebaseFirestore.instance
                            .collection("enrollments")
                            .doc("${user.uid}_${course.title}");

                        final already = await doc.get();

                        if (already.exists) {
                          if (!context.mounted) return;

                          ScaffoldMessenger.of(context)
                              .showSnackBar(
                            const SnackBar(
                              content:
                                  Text("Already Enrolled"),
                            ),
                          );
                          return;
                        }

                        await doc.set({
                          "uid": user.uid,
                          "email": user.email,
                          "courseName": course.title,
                          "teacher": course.teacher,
                          "duration": course.duration,
                          "rating": course.rating,
                          "image": course.image,
                          "progress": 0,
                          "enrolledAt": Timestamp.now(),
                        });

                        if (!context.mounted) return;

                        ScaffoldMessenger.of(context)
                            .showSnackBar(
                          SnackBar(
                            content: Text(
                              "Successfully Enrolled in ${course.title}",
                            ),
                          ),
                        );
                      },
                      child: const Text(
                        "Enroll Now",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
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
}