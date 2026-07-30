import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ReviewScreen extends StatefulWidget {
  final String courseName;

  const ReviewScreen({
    super.key,
    required this.courseName,
  });

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  final TextEditingController reviewController =
      TextEditingController();

  int rating = 5;
  bool isLoading = false;

  Future<void> submitReview() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    if (reviewController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please write your review"),
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    // User Name
    String studentName = "Student";

    final userDoc = await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .get();

    if (userDoc.exists) {
      final data = userDoc.data()!;
      studentName = data["name"] ?? "Student";
    }

    await FirebaseFirestore.instance
        .collection("reviews")
        .add({
      "uid": user.uid,
      "studentName": studentName,
      "courseName": widget.courseName,
      "rating": rating,
      "review": reviewController.text.trim(),
      "createdAt": Timestamp.now(),
    });

    if (!mounted) return;

    setState(() {
      isLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Review Submitted Successfully"),
      ),
    );

    Navigator.pop(context);
  }

  @override
  void dispose() {
    reviewController.dispose();
    super.dispose();
  }

  Widget buildStar(int index) {
    return IconButton(
      onPressed: () {
        setState(() {
          rating = index;
        });
      },
      icon: Icon(
        index <= rating
            ? Icons.star
            : Icons.star_border,
        color: Colors.orange,
        size: 35,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F7FB),

      appBar: AppBar(
        title: const Text("Write Review"),
        backgroundColor: const Color(0xff1565C0),
        foregroundColor: Colors.white,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            Text(
              widget.courseName,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 30),

            const Text(
              "Rate this Course",
              style: TextStyle(
                fontSize: 18,
              ),
            ),

            const SizedBox(height: 10),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                buildStar(1),
                buildStar(2),
                buildStar(3),
                buildStar(4),
                buildStar(5),
              ],
            ),

            const SizedBox(height: 30),

            TextField(
              controller: reviewController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: "Write your review...",
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      const Color(0xff1565C0),
                ),
                onPressed:
                    isLoading ? null : submitReview,
                child: isLoading
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                      )
                    : const Text(
                        "Submit Review",
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