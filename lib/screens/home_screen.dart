import 'dart:async';
import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/course_model.dart';

import 'course_details_screen.dart';
import 'my_learning_screen.dart';
import 'notification_screen.dart';
import 'profile_screen.dart';
import 'wishlist_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // ============================================================
  // CYBER TECH THEME
  // ============================================================

  static const Color bg = Color(0xFF050816);
  static const Color panel = Color(0xFF0B1020);
  static const Color panel2 = Color(0xFF10172A);

  static const Color neonBlue = Color(0xFF00B7FF);
  static const Color neonPurple = Color(0xFF8B5CF6);
  static const Color neonCyan = Color(0xFF00F5D4);
  static const Color neonGreen = Color(0xFF39FF88);
  static const Color neonOrange = Color(0xFFFF8A00);
  static const Color neonPink = Color(0xFFFF3CAC);

  static const Color textWhite = Color(0xFFF5F7FF);
  static const Color textMuted = Color(0xFF8993AD);
  static const Color border = Color(0xFF1C2942);

  // ============================================================
  // FIREBASE
  // ============================================================

  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  User? get currentUser => auth.currentUser;

  // ============================================================
  // USER
  // ============================================================

  String userName = 'Student';
  String? profilePhotoUrl;
  bool isUserLoading = true;

  // ============================================================
  // SEARCH
  // ============================================================

  final TextEditingController searchController =
  TextEditingController();

  String searchText = '';

  // ============================================================
  // BANNERS
  // ============================================================

  final PageController bannerController =
  PageController(viewportFraction: 0.90);

  Timer? bannerTimer;

  int currentBanner = 0;

  final List<String> banners = [
    'assets/images/banner1.jpg',
    'assets/images/banner2.jpg',
    'assets/images/banner3.jpg',
  ];

  // ============================================================
  // COURSES
  // ============================================================

  List<CourseModel> featuredCourses = [];

  bool isCoursesLoading = true;
  String? coursesError;

  // ============================================================
  // LEARNING
  // ============================================================

  String? continueCourseName;
  double continueProgress = 0;

  bool isLearningLoading = true;

  // ============================================================
  // ACHIEVEMENTS
  // ============================================================

  int certificateCount = 0;
  int learningDays = 0;

  bool isAchievementLoading = true;

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    loadHomeData();
    startBannerTimer();
  }

  // ============================================================
  // LOAD HOME DATA
  // ============================================================

  Future<void> loadHomeData() async {
    await Future.wait([
      loadUser(),
      loadCourses(),
      loadLearningProgress(),
      loadAchievements(),
    ]);
  }

  // ============================================================
  // LOAD USER
  // ============================================================

  Future<void> loadUser() async {
    final user = currentUser;

    if (user == null) {
      if (!mounted) return;

      setState(() {
        userName = 'Student';
        profilePhotoUrl = null;
        isUserLoading = false;
      });

      return;
    }

    try {
      final doc = await firestore
          .collection('users')
          .doc(user.uid)
          .get();

      if (!mounted) return;

      final data = doc.data();

      final firestoreName =
          data?['name']?.toString().trim() ?? '';

      final authName =
          user.displayName?.trim() ?? '';

      final resolvedName = firestoreName.isNotEmpty
          ? firestoreName
          : authName.isNotEmpty
          ? authName
          : 'Student';

      final firestorePhoto =
          data?['photoURL']?.toString().trim() ?? '';

      final authPhoto =
          user.photoURL?.trim() ?? '';

      final resolvedPhoto =
      firestorePhoto.isNotEmpty
          ? firestorePhoto
          : authPhoto.isNotEmpty
          ? authPhoto
          : null;

      setState(() {
        userName = resolvedName;
        profilePhotoUrl = resolvedPhoto;
        isUserLoading = false;
      });
    } catch (e) {
      debugPrint('HOME USER ERROR: $e');

      if (!mounted) return;

      final name =
          user.displayName?.trim() ?? '';

      setState(() {
        userName =
        name.isNotEmpty ? name : 'Student';

        profilePhotoUrl = user.photoURL;

        isUserLoading = false;
      });
    }
  }

  // ============================================================
  // LOAD COURSES
  // ============================================================

  Future<void> loadCourses() async {
    try {
      final snapshot =
      await firestore.collection('courses').get();

      final List<CourseModel> loadedCourses = [];

      for (final document in snapshot.docs) {
        final data = document.data();

        final title =
            data['title']?.toString().trim() ?? '';

        if (title.isEmpty) {
          continue;
        }

        loadedCourses.add(
          CourseModel(
            title: title,
            teacher:
            data['teacher']?.toString() ?? '',
            duration:
            data['duration']?.toString() ?? '',
            image: '',
            rating:
            _parseDouble(data['rating']),
          ),
        );
      }

      if (!mounted) return;

      setState(() {
        featuredCourses = loadedCourses;
        isCoursesLoading = false;
        coursesError = null;
      });
    } catch (e) {
      debugPrint('HOME COURSES ERROR: $e');

      if (!mounted) return;

      setState(() {
        isCoursesLoading = false;
        coursesError =
        'Unable to load courses right now.';
      });
    }
  }

  // ============================================================
  // LOAD LEARNING PROGRESS
  // ============================================================

  Future<void> loadLearningProgress() async {
    final user = currentUser;

    if (user == null) {
      if (!mounted) return;

      setState(() {
        isLearningLoading = false;
      });

      return;
    }

    try {
      final snapshot = await firestore
          .collection('enrollments')
          .where(
        'uid',
        isEqualTo: user.uid,
      )
          .get();

      if (snapshot.docs.isEmpty) {
        if (!mounted) return;

        setState(() {
          continueCourseName = null;
          continueProgress = 0;
          isLearningLoading = false;
        });

        return;
      }

      QueryDocumentSnapshot<Map<String, dynamic>>?
      selectedDocument;

      double selectedProgress = -1;

      for (final document in snapshot.docs) {
        final data = document.data();

        final progress =
        _parseDouble(data['progress']);

        if (progress > selectedProgress &&
            progress < 100) {
          selectedProgress = progress;
          selectedDocument = document;
        }
      }

      selectedDocument ??= snapshot.docs.first;

      final selectedData =
      selectedDocument.data();

      final courseName =
          selectedData['courseName']
              ?.toString()
              .trim() ??
              '';

      final progress =
      _parseDouble(selectedData['progress']);

      if (!mounted) return;

      setState(() {
        continueCourseName =
        courseName.isNotEmpty
            ? courseName
            : 'Your Course';

        continueProgress =
            (progress / 100)
                .clamp(0.0, 1.0)
                .toDouble();

        isLearningLoading = false;
      });
    } catch (e) {
      debugPrint(
        'HOME LEARNING ERROR: $e',
      );

      if (!mounted) return;

      setState(() {
        isLearningLoading = false;
      });
    }
  }

  // ============================================================
  // LOAD ACHIEVEMENTS
  // ============================================================

  Future<void> loadAchievements() async {
    final user = currentUser;

    if (user == null) {
      if (!mounted) return;

      setState(() {
        isAchievementLoading = false;
      });

      return;
    }

    try {
      final enrollmentSnapshot =
      await firestore
          .collection('enrollments')
          .where(
        'uid',
        isEqualTo: user.uid,
      )
          .get();

      final quizSnapshot =
      await firestore
          .collection('quiz_results')
          .where(
        'uid',
        isEqualTo: user.uid,
      )
          .get();

      int certificates = 0;

      for (final document
      in enrollmentSnapshot.docs) {
        final data = document.data();

        final progress =
        _parseDouble(data['progress']);

        if (progress >= 100) {
          certificates++;
        }
      }

      int streak = quizSnapshot.docs.length;

      if (streak > 30) {
        streak = 30;
      }

      if (!mounted) return;

      setState(() {
        certificateCount = certificates;
        learningDays = streak;
        isAchievementLoading = false;
      });
    } catch (e) {
      debugPrint(
        'HOME ACHIEVEMENT ERROR: $e',
      );

      if (!mounted) return;

      setState(() {
        isAchievementLoading = false;
      });
    }
  }

  // ============================================================
  // DOUBLE PARSER
  // ============================================================

  double _parseDouble(dynamic value) {
    if (value == null) {
      return 0;
    }

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
      value.toString(),
    ) ??
        0;
  }

  // ============================================================
  // BANNER TIMER
  // ============================================================

  void startBannerTimer() {
    if (banners.length <= 1) {
      return;
    }

    bannerTimer = Timer.periodic(
      const Duration(seconds: 5),
          (_) {
        if (!mounted ||
            !bannerController.hasClients) {
          return;
        }

        final nextPage =
            (currentBanner + 1) %
                banners.length;

        bannerController.animateToPage(
          nextPage,
          duration:
          const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
        );
      },
    );
  }

  // ============================================================
  // GREETING
  // ============================================================

  String greeting() {
    final hour = DateTime.now().hour;

    if (hour < 12) {
      return 'GOOD MORNING';
    }

    if (hour < 17) {
      return 'GOOD AFTERNOON';
    }

    return 'GOOD EVENING';
  }

  // ============================================================
  // FILTERED COURSES
  // ============================================================

  List<CourseModel> get filteredCourses {
    if (searchText.isEmpty) {
      return featuredCourses;
    }

    return featuredCourses.where(
          (course) {
        final title =
        course.title.toLowerCase();

        final teacher =
        course.teacher.toLowerCase();

        final duration =
        course.duration.toLowerCase();

        return title.contains(searchText) ||
            teacher.contains(searchText) ||
            duration.contains(searchText);
      },
    ).toList();
  }

  // ============================================================
  // NAVIGATION
  // ============================================================

  void openProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
        const ProfileScreen(),
      ),
    ).then((_) {
      loadUser();
      loadLearningProgress();
      loadAchievements();
    });
  }

  void openNotifications() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
        const NotificationScreen(),
      ),
    );
  }

  void openWishlist() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
        const WishlistScreen(),
      ),
    );
  }

  void openLearning() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
        const MyLearningScreen(),
      ),
    );
  }

  void openCourse(
      CourseModel course,
      ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            CourseDetailsScreen(
              course: course,
            ),
      ),
    );
  }

  // ============================================================
  // REFRESH
  // ============================================================

  Future<void> refreshHome() async {
    await Future.wait([
      loadUser(),
      loadCourses(),
      loadLearningProgress(),
      loadAchievements(),
    ]);
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    bannerTimer?.cancel();
    bannerController.dispose();
    searchController.dispose();

    super.dispose();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: RefreshIndicator(
          color: neonBlue,
          backgroundColor: panel,
          onRefresh: refreshHome,
          child: CustomScrollView(
            physics:
            const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              SliverToBoxAdapter(
                child: _buildTopHeader(),
              ),

              SliverToBoxAdapter(
                child: _buildSearch(),
              ),

              const SliverToBoxAdapter(
                child: SizedBox(height: 22),
              ),

              SliverToBoxAdapter(
                child: _buildHero(),
              ),

              const SliverToBoxAdapter(
                child: SizedBox(height: 30),
              ),

              SliverToBoxAdapter(
                child: _buildSectionTitle(
                  'CONTINUE LEARNING',
                  'Resume your active course',
                  onTap: openLearning,
                ),
              ),

              const SliverToBoxAdapter(
                child: SizedBox(height: 14),
              ),

              SliverToBoxAdapter(
                child:
                _buildContinueLearning(),
              ),

              const SliverToBoxAdapter(
                child: SizedBox(height: 30),
              ),

              SliverToBoxAdapter(
                child: _buildSectionTitle(
                  'SKILL MATRIX',
                  'Explore your learning areas',
                ),
              ),

              const SliverToBoxAdapter(
                child: SizedBox(height: 14),
              ),

              SliverToBoxAdapter(
                child: _buildCategories(),
              ),

              const SliverToBoxAdapter(
                child: SizedBox(height: 32),
              ),

              SliverToBoxAdapter(
                child: _buildSectionTitle(
                  'FEATURED COURSES',
                  'Level up your developer skills',
                ),
              ),

              const SliverToBoxAdapter(
                child: SizedBox(height: 14),
              ),

              SliverToBoxAdapter(
                child: _buildCourses(),
              ),

              const SliverToBoxAdapter(
                child: SizedBox(height: 32),
              ),

              SliverToBoxAdapter(
                child: _buildSectionTitle(
                  'ACHIEVEMENT CORE',
                  'Your progress at a glance',
                ),
              ),

              const SliverToBoxAdapter(
                child: SizedBox(height: 14),
              ),

              SliverToBoxAdapter(
                child: _buildAchievements(),
              ),

              const SliverToBoxAdapter(
                child: SizedBox(height: 32),
              ),

              SliverToBoxAdapter(
                child: _buildSectionTitle(
                  'MENTOR NETWORK',
                  'Learn from experienced instructors',
                ),
              ),

              const SliverToBoxAdapter(
                child: SizedBox(height: 14),
              ),

              SliverToBoxAdapter(
                child: _buildTeachers(),
              ),

              const SliverToBoxAdapter(
                child: SizedBox(height: 32),
              ),

              SliverToBoxAdapter(
                child: _buildSectionTitle(
                  'STUDENT SIGNAL',
                  'What learners are saying',
                ),
              ),

              const SliverToBoxAdapter(
                child: SizedBox(height: 14),
              ),

              SliverToBoxAdapter(
                child: _buildReview(),
              ),

              const SliverToBoxAdapter(
                child: SizedBox(height: 32),
              ),

              SliverToBoxAdapter(
                child: _buildSectionTitle(
                  'SYSTEM UPDATES',
                  'Latest MMOC Teach notifications',
                  onTap: openNotifications,
                ),
              ),

              const SliverToBoxAdapter(
                child: SizedBox(height: 14),
              ),

              SliverToBoxAdapter(
                child: _buildNotifications(),
              ),

              const SliverToBoxAdapter(
                child: SizedBox(height: 35),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar:
      _buildBottomNavigation(),
    );
  }

  // ============================================================
  // TOP HEADER
  // ============================================================

  Widget _buildTopHeader() {
    final initial =
    userName.trim().isNotEmpty
        ? userName.trim()[0].toUpperCase()
        : 'S';

    return Padding(
      padding:
      const EdgeInsets.fromLTRB(
        20,
        18,
        20,
        5,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration:
                      const BoxDecoration(
                        color: neonGreen,
                        shape:
                        BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: neonGreen,
                            blurRadius: 8,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 7),
                    Text(
                      greeting(),
                      style:
                      const TextStyle(
                        color: neonGreen,
                        fontSize: 10,
                        fontWeight:
                        FontWeight.w800,
                        letterSpacing: 1.4,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                Text(
                  isUserLoading
                      ? 'WELCOME BACK'
                      : userName.toUpperCase(),
                  maxLines: 1,
                  overflow:
                  TextOverflow.ellipsis,
                  style:
                  const TextStyle(
                    color: textWhite,
                    fontSize: 25,
                    fontWeight:
                    FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),

                const SizedBox(height: 3),

                const Text(
                  'READY TO LEVEL UP?',
                  style: TextStyle(
                    color: textMuted,
                    fontSize: 10,
                    fontWeight:
                    FontWeight.w700,
                    letterSpacing: 1.1,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          _cyberIconButton(
            icon:
            Icons.notifications_none_rounded,
            onTap:
            openNotifications,
            badge: true,
          ),

          const SizedBox(width: 10),

          GestureDetector(
            onTap: openProfile,
            child: Container(
              width: 48,
              height: 48,
              decoration:
              BoxDecoration(
                borderRadius:
                BorderRadius.circular(16),
                gradient:
                const LinearGradient(
                  colors: [
                    neonBlue,
                    neonPurple,
                  ],
                ),
                boxShadow: const [
                  BoxShadow(
                    color:
                    Color(0x4400B7FF),
                    blurRadius: 18,
                  ),
                ],
              ),
              padding:
              const EdgeInsets.all(2),
              child: ClipRRect(
                borderRadius:
                BorderRadius.circular(14),
                child:
                profilePhotoUrl != null &&
                    profilePhotoUrl!
                        .isNotEmpty
                    ? Image.network(
                  profilePhotoUrl!,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (
                      context,
                      error,
                      stackTrace,
                      ) {
                    return _avatarInitial(
                      initial,
                    );
                  },
                )
                    : _avatarInitial(
                  initial,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // AVATAR
  // ============================================================

  Widget _avatarInitial(
      String initial,
      ) {
    return Container(
      color: panel2,
      alignment:
      Alignment.center,
      child: Text(
        initial,
        style:
        const TextStyle(
          color: textWhite,
          fontSize: 18,
          fontWeight:
          FontWeight.w900,
        ),
      ),
    );
  }

  // ============================================================
  // CYBER ICON BUTTON
  // ============================================================

  Widget _cyberIconButton({
    required IconData icon,
    required VoidCallback onTap,
    bool badge = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration:
            BoxDecoration(
              color: panel,
              borderRadius:
              BorderRadius.circular(15),
              border: Border.all(
                color: border,
              ),
              boxShadow: const [
                BoxShadow(
                  color:
                  Color(0x2200B7FF),
                  blurRadius: 12,
                ),
              ],
            ),
            child: Icon(
              icon,
              color: neonBlue,
              size: 22,
            ),
          ),

          if (badge)
            Positioned(
              top: 7,
              right: 7,
              child: Container(
                width: 7,
                height: 7,
                decoration:
                const BoxDecoration(
                  color: neonOrange,
                  shape:
                  BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: neonOrange,
                      blurRadius: 7,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ============================================================
  // SEARCH
  // ============================================================

  Widget _buildSearch() {
    return Padding(
      padding:
      const EdgeInsets.fromLTRB(
        20,
        20,
        20,
        0,
      ),
      child: Container(
        height: 55,
        decoration:
        BoxDecoration(
          color: panel,
          borderRadius:
          BorderRadius.circular(17),
          border: Border.all(
            color: border,
          ),
          boxShadow: const [
            BoxShadow(
              color:
              Color(0x2200B7FF),
              blurRadius: 15,
            ),
          ],
        ),
        child: TextField(
          controller:
          searchController,
          style:
          const TextStyle(
            color: textWhite,
            fontSize: 13,
            fontWeight:
            FontWeight.w600,
          ),
          decoration:
          InputDecoration(
            border:
            InputBorder.none,
            hintText:
            'Search courses, skills...',
            hintStyle:
            const TextStyle(
              color: textMuted,
              fontSize: 13,
            ),
            prefixIcon:
            const Icon(
              Icons.search_rounded,
              color: neonBlue,
            ),
            suffixIcon:
            searchText.isNotEmpty
                ? IconButton(
              onPressed: () {
                searchController
                    .clear();

                setState(() {
                  searchText =
                  '';
                });
              },
              icon:
              const Icon(
                Icons
                    .close_rounded,
                color: textMuted,
                size: 19,
              ),
            )
                : const Icon(
              Icons.tune_rounded,
              color:
              neonPurple,
              size: 20,
            ),
            contentPadding:
            const EdgeInsets
                .symmetric(
              vertical: 16,
            ),
          ),
          onChanged: (value) {
            setState(() {
              searchText =
                  value.trim().toLowerCase();
            });
          },
        ),
      ),
    );
  }

  // ============================================================
  // HERO
  // ============================================================

  Widget _buildHero() {
    return Column(
      children: [
        SizedBox(
          height: 220,
          child: PageView.builder(
            controller:
            bannerController,
            itemCount:
            banners.length,
            onPageChanged: (index) {
              if (!mounted) return;

              setState(() {
                currentBanner = index;
              });
            },
            itemBuilder:
                (context, index) {
              return Padding(
                padding:
                const EdgeInsets
                    .symmetric(
                  horizontal: 5,
                ),
                child: _heroCard(
                  index,
                  banners[index],
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 12),

        Row(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children:
          List.generate(
            banners.length,
                (index) {
              final active =
                  currentBanner == index;

              return AnimatedContainer(
                duration:
                const Duration(
                  milliseconds: 250,
                ),
                margin:
                const EdgeInsets
                    .symmetric(
                  horizontal: 3,
                ),
                width:
                active ? 25 : 6,
                height: 6,
                decoration:
                BoxDecoration(
                  color: active
                      ? neonBlue
                      : border,
                  borderRadius:
                  BorderRadius.circular(
                    10,
                  ),
                  boxShadow: active
                      ? const [
                    BoxShadow(
                      color: neonBlue,
                      blurRadius: 8,
                    ),
                  ]
                      : null,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ============================================================
  // HERO CARD
  // ============================================================

  Widget _heroCard(
      int index,
      String imagePath,
      ) {
    final titles = [
      'LEARN. BUILD. DEPLOY.',
      'UPGRADE YOUR SKILLS.',
      'YOUR FUTURE STARTS HERE.',
    ];

    final subtitles = [
      'Master technology with MMOC Teach.',
      'Turn knowledge into real projects.',
      'Keep learning. Keep growing.',
    ];

    return Container(
      decoration:
      BoxDecoration(
        borderRadius:
        BorderRadius.circular(25),
        border: Border.all(
          color:
          neonBlue.withValues(
            alpha: 0.35,
          ),
        ),
        boxShadow: const [
          BoxShadow(
            color:
            Color(0x3300B7FF),
            blurRadius: 25,
            spreadRadius: 1,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius:
        BorderRadius.circular(25),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              imagePath,
              fit: BoxFit.cover,
              errorBuilder:
                  (
                  context,
                  error,
                  stackTrace,
                  ) {
                return Container(
                  decoration:
                  const BoxDecoration(
                    gradient:
                    LinearGradient(
                      colors: [
                        Color(0xFF07152D),
                        Color(0xFF26104D),
                      ],
                    ),
                  ),
                  child:
                  const Center(
                    child: Icon(
                      Icons
                          .terminal_rounded,
                      color:
                      neonBlue,
                      size: 80,
                    ),
                  ),
                );
              },
            ),

            Container(
              decoration:
              const BoxDecoration(
                gradient:
                LinearGradient(
                  begin:
                  Alignment.bottomLeft,
                  end:
                  Alignment.topRight,
                  colors: [
                    Color(0xEE050816),
                    Color(0x99050816),
                    Color(0x22050816),
                  ],
                ),
              ),
            ),

            Positioned(
              top: 18,
              right: 18,
              child: Container(
                padding:
                const EdgeInsets
                    .symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration:
                BoxDecoration(
                  color:
                  const Color(
                    0x3319D3FF,
                  ),
                  borderRadius:
                  BorderRadius.circular(
                    20,
                  ),
                  border: Border.all(
                    color:
                    neonCyan
                        .withValues(
                      alpha: 0.55,
                    ),
                  ),
                ),
                child: const Row(
                  mainAxisSize:
                  MainAxisSize.min,
                  children: [
                    Icon(
                      Icons
                          .bolt_rounded,
                      color:
                      neonCyan,
                      size: 14,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'LIVE LEARNING',
                      style:
                      TextStyle(
                        color:
                        neonCyan,
                        fontSize: 8,
                        fontWeight:
                        FontWeight.w900,
                        letterSpacing:
                        0.8,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Positioned(
              left: 20,
              right: 20,
              bottom: 20,
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment
                    .start,
                children: [
                  const Text(
                    'MMOC // TEACH',
                    style:
                    TextStyle(
                      color:
                      neonBlue,
                      fontSize: 10,
                      fontWeight:
                      FontWeight.w900,
                      letterSpacing:
                      1.8,
                    ),
                  ),

                  const SizedBox(
                    height: 7,
                  ),

                  Text(
                    titles[
                    index %
                        titles.length],
                    maxLines: 1,
                    overflow:
                    TextOverflow
                        .ellipsis,
                    style:
                    const TextStyle(
                      color:
                      textWhite,
                      fontSize: 23,
                      fontWeight:
                      FontWeight.w900,
                      letterSpacing:
                      -0.3,
                    ),
                  ),

                  const SizedBox(
                    height: 4,
                  ),

                  Text(
                    subtitles[
                    index %
                        subtitles.length],
                    style:
                    const TextStyle(
                      color:
                      textMuted,
                      fontSize: 11.5,
                      fontWeight:
                      FontWeight.w600,
                    ),
                  ),

                  const SizedBox(
                    height: 11,
                  ),

                  Container(
                    padding:
                    const EdgeInsets
                        .symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),
                    decoration:
                    BoxDecoration(
                      gradient:
                      const LinearGradient(
                        colors: [
                          neonBlue,
                          neonPurple,
                        ],
                      ),
                      borderRadius:
                      BorderRadius.circular(
                        20,
                      ),
                    ),
                    child:
                    const Row(
                      mainAxisSize:
                      MainAxisSize.min,
                      children: [
                        Text(
                          'EXPLORE NOW',
                          style:
                          TextStyle(
                            color:
                            Colors.white,
                            fontSize: 9,
                            fontWeight:
                            FontWeight
                                .w900,
                            letterSpacing:
                            0.8,
                          ),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Icon(
                          Icons
                              .arrow_forward_rounded,
                          color:
                          Colors.white,
                          size: 14,
                        ),
                      ],
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
  // SECTION TITLE
  // ============================================================

  Widget _buildSectionTitle(
      String title,
      String subtitle, {
        VoidCallback? onTap,
      }) {
    return Padding(
      padding:
      const EdgeInsets.symmetric(
        horizontal: 20,
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 36,
            decoration:
            BoxDecoration(
              gradient:
              const LinearGradient(
                begin:
                Alignment.topCenter,
                end:
                Alignment.bottomCenter,
                colors: [
                  neonBlue,
                  neonPurple,
                ],
              ),
              borderRadius:
              BorderRadius.circular(5),
              boxShadow: const [
                BoxShadow(
                  color: neonBlue,
                  blurRadius: 8,
                ),
              ],
            ),
          ),

          const SizedBox(width: 11),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style:
                  const TextStyle(
                    color: textWhite,
                    fontSize: 17,
                    fontWeight:
                    FontWeight.w900,
                    letterSpacing: 0.4,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  subtitle,
                  style:
                  const TextStyle(
                    color: textMuted,
                    fontSize: 10.5,
                    fontWeight:
                    FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          if (onTap != null)
            GestureDetector(
              onTap: onTap,
              child:
              const Icon(
                Icons
                    .arrow_forward_ios_rounded,
                color: neonBlue,
                size: 15,
              ),
            ),
        ],
      ),
    );
  }

  // ============================================================
  // CONTINUE LEARNING
  // ============================================================

  Widget _buildContinueLearning() {
    if (isLearningLoading) {
      return _loadingPanel(150);
    }

    if (continueCourseName == null) {
      return _startLearningCard();
    }

    final percentage =
    (continueProgress * 100).round();

    return Container(
      margin:
      const EdgeInsets.symmetric(
        horizontal: 20,
      ),
      padding:
      const EdgeInsets.all(15),
      decoration:
      BoxDecoration(
        color: panel,
        borderRadius:
        BorderRadius.circular(22),
        border: Border.all(
          color:
          neonPurple.withValues(
            alpha: 0.35,
          ),
        ),
        boxShadow: const [
          BoxShadow(
            color:
            Color(0x332F1A68),
            blurRadius: 20,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 86,
            height: 100,
            decoration:
            BoxDecoration(
              borderRadius:
              BorderRadius.circular(
                17,
              ),
              border: Border.all(
                color:
                neonBlue.withValues(
                  alpha: 0.35,
                ),
              ),
            ),
            clipBehavior:
            Clip.antiAlias,
            child:
            _dynamicCourseVisual(
              continueCourseName!,
              compact: true,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration:
                      const BoxDecoration(
                        color:
                        neonGreen,
                        shape:
                        BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color:
                            neonGreen,
                            blurRadius:
                            7,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      width: 6,
                    ),
                    const Text(
                      'ACTIVE MODULE',
                      style:
                      TextStyle(
                        color:
                        neonGreen,
                        fontSize: 8,
                        fontWeight:
                        FontWeight
                            .w900,
                        letterSpacing:
                        1.0,
                      ),
                    ),
                  ],
                ),

                const SizedBox(
                  height: 9,
                ),

                Text(
                  continueCourseName!,
                  maxLines: 2,
                  overflow:
                  TextOverflow.ellipsis,
                  style:
                  const TextStyle(
                    color:
                    textWhite,
                    fontSize: 16,
                    fontWeight:
                    FontWeight.w900,
                  ),
                ),

                const SizedBox(
                  height: 5,
                ),

                Text(
                  '$percentage% completed',
                  style:
                  const TextStyle(
                    color:
                    textMuted,
                    fontSize: 10.5,
                    fontWeight:
                    FontWeight.w600,
                  ),
                ),

                const SizedBox(
                  height: 8,
                ),

                ClipRRect(
                  borderRadius:
                  BorderRadius.circular(
                    20,
                  ),
                  child:
                  LinearProgressIndicator(
                    value:
                    continueProgress,
                    minHeight: 6,
                    backgroundColor:
                    const Color(
                      0xFF1B2437,
                    ),
                    valueColor:
                    const AlwaysStoppedAnimation<
                        Color>(
                      neonBlue,
                    ),
                  ),
                ),

                const SizedBox(
                  height: 9,
                ),

                GestureDetector(
                  onTap: openLearning,
                  child:
                  const Row(
                    mainAxisSize:
                    MainAxisSize.min,
                    children: [
                      Text(
                        'RESUME',
                        style:
                        TextStyle(
                          color:
                          neonBlue,
                          fontSize: 10,
                          fontWeight:
                          FontWeight
                              .w900,
                          letterSpacing:
                          0.8,
                        ),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Icon(
                        Icons
                            .arrow_forward_rounded,
                        color:
                        neonBlue,
                        size: 14,
                      ),
                    ],
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
  // START LEARNING
  // ============================================================

  Widget _startLearningCard() {
    return Container(
      margin:
      const EdgeInsets.symmetric(
        horizontal: 20,
      ),
      padding:
      const EdgeInsets.all(18),
      decoration:
      BoxDecoration(
        color: panel,
        borderRadius:
        BorderRadius.circular(22),
        border: Border.all(
          color:
          neonBlue.withValues(
            alpha: 0.25,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration:
            BoxDecoration(
              gradient:
              const LinearGradient(
                colors: [
                  neonBlue,
                  neonPurple,
                ],
              ),
              borderRadius:
              BorderRadius.circular(
                16,
              ),
              boxShadow: const [
                BoxShadow(
                  color:
                  Color(0x4400B7FF),
                  blurRadius: 14,
                ),
              ],
            ),
            child:
            const Icon(
              Icons
                  .terminal_rounded,
              color:
              Colors.white,
              size: 28,
            ),
          ),

          const SizedBox(width: 13),

          const Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  'NO ACTIVE MODULE',
                  style:
                  TextStyle(
                    color:
                    textWhite,
                    fontSize: 14,
                    fontWeight:
                    FontWeight.w900,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Choose a course and start building your next skill.',
                  style:
                  TextStyle(
                    color:
                    textMuted,
                    fontSize: 10.5,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),

          GestureDetector(
            onTap: openLearning,
            child: Container(
              width: 39,
              height: 39,
              decoration:
              const BoxDecoration(
                gradient:
                LinearGradient(
                  colors: [
                    neonBlue,
                    neonPurple,
                  ],
                ),
                shape:
                BoxShape.circle,
              ),
              child:
              const Icon(
                Icons
                    .arrow_forward_rounded,
                color:
                Colors.white,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CATEGORIES
  // ============================================================

  Widget _buildCategories() {
    final categories = [
      {
        'title': 'Flutter',
        'icon':
        Icons.flutter_dash_rounded,
        'color': neonBlue,
      },
      {
        'title': 'Web',
        'icon':
        Icons.language_rounded,
        'color': neonPurple,
      },
      {
        'title': 'Firebase',
        'icon':
        Icons.cloud_rounded,
        'color': neonOrange,
      },
      {
        'title': 'Python',
        'icon':
        Icons.code_rounded,
        'color': neonGreen,
      },
      {
        'title': 'Java',
        'icon':
        Icons.coffee_rounded,
        'color':
        const Color(0xFFFF4D6D),
      },
      {
        'title': 'AI',
        'icon':
        Icons.smart_toy_rounded,
        'color': neonCyan,
      },
    ];

    return SizedBox(
      height: 112,
      child:
      ListView.separated(
        scrollDirection:
        Axis.horizontal,
        padding:
        const EdgeInsets.symmetric(
          horizontal: 20,
        ),
        itemCount:
        categories.length,
        separatorBuilder:
            (context, index) {
          return const SizedBox(
            width: 10,
          );
        },
        itemBuilder:
            (context, index) {
          final category =
          categories[index];

          return _categoryCard(
            title:
            category['title']
            as String,
            icon:
            category['icon']
            as IconData,
            color:
            category['color']
            as Color,
          );
        },
      ),
    );
  }

  // ============================================================
  // CATEGORY CARD
  // ============================================================

  Widget _categoryCard({
    required String title,
    required IconData icon,
    required Color color,
  }) {
    return GestureDetector(
      onTap: () {
        searchController.text =
            title;

        setState(() {
          searchText =
              title.toLowerCase();
        });
      },
      child: Container(
        width: 92,
        padding:
        const EdgeInsets
            .symmetric(
          vertical: 12,
          horizontal: 7,
        ),
        decoration:
        BoxDecoration(
          color: panel,
          borderRadius:
          BorderRadius.circular(
            18,
          ),
          border: Border.all(
            color:
            color.withValues(
              alpha: 0.30,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color:
              color.withValues(
                alpha: 0.10,
              ),
              blurRadius: 14,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            Container(
              width: 46,
              height: 46,
              decoration:
              BoxDecoration(
                color:
                color.withValues(
                  alpha: 0.10,
                ),
                shape:
                BoxShape.circle,
                border:
                Border.all(
                  color:
                  color.withValues(
                    alpha: 0.30,
                  ),
                ),
              ),
              child:
              Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),

            const SizedBox(
              height: 8,
            ),

            Text(
              title.toUpperCase(),
              maxLines: 1,
              overflow:
              TextOverflow.ellipsis,
              style:
              const TextStyle(
                color:
                textWhite,
                fontSize: 9,
                fontWeight:
                FontWeight.w800,
                letterSpacing:
                0.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // FEATURED COURSES
  // ============================================================

  Widget _buildCourses() {
    if (isCoursesLoading) {
      return SizedBox(
        height: 335,
        child:
        ListView.separated(
          scrollDirection:
          Axis.horizontal,
          padding:
          const EdgeInsets.symmetric(
            horizontal: 20,
          ),
          itemCount: 2,
          separatorBuilder:
              (context, index) {
            return const SizedBox(
              width: 14,
            );
          },
          itemBuilder:
              (context, index) {
            return _courseSkeleton();
          },
        ),
      );
    }

    if (coursesError != null) {
      return _errorPanel(
        message: coursesError!,
        onRetry: loadCourses,
      );
    }

    final courses =
        filteredCourses;

    if (courses.isEmpty) {
      return _emptyCourses();
    }

    return SizedBox(
      height: 335,
      child:
      ListView.separated(
        scrollDirection:
        Axis.horizontal,
        padding:
        const EdgeInsets.symmetric(
          horizontal: 20,
        ),
        itemCount:
        courses.length,
        separatorBuilder:
            (context, index) {
          return const SizedBox(
            width: 14,
          );
        },
        itemBuilder:
            (context, index) {
          final course =
          courses[index];

          return _cyberCourseCard(
            course,
          );
        },
      ),
    );
  }

  // ============================================================
  // CYBER COURSE CARD
  // ============================================================

  Widget _cyberCourseCard(
      CourseModel course,
      ) {
    final visual =
    _courseVisualData(
      course.title,
    );

    return GestureDetector(
      onTap: () =>
          openCourse(course),
      child: Container(
        width: 235,
        decoration:
        BoxDecoration(
          color: panel,
          borderRadius:
          BorderRadius.circular(
            22,
          ),
          border: Border.all(
            color:
            visual.color.withValues(
              alpha: 0.45,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color:
              visual.color.withValues(
                alpha: 0.13,
              ),
              blurRadius: 22,
              spreadRadius: 1,
            ),
          ],
        ),
        clipBehavior:
        Clip.antiAlias,
        child: Column(
          children: [
            Expanded(
              flex: 6,
              child:
              _dynamicCourseVisual(
                course.title,
                icon:
                visual.icon,
                accent:
                visual.color,
              ),
            ),

            Expanded(
              flex: 4,
              child: Padding(
                padding:
                const EdgeInsets
                    .fromLTRB(
                  14,
                  10,
                  14,
                  13,
                ),
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
                  children: [
                    Text(
                      course.title
                          .toUpperCase(),
                      maxLines: 1,
                      overflow:
                      TextOverflow
                          .ellipsis,
                      style:
                      const TextStyle(
                        color:
                        textWhite,
                        fontSize: 16,
                        fontWeight:
                        FontWeight.w900,
                        letterSpacing:
                        0.3,
                      ),
                    ),

                    const SizedBox(
                      height: 5,
                    ),

                    Text(
                      course.teacher
                          .isNotEmpty
                          ? 'BY ${course.teacher}'
                          : 'MMOC TEACH',
                      maxLines: 1,
                      overflow:
                      TextOverflow
                          .ellipsis,
                      style:
                      const TextStyle(
                        color:
                        textMuted,
                        fontSize: 9,
                        fontWeight:
                        FontWeight.w700,
                      ),
                    ),

                    const Spacer(),

                    Row(
                      children: [
                        const Icon(
                          Icons
                              .star_rounded,
                          color:
                          neonOrange,
                          size: 15,
                        ),

                        const SizedBox(
                          width: 3,
                        ),

                        Text(
                          course.rating
                              .toStringAsFixed(
                            1,
                          ),
                          style:
                          const TextStyle(
                            color:
                            textWhite,
                            fontSize: 10,
                            fontWeight:
                            FontWeight
                                .w800,
                          ),
                        ),

                        const SizedBox(
                          width: 10,
                        ),

                        const Icon(
                          Icons
                              .schedule_rounded,
                          color:
                          textMuted,
                          size: 14,
                        ),

                        const SizedBox(
                          width: 3,
                        ),

                        Expanded(
                          child: Text(
                            course.duration
                                .isNotEmpty
                                ? course
                                .duration
                                : 'SELF PACED',
                            maxLines: 1,
                            overflow:
                            TextOverflow
                                .ellipsis,
                            style:
                            const TextStyle(
                              color:
                              textMuted,
                              fontSize:
                              9,
                              fontWeight:
                              FontWeight
                                  .w700,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(
                      height: 9,
                    ),

                    Container(
                      height: 35,
                      width:
                      double.infinity,
                      decoration:
                      BoxDecoration(
                        gradient:
                        LinearGradient(
                          colors: [
                            visual.color,
                            neonPurple,
                          ],
                        ),
                        borderRadius:
                        BorderRadius
                            .circular(
                          10,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color:
                            visual
                                .color
                                .withValues(
                              alpha: 0.25,
                            ),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      alignment:
                      Alignment.center,
                      child:
                      const Row(
                        mainAxisAlignment:
                        MainAxisAlignment
                            .center,
                        children: [
                          Text(
                            'VIEW COURSE',
                            style:
                            TextStyle(
                              color:
                              Colors
                                  .white,
                              fontSize:
                              9,
                              fontWeight:
                              FontWeight
                                  .w900,
                              letterSpacing:
                              0.8,
                            ),
                          ),
                          SizedBox(
                            width: 6,
                          ),
                          Icon(
                            Icons
                                .arrow_forward_rounded,
                            color:
                            Colors
                                .white,
                            size: 14,
                          ),
                        ],
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

  // ============================================================
  // COURSE VISUAL DATA
  // ============================================================

  _CourseVisualData _courseVisualData(
      String courseName,
      ) {
    final name =
    courseName.toLowerCase();

    if (name.contains('flutter')) {
      return const _CourseVisualData(
        icon:
        Icons.flutter_dash_rounded,
        color: neonBlue,
      );
    }

    if (name.contains('python')) {
      return const _CourseVisualData(
        icon: Icons.code_rounded,
        color: neonGreen,
      );
    }

    if (name.contains('java')) {
      return const _CourseVisualData(
        icon: Icons.coffee_rounded,
        color: neonOrange,
      );
    }

    if (name.contains('django')) {
      return const _CourseVisualData(
        icon: Icons.dns_rounded,
        color: neonGreen,
      );
    }

    if (name.contains('react')) {
      return const _CourseVisualData(
        icon:
        Icons.data_object_rounded,
        color: neonCyan,
      );
    }

    if (name.contains('firebase')) {
      return const _CourseVisualData(
        icon: Icons.cloud_rounded,
        color: neonOrange,
      );
    }

    if (name.contains('html') ||
        name.contains('css') ||
        name.contains('web')) {
      return const _CourseVisualData(
        icon:
        Icons.language_rounded,
        color: neonPurple,
      );
    }

    if (name.contains('javascript') ||
        name == 'js') {
      return const _CourseVisualData(
        icon:
        Icons.javascript_rounded,
        color: neonOrange,
      );
    }

    if (name.contains('c++') ||
        name.contains('cpp')) {
      return const _CourseVisualData(
        icon: Icons.code_rounded,
        color: neonBlue,
      );
    }

    if (name.contains('c language') ||
        name == 'c') {
      return const _CourseVisualData(
        icon:
        Icons.terminal_rounded,
        color: neonCyan,
      );
    }

    if (name.contains('sql') ||
        name.contains('database') ||
        name.contains('dbms')) {
      return const _CourseVisualData(
        icon:
        Icons.storage_rounded,
        color: neonPink,
      );
    }

    if (name.contains('ai') ||
        name.contains('artificial')) {
      return const _CourseVisualData(
        icon:
        Icons.smart_toy_rounded,
        color: neonCyan,
      );
    }

    if (name.contains('cyber') ||
        name.contains('security')) {
      return const _CourseVisualData(
        icon:
        Icons.security_rounded,
        color: neonGreen,
      );
    }

    return const _CourseVisualData(
      icon: Icons.code_rounded,
      color: neonBlue,
    );
  }

  // ============================================================
  // DYNAMIC COURSE VISUAL
  // ============================================================

  Widget _dynamicCourseVisual(
      String courseName, {
        IconData? icon,
        Color? accent,
        double? width,
        double? height,
        bool compact = false,
      }) {
    final visual =
    _courseVisualData(
      courseName,
    );

    final actualIcon =
        icon ?? visual.icon;

    final actualAccent =
        accent ?? visual.color;

    final initials =
    _courseInitials(
      courseName,
    );

    return Container(
      width: width,
      height: height,
      decoration:
      BoxDecoration(
        gradient:
        LinearGradient(
          begin:
          Alignment.topLeft,
          end:
          Alignment.bottomRight,
          colors: [
            const Color(0xFF071329),
            actualAccent.withValues(
              alpha: 0.22,
            ),
            const Color(0xFF160A32),
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter:
              _CyberCircuitPainter(
                color:
                actualAccent,
              ),
            ),
          ),

          Positioned(
            top:
            compact ? 8 : 13,
            left:
            compact ? 8 : 14,
            child: Container(
              padding:
              EdgeInsets.symmetric(
                horizontal:
                compact ? 6 : 8,
                vertical:
                compact ? 4 : 5,
              ),
              decoration:
              BoxDecoration(
                color:
                actualAccent
                    .withValues(
                  alpha: 0.12,
                ),
                borderRadius:
                BorderRadius.circular(
                  8,
                ),
                border:
                Border.all(
                  color:
                  actualAccent
                      .withValues(
                    alpha: 0.45,
                  ),
                ),
              ),
              child: Text(
                '</>',
                style:
                TextStyle(
                  color:
                  actualAccent,
                  fontSize:
                  compact ? 9 : 11,
                  fontWeight:
                  FontWeight.w900,
                ),
              ),
            ),
          ),

          Positioned(
            top:
            compact ? 8 : 13,
            right:
            compact ? 8 : 14,
            child: Container(
              padding:
              EdgeInsets.symmetric(
                horizontal:
                compact ? 7 : 9,
                vertical:
                compact ? 4 : 5,
              ),
              decoration:
              BoxDecoration(
                color:
                const Color(
                  0x99050816,
                ),
                borderRadius:
                BorderRadius.circular(
                  8,
                ),
                border:
                Border.all(
                  color:
                  actualAccent
                      .withValues(
                    alpha: 0.35,
                  ),
                ),
              ),
              child: Text(
                initials,
                style:
                TextStyle(
                  color:
                  actualAccent,
                  fontSize:
                  compact ? 8 : 10,
                  fontWeight:
                  FontWeight.w900,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),

          Center(
            child: Column(
              mainAxisSize:
              MainAxisSize.min,
              children: [
                Container(
                  width:
                  compact ? 45 : 72,
                  height:
                  compact ? 45 : 72,
                  decoration:
                  BoxDecoration(
                    shape:
                    BoxShape.circle,
                    gradient:
                    RadialGradient(
                      colors: [
                        actualAccent
                            .withValues(
                          alpha: 0.35,
                        ),
                        actualAccent
                            .withValues(
                          alpha: 0.06,
                        ),
                      ],
                    ),
                    border:
                    Border.all(
                      color:
                      actualAccent
                          .withValues(
                        alpha: 0.60,
                      ),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color:
                        actualAccent
                            .withValues(
                          alpha: 0.35,
                        ),
                        blurRadius:
                        compact
                            ? 15
                            : 25,
                      ),
                    ],
                  ),
                  child:
                  Icon(
                    actualIcon,
                    color:
                    actualAccent,
                    size:
                    compact ? 23 : 38,
                  ),
                ),

                if (!compact) ...[
                  const SizedBox(
                    height: 12,
                  ),
                  Padding(
                    padding:
                    const EdgeInsets
                        .symmetric(
                      horizontal: 12,
                    ),
                    child: Text(
                      courseName
                          .toUpperCase(),
                      textAlign:
                      TextAlign.center,
                      maxLines: 1,
                      overflow:
                      TextOverflow
                          .ellipsis,
                      style:
                      const TextStyle(
                        color:
                        textWhite,
                        fontSize: 21,
                        fontWeight:
                        FontWeight.w900,
                        letterSpacing:
                        1.0,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          Positioned(
            left:
            compact ? 12 : 25,
            right:
            compact ? 12 : 25,
            bottom:
            compact ? 8 : 15,
            child: Container(
              height:
              compact ? 3 : 5,
              decoration:
              BoxDecoration(
                borderRadius:
                BorderRadius.circular(
                  20,
                ),
                gradient:
                LinearGradient(
                  colors: [
                    actualAccent
                        .withValues(
                      alpha: 0.0,
                    ),
                    actualAccent,
                    neonPurple
                        .withValues(
                      alpha: 0.0,
                    ),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color:
                    actualAccent
                        .withValues(
                      alpha: 0.50,
                    ),
                    blurRadius:
                    compact ? 8 : 15,
                  ),
                ],
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

  String _courseInitials(
      String title,
      ) {
    final words = title
        .trim()
        .split(RegExp(r'\s+'))
        .where(
          (word) =>
      word.isNotEmpty,
    )
        .toList();

    if (words.isEmpty) {
      return 'DEV';
    }

    if (words.length == 1) {
      final value =
      words.first.toUpperCase();

      if (value.length <= 3) {
        return value;
      }

      return value.substring(0, 3);
    }

    return words
        .take(3)
        .map(
          (word) =>
          word[0].toUpperCase(),
    )
        .join();
  }

  // ============================================================
  // COURSE SKELETON
  // ============================================================

  Widget _courseSkeleton() {
    return Container(
      width: 235,
      decoration:
      BoxDecoration(
        color: panel,
        borderRadius:
        BorderRadius.circular(
          22,
        ),
        border: Border.all(
          color: border,
        ),
      ),
      child: Column(
        children: [
          Expanded(
            flex: 6,
            child: Container(
              decoration:
              const BoxDecoration(
                gradient:
                LinearGradient(
                  colors: [
                    Color(0xFF071329),
                    Color(0xFF15102E),
                  ],
                ),
              ),
              child:
              const Center(
                child: Icon(
                  Icons
                      .auto_stories_rounded,
                  color: border,
                  size: 45,
                ),
              ),
            ),
          ),

          Expanded(
            flex: 4,
            child: Padding(
              padding:
              const EdgeInsets.all(
                15,
              ),
              child: Column(
                children: [
                  _skeletonLine(160),

                  const SizedBox(
                    height: 11,
                  ),

                  _skeletonLine(110),

                  const Spacer(),

                  _skeletonLine(
                    double.infinity,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SKELETON LINE
  // ============================================================

  Widget _skeletonLine(
      double width,
      ) {
    return Container(
      width: width,
      height: 12,
      decoration:
      BoxDecoration(
        color: panel2,
        borderRadius:
        BorderRadius.circular(6),
      ),
    );
  }

  // ============================================================
  // EMPTY COURSES
  // ============================================================

  Widget _emptyCourses() {
    return Container(
      margin:
      const EdgeInsets.symmetric(
        horizontal: 20,
      ),
      padding:
      const EdgeInsets.all(28),
      decoration:
      BoxDecoration(
        color: panel,
        borderRadius:
        BorderRadius.circular(21),
        border: Border.all(
          color: border,
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.search_off_rounded,
            color: neonBlue,
            size: 42,
          ),

          const SizedBox(
            height: 12,
          ),

          Text(
            searchText.isEmpty
                ? 'NO COURSES AVAILABLE'
                : 'NO MATCH FOUND',
            style:
            const TextStyle(
              color: textWhite,
              fontSize: 14,
              fontWeight:
              FontWeight.w900,
              letterSpacing: 0.5,
            ),
          ),

          const SizedBox(
            height: 5,
          ),

          Text(
            searchText.isEmpty
                ? 'New courses will appear here soon.'
                : 'Try another course or teacher name.',
            textAlign:
            TextAlign.center,
            style:
            const TextStyle(
              color: textMuted,
              fontSize: 10.5,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ACHIEVEMENTS
  // ============================================================

  Widget _buildAchievements() {
    if (isAchievementLoading) {
      return _loadingPanel(140);
    }

    return Padding(
      padding:
      const EdgeInsets.symmetric(
        horizontal: 20,
      ),
      child: Row(
        children: [
          Expanded(
            child: _achievementCard(
              icon:
              Icons
                  .workspace_premium_rounded,
              title:
              'CERTIFICATES',
              value:
              certificateCount
                  .toString()
                  .padLeft(
                2,
                '0',
              ),
              color: neonOrange,
            ),
          ),

          const SizedBox(
            width: 12,
          ),

          Expanded(
            child: _achievementCard(
              icon:
              Icons
                  .local_fire_department_rounded,
              title:
              'LEARNING STREAK',
              value:
              '$learningDays DAYS',
              color: neonPurple,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ACHIEVEMENT CARD
  // ============================================================

  Widget _achievementCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding:
      const EdgeInsets.all(16),
      decoration:
      BoxDecoration(
        color: panel,
        borderRadius:
        BorderRadius.circular(20),
        border: Border.all(
          color:
          color.withValues(
            alpha: 0.25,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color:
            color.withValues(
              alpha: 0.08,
            ),
            blurRadius: 18,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Container(
            width: 45,
            height: 45,
            decoration:
            BoxDecoration(
              color:
              color.withValues(
                alpha: 0.10,
              ),
              shape:
              BoxShape.circle,
              border: Border.all(
                color:
                color.withValues(
                  alpha: 0.25,
                ),
              ),
            ),
            child:
            Icon(
              icon,
              color: color,
              size: 23,
            ),
          ),

          const SizedBox(
            height: 12,
          ),

          Text(
            value,
            style:
            const TextStyle(
              color: textWhite,
              fontSize: 20,
              fontWeight:
              FontWeight.w900,
            ),
          ),

          const SizedBox(
            height: 3,
          ),

          Text(
            title,
            style:
            const TextStyle(
              color: textMuted,
              fontSize: 9,
              fontWeight:
              FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TEACHERS
  // ============================================================

  Widget _buildTeachers() {
    final teachers = [
      {
        'name': 'Rahul Sir',
        'subject': 'Flutter',
        'color': neonBlue,
      },
      {
        'name': 'Aman Sir',
        'subject': 'Python',
        'color': neonGreen,
      },
      {
        'name': 'Rohit Sir',
        'subject': 'Java',
        'color': neonPurple,
      },
      {
        'name': "Neha Ma'am",
        'subject': 'Firebase',
        'color': neonOrange,
      },
    ];

    return SizedBox(
      height: 145,
      child:
      ListView.separated(
        scrollDirection:
        Axis.horizontal,
        padding:
        const EdgeInsets.symmetric(
          horizontal: 20,
        ),
        itemCount:
        teachers.length,
        separatorBuilder:
            (context, index) {
          return const SizedBox(
            width: 12,
          );
        },
        itemBuilder:
            (context, index) {
          final teacher =
          teachers[index];

          return _teacherCard(
            name:
            teacher['name']
            as String,
            subject:
            teacher['subject']
            as String,
            color:
            teacher['color']
            as Color,
          );
        },
      ),
    );
  }

  // ============================================================
  // TEACHER CARD
  // ============================================================

  Widget _teacherCard({
    required String name,
    required String subject,
    required Color color,
  }) {
    return Container(
      width: 155,
      padding:
      const EdgeInsets.all(14),
      decoration:
      BoxDecoration(
        color: panel,
        borderRadius:
        BorderRadius.circular(20),
        border: Border.all(
          color:
          color.withValues(
            alpha: 0.25,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration:
                BoxDecoration(
                  gradient:
                  LinearGradient(
                    colors: [
                      color.withValues(
                        alpha: 0.25,
                      ),
                      color.withValues(
                        alpha: 0.05,
                      ),
                    ],
                  ),
                  shape:
                  BoxShape.circle,
                  border:
                  Border.all(
                    color:
                    color.withValues(
                      alpha: 0.40,
                    ),
                  ),
                ),
                child:
                Icon(
                  Icons
                      .person_rounded,
                  color: color,
                  size: 25,
                ),
              ),

              const Spacer(),

              Icon(
                Icons
                    .verified_rounded,
                color: color,
                size: 17,
              ),
            ],
          ),

          const SizedBox(
            height: 12,
          ),

          Text(
            name,
            maxLines: 1,
            overflow:
            TextOverflow.ellipsis,
            style:
            const TextStyle(
              color: textWhite,
              fontSize: 13,
              fontWeight:
              FontWeight.w800,
            ),
          ),

          const SizedBox(
            height: 4,
          ),

          Text(
            subject.toUpperCase(),
            style:
            TextStyle(
              color: color,
              fontSize: 9,
              fontWeight:
              FontWeight.w900,
              letterSpacing: 0.7,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // REVIEW / STUDENT SIGNAL
  // ============================================================

  Widget _buildReview() {
    final reviews = [
      {
        'name': 'Aman',
        'course': 'Flutter',
        'text':
        'The project based learning makes concepts much easier to understand.',
        'color': neonBlue,
      },
      {
        'name': 'Priya',
        'course': 'Python',
        'text':
        'Clean lessons, useful projects and a very smooth learning experience.',
        'color': neonPurple,
      },
      {
        'name': 'Rohit',
        'course': 'Web Development',
        'text':
        'MMOC Teach helped me turn theory into actual development skills.',
        'color': neonCyan,
      },
    ];

    return SizedBox(
      height: 155,
      child:
      ListView.separated(
        scrollDirection:
        Axis.horizontal,
        padding:
        const EdgeInsets.symmetric(
          horizontal: 20,
        ),
        itemCount:
        reviews.length,
        separatorBuilder:
            (context, index) {
          return const SizedBox(
            width: 12,
          );
        },
        itemBuilder:
            (context, index) {
          final review =
          reviews[index];

          return _reviewCard(
            name:
            review['name']
            as String,
            course:
            review['course']
            as String,
            text:
            review['text']
            as String,
            color:
            review['color']
            as Color,
          );
        },
      ),
    );
  }

  // ============================================================
  // REVIEW CARD
  // ============================================================

  Widget _reviewCard({
    required String name,
    required String course,
    required String text,
    required Color color,
  }) {
    return Container(
      width: 280,
      padding:
      const EdgeInsets.all(16),
      decoration:
      BoxDecoration(
        color: panel,
        borderRadius:
        BorderRadius.circular(20),
        border: Border.all(
          color:
          color.withValues(
            alpha: 0.25,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color:
            color.withValues(
              alpha: 0.06,
            ),
            blurRadius: 18,
          ),
        ],
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
                BoxDecoration(
                  gradient:
                  LinearGradient(
                    colors: [
                      color,
                      neonPurple,
                    ],
                  ),
                  shape:
                  BoxShape.circle,
                ),
                alignment:
                Alignment.center,
                child: Text(
                  name[0]
                      .toUpperCase(),
                  style:
                  const TextStyle(
                    color:
                    Colors.white,
                    fontWeight:
                    FontWeight.w900,
                  ),
                ),
              ),

              const SizedBox(
                width: 10,
              ),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
                  children: [
                    Text(
                      name,
                      style:
                      const TextStyle(
                        color:
                        textWhite,
                        fontSize: 12,
                        fontWeight:
                        FontWeight.w800,
                      ),
                    ),
                    const SizedBox(
                      height: 2,
                    ),
                    Text(
                      course
                          .toUpperCase(),
                      style:
                      TextStyle(
                        color: color,
                        fontSize: 8,
                        fontWeight:
                        FontWeight.w900,
                        letterSpacing:
                        0.6,
                      ),
                    ),
                  ],
                ),
              ),

              const Icon(
                Icons
                    .format_quote_rounded,
                color:
                textMuted,
                size: 20,
              ),
            ],
          ),

          const SizedBox(
            height: 12,
          ),

          Text(
            text,
            maxLines: 3,
            overflow:
            TextOverflow.ellipsis,
            style:
            const TextStyle(
              color: textMuted,
              fontSize: 10.5,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // NOTIFICATIONS
  // ============================================================

  Widget _buildNotifications() {
    return StreamBuilder<
        QuerySnapshot<
            Map<String, dynamic>>>(
      stream: firestore
          .collection('notifications')
          .orderBy(
        'createdAt',
        descending: true,
      )
          .limit(3)
          .snapshots(),
      builder:
          (context, snapshot) {
        if (snapshot.hasError) {
          return _notificationFallback();
        }

        if (snapshot.connectionState ==
            ConnectionState.waiting) {
          return _loadingPanel(125);
        }

        final docs =
            snapshot.data?.docs ?? [];

        if (docs.isEmpty) {
          return _notificationFallback();
        }

        return Padding(
          padding:
          const EdgeInsets.symmetric(
            horizontal: 20,
          ),
          child: Column(
            children:
            docs.map(
                  (doc) {
                final data =
                doc.data();

                return Padding(
                  padding:
                  const EdgeInsets.only(
                    bottom: 10,
                  ),
                  child:
                  _notificationCard(
                    title:
                    data['title']
                        ?.toString() ??
                        'MMOC UPDATE',
                    message:
                    data['message']
                        ?.toString() ??
                        'New update available.',
                    icon:
                    Icons
                        .notifications_active_rounded,
                  ),
                );
              },
            ).toList(),
          ),
        );
      },
    );
  }

  // ============================================================
  // NOTIFICATION FALLBACK
  // ============================================================

  Widget _notificationFallback() {
    return Padding(
      padding:
      const EdgeInsets.symmetric(
        horizontal: 20,
      ),
      child: _notificationCard(
        title: 'MMOC SYSTEM ONLINE',
        message:
        'Keep learning, building and upgrading your developer skills.',
        icon:
        Icons
            .rocket_launch_rounded,
      ),
    );
  }

  // ============================================================
  // NOTIFICATION CARD
  // ============================================================

  Widget _notificationCard({
    required String title,
    required String message,
    required IconData icon,
  }) {
    return Container(
      padding:
      const EdgeInsets.all(15),
      decoration:
      BoxDecoration(
        color: panel,
        borderRadius:
        BorderRadius.circular(18),
        border: Border.all(
          color:
          neonBlue.withValues(
            alpha: 0.22,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 45,
            height: 45,
            decoration:
            BoxDecoration(
              gradient:
              const LinearGradient(
                colors: [
                  neonBlue,
                  neonPurple,
                ],
              ),
              borderRadius:
              BorderRadius.circular(
                14,
              ),
              boxShadow: const [
                BoxShadow(
                  color:
                  Color(0x3300B7FF),
                  blurRadius: 12,
                ),
              ],
            ),
            child:
            Icon(
              icon,
              color:
              Colors.white,
              size: 21,
            ),
          ),

          const SizedBox(
            width: 12,
          ),

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
                    color:
                    textWhite,
                    fontSize: 11,
                    fontWeight:
                    FontWeight.w900,
                  ),
                ),

                const SizedBox(
                  height: 5,
                ),

                Text(
                  message,
                  maxLines: 2,
                  overflow:
                  TextOverflow
                      .ellipsis,
                  style:
                  const TextStyle(
                    color:
                    textMuted,
                    fontSize: 9.5,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),

          const Icon(
            Icons
                .arrow_forward_ios_rounded,
            color:
            neonBlue,
            size: 13,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // LOADING PANEL
  // ============================================================

  Widget _loadingPanel(
      double height,
      ) {
    return Container(
      margin:
      const EdgeInsets.symmetric(
        horizontal: 20,
      ),
      height: height,
      decoration:
      BoxDecoration(
        color: panel,
        borderRadius:
        BorderRadius.circular(22),
        border: Border.all(
          color: border,
        ),
      ),
      child:
      const Center(
        child: SizedBox(
          width: 28,
          height: 28,
          child:
          CircularProgressIndicator(
            strokeWidth: 2,
            color: neonBlue,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // ERROR PANEL
  // ============================================================

  Widget _errorPanel({
    required String message,
    required VoidCallback onRetry,
  }) {
    return Container(
      margin:
      const EdgeInsets.symmetric(
        horizontal: 20,
      ),
      padding:
      const EdgeInsets.all(22),
      decoration:
      BoxDecoration(
        color: panel,
        borderRadius:
        BorderRadius.circular(21),
        border: Border.all(
          color:
          neonOrange.withValues(
            alpha: 0.30,
          ),
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons
                .cloud_off_rounded,
            color: neonOrange,
            size: 38,
          ),

          const SizedBox(
            height: 10,
          ),

          const Text(
            'CONNECTION ISSUE',
            style:
            TextStyle(
              color: textWhite,
              fontSize: 13,
              fontWeight:
              FontWeight.w900,
            ),
          ),

          const SizedBox(
            height: 5,
          ),

          Text(
            message,
            textAlign:
            TextAlign.center,
            style:
            const TextStyle(
              color: textMuted,
              fontSize: 10,
            ),
          ),

          const SizedBox(
            height: 13,
          ),

          GestureDetector(
            onTap: onRetry,
            child: Container(
              padding:
              const EdgeInsets
                  .symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              decoration:
              BoxDecoration(
                gradient:
                const LinearGradient(
                  colors: [
                    neonBlue,
                    neonPurple,
                  ],
                ),
                borderRadius:
                BorderRadius.circular(
                  20,
                ),
              ),
              child:
              const Text(
                'RETRY',
                style:
                TextStyle(
                  color:
                  Colors.white,
                  fontSize: 9,
                  fontWeight:
                  FontWeight.w900,
                  letterSpacing:
                  0.8,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // BOTTOM NAVIGATION
  // ============================================================

  Widget _buildBottomNavigation() {
    return Container(
      decoration:
      const BoxDecoration(
        color: panel,
        border: Border(
          top: BorderSide(
            color: border,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color:
            Color(0x5500B7FF),
            blurRadius: 20,
            spreadRadius: -8,
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding:
          const EdgeInsets.fromLTRB(
            16,
            10,
            16,
            8,
          ),
          child: Row(
            mainAxisAlignment:
            MainAxisAlignment
                .spaceAround,
            children: [
              _bottomNavItem(
                icon:
                Icons
                    .home_rounded,
                label: 'HOME',
                active: true,
                onTap: () {},
              ),

              _bottomNavItem(
                icon:
                Icons
                    .school_rounded,
                label: 'LEARNING',
                active: false,
                onTap: openLearning,
              ),

              _bottomNavItem(
                icon:
                Icons
                    .favorite_border_rounded,
                label: 'WISHLIST',
                active: false,
                onTap: openWishlist,
              ),

              _bottomNavItem(
                icon:
                Icons
                    .person_outline_rounded,
                label: 'PROFILE',
                active: false,
                onTap: openProfile,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // BOTTOM NAV ITEM
  // ============================================================

  Widget _bottomNavItem({
    required IconData icon,
    required String label,
    required bool active,
    required VoidCallback onTap,
  }) {
    final color =
    active ? neonBlue : textMuted;

    return GestureDetector(
      onTap: onTap,
      behavior:
      HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration:
        const Duration(
          milliseconds: 200,
        ),
        padding:
        const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 6,
        ),
        decoration:
        BoxDecoration(
          color: active
              ? color.withValues(
            alpha: 0.08,
          )
              : Colors.transparent,
          borderRadius:
          BorderRadius.circular(
            14,
          ),
          border: active
              ? Border.all(
            color:
            color.withValues(
              alpha: 0.22,
            ),
          )
              : null,
        ),
        child: Column(
          mainAxisSize:
          MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: color,
              size: 21,
            ),

            const SizedBox(
              height: 3,
            ),

            Text(
              label,
              style:
              TextStyle(
                color: color,
                fontSize: 7,
                fontWeight:
                FontWeight.w900,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================================================================
// COURSE VISUAL DATA
// ==================================================================

class _CourseVisualData {
  final IconData icon;
  final Color color;

  const _CourseVisualData({
    required this.icon,
    required this.color,
  });
}

// ==================================================================
// CYBER CIRCUIT PAINTER
// ==================================================================

class _CyberCircuitPainter
    extends CustomPainter {
  final Color color;

  _CyberCircuitPainter({
    required this.color,
  });

  @override
  void paint(
      Canvas canvas,
      Size size,
      ) {
    final paint = Paint()
      ..color =
      color.withValues(
        alpha: 0.13,
      )
      ..strokeWidth = 1
      ..style =
          PaintingStyle.stroke;

    final dotPaint = Paint()
      ..color =
      color.withValues(
        alpha: 0.30,
      )
      ..style =
          PaintingStyle.fill;

    final random =
    math.Random(7);

    final horizontalCount =
    math.max(
      4,
      (size.height / 34)
          .floor(),
    );

    final verticalCount =
    math.max(
      3,
      (size.width / 55)
          .floor(),
    );

    for (int i = 0;
    i < horizontalCount;
    i++) {
      final y =
          (i + 1) *
              size.height /
              (horizontalCount + 1);

      final startX =
          random.nextDouble() *
              size.width *
              0.25;

      final midX =
          startX +
              size.width * 0.20;

      final endX =
          midX +
              size.width * 0.22;

      final path =
      Path();

      path.moveTo(
        startX,
        y,
      );

      path.lineTo(
        midX,
        y,
      );

      path.lineTo(
        midX,
        y + 18,
      );

      path.lineTo(
        endX,
        y + 18,
      );

      canvas.drawPath(
        path,
        paint,
      );

      canvas.drawCircle(
        Offset(
          endX,
          y + 18,
        ),
        2,
        dotPaint,
      );
    }

    for (int i = 0;
    i < verticalCount;
    i++) {
      final x =
          (i + 1) *
              size.width /
              (verticalCount + 1);

      final startY =
          random.nextDouble() *
              size.height *
              0.20;

      final path =
      Path();

      path.moveTo(
        x,
        startY,
      );

      path.lineTo(
        x,
        startY + 25,
      );

      path.lineTo(
        x + 18,
        startY + 25,
      );

      path.lineTo(
        x + 18,
        startY + 48,
      );

      canvas.drawPath(
        path,
        paint,
      );

      canvas.drawCircle(
        Offset(
          x + 18,
          startY + 48,
        ),
        2,
        dotPaint,
      );
    }

    // Small futuristic dots
    for (int i = 0; i < 16; i++) {
      final x =
          random.nextDouble() *
              size.width;

      final y =
          random.nextDouble() *
              size.height;

      canvas.drawCircle(
        Offset(x, y),
        1.3,
        dotPaint,
      );
    }
  }

  @override
  bool shouldRepaint(
      covariant _CyberCircuitPainter oldDelegate,
      ) {
    return oldDelegate.color !=
        color;
  }
}