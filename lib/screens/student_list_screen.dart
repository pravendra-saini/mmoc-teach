import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StudentListScreen extends StatelessWidget {
  const StudentListScreen({super.key});

  String _getInitials(String name) {
    final trimmedName = name.trim();

    if (trimmedName.isEmpty) {
      return "S";
    }

    final parts = trimmedName.split(RegExp(r'\s+'));

    if (parts.length >= 2) {
      return "${parts.first[0]}${parts.last[0]}".toUpperCase();
    }

    return trimmedName.substring(0, 1).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final studentsStream = FirebaseFirestore.instance
        .collection("users")
        .where("role", isEqualTo: "student")
        .snapshots();

    return Scaffold(
      backgroundColor: const Color(0xffF5F7FB),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xff1565C0),
        foregroundColor: Colors.white,
        title: const Text(
          "Students",
          style: TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: studentsStream,
        builder: (context, snapshot) {
          // ----------------------------------------------------------
          // LOADING
          // ----------------------------------------------------------
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xff1565C0),
              ),
            );
          }

          // ----------------------------------------------------------
          // ERROR
          // ----------------------------------------------------------
          if (snapshot.hasError) {
            return _ErrorState(
              message: "Unable to load students.",
            );
          }

          final students = snapshot.data?.docs ?? [];

          // ----------------------------------------------------------
          // EMPTY
          // ----------------------------------------------------------
          if (students.isEmpty) {
            return const _EmptyState();
          }

          return RefreshIndicator(
            color: const Color(0xff1565C0),
            onRefresh: () async {
              await Future.delayed(
                const Duration(milliseconds: 500),
              );
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                16,
                18,
                16,
                30,
              ),
              children: [
                // ----------------------------------------------------
                // HEADER SUMMARY
                // ----------------------------------------------------
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xff1565C0),
                        Color(0xff1976D2),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xff1565C0)
                            .withValues(alpha: 0.20),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        height: 56,
                        width: 56,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(
                            alpha: 0.16,
                          ),
                          borderRadius: BorderRadius.circular(17),
                        ),
                        child: const Icon(
                          Icons.groups_rounded,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Registered Students",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "${students.length}",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 30,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(
                            alpha: 0.12,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.school_rounded,
                              color: Colors.white,
                              size: 17,
                            ),
                            SizedBox(width: 6),
                            Text(
                              "Students",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ----------------------------------------------------
                // SECTION TITLE
                // ----------------------------------------------------
                const Text(
                  "All Students",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xff1F2937),
                  ),
                ),

                const SizedBox(height: 5),

                const Text(
                  "View registered student information",
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xff6B7280),
                  ),
                ),

                const SizedBox(height: 14),

                // ----------------------------------------------------
                // STUDENT CARDS
                // ----------------------------------------------------
                ...students.map(
                      (student) {
                    final data = student.data();

                    final String name =
                    data["name"]?.toString().trim().isNotEmpty ==
                        true
                        ? data["name"].toString().trim()
                        : "No Name";

                    final String email =
                        data["email"]?.toString().trim() ?? "";

                    final String mobile =
                        data["mobile"]?.toString().trim() ?? "";

                    final String photoUrl =
                        data["photoUrl"]?.toString().trim() ?? "";

                    return Container(
                      margin: const EdgeInsets.only(
                        bottom: 14,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(
                              alpha: 0.05,
                            ),
                            blurRadius: 12,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            // ----------------------------------------
                            // PROFILE
                            // ----------------------------------------
                            Container(
                              height: 58,
                              width: 58,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xffE3F2FD),
                                border: Border.all(
                                  color: const Color(0xffBBDEFB),
                                  width: 1.5,
                                ),
                              ),
                              child: ClipOval(
                                child: photoUrl.isNotEmpty
                                    ? Image.network(
                                  photoUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder:
                                      (
                                      context,
                                      error,
                                      stackTrace,
                                      ) {
                                    return Center(
                                      child: Text(
                                        _getInitials(name),
                                        style:
                                        const TextStyle(
                                          color: Color(
                                            0xff1565C0,
                                          ),
                                          fontSize: 19,
                                          fontWeight:
                                          FontWeight.w800,
                                        ),
                                      ),
                                    );
                                  },
                                )
                                    : Center(
                                  child: Text(
                                    _getInitials(name),
                                    style:
                                    const TextStyle(
                                      color:
                                      Color(0xff1565C0),
                                      fontSize: 19,
                                      fontWeight:
                                      FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(width: 15),

                            // ----------------------------------------
                            // STUDENT INFORMATION
                            // ----------------------------------------
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    name,
                                    maxLines: 1,
                                    overflow:
                                    TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xff1F2937),
                                    ),
                                  ),

                                  const SizedBox(height: 9),

                                  if (email.isNotEmpty)
                                    Row(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        const Icon(
                                          Icons.email_outlined,
                                          size: 16,
                                          color:
                                          Color(0xff6B7280),
                                        ),
                                        const SizedBox(width: 7),
                                        Expanded(
                                          child: Text(
                                            email,
                                            maxLines: 2,
                                            overflow:
                                            TextOverflow.ellipsis,
                                            style:
                                            const TextStyle(
                                              fontSize: 12,
                                              color:
                                              Color(0xff6B7280),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),

                                  if (mobile.isNotEmpty) ...[
                                    const SizedBox(height: 7),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.phone_outlined,
                                          size: 16,
                                          color:
                                          Color(0xff6B7280),
                                        ),
                                        const SizedBox(width: 7),
                                        Expanded(
                                          child: Text(
                                            mobile,
                                            maxLines: 1,
                                            overflow:
                                            TextOverflow.ellipsis,
                                            style:
                                            const TextStyle(
                                              fontSize: 12,
                                              color:
                                              Color(0xff6B7280),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),

                            const SizedBox(width: 8),

                            // ----------------------------------------
                            // STUDENT BADGE
                            // ----------------------------------------
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 9,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xffE8F5E9),
                                borderRadius:
                                BorderRadius.circular(10),
                              ),
                              child: const Text(
                                "Student",
                                style: TextStyle(
                                  color: Color(0xff2E7D32),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ==================================================================
// EMPTY STATE
// ==================================================================

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 90,
              width: 90,
              decoration: BoxDecoration(
                color: const Color(0xffE3F2FD),
                borderRadius: BorderRadius.circular(28),
              ),
              child: const Icon(
                Icons.people_outline_rounded,
                size: 46,
                color: Color(0xff1565C0),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "No Students Found",
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
                color: Color(0xff1F2937),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Registered students will appear here.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Color(0xff6B7280),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================================================================
// ERROR STATE
// ==================================================================

class _ErrorState extends StatelessWidget {
  final String message;

  const _ErrorState({
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 80,
              width: 80,
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(25),
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 42,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xff1F2937),
              ),
            ),
            const SizedBox(height: 7),
            const Text(
              "Please try again later.",
              style: TextStyle(
                fontSize: 12,
                color: Color(0xff6B7280),
              ),
            ),
          ],
        ),
      ),
    );
  }
}