import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'video_player_screen.dart';

class CourseVideosScreen extends StatelessWidget {
final String courseName;

const CourseVideosScreen({
super.key,
required this.courseName,
});

// ============================================================
// CYBER-TECH COLORS
// ============================================================

static const Color bg = Color(0xFF050816);
static const Color panel = Color(0xFF0A1020);
static const Color panel2 = Color(0xFF0E172B);

static const Color blue = Color(0xFF00B7FF);
static const Color purple = Color(0xFF8B5CF6);
static const Color cyan = Color(0xFF00F5D4);
static const Color green = Color(0xFF39FF88);
static const Color orange = Color(0xFFFF8A00);

static const Color white = Color(0xFFF4F8FF);
static const Color muted = Color(0xFF8B9BB8);
static const Color border = Color(0xFF172B4D);

// ============================================================
// BUILD
// ============================================================

@override
Widget build(BuildContext context) {
final searchCourse = courseName.trim().toLowerCase();

return Scaffold(
backgroundColor: bg,
body: SafeArea(
bottom: false,
child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
stream: FirebaseFirestore.instance
.collection('videos')
.where(
'courseName',
isEqualTo: searchCourse,
)
.snapshots(),
builder: (context, snapshot) {
// ----------------------------------------------------
// LOADING
// ----------------------------------------------------

if (snapshot.connectionState ==
ConnectionState.waiting) {
return _loadingState();
}

// ----------------------------------------------------
// ERROR
// ----------------------------------------------------

if (snapshot.hasError) {
return _errorState(
context,
'Unable to load lessons',
'Something went wrong while loading the course videos.',
);
}

// ----------------------------------------------------
// EMPTY
// ----------------------------------------------------

if (!snapshot.hasData ||
snapshot.data!.docs.isEmpty) {
return _emptyState(
context,
'No Lessons Yet',
'Video lessons for this course will appear here once they are added.',
);
}

  final videos = snapshot.data!.docs.toList()
    ..sort((a, b) {
      final oa = (a.data()['order'] as num?) ?? 0;
      final ob = (b.data()['order'] as num?) ?? 0;
      return oa.compareTo(ob);
    });

return CustomScrollView(
physics: const BouncingScrollPhysics(),
slivers: [
// ==================================================
// TOP BAR
// ==================================================

SliverToBoxAdapter(
child: _buildTopBar(context),
),

// ==================================================
// HERO
// ==================================================

SliverToBoxAdapter(
child: Padding(
padding: const EdgeInsets.fromLTRB(
16,
8,
16,
0,
),
child: _buildCourseHero(
videos.length,
),
),
),

// ==================================================
// QUICK STATS
// ==================================================

SliverToBoxAdapter(
child: Padding(
padding: const EdgeInsets.fromLTRB(
16,
14,
16,
0,
),
child: _buildQuickStats(
videos.length,
),
),
),

// ==================================================
// LESSON HEADER
// ==================================================

SliverToBoxAdapter(
child: Padding(
padding: const EdgeInsets.fromLTRB(
18,
28,
18,
14,
),
child: _buildSectionHeader(
videos.length,
),
),
),

// ==================================================
// VIDEO LIST
// ==================================================

SliverPadding(
padding: const EdgeInsets.fromLTRB(
16,
0,
16,
25,
),
sliver: SliverList(
delegate: SliverChildBuilderDelegate(
(context, index) {
final data =
videos[index].data();

final title =
(data['title'] ?? '')
.toString()
.trim();

final duration =
(data['duration'] ?? '')
.toString()
.trim();

final videoUrl =
(data['videoUrl'] ?? '')
.toString()
.trim();

return Padding(
padding:
const EdgeInsets.only(
bottom: 13,
),
child: _videoCard(
context: context,
index: index,
title: title,
duration: duration,
videoUrl: videoUrl,
totalVideos: videos.length,
),
);
},
childCount: videos.length,
),
),
),

// ==================================================
// BOTTOM MESSAGE
// ==================================================

SliverToBoxAdapter(
child: Padding(
padding: const EdgeInsets.fromLTRB(
16,
0,
16,
110,
),
child: _buildLearningTip(),
),
),
],
);
},
),
),

// ==========================================================
// BOTTOM CYBER BAR
// ==========================================================

);
}

// ============================================================
// TOP BAR
// ============================================================

Widget _buildTopBar(BuildContext context) {
return Container(
height: 76,
padding: const EdgeInsets.fromLTRB(
16,
8,
16,
8,
),
decoration: BoxDecoration(
color: bg.withValues(alpha: 0.96),
border: const Border(
bottom: BorderSide(
color: border,
),
),
boxShadow: [
BoxShadow(
color: blue.withValues(
alpha: 0.045,
),
blurRadius: 20,
),
],
),
child: Row(
children: [
_topButton(
icon: Icons.arrow_back_rounded,
onTap: () {
Navigator.pop(context);
},
),
const SizedBox(width: 13),
Expanded(
child: Column(
mainAxisAlignment:
MainAxisAlignment.center,
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
const Text(
'COURSE VIDEOS',
style: TextStyle(
color: white,
fontSize: 15,
fontWeight: FontWeight.w900,
letterSpacing: 1,
),
),
const SizedBox(height: 3),
Text(
'Learn at your own pace',
maxLines: 1,
overflow:
TextOverflow.ellipsis,
style: const TextStyle(
color: muted,
fontSize: 9.5,
fontWeight: FontWeight.w600,
),
),
],
),
),
_topButton(
icon: Icons.more_horiz_rounded,
onTap: () {
_showMessage(
context,
'More course options coming soon.',
);
},
),
],
),
);
}

Widget _topButton({
required IconData icon,
required VoidCallback onTap,
}) {
return Material(
color: panel,
borderRadius:
BorderRadius.circular(14),
child: InkWell(
onTap: onTap,
borderRadius:
BorderRadius.circular(14),
child: Container(
width: 43,
height: 43,
decoration: BoxDecoration(
borderRadius:
BorderRadius.circular(14),
border: Border.all(
color: blue.withValues(
alpha: 0.28,
),
),
boxShadow: [
BoxShadow(
color: blue.withValues(
alpha: 0.06,
),
blurRadius: 13,
),
],
),
child: Icon(
icon,
color: white,
size: 20,
),
),
),
);
}

// ============================================================
// COURSE HERO
// ============================================================

Widget _buildCourseHero(
int totalVideos,
) {
return Container(
width: double.infinity,
padding: const EdgeInsets.all(20),
decoration: BoxDecoration(
gradient: const LinearGradient(
begin: Alignment.topLeft,
end: Alignment.bottomRight,
colors: [
Color(0xFF071B35),
Color(0xFF0A1740),
Color(0xFF150A35),
],
),
borderRadius:
BorderRadius.circular(24),
border: Border.all(
color: blue.withValues(
alpha: 0.35,
),
),
boxShadow: [
BoxShadow(
color: blue.withValues(
alpha: 0.09,
),
blurRadius: 28,
spreadRadius: 1,
),
BoxShadow(
color: purple.withValues(
alpha: 0.07,
),
blurRadius: 35,
),
],
),
child: Stack(
children: [
// Decorative glow
Positioned(
right: -65,
top: -70,
child: Container(
width: 190,
height: 190,
decoration:
BoxDecoration(
shape: BoxShape.circle,
boxShadow: [
BoxShadow(
color: blue.withValues(
alpha: 0.15,
),
blurRadius: 85,
spreadRadius: 15,
),
],
),
),
),

Positioned(
left: -55,
bottom: -85,
child: Container(
width: 180,
height: 180,
decoration:
BoxDecoration(
shape: BoxShape.circle,
boxShadow: [
BoxShadow(
color: purple.withValues(
alpha: 0.13,
),
blurRadius: 90,
spreadRadius: 15,
),
],
),
),
),

Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
Row(
children: [
Container(
width: 58,
height: 58,
decoration:
BoxDecoration(
gradient:
const LinearGradient(
colors: [
blue,
purple,
],
),
borderRadius:
BorderRadius.circular(
17,
),
boxShadow: [
BoxShadow(
color: blue.withValues(
alpha: 0.25,
),
blurRadius: 20,
),
],
),
child:
const Icon(
Icons.play_arrow_rounded,
color: Colors.white,
size: 34,
),
),
const SizedBox(width: 13),
Expanded(
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
_smallBadge(
Icons.auto_awesome_rounded,
'MMOC TEACH',
cyan,
),
const SizedBox(height: 7),
const Text(
'Video Learning',
style: TextStyle(
color: white,
fontSize: 18,
fontWeight:
FontWeight.w900,
),
),
],
),
),
],
),

const SizedBox(height: 20),

Text(
courseName,
maxLines: 2,
overflow:
TextOverflow.ellipsis,
style: const TextStyle(
color: white,
fontSize: 16,
fontWeight:
FontWeight.w800,
height: 1.3,
),
),

const SizedBox(height: 7),

const Text(
'Watch lessons, practice concepts and keep moving forward.',
style: TextStyle(
color: muted,
fontSize: 10.5,
height: 1.45,
),
),

const SizedBox(height: 18),

Row(
children: [
_heroStat(
Icons.video_library_rounded,
'$totalVideos Lessons',
blue,
),
const SizedBox(width: 8),
_heroStat(
Icons.hd_rounded,
'HD Videos',
cyan,
),
const SizedBox(width: 8),
_heroStat(
Icons.rocket_launch_rounded,
'Learn',
green,
),
],
),
],
),
],
),
);
}

Widget _smallBadge(
IconData icon,
String text,
Color color,
) {
return Container(
padding:
const EdgeInsets.symmetric(
horizontal: 8,
vertical: 5,
),
decoration: BoxDecoration(
color: color.withValues(
alpha: 0.08,
),
borderRadius:
BorderRadius.circular(20),
border: Border.all(
color: color.withValues(
alpha: 0.30,
),
),
),
child: Row(
mainAxisSize:
MainAxisSize.min,
children: [
Icon(
icon,
color: color,
size: 11,
),
const SizedBox(width: 4),
Text(
text,
style: TextStyle(
color: color,
fontSize: 7.5,
fontWeight:
FontWeight.w900,
letterSpacing: 0.7,
),
),
],
),
);
}

Widget _heroStat(
IconData icon,
String text,
Color color,
) {
return Expanded(
child: Container(
padding:
const EdgeInsets.symmetric(
horizontal: 8,
vertical: 9,
),
decoration: BoxDecoration(
color: color.withValues(
alpha: 0.065,
),
borderRadius:
BorderRadius.circular(12),
border: Border.all(
color: color.withValues(
alpha: 0.18,
),
),
),
child: Row(
mainAxisAlignment:
MainAxisAlignment.center,
children: [
Icon(
icon,
color: color,
size: 13,
),
const SizedBox(width: 4),
Flexible(
child: Text(
text,
maxLines: 1,
overflow:
TextOverflow.ellipsis,
style: TextStyle(
color: color,
fontSize: 8.5,
fontWeight:
FontWeight.w800,
),
),
),
],
),
),
);
}

// ============================================================
// QUICK STATS
// ============================================================

Widget _buildQuickStats(
int totalVideos,
) {
return Container(
padding: const EdgeInsets.all(14),
decoration: BoxDecoration(
color: panel,
borderRadius:
BorderRadius.circular(18),
border: Border.all(
color: border,
),
),
child: Row(
children: [
Expanded(
child: _statItem(
Icons.video_library_outlined,
'$totalVideos',
'LESSONS',
blue,
),
),
_divider(),
Expanded(
child: _statItem(
Icons.play_circle_outline_rounded,
'HD',
'QUALITY',
cyan,
),
),
_divider(),
Expanded(
child: _statItem(
Icons.school_outlined,
'100%',
'LEARNING',
purple,
),
),
],
),
);
}

Widget _statItem(
IconData icon,
String value,
String label,
Color color,
) {
return Column(
children: [
Container(
width: 38,
height: 38,
decoration: BoxDecoration(
color: color.withValues(
alpha: 0.08,
),
shape: BoxShape.circle,
border: Border.all(
color: color.withValues(
alpha: 0.18,
),
),
),
child: Icon(
icon,
color: color,
size: 18,
),
),
const SizedBox(height: 7),
Text(
value,
style: const TextStyle(
color: white,
fontSize: 12,
fontWeight: FontWeight.w900,
),
),
const SizedBox(height: 2),
Text(
label,
style: const TextStyle(
color: muted,
fontSize: 7.5,
fontWeight: FontWeight.w800,
letterSpacing: 0.7,
),
),
],
);
}

Widget _divider() {
return Container(
width: 1,
height: 50,
color: border,
);
}

// ============================================================
// SECTION HEADER
// ============================================================

Widget _buildSectionHeader(
int totalVideos,
) {
return Row(
children: [
Expanded(
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
const Text(
'COURSE LESSONS',
style: TextStyle(
color: white,
fontSize: 13,
fontWeight: FontWeight.w900,
letterSpacing: 1.1,
),
),
const SizedBox(height: 4),
const Text(
'Start from the first lesson',
style: TextStyle(
color: muted,
fontSize: 9.5,
fontWeight: FontWeight.w600,
),
),
],
),
),
Container(
padding:
const EdgeInsets.symmetric(
horizontal: 10,
vertical: 7,
),
decoration: BoxDecoration(
color: blue.withValues(
alpha: 0.07,
),
borderRadius:
BorderRadius.circular(20),
border: Border.all(
color: blue.withValues(
alpha: 0.25,
),
),
),
child: Row(
mainAxisSize:
MainAxisSize.min,
children: [
const Icon(
Icons.video_library_rounded,
color: blue,
size: 13,
),
const SizedBox(width: 5),
Text(
'$totalVideos',
style:
const TextStyle(
color: blue,
fontSize: 10,
fontWeight:
FontWeight.w900,
),
),
],
),
),
],
);
}

// ============================================================
// VIDEO CARD
// ============================================================

Widget _videoCard({
required BuildContext context,
required int index,
required String title,
required String duration,
required String videoUrl,
required int totalVideos,
}) {
final hasVideo =
videoUrl.isNotEmpty;

return Material(
color: panel,
borderRadius:
BorderRadius.circular(20),
child: InkWell(
onTap: () {
if (!hasVideo) {
_showMessage(
context,
'This video is not available yet.',
isError: true,
);
return;
}

Navigator.push(
context,
MaterialPageRoute(
builder: (_) =>
VideoPlayerScreen(
videoUrl: videoUrl,
courseTitle: courseName,
videoIndex: index,
totalVideos: totalVideos,
),
),
);
},
borderRadius:
BorderRadius.circular(20),
child: Container(
padding:
const EdgeInsets.all(12),
decoration: BoxDecoration(
borderRadius:
BorderRadius.circular(20),
border: Border.all(
color: hasVideo
? border
: const Color(0xFF202B40),
),
boxShadow: [
BoxShadow(
color: blue.withValues(
alpha: 0.025,
),
blurRadius: 18,
),
],
),
child: Row(
children: [
// --------------------------------------------------
// THUMBNAIL
// --------------------------------------------------

Stack(
children: [
Container(
width: 78,
height: 78,
decoration:
BoxDecoration(
gradient:
LinearGradient(
begin:
Alignment.topLeft,
end:
Alignment.bottomRight,
colors: hasVideo
? const [
Color(
0xFF06345C,
),
Color(
0xFF371477,
),
]
: const [
Color(
0xFF111A2B,
),
Color(
0xFF172238,
),
],
),
borderRadius:
BorderRadius.circular(
17,
),
border: Border.all(
color: hasVideo
? blue.withValues(
alpha: 0.28,
)
: border,
),
boxShadow:
hasVideo
? [
BoxShadow(
color: blue
.withValues(
alpha: 0.10,
),
blurRadius:
15,
),
]
: null,
),
child: Center(
child: Icon(
hasVideo
? Icons
.play_circle_fill_rounded
: Icons
.lock_outline_rounded,
color: hasVideo
? cyan
: muted,
size: 35,
),
),
),

// Lesson number
Positioned(
top: 6,
left: 6,
child: Container(
padding:
const EdgeInsets
.symmetric(
horizontal: 6,
vertical: 3,
),
decoration:
BoxDecoration(
color: Colors.black
.withValues(
alpha: 0.45,
),
borderRadius:
BorderRadius
.circular(
7,
),
),
child: Text(
'${index + 1}',
style:
const TextStyle(
color: white,
fontSize: 8,
fontWeight:
FontWeight.w900,
),
),
),
),

// Status dot
Positioned(
right: 7,
bottom: 7,
child: Container(
width: 8,
height: 8,
decoration:
BoxDecoration(
color: hasVideo
? green
: orange,
shape:
BoxShape.circle,
boxShadow: [
BoxShadow(
color: (hasVideo
? green
: orange)
.withValues(
alpha: 0.55,
),
blurRadius: 7,
),
],
),
),
),
],
),

const SizedBox(width: 13),

// --------------------------------------------------
// LESSON INFO
// --------------------------------------------------

Expanded(
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
Text(
title.isEmpty
? 'Untitled Lesson'
: title,
maxLines: 2,
overflow:
TextOverflow.ellipsis,
style:
const TextStyle(
color: white,
fontSize: 13,
fontWeight:
FontWeight.w800,
height: 1.3,
),
),

const SizedBox(height: 9),

Row(
children: [
Container(
padding:
const EdgeInsets
.symmetric(
horizontal: 7,
vertical: 4,
),
decoration:
BoxDecoration(
color: hasVideo
? cyan.withValues(
alpha:
0.07,
)
: orange.withValues(
alpha:
0.07,
),
borderRadius:
BorderRadius
.circular(
7,
),
border: Border.all(
color: (hasVideo
? cyan
: orange)
.withValues(
alpha: 0.18,
),
),
),
child: Row(
mainAxisSize:
MainAxisSize
.min,
children: [
Icon(
hasVideo
? Icons
.play_arrow_rounded
: Icons
.lock_outline_rounded,
size: 11,
color: hasVideo
? cyan
: orange,
),
const SizedBox(
width: 3,
),
Text(
hasVideo
? 'WATCH'
: 'LOCKED',
style:
TextStyle(
color: hasVideo
? cyan
: orange,
fontSize: 7.5,
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

const SizedBox(width: 7),

Flexible(
child: Row(
children: [
const Icon(
Icons
.schedule_outlined,
color: muted,
size: 13,
),
const SizedBox(
width: 4,
),
Flexible(
child: Text(
duration.isEmpty
? 'Video lesson'
: duration,
maxLines: 1,
overflow:
TextOverflow
.ellipsis,
style:
const TextStyle(
color: muted,
fontSize: 9,
fontWeight:
FontWeight
.w600,
),
),
),
],
),
),
],
),
],
),
),

const SizedBox(width: 8),

// --------------------------------------------------
// ACTION
// --------------------------------------------------

Container(
width: 36,
height: 36,
decoration:
BoxDecoration(
color: hasVideo
? blue.withValues(
alpha: 0.08,
)
: Colors.white
.withValues(
alpha: 0.025,
),
shape:
BoxShape.circle,
border: Border.all(
color: hasVideo
? blue.withValues(
alpha: 0.20,
)
: border,
),
),
child: Icon(
hasVideo
? Icons
.arrow_forward_ios_rounded
: Icons
.lock_outline_rounded,
color: hasVideo
? blue
: muted,
size: 13,
),
),
],
),
),
),
);
}
  // ============================================================
  // LEARNING TIP
  // ============================================================

  Widget _buildLearningTip() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: panel,
        borderRadius:
        BorderRadius.circular(18),
        border: Border.all(
          color: purple.withValues(
            alpha: 0.20,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: purple.withValues(
              alpha: 0.035,
            ),
            blurRadius: 20,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: purple.withValues(
                alpha: 0.08,
              ),
              shape: BoxShape.circle,
              border: Border.all(
                color: purple.withValues(
                  alpha: 0.22,
                ),
              ),
            ),
            child: const Icon(
              Icons.lightbulb_outline_rounded,
              color: purple,
              size: 19,
            ),
          ),
          const SizedBox(width: 11),
          const Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  'LEARNING TIP',
                  style: TextStyle(
                    color: purple,
                    fontSize: 8,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.9,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Complete lessons in order and practice what you learn after every video.',
                  style: TextStyle(
                    color: muted,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
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
  // BOTTOM INFO
  // ============================================================

  Widget _buildBottomInfo() {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        18,
        10,
        18,
        16,
      ),
      decoration: BoxDecoration(
        color: const Color(0xF8050816),
        border: const Border(
          top: BorderSide(
            color: border,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: blue.withValues(
              alpha: 0.06,
            ),
            blurRadius: 25,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 31,
            height: 31,
            decoration: BoxDecoration(
              color: green.withValues(
                alpha: 0.08,
              ),
              shape: BoxShape.circle,
              border: Border.all(
                color: green.withValues(
                  alpha: 0.20,
                ),
              ),
            ),
            child: const Icon(
              Icons.verified_rounded,
              color: green,
              size: 16,
            ),
          ),
          const SizedBox(width: 9),
          const Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  'MMOC TEACH',
                  style: TextStyle(
                    color: white,
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.7,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Keep learning. Keep growing.',
                  style: TextStyle(
                    color: muted,
                    fontSize: 8,
                    fontWeight: FontWeight.w600,
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
              color: blue.withValues(
                alpha: 0.06,
              ),
              borderRadius:
              BorderRadius.circular(20),
              border: Border.all(
                color: blue.withValues(
                  alpha: 0.18,
                ),
              ),
            ),
            child: const Row(
              mainAxisSize:
              MainAxisSize.min,
              children: [
                Icon(
                  Icons.play_arrow_rounded,
                  color: blue,
                  size: 12,
                ),
                SizedBox(width: 4),
                Text(
                  'LEARN',
                  style: TextStyle(
                    color: blue,
                    fontSize: 7.5,
                    fontWeight:
                    FontWeight.w900,
                    letterSpacing: 0.6,
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
  // LOADING STATE
  // ============================================================

  Widget _loadingState() {
    return Column(
      children: [
        _buildLoadingTopBar(),
        Expanded(
          child: ListView(
            physics:
            const NeverScrollableScrollPhysics(),
            padding:
            const EdgeInsets.all(16),
            children: [
              _loadingBox(
                height: 245,
                radius: 24,
              ),
              const SizedBox(height: 14),
              _loadingBox(
                height: 105,
                radius: 18,
              ),
              const SizedBox(height: 25),
              _loadingBox(
                height: 20,
                width: 150,
                radius: 7,
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
                    height: 103,
                    radius: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingTopBar() {
    return Container(
      height: 76,
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 10,
      ),
      decoration: const BoxDecoration(
        color: bg,
        border: Border(
          bottom: BorderSide(
            color: border,
          ),
        ),
      ),
      child: Row(
        children: [
          _loadingBox(
            width: 43,
            height: 43,
            radius: 14,
          ),
          const SizedBox(width: 13),
          Column(
            mainAxisAlignment:
            MainAxisAlignment.center,
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              _loadingBox(
                width: 125,
                height: 13,
                radius: 5,
              ),
              const SizedBox(height: 6),
              _loadingBox(
                width: 100,
                height: 8,
                radius: 4,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // LOADING BOX
  // ============================================================

  Widget _loadingBox({
    required double height,
    required double radius,
    double? width,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: panel2,
        borderRadius:
        BorderRadius.circular(radius),
        border: Border.all(
          color: border,
        ),
      ),
    );
  }

  // ============================================================
  // EMPTY STATE
  // ============================================================

  Widget _emptyState(
      BuildContext context,
      String title,
      String subtitle,
      ) {
    return Column(
      children: [
        _buildTopBar(context),
        Expanded(
          child: Center(
            child: SingleChildScrollView(
              padding:
              const EdgeInsets.all(28),
              child: Column(
                mainAxisAlignment:
                MainAxisAlignment.center,
                children: [
                  _stateIcon(
                    Icons
                        .video_library_outlined,
                    blue,
                  ),
                  const SizedBox(height: 22),
                  Text(
                    title,
                    textAlign:
                    TextAlign.center,
                    style:
                    const TextStyle(
                      color: white,
                      fontSize: 21,
                      fontWeight:
                      FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 9),
                  Text(
                    subtitle,
                    textAlign:
                    TextAlign.center,
                    style:
                    const TextStyle(
                      color: muted,
                      fontSize: 11.5,
                      height: 1.55,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _statusPill(
                    Icons.info_outline_rounded,
                    'Please check again later',
                    blue,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // ERROR STATE
  // ============================================================

  Widget _errorState(
      BuildContext context,
      String title,
      String subtitle,
      ) {
    return Column(
      children: [
        _buildTopBar(context),
        Expanded(
          child: Center(
            child: SingleChildScrollView(
              padding:
              const EdgeInsets.all(28),
              child: Column(
                mainAxisAlignment:
                MainAxisAlignment.center,
                children: [
                  _stateIcon(
                    Icons.error_outline_rounded,
                    const Color(0xFFFF3D6E),
                  ),
                  const SizedBox(height: 22),
                  Text(
                    title,
                    textAlign:
                    TextAlign.center,
                    style:
                    const TextStyle(
                      color: white,
                      fontSize: 21,
                      fontWeight:
                      FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 9),
                  Text(
                    subtitle,
                    textAlign:
                    TextAlign.center,
                    style:
                    const TextStyle(
                      color: muted,
                      fontSize: 11.5,
                      height: 1.55,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _statusPill(
                    Icons.wifi_off_rounded,
                    'Please try again later',
                    const Color(0xFFFF3D6E),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // STATE ICON
  // ============================================================

  Widget _stateIcon(
      IconData icon,
      Color color,
      ) {
    return Container(
      width: 105,
      height: 105,
      decoration: BoxDecoration(
        color: color.withValues(
          alpha: 0.06,
        ),
        shape: BoxShape.circle,
        border: Border.all(
          color: color.withValues(
            alpha: 0.20,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(
              alpha: 0.10,
            ),
            blurRadius: 35,
          ),
        ],
      ),
      child: Icon(
        icon,
        color: color,
        size: 46,
      ),
    );
  }

  // ============================================================
  // STATUS PILL
  // ============================================================

  Widget _statusPill(
      IconData icon,
      String text,
      Color color,
      ) {
    return Container(
      padding:
      const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 9,
      ),
      decoration: BoxDecoration(
        color: color.withValues(
          alpha: 0.06,
        ),
        borderRadius:
        BorderRadius.circular(20),
        border: Border.all(
          color: color.withValues(
            alpha: 0.20,
          ),
        ),
      ),
      child: Row(
        mainAxisSize:
        MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 9.5,
              fontWeight:
              FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SNACKBAR
  // ============================================================

  void _showMessage(
      BuildContext context,
      String message, {
        bool isError = false,
      }) {
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
          shape:
          RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(15),
          ),
          backgroundColor: isError
              ? const Color(0xFFD92D55)
              : const Color(0xFF0B8F70),
          duration:
          const Duration(seconds: 2),
          content: Row(
            children: [
              Icon(
                isError
                    ? Icons
                    .error_outline_rounded
                    : Icons
                    .check_circle_outline_rounded,
                color: Colors.white,
                size: 19,
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  message,
                  style:
                  const TextStyle(
                    color: Colors.white,
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
  }
}