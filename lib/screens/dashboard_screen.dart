import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xffF5F7FB),

      appBar: AppBar(
        backgroundColor: const Color(0xff1565C0),
        foregroundColor: Colors.white,
        title: const Text("Dashboard"),
        centerTitle: true,
      ),

      body: FutureBuilder(
        future: Future.wait([
          FirebaseFirestore.instance
              .collection("wishlist")
              .where("uid", isEqualTo: user!.uid)
              .get(),

          FirebaseFirestore.instance
              .collection("enrollments")
              .where("uid", isEqualTo: user.uid)
              .get(),
        ]),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final wishlist =
              (snapshot.data![0] as QuerySnapshot).docs;

          final enrollments =
              (snapshot.data![1] as QuerySnapshot).docs;

          int certificates = 0;
          double totalProgress = 0;

          for (var doc in enrollments) {
            final data = doc.data() as Map<String, dynamic>;

            int progress = data["progress"] ?? 0;

            totalProgress += progress;

            if (progress == 100) {
              certificates++;
            }
          }

          double avgProgress = 0;

          if (enrollments.isNotEmpty) {
            avgProgress =
                totalProgress / enrollments.length;
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [

                const CircleAvatar(
                  radius: 45,
                  backgroundColor: Color(0xff1565C0),
                  child: Icon(
                    Icons.person,
                    size: 50,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 15),

                Text(
                  user.email ?? "",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 30),

                Row(
                  children: [

                    Expanded(
                      child: dashboardCard(
                        "Wishlist",
                        wishlist.length.toString(),
                        Icons.favorite,
                        Colors.red,
                      ),
                    ),

                    const SizedBox(width: 15),

                    Expanded(
                      child: dashboardCard(
                        "Courses",
                        enrollments.length.toString(),
                        Icons.school,
                        Colors.blue,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 15),

                Row(
                  children: [

                    Expanded(
                      child: dashboardCard(
                        "Certificates",
                        certificates.toString(),
                        Icons.workspace_premium,
                        Colors.orange,
                      ),
                    ),

                    const SizedBox(width: 15),

                    Expanded(
                      child: dashboardCard(
                        "Progress",
                        "${avgProgress.toStringAsFixed(0)}%",
                        Icons.show_chart,
                        Colors.green,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 35),

                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Learning Progress",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                LinearProgressIndicator(
                  value: avgProgress / 100,
                  minHeight: 12,
                  borderRadius:
                      BorderRadius.circular(15),
                  backgroundColor:
                      Colors.grey.shade300,
                  color: Colors.green,
                ),

                const SizedBox(height: 15),

                Text(
                  "${avgProgress.toStringAsFixed(0)}% Completed",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 35),

                Card(
                  elevation: 5,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: const [

                        Icon(
                          Icons.lightbulb,
                          size: 60,
                          color: Colors.amber,
                        ),

                        SizedBox(height: 15),

                        Text(
                          "Keep Learning Every Day 🚀",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        SizedBox(height: 10),

                        Text(
                          "Consistency beats talent. Complete your courses and unlock more certificates.",
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget dashboardCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 5,
      child: SizedBox(
        height: 140,
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [

            Icon(
              icon,
              color: color,
              size: 40,
            ),

            const SizedBox(height: 10),

            Text(
              value,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 5),

            Text(title),
          ],
        ),
      ),
    );
  }
}