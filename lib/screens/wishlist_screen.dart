import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  // ============================================================
  // CYBER-TECH COLORS
  // ============================================================

  static const Color bg = Color(0xFF050816);
  static const Color bgSecondary = Color(0xFF07101F);

  static const Color panel = Color(0xFF0B1326);
  static const Color panelLight = Color(0xFF101B33);

  static const Color neonBlue = Color(0xFF00B7FF);
  static const Color neonPurple = Color(0xFF8B5CF6);
  static const Color neonCyan = Color(0xFF00F5D4);
  static const Color neonGreen = Color(0xFF39FF88);
  static const Color neonOrange = Color(0xFFFF8A00);
  static const Color neonPink = Color(0xFFFF4ECD);

  static const Color textWhite = Color(0xFFF5F9FF);
  static const Color textMuted = Color(0xFF8EA1BD);
  static const Color border = Color(0xFF18345A);

  static const Color heartRed = Color(0xFFFF4D6D);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    // ==========================================================
    // NOT LOGGED IN
    // ==========================================================

    if (user == null) {
      return Scaffold(
        backgroundColor: bg,
        appBar: _buildAppBar(context),
        body: const _EmptyWishlistState(
          icon: Icons.lock_outline_rounded,
          title: 'Login Required',
          subtitle:
          'Login to access your saved courses and continue your learning journey.',
          isError: true,
        ),
      );
    }

    // ==========================================================
    // LOGGED IN
    // ==========================================================

    return Scaffold(
      backgroundColor: bg,
      appBar: _buildAppBar(context),
      body: Stack(
        children: [
          // ======================================================
          // BACKGROUND GLOW
          // ======================================================

          Positioned(
            top: -100,
            right: -80,
            child: _glowCircle(
              size: 240,
              color: neonPurple,
              opacity: 0.08,
            ),
          ),

          Positioned(
            top: 260,
            left: -120,
            child: _glowCircle(
              size: 220,
              color: neonBlue,
              opacity: 0.06,
            ),
          ),

          Positioned(
            bottom: -120,
            right: -80,
            child: _glowCircle(
              size: 260,
              color: neonCyan,
              opacity: 0.045,
            ),
          ),

          // ======================================================
          // MAIN CONTENT
          // ======================================================

          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('wishlist')
                .where(
              'uid',
              isEqualTo: user.uid,
            )
                .snapshots(),
            builder: (context, snapshot) {
              // --------------------------------------------------
              // LOADING
              // --------------------------------------------------

              if (snapshot.connectionState ==
                  ConnectionState.waiting) {
                return _loadingState();
              }

              // --------------------------------------------------
              // ERROR
              // --------------------------------------------------

              if (snapshot.hasError) {
                return const _EmptyWishlistState(
                  icon: Icons.cloud_off_rounded,
                  title: 'Unable to Load Wishlist',
                  subtitle:
                  'Something went wrong while loading your saved courses.',
                  isError: true,
                );
              }

              // --------------------------------------------------
              // EMPTY
              // --------------------------------------------------

              if (!snapshot.hasData ||
                  snapshot.data!.docs.isEmpty) {
                return const _EmptyWishlistState(
                  icon: Icons.favorite_border_rounded,
                  title: 'Your Wishlist is Empty',
                  subtitle:
                  'Save your favourite courses and keep your learning journey ready for later.',
                );
              }

              final docs = snapshot.data!.docs;

              return ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                  16,
                  12,
                  16,
                  35,
                ),
                children: [
                  // ==================================================
                  // PAGE LABEL
                  // ==================================================

                  _buildPageHeading(
                    docs.length,
                  ),

                  const SizedBox(height: 18),

                  // ==================================================
                  // HERO
                  // ==================================================

                  _buildHero(
                    docs.length,
                  ),

                  const SizedBox(height: 16),

                  // ==================================================
                  // STATS
                  // ==================================================

                  _buildStats(
                    docs.length,
                  ),

                  const SizedBox(height: 24),

                  // ==================================================
                  // SECTION TITLE
                  // ==================================================

                  Row(
                    children: [
                      Container(
                        width: 4,
                        height: 25,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              neonBlue,
                              neonPurple,
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          borderRadius:
                          BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: neonBlue.withValues(
                                alpha: 0.55,
                              ),
                              blurRadius: 9,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Text(
                              'SAVED COURSES',
                              style: TextStyle(
                                color: textWhite,
                                fontSize: 16,
                                fontWeight:
                                FontWeight.w900,
                                letterSpacing: 1.1,
                              ),
                            ),
                            SizedBox(height: 3),
                            Text(
                              'Your personal learning collection',
                              style: TextStyle(
                                color: textMuted,
                                fontSize: 10.5,
                                fontWeight:
                                FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding:
                        const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: neonPurple.withValues(
                            alpha: 0.10,
                          ),
                          borderRadius:
                          BorderRadius.circular(10),
                          border: Border.all(
                            color: neonPurple.withValues(
                              alpha: 0.35,
                            ),
                          ),
                        ),
                        child: Row(
                          mainAxisSize:
                          MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.favorite_rounded,
                              color: heartRed,
                              size: 13,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              '${docs.length}',
                              style: const TextStyle(
                                color: textWhite,
                                fontSize: 11,
                                fontWeight:
                                FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // ==================================================
                  // COURSE LIST
                  // ==================================================

                  ...List.generate(
                    docs.length,
                        (index) {
                      final rawData =
                      docs[index].data();

                      final data =
                      rawData is Map<String, dynamic>
                          ? rawData
                          : <String, dynamic>{};

                      final courseName =
                      (data['courseName'] ?? '')
                          .toString()
                          .trim();

                      final teacher =
                      (data['teacher'] ?? '')
                          .toString()
                          .trim();

                      final duration =
                      (data['duration'] ?? '')
                          .toString()
                          .trim();

                      final rating =
                      (data['rating'] ?? '')
                          .toString()
                          .trim();

                      final image =
                      (data['image'] ?? '')
                          .toString()
                          .trim();

                      return Padding(
                        padding:
                        const EdgeInsets.only(
                          bottom: 13,
                        ),
                        child: _wishlistCard(
                          context: context,
                          documentId:
                          docs[index].id,
                          courseName:
                          courseName,
                          teacher: teacher,
                          duration: duration,
                          rating: rating,
                          image: image,
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 8),

                  // ==================================================
                  // FOOTER
                  // ==================================================

                  _buildFooter(),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  // ============================================================
  // APP BAR
  // ============================================================

  PreferredSizeWidget _buildAppBar(
      BuildContext context,
      ) {
    return AppBar(
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: bg,
      surfaceTintColor: Colors.transparent,

      leading: Padding(
        padding: const EdgeInsets.only(
          left: 12,
          top: 9,
          bottom: 9,
        ),
        child: Material(
          color: panel,
          borderRadius:
          BorderRadius.circular(13),
          child: InkWell(
            borderRadius:
            BorderRadius.circular(13),
            onTap: () {
              Navigator.pop(context);
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius:
                BorderRadius.circular(13),
                border: Border.all(
                  color: border,
                ),
              ),
              child: const Center(
                child: Icon(
                  Icons.arrow_back_rounded,
                  color: textWhite,
                  size: 20,
                ),
              ),
            ),
          ),
        ),
      ),

      titleSpacing: 12,

      title: const Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Text(
            'MY WISHLIST',
            style: TextStyle(
              color: textWhite,
              fontSize: 17,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.0,
            ),
          ),
          SizedBox(height: 2),
          Text(
            'YOUR SAVED LEARNING',
            style: TextStyle(
              color: neonCyan,
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1,
            ),
          ),
        ],
      ),

      actions: [
        Padding(
          padding: const EdgeInsets.only(
            right: 15,
          ),
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: panel,
              borderRadius:
              BorderRadius.circular(12),
              border: Border.all(
                color: border,
              ),
            ),
            child: const Icon(
              Icons.favorite_rounded,
              color: heartRed,
              size: 19,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // PAGE HEADING
  // ============================================================

  Widget _buildPageHeading(int count) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                neonBlue,
                neonPurple,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius:
            BorderRadius.circular(13),
            boxShadow: [
              BoxShadow(
                color: neonBlue.withValues(
                  alpha: 0.22,
                ),
                blurRadius: 15,
              ),
            ],
          ),
          child: const Icon(
            Icons.bookmark_rounded,
            color: Colors.white,
            size: 21,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              const Text(
                'YOUR COLLECTION',
                style: TextStyle(
                  color: textWhite,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.9,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                '$count ${count == 1 ? 'course' : 'courses'} waiting for you',
                style: const TextStyle(
                  color: textMuted,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // HERO
  // ============================================================

  Widget _buildHero(int count) {
    return Container(
      height: 170,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF081A36),
            Color(0xFF11103A),
            Color(0xFF180D35),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius:
        BorderRadius.circular(24),
        border: Border.all(
          color: neonBlue.withValues(
            alpha: 0.35,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: neonBlue.withValues(
              alpha: 0.08,
            ),
            blurRadius: 28,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Stack(
        children: [
          // ------------------------------------------------------
          // GRID-LIKE DECORATION
          // ------------------------------------------------------

          Positioned(
            right: -25,
            top: -35,
            child: Container(
              width: 145,
              height: 145,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: neonPurple.withValues(
                    alpha: 0.13,
                  ),
                  width: 1.2,
                ),
              ),
            ),
          ),

          Positioned(
            right: 5,
            top: -5,
            child: Container(
              width: 85,
              height: 85,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: neonBlue.withValues(
                    alpha: 0.15,
                  ),
                ),
              ),
            ),
          ),

          Positioned(
            right: 18,
            bottom: -35,
            child: Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                borderRadius:
                BorderRadius.circular(30),
                border: Border.all(
                  color: neonCyan.withValues(
                    alpha: 0.08,
                  ),
                ),
              ),
            ),
          ),

          // ------------------------------------------------------
          // GLOW
          // ------------------------------------------------------

          Positioned(
            right: 25,
            top: 30,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: neonPurple.withValues(
                  alpha: 0.10,
                ),
                boxShadow: [
                  BoxShadow(
                    color: neonPurple.withValues(
                      alpha: 0.18,
                    ),
                    blurRadius: 40,
                    spreadRadius: 10,
                  ),
                ],
              ),
            ),
          ),

          // ------------------------------------------------------
          // CONTENT
          // ------------------------------------------------------

          Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    mainAxisAlignment:
                    MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 45,
                            height: 45,
                            decoration: BoxDecoration(
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
                              boxShadow: [
                                BoxShadow(
                                  color:
                                  neonBlue.withValues(
                                    alpha: 0.25,
                                  ),
                                  blurRadius: 16,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons
                                  .favorite_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'FAVOURITE\nCOURSES',
                              style: TextStyle(
                                color: textWhite,
                                fontSize: 17,
                                fontWeight:
                                FontWeight.w900,
                                height: 1.05,
                                letterSpacing: 0.6,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 13),
                      Text(
                        '$count ${count == 1 ? 'course' : 'courses'} saved for your next learning session.',
                        style: const TextStyle(
                          color: textMuted,
                          fontSize: 10.5,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // ------------------------------------------------
                // CYBER HEART
                // ------------------------------------------------

                SizedBox(
                  width: 105,
                  height: 115,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 94,
                        height: 94,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color:
                            neonPurple.withValues(
                              alpha: 0.30,
                            ),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color:
                              neonPurple.withValues(
                                alpha: 0.15,
                              ),
                              blurRadius: 30,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 67,
                        height: 67,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color:
                          heartRed.withValues(
                            alpha: 0.08,
                          ),
                          border: Border.all(
                            color:
                            heartRed.withValues(
                              alpha: 0.38,
                            ),
                          ),
                        ),
                        child: const Icon(
                          Icons
                              .favorite_rounded,
                          color: heartRed,
                          size: 31,
                        ),
                      ),
                      Positioned(
                        bottom: 2,
                        child: Container(
                          padding:
                          const EdgeInsets
                              .symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color:
                            Colors.black
                                .withValues(
                              alpha: 0.25,
                            ),
                            borderRadius:
                            BorderRadius
                                .circular(
                              9,
                            ),
                            border:
                            Border.all(
                              color:
                              border,
                            ),
                          ),
                          child: Text(
                            '$count SAVED',
                            style:
                            const TextStyle(
                              color: neonCyan,
                              fontSize: 8.5,
                              fontWeight:
                              FontWeight.w900,
                              letterSpacing:
                              0.7,
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
        ],
      ),
    );
  }

  // ============================================================
  // STATS
  // ============================================================

  Widget _buildStats(int count) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: panel,
        borderRadius:
        BorderRadius.circular(19),
        border: Border.all(
          color: border,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.25,
            ),
            blurRadius: 20,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _statItem(
              icon: Icons.favorite_rounded,
              title: '$count',
              subtitle: 'SAVED',
              color: heartRed,
            ),
          ),
          _statDivider(),
          Expanded(
            child: _statItem(
              icon: Icons.school_rounded,
              title: 'READY',
              subtitle: 'TO LEARN',
              color: neonBlue,
            ),
          ),
          _statDivider(),
          Expanded(
            child: _statItem(
              icon: Icons.bolt_rounded,
              title: 'ANYTIME',
              subtitle: 'ACCESS',
              color: neonCyan,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withValues(
              alpha: 0.09,
            ),
            borderRadius:
            BorderRadius.circular(11),
            border: Border.all(
              color: color.withValues(
                alpha: 0.22,
              ),
            ),
          ),
          child: Icon(
            icon,
            color: color,
            size: 17,
          ),
        ),
        const SizedBox(height: 7),
        Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: textWhite,
            fontSize: 10.5,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.4,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: TextStyle(
            color: color,
            fontSize: 8,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _statDivider() {
    return Container(
      width: 1,
      height: 48,
      color: border,
    );
  }

  // ============================================================
  // WISHLIST CARD
  // ============================================================

  Widget _wishlistCard({
    required BuildContext context,
    required String documentId,
    required String courseName,
    required String teacher,
    required String duration,
    required String rating,
    required String image,
  }) {
    return Material(
      color: Colors.transparent,
      borderRadius:
      BorderRadius.circular(19),
      child: InkWell(
        borderRadius:
        BorderRadius.circular(19),
        onTap: () {},
        child: Container(
          decoration: BoxDecoration(
            color: panel,
            borderRadius:
            BorderRadius.circular(19),
            border: Border.all(
              color: border,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: 0.22,
                ),
                blurRadius: 15,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: Stack(
            children: [
              // --------------------------------------------------
              // CARD GLOW LINE
              // --------------------------------------------------

              Positioned(
                left: 0,
                top: 15,
                bottom: 15,
                child: Container(
                  width: 3,
                  decoration: BoxDecoration(
                    gradient:
                    const LinearGradient(
                      colors: [
                        neonBlue,
                        neonPurple,
                      ],
                      begin:
                      Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius:
                    BorderRadius.circular(
                      5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color:
                        neonBlue.withValues(
                          alpha: 0.45,
                        ),
                        blurRadius: 9,
                      ),
                    ],
                  ),
                ),
              ),

              Padding(
                padding:
                const EdgeInsets.all(11),
                child: Row(
                  children: [
                    // ==========================================
                    // IMAGE
                    // ==========================================

                    Container(
                      width: 82,
                      height: 82,
                      decoration: BoxDecoration(
                        borderRadius:
                        BorderRadius.circular(
                          15,
                        ),
                        border: Border.all(
                          color:
                          neonBlue.withValues(
                            alpha: 0.22,
                          ),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color:
                            neonBlue.withValues(
                              alpha: 0.08,
                            ),
                            blurRadius: 12,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius:
                        BorderRadius.circular(
                          14,
                        ),
                        child: _courseImage(
                          image,
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    // ==========================================
                    // DETAILS
                    // ==========================================

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Text(
                            courseName.isEmpty
                                ? 'COURSE'
                                : courseName,
                            maxLines: 2,
                            overflow:
                            TextOverflow.ellipsis,
                            style:
                            const TextStyle(
                              color: textWhite,
                              fontSize: 13.5,
                              fontWeight:
                              FontWeight.w800,
                              height: 1.25,
                            ),
                          ),

                          const SizedBox(
                            height: 6,
                          ),

                          if (teacher.isNotEmpty)
                            Row(
                              children: [
                                const Icon(
                                  Icons
                                      .person_outline_rounded,
                                  size: 13,
                                  color:
                                  textMuted,
                                ),
                                const SizedBox(
                                  width: 5,
                                ),
                                Expanded(
                                  child: Text(
                                    teacher,
                                    maxLines: 1,
                                    overflow:
                                    TextOverflow
                                        .ellipsis,
                                    style:
                                    const TextStyle(
                                      color:
                                      textMuted,
                                      fontSize:
                                      9.5,
                                      fontWeight:
                                      FontWeight
                                          .w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                          const SizedBox(
                            height: 7,
                          ),

                          Wrap(
                            spacing: 5,
                            runSpacing: 5,
                            children: [
                              if (duration
                                  .isNotEmpty)
                                _infoChip(
                                  icon: Icons
                                      .schedule_outlined,
                                  text: duration,
                                  color:
                                  neonBlue,
                                ),
                              if (rating.isNotEmpty)
                                _infoChip(
                                  icon: Icons
                                      .star_rounded,
                                  text: rating,
                                  color:
                                  neonOrange,
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 6),

                    // ==========================================
                    // REMOVE
                    // ==========================================

                    Material(
                      color:
                      heartRed.withValues(
                        alpha: 0.08,
                      ),
                      borderRadius:
                      BorderRadius.circular(
                        11,
                      ),
                      child: InkWell(
                        borderRadius:
                        BorderRadius.circular(
                          11,
                        ),
                        onTap: () {
                          _confirmDelete(
                            context,
                            documentId,
                            courseName,
                          );
                        },
                        child: Container(
                          width: 37,
                          height: 37,
                          decoration:
                          BoxDecoration(
                            borderRadius:
                            BorderRadius.circular(
                              11,
                            ),
                            border: Border.all(
                              color: heartRed
                                  .withValues(
                                alpha: 0.28,
                              ),
                            ),
                          ),
                          child:
                          const Center(
                            child: Icon(
                              Icons
                                  .favorite_rounded,
                              color:
                              heartRed,
                              size: 18,
                            ),
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
      padding:
      const EdgeInsets.symmetric(
        horizontal: 6,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(
          alpha: 0.07,
        ),
        borderRadius:
        BorderRadius.circular(7),
        border: Border.all(
          color: color.withValues(
            alpha: 0.16,
          ),
        ),
      ),
      child: Row(
        mainAxisSize:
        MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 10,
            color: color,
          ),
          const SizedBox(width: 3),
          Text(
            text,
            maxLines: 1,
            overflow:
            TextOverflow.ellipsis,
            style: TextStyle(
              color: color,
              fontSize: 8.5,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // COURSE IMAGE
  // ============================================================

  Widget _courseImage(String image) {
    if (image.isEmpty) {
      return _imagePlaceholder();
    }

    if (image.startsWith('assets/')) {
      return Image.asset(
        image,
        width: 82,
        height: 82,
        fit: BoxFit.cover,
        errorBuilder:
            (context, error, stackTrace) {
          return _imagePlaceholder();
        },
      );
    }

    return Image.network(
      image,
      width: 82,
      height: 82,
      fit: BoxFit.cover,
      errorBuilder:
          (context, error, stackTrace) {
        return _imagePlaceholder();
      },
      loadingBuilder:
          (context, child, progress) {
        if (progress == null) {
          return child;
        }

        return Container(
          width: 82,
          height: 82,
          color: bgSecondary,
          child: const Center(
            child: SizedBox(
              width: 19,
              height: 19,
              child:
              CircularProgressIndicator(
                strokeWidth: 2,
                color: neonBlue,
              ),
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // IMAGE PLACEHOLDER
  // ============================================================

  Widget _imagePlaceholder() {
    return Container(
      width: 82,
      height: 82,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF101D38),
            Color(0xFF171438),
          ],
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.menu_book_rounded,
          color: neonBlue,
          size: 28,
        ),
      ),
    );
  }

  // ============================================================
  // FOOTER
  // ============================================================

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: panel,
        borderRadius:
        BorderRadius.circular(16),
        border: Border.all(
          color: neonCyan.withValues(
            alpha: 0.16,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: neonCyan.withValues(
                alpha: 0.08,
              ),
              borderRadius:
              BorderRadius.circular(10),
              border: Border.all(
                color: neonCyan.withValues(
                  alpha: 0.20,
                ),
              ),
            ),
            child: const Icon(
              Icons.bolt_rounded,
              color: neonCyan,
              size: 17,
            ),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Save courses now and start learning whenever you are ready.',
              style: TextStyle(
                color: textMuted,
                fontSize: 9.8,
                fontWeight: FontWeight.w600,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // LOADING
  // ============================================================

  Widget _loadingState() {
    return ListView(
      physics:
      const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        16,
        12,
        16,
        30,
      ),
      children: [
        _loadingBox(
          height: 45,
          radius: 14,
          width: 210,
        ),
        const SizedBox(height: 18),
        _loadingBox(
          height: 170,
          radius: 24,
        ),
        const SizedBox(height: 15),
        _loadingBox(
          height: 91,
          radius: 19,
        ),
        const SizedBox(height: 25),
        _loadingBox(
          height: 26,
          radius: 8,
          width: 180,
        ),
        const SizedBox(height: 14),
        ...List.generate(
          5,
              (index) => Padding(
            padding:
            const EdgeInsets.only(
              bottom: 13,
            ),
            child: _loadingBox(
              height: 108,
              radius: 19,
            ),
          ),
        ),
      ],
    );
  }

  Widget _loadingBox({
    required double height,
    required double radius,
    double? width,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: panel,
        borderRadius:
        BorderRadius.circular(radius),
        border: Border.all(
          color: border,
        ),
      ),
    );
  }

  // ============================================================
  // DELETE CONFIRMATION
  // ============================================================

  Future<void> _confirmDelete(
      BuildContext context,
      String documentId,
      String courseName,
      ) async {
    final shouldDelete =
    await showModalBottomSheet<bool>(
      context: context,
      backgroundColor:
      Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return Container(
          padding:
          const EdgeInsets.fromLTRB(
            20,
            10,
            20,
            25,
          ),
          decoration: const BoxDecoration(
            color: bgSecondary,
            borderRadius:
            BorderRadius.vertical(
              top: Radius.circular(28),
            ),
            border: Border(
              top: BorderSide(
                color: border,
              ),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize:
              MainAxisSize.min,
              children: [
                // ----------------------------------------------
                // HANDLE
                // ----------------------------------------------

                Container(
                  width: 45,
                  height: 4,
                  decoration: BoxDecoration(
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
                ),

                const SizedBox(height: 24),

                // ----------------------------------------------
                // ICON
                // ----------------------------------------------

                Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    color:
                    heartRed.withValues(
                      alpha: 0.08,
                    ),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color:
                      heartRed.withValues(
                        alpha: 0.30,
                      ),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color:
                        heartRed.withValues(
                          alpha: 0.12,
                        ),
                        blurRadius: 25,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons
                        .favorite_border_rounded,
                    color: heartRed,
                    size: 31,
                  ),
                ),

                const SizedBox(height: 16),

                const Text(
                  'REMOVE FROM WISHLIST?',
                  textAlign:
                  TextAlign.center,
                  style: TextStyle(
                    color: textWhite,
                    fontSize: 17,
                    fontWeight:
                    FontWeight.w900,
                    letterSpacing: 0.7,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  courseName.isEmpty
                      ? 'Do you want to remove this course from your saved courses?'
                      : 'Remove "$courseName" from your saved courses?',
                  textAlign:
                  TextAlign.center,
                  style: const TextStyle(
                    color: textMuted,
                    fontSize: 11.5,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 23),

                // ----------------------------------------------
                // BUTTONS
                // ----------------------------------------------

                Row(
                  children: [
                    Expanded(
                      child:
                      OutlinedButton(
                        onPressed: () {
                          Navigator.pop(
                            sheetContext,
                            false,
                          );
                        },
                        style:
                        OutlinedButton.styleFrom(
                          foregroundColor:
                          textWhite,
                          side:
                          const BorderSide(
                            color: border,
                          ),
                          backgroundColor:
                          panel,
                          minimumSize:
                          const Size(
                            0,
                            51,
                          ),
                          shape:
                          RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius
                                .circular(
                              14,
                            ),
                          ),
                        ),
                        child:
                        const Text(
                          'CANCEL',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight:
                            FontWeight.w800,
                            letterSpacing:
                            0.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 11,
                    ),
                    Expanded(
                      child:
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(
                            sheetContext,
                            true,
                          );
                        },
                        style:
                        ElevatedButton.styleFrom(
                          backgroundColor:
                          heartRed,
                          foregroundColor:
                          Colors.white,
                          elevation: 0,
                          minimumSize:
                          const Size(
                            0,
                            51,
                          ),
                          shape:
                          RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius
                                .circular(
                              14,
                            ),
                          ),
                        ),
                        child:
                        const Text(
                          'REMOVE',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight:
                            FontWeight.w900,
                            letterSpacing:
                            0.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    if (shouldDelete != true) {
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('wishlist')
          .doc(documentId)
          .delete();

      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            behavior:
            SnackBarBehavior.floating,
            margin:
            const EdgeInsets.fromLTRB(
              16,
              0,
              16,
              18,
            ),
            backgroundColor: panel,
            shape:
            RoundedRectangleBorder(
              borderRadius:
              BorderRadius.circular(
                13,
              ),
              side: const BorderSide(
                color: neonGreen,
              ),
            ),
            content: const Row(
              children: [
                Icon(
                  Icons
                      .check_circle_rounded,
                  color: neonGreen,
                  size: 19,
                ),
                SizedBox(width: 9),
                Expanded(
                  child: Text(
                    'Course removed from Wishlist',
                    style: TextStyle(
                      color: textWhite,
                      fontSize: 11,
                      fontWeight:
                      FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
    } catch (e) {
      debugPrint(
        'WISHLIST DELETE ERROR: $e',
      );

      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            behavior:
            SnackBarBehavior.floating,
            backgroundColor: panel,
            content: const Text(
              'Unable to remove course. Please try again.',
              style: TextStyle(
                color: textWhite,
              ),
            ),
          ),
        );
    }
  }

  // ============================================================
  // GLOW CIRCLE
  // ============================================================

  Widget _glowCircle({
    required double size,
    required Color color,
    required double opacity,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(
          alpha: opacity,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(
              alpha: opacity,
            ),
            blurRadius: 70,
            spreadRadius: 20,
          ),
        ],
      ),
    );
  }
}

// ================================================================
// EMPTY / ERROR STATE
// ================================================================

class _EmptyWishlistState
    extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isError;

  const _EmptyWishlistState({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.isError = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color accent = isError
        ? WishlistScreen.neonOrange
        : WishlistScreen.neonPurple;

    return Stack(
      children: [
        Positioned(
          top: -100,
          right: -80,
          child: Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: accent.withValues(
                alpha: 0.06,
              ),
              boxShadow: [
                BoxShadow(
                  color: accent.withValues(
                    alpha: 0.10,
                  ),
                  blurRadius: 70,
                  spreadRadius: 10,
                ),
              ],
            ),
          ),
        ),
        Positioned(
          bottom: -100,
          left: -90,
          child: Container(
            width: 210,
            height: 210,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color:
              WishlistScreen.neonBlue
                  .withValues(
                alpha: 0.045,
              ),
            ),
          ),
        ),
        Center(
          child: SingleChildScrollView(
            padding:
            const EdgeInsets.all(30),
            child: Column(
              mainAxisAlignment:
              MainAxisAlignment.center,
              children: [
                // ------------------------------------------------
                // ICON
                // ------------------------------------------------

                Container(
                  width: 112,
                  height: 112,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: accent.withValues(
                      alpha: 0.07,
                    ),
                    border: Border.all(
                      color: accent.withValues(
                        alpha: 0.28,
                      ),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: accent.withValues(
                          alpha: 0.12,
                        ),
                        blurRadius: 30,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration:
                      BoxDecoration(
                        shape: BoxShape.circle,
                        color:
                        WishlistScreen
                            .panel,
                        border: Border.all(
                          color:
                          accent.withValues(
                            alpha: 0.20,
                          ),
                        ),
                      ),
                      child: Icon(
                        icon,
                        color: accent,
                        size: 37,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                Text(
                  title.toUpperCase(),
                  textAlign:
                  TextAlign.center,
                  style: const TextStyle(
                    color:
                    WishlistScreen
                        .textWhite,
                    fontSize: 20,
                    fontWeight:
                    FontWeight.w900,
                    letterSpacing: 0.8,
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  subtitle,
                  textAlign:
                  TextAlign.center,
                  style: const TextStyle(
                    color:
                    WishlistScreen
                        .textMuted,
                    fontSize: 12,
                    height: 1.55,
                  ),
                ),

                const SizedBox(height: 22),

                Container(
                  padding:
                  const EdgeInsets
                      .symmetric(
                    horizontal: 14,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: accent.withValues(
                      alpha: 0.07,
                    ),
                    borderRadius:
                    BorderRadius.circular(
                      20,
                    ),
                    border: Border.all(
                      color: accent
                          .withValues(
                        alpha: 0.20,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisSize:
                    MainAxisSize.min,
                    children: [
                      Icon(
                        isError
                            ? Icons
                            .refresh_rounded
                            : Icons
                            .favorite_border_rounded,
                        size: 14,
                        color: accent,
                      ),
                      const SizedBox(
                        width: 6,
                      ),
                      Text(
                        isError
                            ? 'PLEASE TRY AGAIN'
                            : 'EXPLORE COURSES TO SAVE',
                        style: TextStyle(
                          color: accent,
                          fontSize: 9,
                          fontWeight:
                          FontWeight.w800,
                          letterSpacing:
                          0.6,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}