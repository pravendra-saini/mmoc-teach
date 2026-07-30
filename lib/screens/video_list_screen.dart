import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'video_player_screen.dart';

class VideoListScreen extends StatelessWidget {
  final String courseTitle;

  const VideoListScreen({
    super.key,
    required this.courseTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(courseTitle),
        backgroundColor: const Color(0xff1565C0),
        foregroundColor: Colors.white,
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("videos")
            .where("courseName", isEqualTo: courseTitle)
            .orderBy("createdAt")
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
                "No Videos Available",
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          final videos = snapshot.data!.docs;

          return ListView.builder(
            itemCount: videos.length,
            itemBuilder: (context, index) {
              final video =
                  videos[index].data() as Map<String, dynamic>;

              return Card(
                margin: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.red,
                    child: Text(
                      "${index + 1}",
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),

                  title: Text(video["title"]),

                  subtitle: Text(
                    "${video["duration"]} min",
                  ),

                  trailing: const Icon(
                    Icons.play_circle_fill,
                    color: Colors.blue,
                    size: 32,
                  ),

                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => VideoPlayerScreen(
                          videoUrl: video["videoUrl"],
                          courseTitle: courseTitle,
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