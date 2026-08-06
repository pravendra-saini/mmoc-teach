import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String videoUrl;
  final String courseTitle;
  final int videoIndex;
  final int totalVideos;

  const VideoPlayerScreen({
    super.key,
    required this.videoUrl,
    required this.courseTitle,
    required this.videoIndex,
    required this.totalVideos,
  });

  @override
  State<VideoPlayerScreen> createState() =>
      _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  bool progressUpdated = false;

  Future<void> _openVideo() async {
    debugPrint("========== VIDEO DEBUG ==========");
    debugPrint("VIDEO URL : ${widget.videoUrl}");

    if (widget.videoUrl.trim().isEmpty) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("❌ Video URL Empty Hai"),
        ),
      );
      return;
    }

    final Uri url = Uri.parse(widget.videoUrl);

    debugPrint("URI : $url");

    if (!await canLaunchUrl(url)) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("❌ Invalid Video URL"),
        ),
      );

      return;
    }

    await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    );
  }

  Future<void> _markCompleted() async {
    if (progressUpdated) return;

    progressUpdated = true;

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    int progress =
        (((widget.videoIndex + 1) / widget.totalVideos) * 100)
            .round();

    if (progress > 100) {
      progress = 100;
    }

    final doc = FirebaseFirestore.instance
        .collection("enrollments")
        .doc("${user.uid}_${widget.courseTitle}");

    final snapshot = await doc.get();

    if (snapshot.exists) {
      await doc.update({
        "progress": progress,
        "updatedAt": Timestamp.now(),
      });
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("🎉 Progress Updated : $progress%"),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.courseTitle),
        backgroundColor: const Color(0xff1565C0),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(
              Icons.play_circle_fill,
              size: 120,
              color: Colors.red,
            ),

            const SizedBox(height: 20),

            Text(
              widget.courseTitle,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              "Lesson ${widget.videoIndex + 1} of ${widget.totalVideos}",
              style: const TextStyle(fontSize: 18),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: _openVideo,
                icon: const Icon(Icons.play_arrow),
                label: const Text(
                  "Watch Video",
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: _markCompleted,
                icon: const Icon(Icons.check_circle),
                label: const Text(
                  "Mark as Completed",
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),

            const SizedBox(height: 30),

            const Text(
              "Click Watch Video to open YouTube.\nAfter watching, click Mark as Completed.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}