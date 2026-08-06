import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'certificate_screen.dart';

class MyLearningScreen extends StatelessWidget {
  const MyLearningScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Learning"),
        backgroundColor: const Color(0xff1565C0),
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("enrollments")
            .where("uid", isEqualTo: user?.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!snapshot.hasData ||
              snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "No Enrolled Courses",
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          final courses = snapshot.data!.docs;

          return ListView.builder(
            itemCount: courses.length,
            itemBuilder: (context, index) {
              final data = courses[index].data()
                  as Map<String, dynamic>;

              final progress = data["progress"] ?? 0;

              return FutureBuilder<QuerySnapshot>(
                future: FirebaseFirestore.instance
                    .collection("quiz_results")
                    .where("uid", isEqualTo: user!.uid)
                    .where(
                      "courseName",
                      isEqualTo: data["courseName"],
                    )
                    .get(),
                builder: (context, quizSnapshot) {
                  int score = 0;
                  int total = 0;

                  if (quizSnapshot.hasData &&
                      quizSnapshot.data!.docs.isNotEmpty) {
                    final quiz =
                        quizSnapshot.data!.docs.first.data()
                            as Map<String, dynamic>;

                    score = quiz["score"] ?? 0;
                    total = quiz["total"] ?? 0;
                  }

                  bool passed = false;

                  if (total > 0) {
                    passed = (score / total) >= 0.6;
                  }

                  bool certificateUnlocked =
                      progress == 100 && passed;

                  return Card(
                    margin: const EdgeInsets.all(12),
                    child: Padding(
                      padding: const EdgeInsets.all(15),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            data["courseName"],
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 10),

                          Text(
                            "Teacher : ${data["teacher"]}",
                          ),

                          const SizedBox(height: 15),

                          LinearProgressIndicator(
                            value: progress / 100,
                            minHeight: 10,
                          ),

                          const SizedBox(height: 10),

                          Text(
                            "Progress : $progress%",
                            style: const TextStyle(
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 10),

                          Text(
                            "Quiz Score : $score / $total",
                            style: const TextStyle(
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 15),

                          if (certificateUnlocked)
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                style:
                                    ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Colors.green,
                                ),
                                icon: const Icon(
                                  Icons.workspace_premium,
                                  color: Colors.white,
                                ),
                                label: const Text(
                                  "Download Certificate",
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          CertificateScreen(
                                        courseName:
                                            data["courseName"],
                                        studentName:
                                            user.email ??
                                                "Student",
                                      ),
                                    ),
                                  );
                                },
                              ),
                            )
                          else
                            Container(
                              width: double.infinity,
                              padding:
                                  const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color:
                                    Colors.orange.shade100,
                                borderRadius:
                                    BorderRadius
                                        .circular(10),
                              ),
                              child: const Text(
                                "🔒 Complete Course (100%) and Pass Quiz (60%) to Unlock Certificate",
                                style: TextStyle(
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}