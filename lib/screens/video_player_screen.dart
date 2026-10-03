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
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  bool progressUpdated = false;
  bool isSaving = false;

  void _showSnack(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message)),
      );
  }

  // ============================================================
  // OPEN VIDEO
  // ============================================================

  Future<void> _openVideo() async {
    debugPrint("========== VIDEO DEBUG ==========");
    debugPrint("VIDEO URL : ${widget.videoUrl}");

    final rawUrl = widget.videoUrl.trim();

    if (rawUrl.isEmpty) {
      _showSnack("❌ Video URL Empty Hai");
      return;
    }

    final Uri? url = Uri.tryParse(rawUrl);

    if (url == null || !url.hasScheme) {
      _showSnack("❌ Invalid Video URL");
      return;
    }

    debugPrint("URI : $url");

    try {
      final opened = await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );

      if (!opened) {
        _showSnack("❌ Unable to open video");
      }
    } catch (e) {
      debugPrint("LAUNCH ERROR: $e");
      _showSnack("❌ Unable to open video");
    }
  }

  // ============================================================
  // MARK COMPLETED
  // ============================================================

  Future<void> _markCompleted() async {
    if (isSaving) return;

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      _showSnack("Please login first.");
      return;
    }

    if (widget.totalVideos <= 0) return;

    setState(() {
      isSaving = true;
    });

    try {
      final enrollments =
      FirebaseFirestore.instance.collection("enrollments");

      final title = widget.courseTitle.trim();

      final candidateIds = <String>{
        "${user.uid}_$title",
        "${user.uid}_${title.toLowerCase()}",
        "${user.uid}_${title.toUpperCase()}",
      };

      DocumentReference<Map<String, dynamic>>? foundRef;
      Map<String, dynamic>? foundData;

      for (final id in candidateIds) {
        final ref = enrollments.doc(id);
        final snap = await ref.get();

        if (snap.exists) {
          foundRef = ref;
          foundData = snap.data();
          break;
        }
      }

      if (foundRef == null) {
        _showSnack("Please enroll in this course first.");
        return;
      }

      final done = <int>{};
      final saved = foundData?["completedLessons"];

      if (saved is List) {
        for (final e in saved) {
          if (e is num) done.add(e.toInt());
        }
      }

      if (done.contains(widget.videoIndex)) {
        _showSnack("✅ Lesson already completed.");
        return;
      }

      done.add(widget.videoIndex);

      final progress =
      ((done.length / widget.totalVideos) * 100).round().clamp(0, 100);

      await foundRef.update({
        "completedLessons": done.toList()..sort(),
        "totalLessons": widget.totalVideos,
        "progress": progress,
        "updatedAt": Timestamp.now(),
      });

      _showSnack(
        "🎉 ${done.length}/${widget.totalVideos} lessons done ($progress%)",
      );
    } on FirebaseException catch (e) {
      debugPrint("PROGRESS FIREBASE ERROR: ${e.code} - ${e.message}");
      _showSnack("Unable to update progress.");
    } catch (e) {
      debugPrint("PROGRESS ERROR: $e");
      _showSnack("Unable to update progress.");
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }
  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.courseTitle),
        backgroundColor: const Color(0xff1565C0),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
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
              textAlign: TextAlign.center,
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
                onPressed: isSaving ? null : _markCompleted,
                icon: isSaving
                    ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : const Icon(Icons.check_circle),
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