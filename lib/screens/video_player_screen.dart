import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
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
  late VideoPlayerController controller;

  bool progressUpdated = false;

  @override
  void initState() {
    super.initState();

    controller = VideoPlayerController.networkUrl(
      Uri.parse(widget.videoUrl),
    );

    controller.initialize().then((_) {
      setState(() {});
    });

    controller.addListener(_updateProgress);
  }

  Future<void> _updateProgress() async {
    if (!controller.value.isInitialized) return;

    if (progressUpdated) return;

    if (controller.value.position >= controller.value.duration &&
        controller.value.duration != Duration.zero) {
      progressUpdated = true;

      final user = FirebaseAuth.instance.currentUser;

      if (user == null) return;

      final progress =
          (((widget.videoIndex + 1) / widget.totalVideos) * 100).round();

      await FirebaseFirestore.instance
          .collection("enrollments")
          .doc("${user.uid}_${widget.courseTitle}")
          .update({
        "progress": progress,
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Progress Updated : $progress%",
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    controller.removeListener(_updateProgress);
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.courseTitle),
        backgroundColor: const Color(0xff1565C0),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: controller.value.isInitialized
            ? SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    AspectRatio(
                      aspectRatio: controller.value.aspectRatio,
                      child: VideoPlayer(controller),
                    ),

                    const SizedBox(height: 20),

                    VideoProgressIndicator(
                      controller,
                      allowScrubbing: true,
                      colors: const VideoProgressColors(
                        playedColor: Colors.blue,
                        bufferedColor: Colors.grey,
                        backgroundColor: Colors.black26,
                      ),
                    ),

                    const SizedBox(height: 25),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              if (controller.value.isPlaying) {
                                controller.pause();
                              } else {
                                controller.play();
                              }
                            });
                          },
                          icon: Icon(
                            controller.value.isPlaying
                                ? Icons.pause
                                : Icons.play_arrow,
                          ),
                          label: Text(
                            controller.value.isPlaying
                                ? "Pause"
                                : "Play",
                          ),
                        ),

                        const SizedBox(width: 20),

                        ElevatedButton.icon(
                          onPressed: () async {
                            await controller.seekTo(Duration.zero);
                            controller.play();
                          },
                          icon: const Icon(Icons.replay),
                          label: const Text("Replay"),
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    Card(
                      child: ListTile(
                        leading: const Icon(
                          Icons.school,
                          color: Colors.blue,
                        ),
                        title: Text(widget.courseTitle),
                        subtitle: Text(
                          "Lesson ${widget.videoIndex + 1} of ${widget.totalVideos}",
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    const Text(
                      "Watch the complete video to automatically update your course progress.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              )
            : const CircularProgressIndicator(),
      ),
    );
  }
}