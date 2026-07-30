import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StudentListScreen extends StatelessWidget {
  const StudentListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F7FB),

      appBar: AppBar(
        title: const Text("Students"),
        backgroundColor: const Color(0xff1565C0),
        foregroundColor: Colors.white,
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("users")
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!snapshot.hasData ||
              snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "No Students Found",
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          final students = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(15),
            itemCount: students.length,
            itemBuilder: (context, index) {
              final data = students[index].data()
                  as Map<String, dynamic>;

              return Card(
                elevation: 5,
                margin:
                    const EdgeInsets.only(bottom: 15),
                child: ListTile(
                  leading: const CircleAvatar(
                    radius: 28,
                    backgroundColor: Color(0xff1565C0),
                    child: Icon(
                      Icons.person,
                      color: Colors.white,
                    ),
                  ),

                  title: Text(
                    data["name"] ?? "No Name",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  subtitle: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 5),

                      Text(
                        data["email"] ?? "",
                      ),

                      Text(
                        data["mobile"] ?? "",
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}