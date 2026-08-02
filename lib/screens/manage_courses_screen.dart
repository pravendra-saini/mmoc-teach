import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'add_course_screen.dart';
import 'add_video_screen.dart';

class ManageCoursesScreen extends StatelessWidget {
  const ManageCoursesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F7FB),

      appBar: AppBar(
        title: const Text("Manage Courses"),
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
              builder: (_) => const AddCourseScreen(),
            ),
          );
        },
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("courses")
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
                "No Courses Found",
                style: TextStyle(fontSize: 20),
              ),
            );
          }

          final courses = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(15),
            itemCount: courses.length,
            itemBuilder: (context, index) {
              final doc = courses[index];
              final data =
                  doc.data() as Map<String, dynamic>;

              return Card(
                elevation: 5,
                margin: const EdgeInsets.only(bottom: 15),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xff1565C0),
                    child: Icon(
                      Icons.menu_book,
                      color: Colors.white,
                    ),
                  ),

                  title: Text(
                    data["title"] ?? "",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  subtitle: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(data["teacher"] ?? ""),
                      Text(data["duration"] ?? ""),
                    ],
                  ),

                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [

                      // EDIT COURSE
                      IconButton(
                        icon: const Icon(
                          Icons.edit,
                          color: Colors.blue,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AddCourseScreen(
                                docId: doc.id,
                                course: data,
                              ),
                            ),
                          );
                        },
                      ),

                      // ADD VIDEO
                      IconButton(
                        icon: const Icon(
                          Icons.video_library,
                          color: Colors.green,
                        ),
                        tooltip: "Add Videos",
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AddVideoScreen(
                                courseId: doc.id,
                                courseName: data["title"] ?? "",
                              ),
                            ),
                          );
                        },
                      ),

                      // DELETE COURSE
                      IconButton(
                        icon: const Icon(
                          Icons.delete,
                          color: Colors.red,
                        ),
                        onPressed: () async {
                          final ok = await showDialog<bool>(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: const Text(
                                      "Delete Course"),
                                  content: const Text(
                                    "Are you sure you want to delete this course?",
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(
                                            context, false);
                                      },
                                      child:
                                          const Text("Cancel"),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.pop(
                                            context, true);
                                      },
                                      child:
                                          const Text("Delete"),
                                    ),
                                  ],
                                ),
                              ) ??
                              false;

                          if (!ok) return;

                          await FirebaseFirestore.instance
                              .collection("courses")
                              .doc(doc.id)
                              .delete();

                          if (!context.mounted) return;

                          ScaffoldMessenger.of(context)
                              .showSnackBar(
                            const SnackBar(
                              content: Text(
                                "Course Deleted Successfully",
                              ),
                            ),
                          );
                        },
                      ),
                    ],
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