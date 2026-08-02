import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddVideoScreen extends StatefulWidget {
  final String courseId;
  final String courseName;

  const AddVideoScreen({
    super.key,
    required this.courseId,
    required this.courseName,
  });

  @override
  State<AddVideoScreen> createState() => _AddVideoScreenState();
}

class _AddVideoScreenState extends State<AddVideoScreen> {
  final TextEditingController titleController =
      TextEditingController();

  final TextEditingController urlController =
      TextEditingController();

  final TextEditingController durationController =
      TextEditingController();

  bool isLoading = false;

  @override
  void dispose() {
    titleController.dispose();
    urlController.dispose();
    durationController.dispose();
    super.dispose();
  }

  Future<void> saveVideo() async {
    if (titleController.text.trim().isEmpty ||
        urlController.text.trim().isEmpty ||
        durationController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill all fields"),
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    await FirebaseFirestore.instance.collection("videos").add({
      "courseId": widget.courseId,
     "courseName": widget.courseName.trim().toLowerCase(),
      "title": titleController.text.trim(),
      "videoUrl": urlController.text.trim(),
      "duration": int.tryParse(durationController.text.trim()) ?? 0,
      "createdAt": Timestamp.now(),
    });

    setState(() {
      isLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Video Added Successfully"),
      ),
    );

    titleController.clear();
    urlController.clear();
    durationController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F7FB),

      appBar: AppBar(
        title: const Text("Add Video"),
        backgroundColor: const Color(0xff1565C0),
        foregroundColor: Colors.white,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                "Course : ${widget.courseName}",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: "Video Title",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: urlController,
              decoration: const InputDecoration(
                labelText: "YouTube Video URL",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: durationController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Duration (Minutes)",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff1565C0),
                ),
                onPressed: isLoading ? null : saveVideo,
                child: isLoading
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                      )
                    : const Text(
                        "Save Video",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}