import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'add_quiz_screen.dart';

class ManageQuizScreen extends StatelessWidget {
  const ManageQuizScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F7FB),

      appBar: AppBar(
        title: const Text("Manage Quiz"),
        backgroundColor: const Color(0xff1565C0),
        foregroundColor: Colors.white,
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xff1565C0),
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddQuizScreen(),
            ),
          );
        },
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("quizzes")
            .orderBy("createdAt", descending: true)
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
                "No Quiz Added",
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          final quizzes = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(15),
            itemCount: quizzes.length,
            itemBuilder: (context, index) {
              final doc = quizzes[index];

              final data =
                  doc.data() as Map<String, dynamic>;

              return Card(
                elevation: 5,
                margin: const EdgeInsets.only(bottom: 15),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue,
                    child: Text(
                      "${index + 1}",
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),

                  title: Text(
                    data["question"] ?? "",
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  subtitle: Text(
                    "Course : ${data["courseName"]}",
                  ),

                  trailing: IconButton(
                    icon: const Icon(
                      Icons.delete,
                      color: Colors.red,
                    ),
                    onPressed: () async {
                      await FirebaseFirestore.instance
                          .collection("quizzes")
                          .doc(doc.id)
                          .delete();

                      if (!context.mounted) return;

                      ScaffoldMessenger.of(context)
                          .showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Quiz Deleted",
                          ),
                        ),
                      );
                    },
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