import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'result_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class QuizScreen extends StatefulWidget {
  final String courseName;

  const QuizScreen({
    super.key,
    required this.courseName,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final Map<int, String> selectedAnswers = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.courseName} Quiz"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("quizzes")
            .where(
              "courseName",
              isEqualTo: widget.courseName.trim().toLowerCase(),
            )
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
                "No Quiz Available",
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          final quizzes = snapshot.data!.docs;

          return Column(
            children: [

              Expanded(
                child: ListView.builder(
                  itemCount: quizzes.length,
                  itemBuilder: (context, index) {

                    final data =
                        quizzes[index].data()
                            as Map<String, dynamic>;

                    return Card(
                      margin: const EdgeInsets.all(12),
                      child: Padding(
                        padding:
                            const EdgeInsets.all(15),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [

                            Text(
                              "Q${index + 1}. ${data["question"]}",
                              style: const TextStyle(
                                fontWeight:
                                    FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),

                            const SizedBox(height: 15),

                            RadioListTile<String>(
                              value: data["option1"],
                              groupValue:
                                  selectedAnswers[index],
                              title:
                                  Text(data["option1"]),
                              onChanged: (value) {
                                setState(() {
                                  selectedAnswers[index] =
                                      value!;
                                });
                              },
                            ),

                            RadioListTile<String>(
                              value: data["option2"],
                              groupValue:
                                  selectedAnswers[index],
                              title:
                                  Text(data["option2"]),
                              onChanged: (value) {
                                setState(() {
                                  selectedAnswers[index] =
                                      value!;
                                });
                              },
                            ),

                            RadioListTile<String>(
                              value: data["option3"],
                              groupValue:
                                  selectedAnswers[index],
                              title:
                                  Text(data["option3"]),
                              onChanged: (value) {
                                setState(() {
                                  selectedAnswers[index] =
                                      value!;
                                });
                              },
                            ),

                            RadioListTile<String>(
                              value: data["option4"],
                              groupValue:
                                  selectedAnswers[index],
                              title:
                                  Text(data["option4"]),
                              onChanged: (value) {
                                setState(() {
                                  selectedAnswers[index] =
                                      value!;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(15),
                child: SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    child: const Text(
                      "Submit Quiz",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                    onPressed: () async {
                      int score = 0;

                      for (int i = 0; i < quizzes.length; i++) {
                        final data =
                            quizzes[i].data() as Map<String, dynamic>;

                        if (selectedAnswers[i] == data["answer"]) {
                          score++;
                        }
                      }

                      final user = FirebaseAuth.instance.currentUser;

                      if (user != null) {
                        await FirebaseFirestore.instance
                            .collection("quiz_results")
                            .add({
                          "uid": user.uid,
                          "email": user.email,
                          "courseName": widget.courseName,
                          "score": score,
                          "total": quizzes.length,
                          "submittedAt": Timestamp.now(),
                        });
                      }

                      if (!context.mounted) return;

                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ResultScreen(
                            score: score,
                            total: quizzes.length,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}