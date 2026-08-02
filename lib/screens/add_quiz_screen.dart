import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddQuizScreen extends StatefulWidget {
  const AddQuizScreen({super.key});

  @override
  State<AddQuizScreen> createState() => _AddQuizScreenState();
}

class _AddQuizScreenState extends State<AddQuizScreen> {
  final TextEditingController courseController = TextEditingController();
  final TextEditingController questionController = TextEditingController();

  final TextEditingController option1Controller = TextEditingController();
  final TextEditingController option2Controller = TextEditingController();
  final TextEditingController option3Controller = TextEditingController();
  final TextEditingController option4Controller = TextEditingController();

  String correctAnswer = "";
  bool isLoading = false;

  @override
  void dispose() {
    courseController.dispose();
    questionController.dispose();
    option1Controller.dispose();
    option2Controller.dispose();
    option3Controller.dispose();
    option4Controller.dispose();
    super.dispose();
  }

  Future<void> saveQuiz() async {
    if (courseController.text.trim().isEmpty ||
        questionController.text.trim().isEmpty ||
        option1Controller.text.trim().isEmpty ||
        option2Controller.text.trim().isEmpty ||
        option3Controller.text.trim().isEmpty ||
        option4Controller.text.trim().isEmpty ||
        correctAnswer.isEmpty) {
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

    await FirebaseFirestore.instance.collection("quizzes").add({
      "courseName": courseController.text.trim().toLowerCase(),
      "question": questionController.text.trim(),
      "option1": option1Controller.text.trim(),
      "option2": option2Controller.text.trim(),
      "option3": option3Controller.text.trim(),
      "option4": option4Controller.text.trim(),
      "answer": correctAnswer,
      "createdAt": Timestamp.now(),
    });

    setState(() {
      isLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Quiz Added Successfully"),
      ),
    );

    courseController.clear();
    questionController.clear();
    option1Controller.clear();
    option2Controller.clear();
    option3Controller.clear();
    option4Controller.clear();

    setState(() {
      correctAnswer = "";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F7FB),

      appBar: AppBar(
        title: const Text("Add Quiz"),
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
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: questionController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: "Question",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: option1Controller,
              decoration: const InputDecoration(
                labelText: "Option 1",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: option2Controller,
              decoration: const InputDecoration(
                labelText: "Option 2",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: option3Controller,
              decoration: const InputDecoration(
                labelText: "Option 3",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: option4Controller,
              decoration: const InputDecoration(
                labelText: "Option 4",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 25),

            DropdownButtonFormField<String>(
              value: correctAnswer.isEmpty ? null : correctAnswer,
              decoration: const InputDecoration(
                labelText: "Correct Answer",
                border: OutlineInputBorder(),
              ),
              items: [
                DropdownMenuItem(
                  value: option1Controller.text,
                  child: Text(
                    option1Controller.text.isEmpty
                        ? "Option 1"
                        : option1Controller.text,
                  ),
                ),
                DropdownMenuItem(
                  value: option2Controller.text,
                  child: Text(
                    option2Controller.text.isEmpty
                        ? "Option 2"
                        : option2Controller.text,
                  ),
                ),
                DropdownMenuItem(
                  value: option3Controller.text,
                  child: Text(
                    option3Controller.text.isEmpty
                        ? "Option 3"
                        : option3Controller.text,
                  ),
                ),
                DropdownMenuItem(
                  value: option4Controller.text,
                  child: Text(
                    option4Controller.text.isEmpty
                        ? "Option 4"
                        : option4Controller.text,
                  ),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  correctAnswer = value!;
                });
              },
            ),

            const SizedBox(height: 35),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff1565C0),
                ),
                onPressed: isLoading ? null : saveQuiz,
                child: isLoading
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                      )
                    : const Text(
                        "Save Quiz",
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