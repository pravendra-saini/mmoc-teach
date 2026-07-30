import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddCourseScreen extends StatefulWidget {
  final String? docId;
  final Map<String, dynamic>? course;

  const AddCourseScreen({
    super.key,
    this.docId,
    this.course,
  });

  @override
  State<AddCourseScreen> createState() => _AddCourseScreenState();
}

class _AddCourseScreenState extends State<AddCourseScreen> {
  final titleController = TextEditingController();
  final teacherController = TextEditingController();
  final durationController = TextEditingController();
  final ratingController = TextEditingController();
  final imageController = TextEditingController();

  @override
  void initState() {
    super.initState();

    if (widget.course != null) {
      titleController.text = widget.course!["title"] ?? "";
      teacherController.text = widget.course!["teacher"] ?? "";
      durationController.text = widget.course!["duration"] ?? "";
      ratingController.text =
          widget.course!["rating"].toString();
      imageController.text = widget.course!["image"] ?? "";
    }
  }

  Future<void> saveCourse() async {
    if (titleController.text.trim().isEmpty ||
        teacherController.text.trim().isEmpty ||
        durationController.text.trim().isEmpty ||
        ratingController.text.trim().isEmpty ||
        imageController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill all fields"),
        ),
      );
      return;
    }

    final data = {
      "title": titleController.text.trim(),
      "teacher": teacherController.text.trim(),
      "duration": durationController.text.trim(),
      "rating":
          double.tryParse(ratingController.text.trim()) ?? 5.0,
      "image": imageController.text.trim(),
    };

    if (widget.docId == null) {
      data["createdAt"] = Timestamp.now();

      await FirebaseFirestore.instance
          .collection("courses")
          .add(data);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Course Added Successfully"),
        ),
      );
    } else {
      await FirebaseFirestore.instance
          .collection("courses")
          .doc(widget.docId)
          .update(data);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Course Updated Successfully"),
        ),
      );
    }

    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  void dispose() {
    titleController.dispose();
    teacherController.dispose();
    durationController.dispose();
    ratingController.dispose();
    imageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F7FB),

      appBar: AppBar(
        title: Text(
          widget.docId == null
              ? "Add Course"
              : "Edit Course",
        ),
        backgroundColor: const Color(0xff1565C0),
        foregroundColor: Colors.white,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: "Course Title",
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: teacherController,
              decoration: const InputDecoration(
                labelText: "Teacher Name",
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: durationController,
              decoration: const InputDecoration(
                labelText: "Duration",
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: ratingController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Rating",
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: imageController,
              decoration: const InputDecoration(
                labelText: "Image Path",
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: saveCourse,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff1565C0),
                ),
                child: Text(
                  widget.docId == null
                      ? "Save Course"
                      : "Update Course",
                  style: const TextStyle(
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