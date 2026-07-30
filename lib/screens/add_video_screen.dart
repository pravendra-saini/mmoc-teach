import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddVideoScreen extends StatefulWidget {
  const AddVideoScreen({super.key});

  @override
  State<AddVideoScreen> createState() => _AddVideoScreenState();
}

class _AddVideoScreenState extends State<AddVideoScreen> {
  final TextEditingController courseController =
      TextEditingController();

  final TextEditingController titleController =
      TextEditingController();

  final TextEditingController urlController =
      TextEditingController();

  final TextEditingController durationController =
      TextEditingController();

  @override
  void dispose() {
    courseController.dispose();
    titleController.dispose();
    urlController.dispose();
    durationController.dispose();
    super.dispose();
  }

  Future<void> saveVideo() async {
    if (courseController.text.trim().isEmpty ||
        titleController.text.trim().isEmpty ||
        urlController.text.trim().isEmpty ||
        durationController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill all fields"),
        ),
      );
      return;
    }

    await FirebaseFirestore.instance.collection("videos").add({
      "courseName": courseController.text.trim(),
      "title": titleController.text.trim(),
      "videoUrl": urlController.text.trim(),
      "duration":
          int.tryParse(durationController.text.trim()) ?? 0,
      "createdAt": Timestamp.now(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Video Added Successfully"),
      ),
    );

    courseController.clear();
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
          children: [

            TextField(
              controller: courseController,
              decoration: const InputDecoration(
                labelText: "Course Name",
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: "Video Title",
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: urlController,
              decoration: const InputDecoration(
                labelText: "Video URL",
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: durationController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Duration (Minutes)",
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
                onPressed: saveVideo,
                child: const Text(
                  "Save Video",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
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