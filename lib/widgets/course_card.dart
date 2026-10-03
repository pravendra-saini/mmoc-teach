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

  // ==========================================
  // COURSE IMAGE
  // ==========================================

  String getCourseImage() {
    // Firestore me saved image ko priority
    if (course.image.isNotEmpty) {
      return course.image;
    }

    final title = course.title.toLowerCase();

    if (title.contains("flutter") ||
        title.contains("dart")) {
      return "assets/images/flutter.jpg";
    }

    if (title.contains("python")) {
      return "assets/images/python.jpg";
    }

    if (title.contains("java")) {
      return "assets/images/java.jpg";
    }

    if (title.contains("firebase")) {
      return "assets/images/firebase.jpg";
    }

    if (title.contains("web") ||
        title.contains("html") ||
        title.contains("css") ||
        title.contains("javascript") ||
        title.contains("frontend") ||
        title.contains("react")) {
      return "assets/images/web.jpg";
    }

    return "assets/images/default.jpg";
  }

  // ==========================================
  // OPEN COURSE
  // ==========================================

  void openCourse(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            CourseDetailsScreen(course: course),
      ),
    );
  }

  // ==========================================
  // BUILD
  // ==========================================

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => openCourse(context),

      child: Container(
        width: 240,
        margin: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 8,
        ),

        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),

          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(
                alpha: .08,
              ),
              blurRadius: 15,
              offset: const Offset(0, 7),
            ),
          ],
        ),

        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,

          children: [
            // ====================================
            // COURSE IMAGE
            // ====================================

            ClipRRect(
              borderRadius:
              const BorderRadius.vertical(
                top: Radius.circular(22),
              ),

              child: SizedBox(
                width: double.infinity,
                height: 135,

                child: Stack(
                  fit: StackFit.expand,

                  children: [
                    Image.asset(
                      getCourseImage(),

                      fit: BoxFit.cover,

                      alignment:
                      Alignment.center,

                      errorBuilder:
                          (context, error, stackTrace) {
                        return Image.asset(
                          "assets/images/default.jpg",
                          fit: BoxFit.cover,
                        );
                      },
                    ),

                    // Image dark gradient
                    Container(
                      decoration:
                      const BoxDecoration(
                        gradient: LinearGradient(
                          begin:
                          Alignment.bottomCenter,
                          end:
                          Alignment.topCenter,
                          colors: [
                            Colors.black54,
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),

                    // BESTSELLER
                    Positioned(
                      top: 10,
                      left: 10,

                      child: Container(
                        padding:
                        const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),

                        decoration: BoxDecoration(
                          color: color,
                          borderRadius:
                          BorderRadius.circular(30),
                        ),

                        child: const Text(
                          "BESTSELLER",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight:
                            FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ====================================
            // COURSE DETAILS
            // ====================================

            Padding(
              padding: const EdgeInsets.all(13),

              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,

                children: [
                  Text(
                    course.title,

                    maxLines: 2,

                    overflow:
                    TextOverflow.ellipsis,

                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    "By ${course.teacher}",

                    maxLines: 1,

                    overflow:
                    TextOverflow.ellipsis,

                    style: TextStyle(
                      color:
                      Colors.grey.shade600,
                      fontSize: 13,
                    ),
                  ),

                  const SizedBox(height: 9),

                  Row(
                    children: [
                      const Icon(
                        Icons.star,
                        color: Colors.amber,
                        size: 18,
                      ),

                      const SizedBox(width: 4),

                      Text(
                        course.rating
                            .toStringAsFixed(1),

                        style:
                        const TextStyle(
                          fontWeight:
                          FontWeight.bold,
                        ),
                      ),

                      const Spacer(),

                      const Icon(
                        Icons.schedule,
                        size: 16,
                        color: Colors.grey,
                      ),

                      const SizedBox(width: 4),

                      Flexible(
                        child: Text(
                          course.duration,

                          maxLines: 1,

                          overflow:
                          TextOverflow.ellipsis,

                          style:
                          const TextStyle(
                            fontSize: 12,
                            fontWeight:
                            FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 11),

                  // ==================================
                  // VIEW COURSE BUTTON
                  // ==================================

                  SizedBox(
                    width: double.infinity,
                    height: 38,

                    child: ElevatedButton(
                      onPressed: () =>
                          openCourse(context),

                      style:
                      ElevatedButton.styleFrom(
                        backgroundColor: color,
                        foregroundColor:
                        Colors.white,
                        elevation: 0,

                        shape:
                        RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(
                            11,
                          ),
                        ),
                      ),

                      child: const Text(
                        "View Course",

                        style: TextStyle(
                          fontWeight:
                          FontWeight.w600,
                        ),
                      ),
                    ),
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