import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  Future<int> getCount(String collection) async {
    final snapshot =
        await FirebaseFirestore.instance.collection(collection).get();
    return snapshot.docs.length;
  }

  Widget analyticsCard(
    String title,
    IconData icon,
    Color color,
    Future<int> future,
  ) {
    return FutureBuilder<int>(
      future: future,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Card(
            child: SizedBox(
              height: 120,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        }

        return Card(
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: color,
                  size: 45,
                ),

                const SizedBox(height: 10),

                Text(
                  snapshot.data.toString(),
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F7FB),

      appBar: AppBar(
        title: const Text("Analytics"),
        backgroundColor: const Color(0xff1565C0),
        foregroundColor: Colors.white,
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
          children: [

            analyticsCard(
              "Students",
              Icons.people,
              Colors.blue,
              getCount("users"),
            ),

            analyticsCard(
              "Courses",
              Icons.menu_book,
              Colors.green,
              getCount("courses"),
            ),

            analyticsCard(
              "Videos",
              Icons.video_library,
              Colors.red,
              getCount("videos"),
            ),

            analyticsCard(
              "Enrollments",
              Icons.school,
              Colors.orange,
              getCount("enrollments"),
            ),
          ],
        ),
      ),
    );
  }
}