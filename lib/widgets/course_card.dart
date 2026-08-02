import 'package:flutter/material.dart';
import '../models/course_model.dart';
import '../screens/course_videos_screen.dart';
import '../screens/course_details_screen.dart';

class CourseCard extends StatelessWidget {
  final CourseModel course;
  final Color color;

  const CourseCard({
    super.key,
    required this.course,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => CourseDetailsScreen(
        course: course,
      ),
    ),
  );
},
      child: Container(
        width: 260,
        margin: const EdgeInsets.only(right: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(18),
              ),
              child: Image.asset(
                course.image,
                height: 140,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    course.teacher,
                    style: const TextStyle(
                      color: Colors.grey,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Row(
                    children: [
                      const Icon(
                        Icons.star,
                        color: Colors.orange,
                        size: 18,
                      ),

                      const SizedBox(width: 5),

                      Text(
                        course.rating.toString(),
                      ),

                      const Spacer(),

                      const Icon(
                        Icons.schedule,
                        size: 18,
                      ),

                      const SizedBox(width: 5),

                      Text(
                        course.duration,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}