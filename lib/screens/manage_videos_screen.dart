import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManageVideosScreen extends StatefulWidget {
  const ManageVideosScreen({super.key});

  @override
  State<ManageVideosScreen> createState() =>
      _ManageVideosScreenState();
}

class _ManageVideosScreenState
    extends State<ManageVideosScreen> {

  final titleController = TextEditingController();
  final urlController = TextEditingController();
  final orderController = TextEditingController();

  String? selectedCourseId;
  String? selectedCourseName;

  Future<void> addVideo() async {

    if (selectedCourseId == null ||
        titleController.text.isEmpty ||
        urlController.text.isEmpty ||
        orderController.text.isEmpty) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Fill all fields"),
        ),
      );
      return;
    }

    await FirebaseFirestore.instance
        .collection("videos")
        .add({

      "courseId": selectedCourseId,
      "courseName": selectedCourseName,

      "title": titleController.text.trim(),

      "youtubeUrl": urlController.text.trim(),

      "order":
          int.parse(orderController.text.trim()),

      "createdAt": Timestamp.now(),

    });

    titleController.clear();
    urlController.clear();
    orderController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Video Added Successfully"),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Manage Videos"),
        backgroundColor: const Color(0xff1565C0),
        foregroundColor: Colors.white,
      ),

      body: SingleChildScrollView(

        padding: const EdgeInsets.all(20),

        child: Column(

          children: [

            StreamBuilder<QuerySnapshot>(

              stream: FirebaseFirestore.instance
                  .collection("courses")
                  .snapshots(),

              builder: (context, snapshot) {

                if (!snapshot.hasData) {
                  return const CircularProgressIndicator();
                }

                final docs = snapshot.data!.docs;

                return DropdownButtonFormField<String>(

                  value: selectedCourseId,

                  decoration: const InputDecoration(
                    labelText: "Select Course",
                    border: OutlineInputBorder(),
                  ),

                  items: docs.map((doc) {

                    final data =
                        doc.data() as Map<String, dynamic>;

                    return DropdownMenuItem(

                      value: doc.id,

                      child: Text(data["title"]),

                      onTap: () {

                        selectedCourseName =
                            data["title"];

                      },

                    );

                  }).toList(),

                  onChanged: (value) {

                    setState(() {

                      selectedCourseId = value;

                    });

                  },

                );

              },

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

                labelText: "YouTube URL",

                border: OutlineInputBorder(),

              ),

            ),

            const SizedBox(height: 20),

            TextField(

              controller: orderController,

              keyboardType: TextInputType.number,

              decoration: const InputDecoration(

                labelText: "Video Number",

                border: OutlineInputBorder(),

              ),

            ),

            const SizedBox(height: 25),

            SizedBox(

              width: double.infinity,

              height: 55,

              child: ElevatedButton.icon(

                style: ElevatedButton.styleFrom(

                  backgroundColor:
                      const Color(0xff1565C0),

                ),

                onPressed: addVideo,

                icon: const Icon(
                  Icons.save,
                  color: Colors.white,
                ),

                label: const Text(

                  "Save Video",

                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),

                ),

              ),

            ),

            const SizedBox(height: 30),

                        StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("videos")
                  .orderBy("order")
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const CircularProgressIndicator();
                }

                final docs = snapshot.data!.docs;

                if (docs.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Text(
                        "No Videos Added Yet",
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data =
                        docs[index].data() as Map<String, dynamic>;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.red,
                          child: Text(
                            "${data["order"]}",
                            style: const TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),

                        title: Text(data["title"]),

                        subtitle: Text(data["courseName"]),

                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.edit,
                                color: Colors.blue,
                              ),
                              onPressed: () {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "Edit Feature Coming Next",
                                    ),
                                  ),
                                );
                              },
                            ),

                            IconButton(
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.red,
                              ),
                              onPressed: () async {
                                await FirebaseFirestore.instance
                                    .collection("videos")
                                    .doc(docs[index].id)
                                    .delete();

                                if (!mounted) return;

                                ScaffoldMessenger.of(context)
                                    .showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "Video Deleted",
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    titleController.dispose();
    urlController.dispose();
    orderController.dispose();
    super.dispose();
  }
}