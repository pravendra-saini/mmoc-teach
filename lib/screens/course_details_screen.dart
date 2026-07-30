import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/course_model.dart';
import '../data/video_data.dart';
import 'video_player_screen.dart';
import 'video_list_screen.dart';
import 'review_screen.dart';


class CourseDetailsScreen extends StatelessWidget {
  final CourseModel course;

  const CourseDetailsScreen({
    super.key,
    required this.course,
  });

  @override
  Widget build(BuildContext context) {
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
            Image.asset(
              course.image,
              width: double.infinity,
              height: 220,
              fit: BoxFit.cover,
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                      const SizedBox(width: 5),
                      Text("${course.rating} Rating"),
                    ],
                  ),

                  const SizedBox(height: 15),

                  Text(
                    "Teacher : ${course.teacher}",
                    style: const TextStyle(fontSize: 18),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    "Duration : ${course.duration}",
                    style: const TextStyle(fontSize: 18),
                  ),

                  const SizedBox(height: 30),

                  const Text(
                    "About Course",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    "Learn this course from basic to advanced with practical projects and real examples.",
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.6,
                    ),
                  ),

                  const SizedBox(height: 30),

                  
// =========================
// VIDEO LESSON BUTTON
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
      final videos = videoData[course.title];

      if (videos == null || videos.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("No Videos Available"),
          ),
        );
        return;
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => VideoListScreen(
            courseTitle: course.title,
          
          ),
        ),
      );
    },
  ),
),
                  const SizedBox(height: 20),


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
                  // WISHLIST BUTTON
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
                          fontSize: 18,
                          color: Colors.white,
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