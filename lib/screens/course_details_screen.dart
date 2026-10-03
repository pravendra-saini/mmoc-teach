import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import '../models/course_model.dart';
import 'certificate_screen.dart';
import 'course_videos_screen.dart';
import 'quiz_screen.dart';
import 'review_screen.dart';

class CourseDetailsScreen extends StatefulWidget {
  final CourseModel course;

  const CourseDetailsScreen({
    super.key,
    required this.course,
  });

  @override
  State<CourseDetailsScreen> createState() =>
      _CourseDetailsScreenState();
}

class _CourseDetailsScreenState extends State<CourseDetailsScreen>
    with SingleTickerProviderStateMixin {
  // ============================================================
  // CYBER-TECH NEON THEME
  // ============================================================

  static const Color bg = Color(0xFF050816);
  static const Color panel = Color(0xFF0A1020);
  static const Color panel2 = Color(0xFF0E172B);

  static const Color blue = Color(0xFF00B7FF);
  static const Color purple = Color(0xFF8B5CF6);
  static const Color cyan = Color(0xFF00F5D4);
  static const Color green = Color(0xFF39FF88);
  static const Color orange = Color(0xFFFF8A00);
  static const Color pink = Color(0xFFFF3CAC);

  static const Color white = Color(0xFFF4F8FF);
  static const Color muted = Color(0xFF8B9BB8);
  static const Color border = Color(0xFF172B4D);

  // ============================================================
  // FIREBASE
  // ============================================================

  final FirebaseAuth auth = FirebaseAuth.instance;

  final FirebaseFirestore firestore =
      FirebaseFirestore.instance;

  // ============================================================
  // STATE
  // ============================================================

  bool isWishlistLoading = false;
  bool isEnrollLoading = false;

  bool? isEnrolled;

  int selectedTab = 0;

  late AnimationController glowController;

  // ============================================================
  // USER
  // ============================================================

  User? get currentUser => auth.currentUser;

  CourseModel get course => widget.course;

  // ============================================================
  // IDS
  // ============================================================

  String get enrollmentId {
    final uid = currentUser?.uid ?? '';
    return '${uid}_${course.title}';
  }

  String get wishlistId {
    final uid = currentUser?.uid ?? '';
    return '${uid}_${course.title}';
  }

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _checkEnrollment();
  }

  @override
  void dispose() {
    glowController.dispose();
    super.dispose();
  }

  // ============================================================
  // COURSE NOTES PATH
  // ============================================================

  String? get courseNotesAsset {
    final key = _normalizeCourseName(course.title);

    const notes = <String, String>{
      'clanguage':
      'assets/notes/C_Language_Complete_Notes.pdf',

      'c':
      'assets/notes/C_Language_Complete_Notes.pdf',

      'cpp':
      'assets/notes/CPP_Complete_Notes.pdf',

      'cplusplus':
      'assets/notes/CPP_Complete_Notes.pdf',

      'java':
      'assets/notes/Java_Complete_Notes.pdf',

      'python':
      'assets/notes/Python_Complete_Notes.pdf',

      'javascript':
      'assets/notes/JavaScript_Complete_Notes.pdf',

      'js':
      'assets/notes/JavaScript_Complete_Notes.pdf',

      'sql':
      'assets/notes/SQL_Complete_Notes.pdf',

      'dbms':
      'assets/notes/DBMS_Complete_Notes.pdf',

      'computernetworks':
      'assets/notes/Computer_Networks_Complete_Notes.pdf',

      'operatingsystem':
      'assets/notes/Operating_System_Complete_Notes.pdf',

      'dsa':
      'assets/notes/DSA_Complete_Notes.pdf',

      'datastructuresandalgorithms':
      'assets/notes/DSA_Complete_Notes.pdf',

      'flutter':
      'assets/notes/Flutter_Complete_Notes.pdf',

      'kotlin':
      'assets/notes/Kotlin_Complete_Notes.pdf',

      'nodejs':
      'assets/notes/NodeJS_Complete_Notes.pdf',

      'node':
      'assets/notes/NodeJS_Complete_Notes.pdf',

      'php':
      'assets/notes/PHP_Complete_Notes.pdf',

      'go':
      'assets/notes/Go_Complete_Notes.pdf',

      'golang':
      'assets/notes/Go_Complete_Notes.pdf',

      'rust':
      'assets/notes/Rust_Complete_Notes.pdf',

      'rlanguage':
      'assets/notes/R_Language_Complete_Notes.pdf',

      'r':
      'assets/notes/R_Language_Complete_Notes.pdf',

      'matlab':
      'assets/notes/MATLAB_Complete_Notes.pdf',

      'swift':
      'assets/notes/Swift_Complete_Notes.pdf',

      'cybersecurity':
      'assets/notes/Cyber_Security_Complete_Notes.pdf',

      'ethicalhacking':
      'assets/notes/Ethical_Hacking_Complete_Notes.pdf',
    };

    return notes[key];
  }

  String _normalizeCourseName(String value) {
    return value
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '');
  }

  // ============================================================
  // CHECK ENROLLMENT
  // ============================================================

  Future<void> _checkEnrollment() async {
    final user = currentUser;

    if (user == null) {
      if (mounted) {
        setState(() {
          isEnrolled = false;
        });
      }
      return;
    }

    try {
      final document = await firestore
          .collection('enrollments')
          .doc(enrollmentId)
          .get();

      if (mounted) {
        setState(() {
          isEnrolled = document.exists;
        });
      }
    } catch (e) {
      debugPrint('CHECK ENROLLMENT ERROR: $e');
    }
  }

  // ============================================================
  // OPEN NOTES
  // ============================================================

  void openNotes() {
    final assetPath = courseNotesAsset;

    if (assetPath == null) {
      _showMessage(
        'Notes are not available for this course yet.',
        isError: true,
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CourseNotesViewerScreen(
          courseName: course.title,
          assetPath: assetPath,
        ),
      ),
    );
  }

  // ============================================================
  // WISHLIST
  // ============================================================

  Future<void> addToWishlist() async {
    final user = currentUser;

    if (user == null) {
      _showMessage(
        'Please login first.',
        isError: true,
      );
      return;
    }

    if (isWishlistLoading) return;

    setState(() {
      isWishlistLoading = true;
    });

    try {
      final ref = firestore
          .collection('wishlist')
          .doc(wishlistId);

      final existing = await ref.get();

      if (existing.exists) {
        _showMessage(
          'This course is already in your Wishlist ❤️',
        );
        return;
      }

      await ref.set({
        'uid': user.uid,
        'email': user.email,
        'courseName': course.title,
        'teacher': course.teacher,
        'duration': course.duration,
        'rating': course.rating,
        'addedAt': Timestamp.now(),
      });

      _showMessage(
        'Course added to Wishlist ❤️',
      );
    } on FirebaseException catch (e) {
      debugPrint(
        'WISHLIST FIREBASE ERROR: '
            '${e.code} - ${e.message}',
      );

      _showMessage(
        'Unable to add this course to Wishlist.',
        isError: true,
      );
    } catch (e) {
      debugPrint(
        'COURSE DETAILS WISHLIST ERROR: $e',
      );

      _showMessage(
        'Unable to add this course to Wishlist.',
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          isWishlistLoading = false;
        });
      }
    }
  }

  // ============================================================
  // ENROLL
  // ============================================================

  Future<void> enrollCourse() async {
    final user = currentUser;

    if (user == null) {
      _showMessage(
        'Please login first.',
        isError: true,
      );
      return;
    }

    if (isEnrollLoading) return;

    setState(() {
      isEnrollLoading = true;
    });

    try {
      final ref = firestore
          .collection('enrollments')
          .doc(enrollmentId);

      final existing = await ref.get();

      if (existing.exists) {
        if (mounted) {
          setState(() {
            isEnrolled = true;
          });
        }

        _showMessage(
          'You are already enrolled in this course 📚',
        );
        return;
      }

      await ref.set({
        'uid': user.uid,
        'email': user.email,
        'courseName': course.title,
        'teacher': course.teacher,
        'duration': course.duration,
        'rating': course.rating,
        'progress': 0,
        'enrolledAt': Timestamp.now(),
      });

      if (mounted) {
        setState(() {
          isEnrolled = true;
        });
      }

      _showMessage(
        'Successfully enrolled 🎉',
      );
    } on FirebaseException catch (e) {
      debugPrint(
        'ENROLL FIREBASE ERROR: '
            '${e.code} - ${e.message}',
      );

      _showMessage(
        'Unable to enroll in this course.',
        isError: true,
      );
    } catch (e) {
      debugPrint(
        'COURSE DETAILS ENROLL ERROR: $e',
      );

      _showMessage(
        'Unable to enroll in this course.',
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          isEnrollLoading = false;
        });
      }
    }
  }

  // ============================================================
  // NAVIGATION
  // ============================================================

  void openVideos() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CourseVideosScreen(
          courseName:
          course.title.trim().toLowerCase(),
        ),
      ),
    );
  }

  void openQuiz() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QuizScreen(
          courseName:
          course.title.trim().toLowerCase(),
        ),
      ),
    );
  }

  void openReview() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReviewScreen(
          courseName: course.title,
        ),
      ),
    );
  }

  Future<void> openCertificate() async {
    final user = currentUser;

    if (user == null) {
      _showMessage('Please login first.', isError: true);
      return;
    }

    try {
      final enrollSnap =
      await firestore.collection('enrollments').doc(enrollmentId).get();

      if (!enrollSnap.exists) {
        _showMessage('Please enroll in this course first.', isError: true);
        return;
      }

      final data = enrollSnap.data() ?? {};

      final total = (data['totalLessons'] as num?)?.toInt() ?? 0;
      final done = (data['completedLessons'] as List?)?.length ?? 0;

      final videosDone = total > 0 && done >= total;
      final notesDone = data['notesCompleted'] == true;

      // Quiz: course key same as QuizScreen
      final quizKey = course.title
          .trim()
          .toLowerCase()
          .replaceAll('+', 'plus')
          .replaceAll(RegExp(r'[^a-z0-9]'), '');

      final quizSnap = await firestore
          .collection('quiz_results')
          .where('uid', isEqualTo: user.uid)
          .where('courseKey', isEqualTo: quizKey)
          .get();

      const passMarks = 60;

      final quizDone = quizSnap.docs.any((doc) {
        final p = doc.data()['percentage'];
        return p is num && p >= passMarks;
      });

      if (!mounted) return;

      if (videosDone && notesDone && quizDone) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CertificateScreen(
              courseName: course.title,
              studentName:
              user.displayName ?? user.email ?? 'Student',
            ),
          ),
        );
        return;
      }

      showDialog<void>(
        context: context,
        builder: (dialogContext) {
          Widget row(bool ok, String text) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                children: [
                  Icon(
                    ok ? Icons.check_circle_rounded : Icons.cancel_rounded,
                    color: ok ? green : orange,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      text,
                      style: const TextStyle(color: white, fontSize: 13),
                    ),
                  ),
                ],
              ),
            );
          }

          return AlertDialog(
            backgroundColor: panel,
            title: const Text(
              'Certificate Locked 🔒',
              style: TextStyle(color: white, fontWeight: FontWeight.w900),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Certificate ke liye ye teeno complete karo:',
                  style: TextStyle(color: muted, fontSize: 12),
                ),
                const SizedBox(height: 12),
                row(videosDone, 'Videos: $done / $total lessons'),
                row(notesDone, 'Notes: poori PDF padho'),
                row(quizDone, 'Quiz: $passMarks% ya zyada score karo'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    } on FirebaseException catch (e) {
      debugPrint('CERTIFICATE CHECK ERROR: ${e.code}');
      _showMessage('Unable to check certificate status.', isError: true);
    } catch (e) {
      debugPrint('CERTIFICATE CHECK ERROR: $e');
      _showMessage('Unable to check certificate status.', isError: true);
    }
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(
      String message, {
        bool isError = false,
      }) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: isError
              ? const Color(0xFFD92D55)
              : const Color(0xFF0B8F70),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.fromLTRB(
            16,
            0,
            16,
            18,
          ),
          shape: RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(16),
          ),
          duration:
          const Duration(seconds: 2),
          content: Row(
            children: [
              Icon(
                isError
                    ? Icons.error_outline_rounded
                    : Icons
                    .check_circle_outline_rounded,
                color: Colors.white,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight:
                    FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            _buildCyberBackground(),

            CustomScrollView(
              physics:
              const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: _buildHero(),
                ),
                SliverToBoxAdapter(
                  child:
                  _buildCourseHeader(),
                ),
                SliverToBoxAdapter(
                  child: _buildTabs(),
                ),
                SliverToBoxAdapter(
                  child:
                  _buildSelectedTab(),
                ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: 150),
                ),
              ],
            ),

            _buildTopBar(),
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // HERO
  // ============================================================

  Widget _buildHero() {
    return SizedBox(
      height: 285,
      child: Stack(
        fit: StackFit.expand,
        children: [
          _buildCourseVisual(),

          Container(
            decoration:
            const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0x1500B7FF),
                  Color(0x18000000),
                  Color(0xE8050816),
                ],
                stops: [
                  0,
                  0.45,
                  1,
                ],
              ),
            ),
          ),

          Positioned(
            top: 35,
            left: -60,
            child: AnimatedBuilder(
              animation: glowController,
              builder:
                  (context, child) {
                final opacity =
                    0.08 +
                        glowController.value *
                            0.08;

                return Container(
                  width: 170,
                  height: 170,
                  decoration:
                  BoxDecoration(
                    shape:
                    BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color:
                        blue.withValues(
                          alpha: opacity,
                        ),
                        blurRadius: 90,
                        spreadRadius: 20,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          Positioned(
            right: -70,
            top: 70,
            child: Container(
              width: 190,
              height: 190,
              decoration:
              BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color:
                    purple.withValues(
                      alpha: 0.12,
                    ),
                    blurRadius: 90,
                    spreadRadius: 20,
                  ),
                ],
              ),
            ),
          ),

          Positioned(
            left: 20,
            right: 20,
            bottom: 22,
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                _neonBadge(
                  icon: Icons
                      .auto_awesome_rounded,
                  text:
                  'MMOC TECH COURSE',
                  color: cyan,
                ),
                const SizedBox(height: 11),
                Text(
                  course.title,
                  maxLines: 2,
                  overflow:
                  TextOverflow.ellipsis,
                  style:
                  const TextStyle(
                    color: white,
                    fontSize: 27,
                    height: 1.08,
                    fontWeight:
                    FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // COURSE VISUAL
  // ============================================================

  Widget _buildCourseVisual() {
    final title = course.title.trim();
    final initials =
    _getCourseInitials(title);

    return Container(
      decoration:
      const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF071A35),
            Color(0xFF101052),
            Color(0xFF240D4F),
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -55,
            top: -50,
            child: Container(
              width: 190,
              height: 190,
              decoration:
              BoxDecoration(
                shape: BoxShape.circle,
                color:
                purple.withValues(
                  alpha: 0.08,
                ),
              ),
            ),
          ),
          Positioned(
            left: -60,
            bottom: -75,
            child: Container(
              width: 210,
              height: 210,
              decoration:
              BoxDecoration(
                shape: BoxShape.circle,
                color:
                cyan.withValues(
                  alpha: 0.06,
                ),
              ),
            ),
          ),
          Positioned(
            right: 25,
            top: 90,
            child: Icon(
              Icons.code_rounded,
              size: 110,
              color:
              blue.withValues(
                alpha: 0.035,
              ),
            ),
          ),
          Center(
            child: Container(
              width: 105,
              height: 105,
              decoration:
              BoxDecoration(
                borderRadius:
                BorderRadius.circular(
                  28,
                ),
                gradient:
                const LinearGradient(
                  begin:
                  Alignment.topLeft,
                  end:
                  Alignment.bottomRight,
                  colors: [
                    blue,
                    purple,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color:
                    blue.withValues(
                      alpha: 0.25,
                    ),
                    blurRadius: 35,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  initials,
                  textAlign:
                  TextAlign.center,
                  style:
                  const TextStyle(
                    color: Colors.white,
                    fontSize: 29,
                    fontWeight:
                    FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // COURSE INITIALS
  // ============================================================

  String _getCourseInitials(
      String title,
      ) {
    if (title.isEmpty) {
      return 'C';
    }

    final words =
    title.split(RegExp(r'\s+'));

    if (words.length == 1) {
      final word = words.first;

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
          (word) => word.isEmpty
          ? ''
          : word[0].toUpperCase(),
    )
        .join();
  }

  // ============================================================
  // COURSE HEADER
  // ============================================================

  Widget _buildCourseHeader() {
    return Padding(
      padding:
      const EdgeInsets.fromLTRB(
        18,
        0,
        18,
        18,
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _infoChip(
                  icon: Icons
                      .person_outline_rounded,
                  text: course.teacher
                      .trim()
                      .isEmpty
                      ? 'Instructor'
                      : course.teacher,
                  color: blue,
                ),
              ),
              const SizedBox(width: 8),
              _ratingChip(),
            ],
          ),
          const SizedBox(height: 14),
          _buildProgressPreview(),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _smallInfoCard(
                  icon: Icons
                      .schedule_rounded,
                  title: 'DURATION',
                  value: course.duration
                      .trim()
                      .isEmpty
                      ? 'Flexible'
                      : course.duration,
                  color: cyan,
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: _smallInfoCard(
                  icon: Icons
                      .workspace_premium_outlined,
                  title: 'CERTIFICATE',
                  value: 'Included',
                  color: green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TABS
  // ============================================================

  Widget _buildTabs() {
    const tabs = [
      'OVERVIEW',
      'CURRICULUM',
      'REVIEWS',
    ];

    return Padding(
      padding:
      const EdgeInsets.fromLTRB(
        18,
        0,
        18,
        18,
      ),
      child: Container(
        height: 52,
        padding:
        const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: panel,
          borderRadius:
          BorderRadius.circular(16),
          border: Border.all(
            color: border,
          ),
        ),
        child: Row(
          children:
          List.generate(
            tabs.length,
                (index) {
              final selected =
                  selectedTab == index;

              final color = index == 0
                  ? blue
                  : index == 1
                  ? purple
                  : cyan;

              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedTab =
                          index;
                    });
                  },
                  child:
                  AnimatedContainer(
                    duration:
                    const Duration(
                      milliseconds: 220,
                    ),
                    curve:
                    Curves.easeOut,
                    decoration:
                    BoxDecoration(
                      color: selected
                          ? color
                          .withValues(
                        alpha: 0.12,
                      )
                          : Colors
                          .transparent,
                      borderRadius:
                      BorderRadius
                          .circular(
                        12,
                      ),
                      border: selected
                          ? Border.all(
                        color: color
                            .withValues(
                          alpha:
                          0.28,
                        ),
                      )
                          : null,
                      boxShadow: selected
                          ? [
                        BoxShadow(
                          color: color
                              .withValues(
                            alpha:
                            0.08,
                          ),
                          blurRadius:
                          15,
                        ),
                      ]
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        tabs[index],
                        style:
                        TextStyle(
                          color: selected
                              ? color
                              : muted,
                          fontSize: 9.5,
                          fontWeight:
                          FontWeight
                              .w900,
                          letterSpacing:
                          0.3,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // ============================================================
  // SELECTED TAB
  // ============================================================

  Widget _buildSelectedTab() {
    switch (selectedTab) {
      case 1:
        return _buildCurriculumTab();

      case 2:
        return _buildReviewsTab();

      default:
        return _buildOverviewTab();
    }
  }

  // ============================================================
  // OVERVIEW TAB
  // ============================================================

  Widget _buildOverviewTab() {
    return Padding(
      padding:
      const EdgeInsets.symmetric(
        horizontal: 18,
      ),
      child: Column(
        children: [
          _buildNotesSection(),
          const SizedBox(height: 16),
          _buildLearningActions(),
          const SizedBox(height: 16),
          _buildCourseStats(),
          const SizedBox(height: 16),
          _buildEnrollmentInfo(),
        ],
      ),
    );
  }

  // ============================================================
  // CURRICULUM TAB
  // ============================================================

  Widget _buildCurriculumTab() {
    return Padding(
      padding:
      const EdgeInsets.symmetric(
        horizontal: 18,
      ),
      child: Column(
        children: [
          _section(
            title: 'LEARNING PATH',
            subtitle:
            'Everything you need to complete this course',
            child: Column(
              children: [
                _curriculumItem(
                  number: '01',
                  icon: Icons
                      .play_circle_outline_rounded,
                  title: 'Course Videos',
                  subtitle:
                  'Watch lessons and build your concepts.',
                  color: blue,
                  onTap: openVideos,
                ),
                _curriculumItem(
                  number: '02',
                  icon: Icons
                      .menu_book_rounded,
                  title: 'Course Notes',
                  subtitle:
                  'Read the study material for this course.',
                  color: pink,
                  onTap: openNotes,
                ),
                _curriculumItem(
                  number: '03',
                  icon: Icons
                      .quiz_outlined,
                  title: 'Practice Quiz',
                  subtitle:
                  'Check your understanding with quizzes.',
                  color: purple,
                  onTap: openQuiz,
                ),
                _curriculumItem(
                  number: '04',
                  icon: Icons
                      .rate_review_outlined,
                  title: 'Course Review',
                  subtitle:
                  'Share your experience with other students.',
                  color: cyan,
                  onTap: openReview,
                ),
                _curriculumItem(
                  number: '05',
                  icon: Icons
                      .workspace_premium_outlined,
                  title: 'Certificate',
                  subtitle:
                  'View your certificate after completion.',
                  color: green,
                  onTap: openCertificate,
                  isLast: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // REVIEWS TAB
  // ============================================================

  Widget _buildReviewsTab() {
    return Padding(
      padding:
      const EdgeInsets.symmetric(
        horizontal: 18,
      ),
      child: Column(
        children: [
          _section(
            title: 'STUDENT REVIEWS',
            subtitle:
            'See what learners are saying',
            child: _reviewsStream(),
          ),
          const SizedBox(height: 14),
          _actionCard(
            icon: Icons
                .rate_review_rounded,
            title: 'Write a Review',
            subtitle:
            'Share your experience with this course.',
            color: cyan,
            onTap: openReview,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // REVIEWS STREAM
  // ============================================================

  Widget _reviewsStream() {
    return StreamBuilder<
        QuerySnapshot<
            Map<String, dynamic>>>(
      stream: firestore
          .collection('reviews')
          .where(
        'courseName',
        isEqualTo: course.title,
      )
          .snapshots(),
      builder:
          (context, snapshot) {
        if (snapshot.connectionState ==
            ConnectionState.waiting) {
          return const Padding(
            padding:
            EdgeInsets.all(24),
            child: Center(
              child:
              CircularProgressIndicator(
                strokeWidth: 2,
                color: cyan,
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          return _emptyState(
            icon:
            Icons.cloud_off_rounded,
            title:
            'Unable to load reviews',
            subtitle:
            'Please try again later.',
            color: orange,
          );
        }

        final docs =
            snapshot.data?.docs ?? [];

        if (docs.isEmpty) {
          return _emptyState(
            icon:
            Icons
                .rate_review_outlined,
            title:
            'No reviews yet',
            subtitle:
            'Be the first student to review this course.',
            color: cyan,
          );
        }

        final visibleDocs =
        docs.take(5).toList();

        return Column(
          children:
          visibleDocs.map(
                (doc) {
              final data =
              doc.data();

              final name =
                  data['name']
                      ?.toString() ??
                      data['userName']
                          ?.toString() ??
                      data['email']
                          ?.toString() ??
                      'Student';

              final review =
                  data['review']
                      ?.toString() ??
                      data['comment']
                          ?.toString() ??
                      '';

              final rating =
              _parseRating(
                data['rating'],
              );

              return _reviewCard(
                name: name,
                review: review,
                rating: rating,
              );
            },
          ).toList(),
        );
      },
    );
  }

  // ============================================================
  // NEON BADGE
  // ============================================================

  Widget _neonBadge({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Container(
      padding:
      const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color:
        color.withValues(
          alpha: 0.08,
        ),
        borderRadius:
        BorderRadius.circular(10),
        border: Border.all(
          color:
          color.withValues(
            alpha: 0.28,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color:
            color.withValues(
              alpha: 0.08,
            ),
            blurRadius: 14,
          ),
        ],
      ),
      child: Row(
        mainAxisSize:
        MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: color,
            size: 13,
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 8.5,
              fontWeight:
              FontWeight.w900,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // INFO CHIP
  // ============================================================

  Widget _infoChip({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Container(
      height: 40,
      padding:
      const EdgeInsets.symmetric(
        horizontal: 11,
      ),
      decoration: BoxDecoration(
        color: panel,
        borderRadius:
        BorderRadius.circular(13),
        border: Border.all(
          color:
          color.withValues(
            alpha: 0.18,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: color,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              maxLines: 1,
              overflow:
              TextOverflow.ellipsis,
              style:
              const TextStyle(
                color: white,
                fontSize: 10,
                fontWeight:
                FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // RATING CHIP
  // ============================================================

  Widget _ratingChip() {
    return Container(
      height: 40,
      padding:
      const EdgeInsets.symmetric(
        horizontal: 11,
      ),
      decoration: BoxDecoration(
        color:
        orange.withValues(
          alpha: 0.07,
        ),
        borderRadius:
        BorderRadius.circular(13),
        border: Border.all(
          color:
          orange.withValues(
            alpha: 0.20,
          ),
        ),
      ),
      child: Row(
        mainAxisSize:
        MainAxisSize.min,
        children: [
          const Icon(
            Icons.star_rounded,
            color: orange,
            size: 17,
          ),
          const SizedBox(width: 5),
          Text(
            course.rating.toString(),
            style:
            const TextStyle(
              color: white,
              fontSize: 10.5,
              fontWeight:
              FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PROGRESS PREVIEW
  // ============================================================

  Widget _buildProgressPreview() {
    return StreamBuilder<
        DocumentSnapshot<
            Map<String, dynamic>>>(
      stream: currentUser == null
          ? null
          : firestore
          .collection('enrollments')
          .doc(enrollmentId)
          .snapshots(),
      builder:
          (context, snapshot) {
        int progress = 0;

        if (snapshot.hasData &&
            snapshot.data != null &&
            snapshot.data!.exists) {
          final data =
          snapshot.data!.data();

          progress = _parseProgress(
            data?['progress'],
          );
        }

        final enrolled =
            snapshot.hasData &&
                snapshot.data != null &&
                snapshot.data!.exists;

        return Container(
          padding:
          const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: panel,
            borderRadius:
            BorderRadius.circular(
              17,
            ),
            border: Border.all(
              color: enrolled
                  ? cyan.withValues(
                alpha: 0.20,
              )
                  : border,
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(
                    enrolled
                        ? Icons
                        .trending_up_rounded
                        : Icons
                        .school_outlined,
                    color: enrolled
                        ? cyan
                        : muted,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      enrolled
                          ? 'LEARNING PROGRESS'
                          : 'YOUR LEARNING PATH',
                      style:
                      const TextStyle(
                        color: white,
                        fontSize: 10,
                        fontWeight:
                        FontWeight.w900,
                        letterSpacing:
                        0.4,
                      ),
                    ),
                  ),
                  if (enrolled)
                    Text(
                      '$progress%',
                      style:
                      const TextStyle(
                        color: cyan,
                        fontSize: 11,
                        fontWeight:
                        FontWeight.w900,
                      ),
                    )
                  else
                    const Text(
                      'NOT ENROLLED',
                      style:
                      TextStyle(
                        color: muted,
                        fontSize: 8,
                        fontWeight:
                        FontWeight.w800,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius:
                BorderRadius.circular(
                  20,
                ),
                child:
                LinearProgressIndicator(
                  minHeight: 6,
                  value: enrolled
                      ? progress / 100
                      : 0,
                  backgroundColor:
                  const Color(
                    0xFF151F33,
                  ),
                  valueColor:
                  const AlwaysStoppedAnimation<
                      Color>(
                    cyan,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ============================================================
  // SMALL INFO CARD
  // ============================================================

  Widget _smallInfoCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding:
      const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: panel,
        borderRadius:
        BorderRadius.circular(15),
        border: Border.all(
          color: border,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration:
            BoxDecoration(
              color:
              color.withValues(
                alpha: 0.08,
              ),
              borderRadius:
              BorderRadius.circular(
                10,
              ),
              border: Border.all(
                color:
                color.withValues(
                  alpha: 0.20,
                ),
              ),
            ),
            child: Icon(
              icon,
              color: color,
              size: 17,
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style:
                  const TextStyle(
                    color: muted,
                    fontSize: 7.5,
                    fontWeight:
                    FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  maxLines: 1,
                  overflow:
                  TextOverflow.ellipsis,
                  style:
                  const TextStyle(
                    color: white,
                    fontSize: 10,
                    fontWeight:
                    FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // NOTES SECTION
  // ============================================================

  Widget _buildNotesSection() {
    final available =
        courseNotesAsset != null;

    return _section(
      title: 'COURSE NOTES',
      subtitle:
      'Study material for this course',
      child: _actionCard(
        icon:
        Icons.picture_as_pdf_rounded,
        title: available
            ? 'Open Course Notes'
            : 'Course Notes',
        subtitle: available
            ? 'Read the PDF study material inside the app.'
            : 'Notes are not available yet.',
        color: pink,
        trailing: Icon(
          available
              ? Icons
              .arrow_forward_ios_rounded
              : Icons.lock_outline_rounded,
          color:
          available ? pink : muted,
          size: 15,
        ),
        onTap: available
            ? openNotes
            : () {
          _showMessage(
            'Notes are not available for this course yet.',
            isError: true,
          );
        },
      ),
    );
  }

  // ============================================================
  // LEARNING ACTIONS
  // ============================================================

  Widget _buildLearningActions() {
    return _section(
      title: 'LEARNING HUB',
      subtitle:
      'Jump directly into your course',
      child: Column(
        children: [
          _actionCard(
            icon: Icons
                .play_circle_fill_rounded,
            title: 'Course Videos',
            subtitle:
            'Watch all lessons and continue learning.',
            color: blue,
            onTap: openVideos,
          ),
          const SizedBox(height: 10),
          _actionCard(
            icon: Icons.quiz_rounded,
            title: 'Course Quiz',
            subtitle:
            'Test your knowledge with course quizzes.',
            color: purple,
            onTap: openQuiz,
          ),
          const SizedBox(height: 10),
          _actionCard(
            icon:
            Icons.rate_review_rounded,
            title: 'Write Review',
            subtitle:
            'Share your learning experience.',
            color: cyan,
            onTap: openReview,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // COURSE STATS
  // ============================================================

  Widget _buildCourseStats() {
    return _section(
      title: 'COURSE STATS',
      subtitle:
      'Quick information about this course',
      child: Row(
        children: [
          Expanded(
            child: _statCard(
              icon:
              Icons.star_rounded,
              value:
              course.rating.toString(),
              label: 'Rating',
              color: orange,
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: _statCard(
              icon:
              Icons.schedule_rounded,
              value: course.duration
                  .trim()
                  .isEmpty
                  ? 'Flexible'
                  : course.duration,
              label: 'Duration',
              color: cyan,
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: _statCard(
              icon: Icons
                  .workspace_premium_rounded,
              value: 'YES',
              label: 'Certificate',
              color: green,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding:
      const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 14,
      ),
      decoration: BoxDecoration(
        color: panel,
        borderRadius:
        BorderRadius.circular(16),
        border: Border.all(
          color:
          color.withValues(
            alpha: 0.20,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color:
            color.withValues(
              alpha: 0.045,
            ),
            blurRadius: 18,
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration:
            BoxDecoration(
              color:
              color.withValues(
                alpha: 0.08,
              ),
              borderRadius:
              BorderRadius.circular(
                11,
              ),
              border: Border.all(
                color:
                color.withValues(
                  alpha: 0.22,
                ),
              ),
            ),
            child: Icon(
              icon,
              color: color,
              size: 18,
            ),
          ),
          const SizedBox(height: 9),
          Text(
            value,
            maxLines: 1,
            overflow:
            TextOverflow.ellipsis,
            textAlign:
            TextAlign.center,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight:
              FontWeight.w900,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            maxLines: 1,
            overflow:
            TextOverflow.ellipsis,
            textAlign:
            TextAlign.center,
            style:
            const TextStyle(
              color: muted,
              fontSize: 8.5,
              fontWeight:
              FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ENROLLMENT INFO
  // ============================================================

  Widget _buildEnrollmentInfo() {
    return StreamBuilder<
        DocumentSnapshot<
            Map<String, dynamic>>>(
      stream: currentUser == null
          ? null
          : firestore
          .collection('enrollments')
          .doc(enrollmentId)
          .snapshots(),
      builder:
          (context, snapshot) {
        if (snapshot.connectionState ==
            ConnectionState.waiting) {
          return const SizedBox(
            height: 80,
            child: Center(
              child:
              CircularProgressIndicator(
                strokeWidth: 2,
                color: blue,
              ),
            ),
          );
        }

        final document =
            snapshot.data;

        if (document == null ||
            !document.exists) {
          return _buildEnrollmentCard();
        }

        final data =
            document.data() ?? {};

        final progress =
        _parseProgress(
          data['progress'],
        );

        return Column(
          children: [
            _buildCompletionStatus(
              progress,
            ),
            const SizedBox(height: 14),
          ],
        );
      },
    );
  }

  // ============================================================
  // ENROLLMENT CARD
  // ============================================================

  Widget _buildEnrollmentCard() {
    return _cyberCard(
      borderColor:
      blue.withValues(
        alpha: 0.24,
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration:
            BoxDecoration(
              color:
              blue.withValues(
                alpha: 0.08,
              ),
              borderRadius:
              BorderRadius.circular(
                15,
              ),
              border: Border.all(
                color:
                blue.withValues(
                  alpha: 0.22,
                ),
              ),
            ),
            child: const Icon(
              Icons.school_rounded,
              color: blue,
              size: 25,
            ),
          ),
          const SizedBox(width: 13),
          const Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  'READY TO START?',
                  style:
                  TextStyle(
                    color: white,
                    fontSize: 12,
                    fontWeight:
                    FontWeight.w900,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Enroll in this course and start your learning journey.',
                  style:
                  TextStyle(
                    color: muted,
                    fontSize: 9.5,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // COMPLETION STATUS
  // ============================================================

  Widget _buildCompletionStatus(
      int progress,
      ) {
    final completed =
        progress >= 100;

    return _section(
      title: 'COMPLETION STATUS',
      subtitle: completed
          ? 'You have completed this course'
          : 'Keep going and complete your learning path',
      child: _cyberCard(
        borderColor: completed
            ? green.withValues(
          alpha: 0.35,
        )
            : blue.withValues(
          alpha: 0.25,
        ),
        child: Row(
          children: [
            Container(
              width: 58,
              height: 58,
              decoration:
              BoxDecoration(
                shape: BoxShape.circle,
                color: (completed
                    ? green
                    : blue)
                    .withValues(
                  alpha: 0.08,
                ),
                border: Border.all(
                  color: (completed
                      ? green
                      : blue)
                      .withValues(
                    alpha: 0.30,
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: (completed
                        ? green
                        : blue)
                        .withValues(
                      alpha: 0.12,
                    ),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: Icon(
                completed
                    ? Icons
                    .check_circle_rounded
                    : Icons
                    .school_rounded,
                color:
                completed
                    ? green
                    : blue,
                size: 28,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment
                    .start,
                children: [
                  Text(
                    completed
                        ? 'COURSE COMPLETED'
                        : 'LEARNING IN PROGRESS',
                    style:
                    const TextStyle(
                      color: white,
                      fontSize: 12,
                      fontWeight:
                      FontWeight.w900,
                      letterSpacing:
                      0.4,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    completed
                        ? 'Your certificate is ready to view.'
                        : 'Continue watching lessons to increase your progress.',
                    maxLines: 2,
                    overflow:
                    TextOverflow
                        .ellipsis,
                    style:
                    const TextStyle(
                      color: muted,
                      fontSize: 10,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '$progress%',
              style: TextStyle(
                color: completed
                    ? green
                    : cyan,
                fontSize: 19,
                fontWeight:
                FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // CURRICULUM ITEM
  // ============================================================

  Widget _curriculumItem({
    required String number,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
    bool isLast = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius:
      BorderRadius.circular(15),
      child: Padding(
        padding:
        const EdgeInsets.only(
          bottom: 12,
        ),
        child: Row(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 42,
              child: Column(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration:
                    BoxDecoration(
                      color:
                      color.withValues(
                        alpha: 0.08,
                      ),
                      borderRadius:
                      BorderRadius
                          .circular(
                        12,
                      ),
                      border: Border.all(
                        color:
                        color.withValues(
                          alpha: 0.22,
                        ),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        number,
                        style:
                        TextStyle(
                          color: color,
                          fontSize: 10,
                          fontWeight:
                          FontWeight
                              .w900,
                        ),
                      ),
                    ),
                  ),
                  if (!isLast)
                    Container(
                      width: 1,
                      height: 42,
                      color: border,
                    ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                padding:
                const EdgeInsets.all(
                  13,
                ),
                decoration:
                BoxDecoration(
                  color: panel,
                  borderRadius:
                  BorderRadius
                      .circular(15),
                  border: Border.all(
                    color: border,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      icon,
                      color: color,
                      size: 21,
                    ),
                    const SizedBox(
                        width: 11),
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                        children: [
                          Text(
                            title,
                            style:
                            const TextStyle(
                              color:
                              white,
                              fontSize:
                              11,
                              fontWeight:
                              FontWeight
                                  .w900,
                            ),
                          ),
                          const SizedBox(
                              height: 4),
                          Text(
                            subtitle,
                            maxLines: 2,
                            overflow:
                            TextOverflow
                                .ellipsis,
                            style:
                            const TextStyle(
                              color:
                              muted,
                              fontSize:
                              9,
                              height:
                              1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 7),
                    Icon(
                      Icons
                          .arrow_forward_ios_rounded,
                      color:
                      color.withValues(
                        alpha: 0.7,
                      ),
                      size: 13,
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

  // ============================================================
  // REVIEW CARD
  // ============================================================

  Widget _reviewCard({
    required String name,
    required String review,
    required double rating,
  }) {
    return Container(
      width: double.infinity,
      margin:
      const EdgeInsets.only(
        bottom: 10,
      ),
      padding:
      const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: panel,
        borderRadius:
        BorderRadius.circular(16),
        border: Border.all(
          color: border,
        ),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration:
                const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient:
                  LinearGradient(
                    colors: [
                      blue,
                      purple,
                    ],
                  ),
                ),
                child: Center(
                  child: Text(
                    name.isEmpty
                        ? 'S'
                        : name[0]
                        .toUpperCase(),
                    style:
                    const TextStyle(
                      color:
                      Colors.white,
                      fontSize: 14,
                      fontWeight:
                      FontWeight.w900,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  name,
                  maxLines: 1,
                  overflow:
                  TextOverflow
                      .ellipsis,
                  style:
                  const TextStyle(
                    color: white,
                    fontSize: 11,
                    fontWeight:
                    FontWeight.w900,
                  ),
                ),
              ),
              _stars(rating),
            ],
          ),
          if (review.trim()
              .isNotEmpty) ...[
            const SizedBox(height: 11),
            Text(
              review,
              style:
              const TextStyle(
                color: muted,
                fontSize: 10,
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ============================================================
  // STARS
  // ============================================================

  Widget _stars(double rating) {
    final rounded =
    rating.round().clamp(0, 5);

    return Row(
      mainAxisSize:
      MainAxisSize.min,
      children: List.generate(
        5,
            (index) {
          return Icon(
            index < rounded
                ? Icons.star_rounded
                : Icons
                .star_border_rounded,
            color: orange,
            size: 14,
          );
        },
      ),
    );
  }

  // ============================================================
  // SECTION
  // ============================================================

  Widget _section({
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Padding(
          padding:
          const EdgeInsets.only(
            left: 2,
            bottom: 9,
          ),
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment
                .start,
            children: [
              Text(
                title,
                style:
                const TextStyle(
                  color: white,
                  fontSize: 11,
                  fontWeight:
                  FontWeight.w900,
                  letterSpacing: 0.7,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style:
                const TextStyle(
                  color: muted,
                  fontSize: 8.5,
                ),
              ),
            ],
          ),
        ),
        child,
      ],
    );
  }

  // ============================================================
  // CYBER CARD
  // ============================================================

  Widget _cyberCard({
    required Widget child,
    Color? borderColor,
  }) {
    return Container(
      width: double.infinity,
      padding:
      const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: panel,
        borderRadius:
        BorderRadius.circular(17),
        border: Border.all(
          color:
          borderColor ?? border,
        ),
        boxShadow: [
          BoxShadow(
            color:
            Colors.black.withValues(
              alpha: 0.16,
            ),
            blurRadius: 18,
            offset:
            const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }

  // ============================================================
  // ACTION CARD
  // ============================================================

  Widget _actionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius:
      BorderRadius.circular(17),
      child: _cyberCard(
        borderColor:
        color.withValues(
          alpha: 0.16,
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration:
              BoxDecoration(
                color:
                color.withValues(
                  alpha: 0.08,
                ),
                borderRadius:
                BorderRadius.circular(
                  14,
                ),
                border: Border.all(
                  color:
                  color.withValues(
                    alpha: 0.22,
                  ),
                ),
              ),
              child: Icon(
                icon,
                color: color,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment
                    .start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow:
                    TextOverflow
                        .ellipsis,
                    style:
                    const TextStyle(
                      color: white,
                      fontSize: 11,
                      fontWeight:
                      FontWeight
                          .w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow:
                    TextOverflow
                        .ellipsis,
                    style:
                    const TextStyle(
                      color: muted,
                      fontSize: 9,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            trailing ??
                Icon(
                  Icons
                      .arrow_forward_ios_rounded,
                  color:
                  color.withValues(
                    alpha: 0.75,
                  ),
                  size: 14,
                ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // EMPTY STATE
  // ============================================================

  Widget _emptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      padding:
      const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 24,
      ),
      decoration: BoxDecoration(
        color: panel,
        borderRadius:
        BorderRadius.circular(17),
        border: Border.all(
          color: border,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 34,
          ),
          const SizedBox(height: 10),
          Text(
            title,
            textAlign:
            TextAlign.center,
            style:
            const TextStyle(
              color: white,
              fontSize: 11,
              fontWeight:
              FontWeight.w900,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            subtitle,
            textAlign:
            TextAlign.center,
            style:
            const TextStyle(
              color: muted,
              fontSize: 9,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TOP BAR
  // ============================================================

  Widget _buildTopBar() {
    return Positioned(
      top: 10,
      left: 12,
      right: 12,
      child: Row(
        mainAxisAlignment:
        MainAxisAlignment
            .spaceBetween,
        children: [
          _topBarButton(
            icon:
            Icons.arrow_back_rounded,
            color: blue,
            onTap: () {
              Navigator.pop(context);
            },
          ),
          _topBarButton(
            icon:
            Icons.more_horiz_rounded,
            color: purple,
            onTap: () {
              _showCourseMenu();
            },
          ),
        ],
      ),
    );
  }

  Widget _topBarButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius:
        BorderRadius.circular(13),
        child: Container(
          width: 42,
          height: 42,
          decoration:
          BoxDecoration(
            color:
            bg.withValues(
              alpha: 0.78,
            ),
            borderRadius:
            BorderRadius.circular(
              13,
            ),
            border: Border.all(
              color:
              color.withValues(
                alpha: 0.22,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color:
                color.withValues(
                  alpha: 0.08,
                ),
                blurRadius: 15,
              ),
            ],
          ),
          child: Icon(
            icon,
            color: white,
            size: 19,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // COURSE MENU
  // ============================================================

  void _showCourseMenu() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: panel,
      shape:
      const RoundedRectangleBorder(
        borderRadius:
        BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding:
            const EdgeInsets.fromLTRB(
              18,
              18,
              18,
              20,
            ),
            child: Column(
              mainAxisSize:
              MainAxisSize.min,
              children: [
                Container(
                  width: 42,
                  height: 4,
                  decoration:
                  BoxDecoration(
                    color: border,
                    borderRadius:
                    BorderRadius
                        .circular(
                      10,
                    ),
                  ),
                ),
                const SizedBox(
                    height: 18),
                _menuItem(
                  icon: Icons
                      .favorite_border_rounded,
                  title:
                  'Add to Wishlist',
                  color: pink,
                  onTap: () {
                    Navigator.pop(
                        sheetContext);
                    addToWishlist();
                  },
                ),
                const SizedBox(height: 9),
                _menuItem(
                  icon: Icons
                      .picture_as_pdf_outlined,
                  title: 'Course Notes',
                  color: cyan,
                  onTap: () {
                    Navigator.pop(
                        sheetContext);
                    openNotes();
                  },
                ),
                const SizedBox(height: 9),
                _menuItem(
                  icon: Icons
                      .share_outlined,
                  title:
                  'Course Information',
                  color: blue,
                  onTap: () {
                    Navigator.pop(
                        sheetContext);
                    _showMessage(
                      'Course information is available on this page.',
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _menuItem({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius:
      BorderRadius.circular(15),
      child: Container(
        padding:
        const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 13,
        ),
        decoration:
        BoxDecoration(
          color: panel2,
          borderRadius:
          BorderRadius.circular(15),
          border: Border.all(
            color:
            color.withValues(
              alpha: 0.15,
            ),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: color,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style:
                const TextStyle(
                  color: white,
                  fontSize: 11,
                  fontWeight:
                  FontWeight.w800,
                ),
              ),
            ),
            const Icon(
              Icons
                  .arrow_forward_ios_rounded,
              color: muted,
              size: 13,
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // BOTTOM BAR
  // ============================================================

  Widget _buildBottomBar() {
    return Positioned(
      left: 12,
      right: 12,
      bottom: 12,
      child: Container(
        padding:
        const EdgeInsets.all(9),
        decoration:
        BoxDecoration(
          color:
          const Color(0xF20A1020),
          borderRadius:
          BorderRadius.circular(20),
          border: Border.all(
            color:
            blue.withValues(
              alpha: 0.18,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color:
              Colors.black.withValues(
                alpha: 0.38,
              ),
              blurRadius: 30,
              offset:
              const Offset(0, 12),
            ),
            BoxShadow(
              color:
              blue.withValues(
                alpha: 0.05,
              ),
              blurRadius: 22,
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: _bottomAction(
                icon: Icons
                    .favorite_border_rounded,
                label: 'Wishlist',
                color: pink,
                loading:
                isWishlistLoading,
                onTap:
                addToWishlist,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 2,
              child:
              _enrollButton(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bottomAction({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    bool loading = false,
  }) {
    return InkWell(
      onTap: loading
          ? null
          : onTap,
      borderRadius:
      BorderRadius.circular(14),
      child: Container(
        height: 50,
        decoration:
        BoxDecoration(
          color:
          color.withValues(
            alpha: 0.07,
          ),
          borderRadius:
          BorderRadius.circular(
            14,
          ),
          border: Border.all(
            color:
            color.withValues(
              alpha: 0.18,
            ),
          ),
        ),
        child: Center(
          child: loading
              ? SizedBox(
            width: 19,
            height: 19,
            child:
            CircularProgressIndicator(
              strokeWidth: 2,
              color: color,
            ),
          )
              : Row(
            mainAxisAlignment:
            MainAxisAlignment
                .center,
            children: [
              Icon(
                icon,
                color: color,
                size: 18,
              ),
              const SizedBox(
                  width: 6),
              Text(
                label,
                style:
                TextStyle(
                  color: color,
                  fontSize: 9.5,
                  fontWeight:
                  FontWeight
                      .w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // ENROLL BUTTON
  // ============================================================

  Widget _enrollButton() {
    final enrolled =
        isEnrolled == true;

    return InkWell(
      onTap:
      isEnrollLoading ||
          enrolled
          ? null
          : enrollCourse,
      borderRadius:
      BorderRadius.circular(14),
      child:
      AnimatedContainer(
        duration:
        const Duration(
          milliseconds: 220,
        ),
        height: 50,
        decoration:
        BoxDecoration(
          gradient:
          LinearGradient(
            colors: enrolled
                ? [
              const Color(
                  0xFF174D3D),
              const Color(
                  0xFF12372D),
            ]
                : [
              blue,
              purple,
            ],
          ),
          borderRadius:
          BorderRadius.circular(
            14,
          ),
          boxShadow: [
            BoxShadow(
              color:
              (enrolled
                  ? green
                  : blue)
                  .withValues(
                alpha: 0.18,
              ),
              blurRadius: 20,
            ),
          ],
        ),
        child: Center(
          child: isEnrollLoading
              ? const SizedBox(
            width: 20,
            height: 20,
            child:
            CircularProgressIndicator(
              strokeWidth: 2,
              color:
              Colors.white,
            ),
          )
              : Row(
            mainAxisAlignment:
            MainAxisAlignment
                .center,
            children: [
              Icon(
                enrolled
                    ? Icons
                    .check_circle_rounded
                    : Icons
                    .rocket_launch_rounded,
                color:
                Colors.white,
                size: 18,
              ),
              const SizedBox(
                  width: 7),
              Text(
                enrolled
                    ? 'ENROLLED'
                    : 'ENROLL NOW',
                style:
                const TextStyle(
                  color:
                  Colors.white,
                  fontSize: 10.5,
                  fontWeight:
                  FontWeight
                      .w900,
                  letterSpacing:
                  0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // PARSE PROGRESS
  // ============================================================

  int _parseProgress(dynamic value) {
    if (value is num) {
      return value.round().clamp(0, 100).toInt();
    }

    if (value is String) {
      final parsed = double.tryParse(value);
      return (parsed ?? 0).round().clamp(0, 100).toInt();
    }

    return 0;
  }

  // ============================================================
  // PARSE RATING
  // ============================================================

  double _parseRating(dynamic value) {
    if (value is num) {
      return value.toDouble().clamp(0.0, 5.0).toDouble();
    }

    if (value is String) {
      final parsed = double.tryParse(value);
      return (parsed ?? 0.0).clamp(0.0, 5.0).toDouble();
    }

    return 0.0;
  }

  // ============================================================
  // CYBER BACKGROUND
  // ============================================================

  Widget _buildCyberBackground() {
    return Positioned.fill(
      child: IgnorePointer(
        child: CustomPaint(
          painter:
          _CyberGridPainter(),
        ),
      ),
    );
  }
}

// ================================================================
// COURSE NOTES VIEWER
// ================================================================

class CourseNotesViewerScreen
    extends StatefulWidget {
  final String courseName;
  final String assetPath;

  const CourseNotesViewerScreen({
    super.key,
    required this.courseName,
    required this.assetPath,
  });

  @override
  State<CourseNotesViewerScreen>
  createState() =>
      _CourseNotesViewerScreenState();
}

class _CourseNotesViewerScreenState
    extends State<CourseNotesViewerScreen> {
  static const Color bg =
  Color(0xFF050816);

  static const Color panel =
  Color(0xFF0A1020);

  static const Color blue =
  Color(0xFF00B7FF);

  static const Color purple =
  Color(0xFF8B5CF6);

  static const Color cyan =
  Color(0xFF00F5D4);

  static const Color white =
  Color(0xFFF4F8FF);

  static const Color muted =
  Color(0xFF8B9BB8);

  static const Color border =
  Color(0xFF172B4D);

  final PdfViewerController
  pdfController =
  PdfViewerController();

  int currentPage = 1;
  int totalPages = 0;

  bool notesMarked = false;

  Future<void> _markNotesCompleted() async {
    if (notesMarked) return;
    notesMarked = true;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final ref = FirebaseFirestore.instance
          .collection('enrollments')
          .doc('${user.uid}_${widget.courseName}');

      final snap = await ref.get();

      if (snap.exists) {
        await ref.update({'notesCompleted': true});

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Notes completed')),
        );
      }
    } catch (e) {
      debugPrint('NOTES COMPLETE ERROR: $e');
      notesMarked = false;
    }
  }

  @override
  Widget build(
      BuildContext context,
      ) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        surfaceTintColor:
        Colors.transparent,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: white,
          ),
        ),
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            const Text(
              'COURSE NOTES',
              style: TextStyle(
                color: cyan,
                fontSize: 10,
                fontWeight:
                FontWeight.w900,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              widget.courseName,
              maxLines: 1,
              overflow:
              TextOverflow.ellipsis,
              style: const TextStyle(
                color: white,
                fontSize: 15,
                fontWeight:
                FontWeight.w900,
              ),
            ),
          ],
        ),
        actions: [
          if (totalPages > 0)
            Center(
              child: Container(
                margin:
                const EdgeInsets.only(
                  right: 14,
                ),
                padding:
                const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration:
                BoxDecoration(
                  color:
                  blue.withValues(
                    alpha: 0.08,
                  ),
                  borderRadius:
                  BorderRadius.circular(
                    10,
                  ),
                  border: Border.all(
                    color:
                    blue.withValues(
                      alpha: 0.22,
                    ),
                  ),
                ),
                child: Text(
                  '$currentPage / $totalPages',
                  style:
                  const TextStyle(
                    color: blue,
                    fontSize: 10,
                    fontWeight:
                    FontWeight.w900,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              color: bg,
            ),
          ),

          SfPdfViewer.asset(
            widget.assetPath,
            controller:
            pdfController,
            onDocumentLoaded:
                (details) {
              if (!mounted) return;

              setState(() {
                totalPages =
                    details.document
                        .pages
                        .count;
                currentPage =
                1;
              });
            },
            onPageChanged: (details) {
              if (!mounted) return;

              setState(() {
                currentPage = details.newPageNumber;
              });

              if (totalPages > 0 && details.newPageNumber >= totalPages) {
                _markNotesCompleted();
              }
            },
            onDocumentLoadFailed:
                (details) {
              if (!mounted) return;

              ScaffoldMessenger.of(
                context,
              ).showSnackBar(
                SnackBar(
                  backgroundColor:
                  const Color(
                    0xFFD92D55,
                  ),
                  content: Text(
                    'Unable to open notes: ${details.description}',
                  ),
                ),
              );
            },
          ),

          Positioned(
            left: 14,
            right: 14,
            bottom: 16,
            child: SafeArea(
              child: Container(
                padding:
                const EdgeInsets.all(
                  8,
                ),
                decoration:
                BoxDecoration(
                  color:
                  panel.withValues(
                    alpha: 0.96,
                  ),
                  borderRadius:
                  BorderRadius.circular(
                    18,
                  ),
                  border: Border.all(
                    color:
                    purple.withValues(
                      alpha: 0.22,
                    ),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color:
                      Colors.black
                          .withValues(
                        alpha: 0.35,
                      ),
                      blurRadius: 24,
                      offset:
                      const Offset(
                        0,
                        8,
                      ),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    _viewerButton(
                      icon: Icons
                          .zoom_out_rounded,
                      color: purple,
                      onTap: () {
                        pdfController
                            .zoomLevel =
                            (pdfController
                                .zoomLevel -
                                0.25)
                                .clamp(
                              1.0,
                              3.0,
                            );
                      },
                    ),
                    const SizedBox(width: 8),
                    _viewerButton(
                      icon: Icons
                          .zoom_in_rounded,
                      color: blue,
                      onTap: () {
                        pdfController
                            .zoomLevel =
                            (pdfController
                                .zoomLevel +
                                0.25)
                                .clamp(
                              1.0,
                              3.0,
                            );
                      },
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child:
                      Container(
                        height: 44,
                        decoration:
                        BoxDecoration(
                          color:
                          cyan.withValues(
                            alpha: 0.05,
                          ),
                          borderRadius:
                          BorderRadius
                              .circular(
                            13,
                          ),
                          border:
                          Border.all(
                            color:
                            cyan.withValues(
                              alpha:
                              0.14,
                            ),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            totalPages ==
                                0
                                ? 'Loading notes...'
                                : 'Page $currentPage of $totalPages',
                            style:
                            const TextStyle(
                              color:
                              muted,
                              fontSize:
                              10,
                              fontWeight:
                              FontWeight
                                  .w800,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _viewerButton(
                      icon: Icons
                          .first_page_rounded,
                      color: cyan,
                      onTap:
                      totalPages ==
                          0
                          ? null
                          : () {
                        pdfController
                            .jumpToPage(
                          1,
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    _viewerButton(
                      icon: Icons
                          .last_page_rounded,
                      color: cyan,
                      onTap:
                      totalPages ==
                          0
                          ? null
                          : () {
                        pdfController
                            .jumpToPage(
                          totalPages,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _viewerButton({
    required IconData icon,
    required Color color,
    required VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius:
        BorderRadius.circular(13),
        child: Container(
          width: 44,
          height: 44,
          decoration:
          BoxDecoration(
            color:
            color.withValues(
              alpha:
              onTap == null
                  ? 0.025
                  : 0.07,
            ),
            borderRadius:
            BorderRadius.circular(
              13,
            ),
            border: Border.all(
              color:
              color.withValues(
                alpha:
                onTap == null
                    ? 0.06
                    : 0.18,
              ),
            ),
          ),
          child: Icon(
            icon,
            color: onTap == null
                ? muted
                : color,
            size: 19,
          ),
        ),
      ),
    );
  }
}

// ================================================================
// CYBER GRID PAINTER
// ================================================================

class _CyberGridPainter
    extends CustomPainter {
  @override
  void paint(
      Canvas canvas,
      Size size,
      ) {
    final gridPaint = Paint()
      ..color =
      const Color(0xFF00B7FF)
          .withValues(
        alpha: 0.025,
      )
      ..strokeWidth = 0.6;

    const double gridSize = 42;

    for (
    double x = 0;
    x <= size.width;
    x += gridSize
    ) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        gridPaint,
      );
    }

    for (
    double y = 0;
    y <= size.height;
    y += gridSize
    ) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        gridPaint,
      );
    }

    final purpleGlow = Paint()
      ..color =
      const Color(0xFF8B5CF6)
          .withValues(
        alpha: 0.025,
      )
      ..maskFilter =
      const MaskFilter.blur(
        BlurStyle.normal,
        70,
      );

    canvas.drawCircle(
      Offset(
        size.width * 0.85,
        size.height * 0.20,
      ),
      110,
      purpleGlow,
    );

    final cyanGlow = Paint()
      ..color =
      const Color(0xFF00F5D4)
          .withValues(
        alpha: 0.018,
      )
      ..maskFilter =
      const MaskFilter.blur(
        BlurStyle.normal,
        80,
      );

    canvas.drawCircle(
      Offset(
        size.width * 0.10,
        size.height * 0.72,
      ),
      120,
      cyanGlow,
    );
  }

  @override
  bool shouldRepaint(
      covariant CustomPainter
      oldDelegate,
      ) {
    return false;
  }
}