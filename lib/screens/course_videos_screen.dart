import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'video_player_screen.dart';

class CourseVideosScreen extends StatelessWidget {
  final String courseName;

  const CourseVideosScreen({
    super.key,
    required this.courseName,
  });

  @override
  Widget build(BuildContext context) {
    final searchCourse = courseName.trim().toLowerCase();

    print("Course Name Received: $searchCourse");

    return Scaffold(
      appBar: AppBar(
        title: Text(courseName),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("videos")
            .where(
              "courseName",
              isEqualTo: searchCourse,
            )
            .snapshots(), // ✅ orderBy hata diya

        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(snapshot.error.toString()),
            );
          }

          if (!snapshot.hasData ||
              snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "No Videos Added Yet",
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          final videos = snapshot.data!.docs;

          print("Videos Found: ${videos.length}");

          return ListView.builder(
            itemCount: videos.length,
            itemBuilder: (context, index) {
              final data =
                  videos[index].data() as Map<String, dynamic>;

              return Card(
                margin: const EdgeInsets.all(10),
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

                  title: Text(data["title"] ?? ""),

                  subtitle: Text(
                    "${data["duration"]} Minutes",
                  ),

                  trailing: const Icon(
                    Icons.play_circle_fill,
                    color: Colors.blue,
                  ),

                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => VideoPlayerScreen(
                          videoUrl: data["videoUrl"] ?? "",
                          courseTitle: courseName,
                          videoIndex: index,
                          totalVideos: videos.length,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}