import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'add_course_screen.dart';
import 'add_video_screen.dart';

class ManageCoursesScreen extends StatelessWidget {
  const ManageCoursesScreen({super.key});

  // ============================================================
  // COLORS
  // ============================================================

  static const Color bg = Color(0xff050816);
  static const Color panel = Color(0xff0B1020);
  static const Color panel2 = Color(0xff10172A);

  static const Color neonBlue = Color(0xff00B7FF);
  static const Color neonPurple = Color(0xff8B5CF6);
  static const Color neonCyan = Color(0xff00F5D4);
  static const Color neonGreen = Color(0xff39FF88);
  static const Color neonOrange = Color(0xffFF8A00);

  static const Color textWhite = Color(0xffF8FAFF);
  static const Color textMuted = Color(0xff8D98B2);
  static const Color border = Color(0xff1C2742);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,

      appBar: AppBar(
        backgroundColor: bg,
        foregroundColor: textWhite,
        elevation: 0,

        title: const Row(
          children: [
            Icon(
              Icons.school_rounded,
              color: neonCyan,
            ),
            SizedBox(width: 10),
            Text(
              'MANAGE COURSES',
              style: TextStyle(
                color: textWhite,
                fontSize: 17,
                fontWeight: FontWeight.w900,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),

      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: const LinearGradient(
            colors: [
              neonBlue,
              neonPurple,
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: neonBlue.withValues(
                alpha: 0.30,
              ),
              blurRadius: 22,
            ),
          ],
        ),

        child: FloatingActionButton(
          backgroundColor: Colors.transparent,
          elevation: 0,

          tooltip: 'Add Course',

          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                const AddCourseScreen(),
              ),
            );
          },

          child: const Icon(
            Icons.add_rounded,
            color: Colors.white,
            size: 30,
          ),
        ),
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('courses')
            .orderBy(
          'createdAt',
          descending: true,
        )
            .snapshots(),

        builder: (
            context,
            snapshot,
            ) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: neonCyan,
              ),
            );
          }

          if (snapshot.hasError) {
            return _buildErrorState(
              snapshot.error.toString(),
            );
          }

          if (!snapshot.hasData ||
              snapshot.data!.docs.isEmpty) {
            return _buildEmptyState(
              context,
            );
          }

          final courses =
              snapshot.data!.docs;

          return ListView.builder(
            physics:
            const BouncingScrollPhysics(),

            padding:
            const EdgeInsets.fromLTRB(
              16,
              10,
              16,
              100,
            ),

            itemCount:
            courses.length,

            itemBuilder:
                (
                context,
                index,
                ) {
              final doc =
              courses[index];

              final data =
              doc.data()
              as Map<String, dynamic>;

              return _buildCourseCard(
                context,
                doc,
                data,
              );
            },
          );
        },
      ),
    );
  }

  // ============================================================
  // COURSE CARD
  // ============================================================

  Widget _buildCourseCard(
      BuildContext context,
      QueryDocumentSnapshot doc,
      Map<String, dynamic> data,
      ) {
    final title =
    data['title']
        ?.toString()
        .trim()
        .isNotEmpty ==
        true
        ? data['title']
        .toString()
        .trim()
        : 'Untitled Course';

    final teacher =
        data['teacher']
            ?.toString()
            .trim() ??
            '';

    final duration =
        data['duration']
            ?.toString()
            .trim() ??
            '';

    final rating =
        data['rating']
            ?.toString() ??
            '';

    final notesAsset =
        data['notesAsset']
            ?.toString()
            .trim() ??
            '';

    final initials =
    _getInitials(title);

    return Container(
      margin:
      const EdgeInsets.only(
        bottom: 16,
      ),

      decoration:
      BoxDecoration(
        color: panel,

        borderRadius:
        BorderRadius.circular(
          22,
        ),

        border:
        Border.all(
          color:
          neonBlue.withValues(
            alpha: 0.20,
          ),
        ),

        boxShadow: [
          BoxShadow(
            color:
            neonBlue.withValues(
              alpha: 0.06,
            ),
            blurRadius: 24,
          ),
        ],
      ),

      child: Padding(
        padding:
        const EdgeInsets.all(
          15,
        ),

        child: Column(
          children: [
            Row(
              crossAxisAlignment:
              CrossAxisAlignment
                  .start,

              children: [
                Container(
                  width: 62,
                  height: 62,

                  decoration:
                  BoxDecoration(
                    borderRadius:
                    BorderRadius
                        .circular(
                      18,
                    ),

                    gradient:
                    const LinearGradient(
                      begin:
                      Alignment
                          .topLeft,
                      end:
                      Alignment
                          .bottomRight,
                      colors: [
                        neonBlue,
                        neonPurple,
                      ],
                    ),

                    boxShadow: [
                      BoxShadow(
                        color:
                        neonBlue
                            .withValues(
                          alpha: 0.22,
                        ),
                        blurRadius: 18,
                      ),
                    ],
                  ),

                  child: Center(
                    child: Text(
                      initials,
                      style:
                      const TextStyle(
                        color:
                        Colors.white,
                        fontSize: 19,
                        fontWeight:
                        FontWeight
                            .w900,
                      ),
                    ),
                  ),
                ),

                const SizedBox(
                  width: 13,
                ),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment
                        .start,

                    children: [
                      Text(
                        title,
                        maxLines: 2,
                        overflow:
                        TextOverflow
                            .ellipsis,

                        style:
                        const TextStyle(
                          color:
                          textWhite,
                          fontSize: 16,
                          fontWeight:
                          FontWeight
                              .w900,
                        ),
                      ),

                      const SizedBox(
                        height: 7,
                      ),

                      if (teacher.isNotEmpty)
                        _buildInfoRow(
                          Icons
                              .person_outline_rounded,
                          teacher,
                          neonCyan,
                        ),

                      if (duration.isNotEmpty)
                        Padding(
                          padding:
                          const EdgeInsets
                              .only(
                            top: 4,
                          ),
                          child:
                          _buildInfoRow(
                            Icons
                                .schedule_outlined,
                            duration,
                            neonPurple,
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(
                  width: 8,
                ),

                Container(
                  padding:
                  const EdgeInsets
                      .symmetric(
                    horizontal: 8,
                    vertical: 5,
                  ),

                  decoration:
                  BoxDecoration(
                    color:
                    neonOrange
                        .withValues(
                      alpha: 0.10,
                    ),

                    borderRadius:
                    BorderRadius
                        .circular(
                      8,
                    ),

                    border:
                    Border.all(
                      color:
                      neonOrange
                          .withValues(
                        alpha: 0.25,
                      ),
                    ),
                  ),

                  child: Row(
                    mainAxisSize:
                    MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons
                            .star_rounded,
                        color:
                        neonOrange,
                        size: 14,
                      ),
                      const SizedBox(
                        width: 3,
                      ),
                      Text(
                        rating.isEmpty
                            ? '—'
                            : rating,
                        style:
                        const TextStyle(
                          color:
                          neonOrange,
                          fontSize: 11,
                          fontWeight:
                          FontWeight
                              .w900,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(
              height: 14,
            ),

            Container(
              height: 1,
              color:
              border.withValues(
                alpha: 0.7,
              ),
            ),

            const SizedBox(
              height: 12,
            ),

            Row(
              children: [
                Expanded(
                  child:
                  _buildActionButton(
                    icon:
                    Icons
                        .edit_rounded,
                    label:
                    'EDIT',
                    color:
                    neonBlue,
                    onPressed:
                        () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) =>
                              AddCourseScreen(
                                docId:
                                doc.id,
                                course:
                                data,
                              ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(
                  width: 8,
                ),

                Expanded(
                  child:
                  _buildActionButton(
                    icon:
                    Icons
                        .video_library_rounded,
                    label:
                    'VIDEOS',
                    color:
                    neonGreen,
                    onPressed:
                        () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) =>
                              AddVideoScreen(
                                courseId:
                                doc.id,
                                courseName:
                                title,
                              ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(
                  width: 8,
                ),

                _buildDeleteButton(
                  context,
                  doc,
                  title,
                ),
              ],
            ),

            if (notesAsset.isNotEmpty)
              Padding(
                padding:
                const EdgeInsets
                    .only(
                  top: 10,
                ),

                child: Row(
                  children: [
                    const Icon(
                      Icons
                          .picture_as_pdf_rounded,
                      color:
                      neonGreen,
                      size: 15,
                    ),

                    const SizedBox(
                      width: 6,
                    ),

                    Expanded(
                      child: Text(
                        'Notes attached: ${notesAsset.split('/').last}',
                        maxLines: 1,
                        overflow:
                        TextOverflow
                            .ellipsis,

                        style:
                        const TextStyle(
                          color:
                          neonGreen,
                          fontSize: 9.5,
                          fontWeight:
                          FontWeight
                              .w700,
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

  // ============================================================
  // INFO ROW
  // ============================================================

  Widget _buildInfoRow(
      IconData icon,
      String text,
      Color color,
      ) {
    return Row(
      children: [
        Icon(
          icon,
          color: color,
          size: 14,
        ),

        const SizedBox(
          width: 5,
        ),

        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow:
            TextOverflow.ellipsis,

            style:
            const TextStyle(
              color: textMuted,
              fontSize: 10.5,
              fontWeight:
              FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // ACTION BUTTON
  // ============================================================

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      height: 42,

      child:
      OutlinedButton.icon(
        onPressed: onPressed,

        icon: Icon(
          icon,
          color: color,
          size: 17,
        ),

        label: Text(
          label,
          style:
          TextStyle(
            color: color,
            fontSize: 10,
            fontWeight:
            FontWeight.w900,
            letterSpacing:
            0.5,
          ),
        ),

        style:
        OutlinedButton.styleFrom(
          side:
          BorderSide(
            color:
            color.withValues(
              alpha: 0.35,
            ),
          ),

          backgroundColor:
          color.withValues(
            alpha: 0.05,
          ),

          shape:
          RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(
              12,
            ),
          ),

          padding:
          const EdgeInsets
              .symmetric(
            horizontal: 8,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // DELETE BUTTON
  // ============================================================

  Widget _buildDeleteButton(
      BuildContext context,
      QueryDocumentSnapshot doc,
      String title,
      ) {
    return SizedBox(
      width: 48,
      height: 42,

      child:
      OutlinedButton(
        onPressed:
            () async {
          final confirmed =
              await showDialog<bool>(
                context: context,

                builder:
                    (dialogContext) {
                  return AlertDialog(
                    backgroundColor:
                    panel2,

                    shape:
                    RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius
                          .circular(
                        18,
                      ),
                    ),

                    title:
                    const Text(
                      'Delete Course?',
                      style:
                      TextStyle(
                        color:
                        textWhite,
                        fontWeight:
                        FontWeight
                            .w900,
                      ),
                    ),

                    content:
                    Text(
                      'Delete "$title" permanently?',
                      style:
                      const TextStyle(
                        color:
                        textMuted,
                      ),
                    ),

                    actions: [
                      TextButton(
                        onPressed:
                            () {
                          Navigator.pop(
                            dialogContext,
                            false,
                          );
                        },

                        child:
                        const Text(
                          'CANCEL',
                          style:
                          TextStyle(
                            color:
                            textMuted,
                            fontWeight:
                            FontWeight
                                .w800,
                          ),
                        ),
                      ),

                      ElevatedButton(
                        style:
                        ElevatedButton
                            .styleFrom(
                          backgroundColor:
                          neonOrange,
                          foregroundColor:
                          Colors.white,
                        ),

                        onPressed:
                            () {
                          Navigator.pop(
                            dialogContext,
                            true,
                          );
                        },

                        child:
                        const Text(
                          'DELETE',
                          style:
                          TextStyle(
                            fontWeight:
                            FontWeight
                                .w900,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ) ??
                  false;

          if (!confirmed) return;

          try {
            await FirebaseFirestore
                .instance
                .collection(
              'courses',
            )
                .doc(
              doc.id,
            )
                .delete();

            if (!context.mounted) {
              return;
            }

            ScaffoldMessenger.of(
              context,
            ).showSnackBar(
              const SnackBar(
                content:
                Text(
                  'Course deleted successfully.',
                  style:
                  TextStyle(
                    fontWeight:
                    FontWeight
                        .w700,
                  ),
                ),

                backgroundColor:
                neonGreen,

                behavior:
                SnackBarBehavior
                    .floating,
              ),
            );
          } on FirebaseException catch (e) {
            if (!context.mounted) {
              return;
            }

            ScaffoldMessenger.of(
              context,
            ).showSnackBar(
              SnackBar(
                content:
                Text(
                  'Delete failed: ${e.message ?? e.code}',
                ),
                backgroundColor:
                neonOrange,
              ),
            );
          } catch (e) {
            if (!context.mounted) {
              return;
            }

            ScaffoldMessenger.of(
              context,
            ).showSnackBar(
              const SnackBar(
                content:
                Text(
                  'Unable to delete course.',
                ),
                backgroundColor:
                neonOrange,
              ),
            );
          }
        },

        style:
        OutlinedButton.styleFrom(
          side:
          BorderSide(
            color:
            neonOrange.withValues(
              alpha: 0.35,
            ),
          ),

          backgroundColor:
          neonOrange.withValues(
            alpha: 0.05,
          ),

          shape:
          RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(
              12,
            ),
          ),

          padding:
          EdgeInsets.zero,
        ),

        child:
        const Icon(
          Icons
              .delete_outline_rounded,
          color:
          neonOrange,
          size: 19,
        ),
      ),
    );
  }

  // ============================================================
  // INITIALS
  // ============================================================

  String _getInitials(
      String title,
      ) {
    final words =
    title.trim().split(
      RegExp(r'\s+'),
    );

    if (words.isEmpty) {
      return 'C';
    }

    if (words.length == 1) {
      final word =
          words.first;

      if (word.length >= 2) {
        return word
            .substring(0, 2)
            .toUpperCase();
      }

      return word.toUpperCase();
    }

    return words
        .take(2)
        .map(
          (word) =>
      word.isEmpty
          ? ''
          : word[0]
          .toUpperCase(),
    )
        .join();
  }

  // ============================================================
  // EMPTY STATE
  // ============================================================

  Widget _buildEmptyState(
      BuildContext context,
      ) {
    return Center(
      child: Padding(
        padding:
        const EdgeInsets.all(
          30,
        ),

        child: Column(
          mainAxisSize:
          MainAxisSize.min,

          children: [
            Container(
              width: 90,
              height: 90,

              decoration:
              BoxDecoration(
                shape:
                BoxShape.circle,

                color:
                neonBlue
                    .withValues(
                  alpha: 0.08,
                ),

                border:
                Border.all(
                  color:
                  neonBlue
                      .withValues(
                    alpha: 0.25,
                  ),
                ),
              ),

              child:
              const Icon(
                Icons
                    .school_outlined,
                color:
                neonBlue,
                size: 42,
              ),
            ),

            const SizedBox(
              height: 18,
            ),

            const Text(
              'NO COURSES FOUND',
              style:
              TextStyle(
                color:
                textWhite,
                fontSize: 18,
                fontWeight:
                FontWeight.w900,
                letterSpacing:
                1,
              ),
            ),

            const SizedBox(
              height: 8,
            ),

            const Text(
              'Create your first learning course.',
              textAlign:
              TextAlign.center,
              style:
              TextStyle(
                color:
                textMuted,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // ERROR STATE
  // ============================================================

  Widget _buildErrorState(
      String error,
      ) {
    return Center(
      child: Padding(
        padding:
        const EdgeInsets.all(
          25,
        ),

        child: Column(
          mainAxisSize:
          MainAxisSize.min,

          children: [
            const Icon(
              Icons
                  .error_outline_rounded,
              color:
              neonOrange,
              size: 50,
            ),

            const SizedBox(
              height: 14,
            ),

            const Text(
              'UNABLE TO LOAD COURSES',
              style:
              TextStyle(
                color:
                textWhite,
                fontSize: 16,
                fontWeight:
                FontWeight.w900,
              ),
            ),

            const SizedBox(
              height: 8,
            ),

            Text(
              error,
              textAlign:
              TextAlign.center,
              maxLines: 4,
              overflow:
              TextOverflow.ellipsis,
              style:
              const TextStyle(
                color:
                textMuted,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}