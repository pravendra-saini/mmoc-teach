import 'package:flutter/material.dart';
import '../models/course_model.dart';
import '../screens/course_details_screen.dart';

class CourseCard extends StatelessWidget {
  final CourseModel course;
  final Color color;

  const CourseCard({
    super.key,
    required this.course,
    this.color = const Color(0xff1565C0),
  });

  //==============================
  // AUTO IMAGE
  //==============================
  String getCourseImage() {
    final title = course.title.toLowerCase();

    if (title.contains("flutter")) {
      return "assets/images/flutter.jpg";
    }

    if (title.contains("java")) {
      return "assets/images/java.jpg";
    }

    if (title.contains("python")) {
      return "assets/images/python.jpg";
    }

    if (title.contains("firebase")) {
      return "assets/images/firebase.jpg";
    }

    if (title.contains("web")) {
      return "assets/images/web.jpg";
    }

    if (title.contains("html")) {
      return "assets/images/web.jpg";
    }

    if (title.contains("css")) {
      return "assets/images/web.jpg";
    }

    if (title.contains("javascript")) {
      return "assets/images/web.jpg";
    }

    if (title.contains("dart")) {
      return "assets/images/flutter.jpg";
    }

    return "assets/images/default.jpg";
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CourseDetailsScreen(course: course),
          ),
        );
      },
      child: Container(
        width: 240,
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(.18),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // IMAGE
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(22),
              ),
              child: Stack(
                children: [

                  Image.asset(
                    getCourseImage(),
                    width: double.infinity,
                    height: 150,
                    fit: BoxFit.cover,
                  ),

                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Text(
                        "BESTSELLER",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Text(
                      course.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      "By ${course.teacher}",
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),

                    const Spacer(),

                    Row(
                      children: [

                        const Icon(
                          Icons.star,
                          color: Colors.amber,
                          size: 20,
                        ),

                        const SizedBox(width: 5),

                        Text(
                          course.rating.toString(),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const Spacer(),

                        const Icon(
                          Icons.schedule,
                          size: 18,
                          color: Colors.grey,
                        ),

                        const SizedBox(width: 5),

                        Text(
                          course.duration,
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 15),

                    SizedBox(
                      width: double.infinity,
                      height: 42,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: color,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  CourseDetailsScreen(course: course),
                            ),
                          );
                        },
                        child: const Text("View Course"),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}