import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class NotificationScreen extends StatelessWidget {
const NotificationScreen({super.key});

// ============================================================
// CYBER-TECH THEME
// ============================================================

static const Color bg = Color(0xff050814);
static const Color panel = Color(0xff0A1020);
static const Color panel2 = Color(0xff0D1427);

static const Color neonBlue = Color(0xff00A8FF);
static const Color neonCyan = Color(0xff00E5FF);
static const Color neonPurple = Color(0xff8B5CFF);
static const Color neonGreen = Color(0xff00E676);
static const Color neonOrange = Color(0xffff9d00);
static const Color neonRed = Color(0xffff4567);

static const Color textPrimary = Color(0xffF4F8FF);
static const Color textSecondary = Color(0xff8D9AB5);
static const Color border = Color(0xff1A2945);

// ============================================================
// DATE FORMAT
// ============================================================

String formatDate(Timestamp? timestamp) {
if (timestamp == null) return '';

final date = timestamp.toDate();
final now = DateTime.now();

final difference = now.difference(date);

if (difference.inSeconds < 60) {
return 'JUST NOW';
}

if (difference.inMinutes < 60) {
final minutes = difference.inMinutes;
return '$minutes ${minutes == 1 ? 'MINUTE' : 'MINUTES'} AGO';
}

if (difference.inHours < 24) {
final hours = difference.inHours;
return '$hours ${hours == 1 ? 'HOUR' : 'HOURS'} AGO';
}

if (difference.inDays == 1) {
return 'YESTERDAY';
}

if (difference.inDays < 7) {
return '${difference.inDays} DAYS AGO';
}

final hour =
date.hour % 12 == 0 ? 12 : date.hour % 12;

final minute =
date.minute.toString().padLeft(2, '0');

final period =
date.hour >= 12 ? 'PM' : 'AM';

return '${date.day.toString().padLeft(2, '0')}/'
'${date.month.toString().padLeft(2, '0')}/'
'${date.year} '
'$hour:$minute $period';
}

// ============================================================
// NOTIFICATION STYLE
// ============================================================

Map<String, dynamic> getNotificationStyle(
Map<String, dynamic> data,
) {
final title =
(data['title'] ?? '').toString().toLowerCase();

final message =
(data['message'] ?? '').toString().toLowerCase();

final text = '$title $message';

if (text.contains('course') ||
text.contains('lesson') ||
text.contains('learning')) {
return {
'icon': Icons.school_rounded,
'color': neonBlue,
'label': 'COURSE',
};
}

if (text.contains('quiz') ||
text.contains('test') ||
text.contains('exam') ||
text.contains('question')) {
return {
'icon': Icons.quiz_rounded,
'color': neonPurple,
'label': 'QUIZ',
};
}

if (text.contains('certificate') ||
text.contains('completed') ||
text.contains('completion')) {
return {
'icon': Icons.workspace_premium_rounded,
'color': neonOrange,
'label': 'ACHIEVEMENT',
};
}

if (text.contains('offer') ||
text.contains('discount') ||
text.contains('sale')) {
return {
'icon': Icons.local_offer_rounded,
'color': neonGreen,
'label': 'OFFER',
};
}

if (text.contains('warning') ||
text.contains('alert') ||
text.contains('important')) {
return {
'icon': Icons.warning_amber_rounded,
'color': neonRed,
'label': 'IMPORTANT',
};
}

if (text.contains('update') ||
text.contains('new') ||
text.contains('announcement')) {
return {
'icon': Icons.auto_awesome_rounded,
'color': neonCyan,
'label': 'UPDATE',
};
}

return {
'icon': Icons.notifications_active_rounded,
'color': neonBlue,
'label': 'NOTICE',
};
}

// ============================================================
// CYBER PANEL
// ============================================================

Widget cyberPanel({
required Widget child,
required Color glowColor,
EdgeInsetsGeometry padding =
const EdgeInsets.all(15),
}) {
return Container(
width: double.infinity,
padding: padding,
decoration: BoxDecoration(
color: panel,
borderRadius:
BorderRadius.circular(20),
border: Border.all(
color: border,
),
boxShadow: [
BoxShadow(
color: glowColor.withValues(
alpha: .055,
),
blurRadius: 22,
),
],
),
child: child,
);
}

// ============================================================
// CYBER HEADER
// ============================================================

Widget headerSection(int count) {
final subtitle = count == 0
? 'SYSTEM CLEAR • NO NEW SIGNALS'
: count == 1
? '1 NEW SIGNAL DETECTED'
: '$count NEW SIGNALS DETECTED';

return Container(
width: double.infinity,
padding: const EdgeInsets.fromLTRB(
18,
20,
18,
22,
),
decoration: BoxDecoration(
gradient:
const LinearGradient(
colors: [
Color(0xff071426),
Color(0xff0B1230),
Color(0xff100A27),
],
begin: Alignment.topLeft,
end: Alignment.bottomRight,
),
border: Border(
bottom: BorderSide(
color: neonBlue.withValues(
alpha: .18,
),
),
),
),
child: Stack(
children: [
// Decorative glow.
Positioned(
right: -55,
top: -65,
child: Container(
width: 170,
height: 170,
decoration: BoxDecoration(
shape: BoxShape.circle,
gradient:
RadialGradient(
colors: [
neonPurple.withValues(
alpha: .15,
),
Colors.transparent,
],
),
),
),
),

Positioned(
left: -65,
bottom: -90,
child: Container(
width: 190,
height: 190,
decoration: BoxDecoration(
shape: BoxShape.circle,
gradient:
RadialGradient(
colors: [
neonBlue.withValues(
alpha: .10,
),
Colors.transparent,
],
),
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
width: 52,
height: 52,
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
boxShadow: [
BoxShadow(
color: neonBlue
.withValues(
alpha: .25,
),
blurRadius: 20,
),
],
),
child: const Icon(
Icons
.notifications_active_rounded,
color: Colors.white,
size: 26,
),
),
const SizedBox(width: 13),
Expanded(
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
const Text(
'NOTIFICATION HUB',
style: TextStyle(
color: neonCyan,
fontSize: 10,
fontWeight:
FontWeight.w900,
letterSpacing: 1.8,
),
),
const SizedBox(height: 5),
Text(
subtitle,
style: const TextStyle(
color:
textPrimary,
fontSize: 11,
fontWeight:
FontWeight.w800,
letterSpacing: .6,
),
),
],
),
),
Container(
width: 43,
height: 43,
alignment:
Alignment.center,
decoration: BoxDecoration(
color: panel2,
borderRadius:
BorderRadius.circular(
13,
),
border: Border.all(
color: neonCyan
.withValues(
alpha: .22,
),
),
),
child: Text(
'$count',
style:
const TextStyle(
color: neonCyan,
fontSize: 16,
fontWeight:
FontWeight.w900,
),
),
),
],
),

const SizedBox(height: 18),

Container(
width: double.infinity,
padding:
const EdgeInsets.all(13),
decoration: BoxDecoration(
color: Colors.black
.withValues(
alpha: .16,
),
borderRadius:
BorderRadius.circular(15),
border: Border.all(
color: neonBlue
.withValues(
alpha: .13,
),
),
),
child: Row(
children: [
Container(
width: 7,
height: 7,
decoration:
const BoxDecoration(
color: neonGreen,
shape:
BoxShape.circle,
),
),
const SizedBox(width: 9),
const Expanded(
child: Text(
'Learning alerts, course updates and achievements appear here.',
style: TextStyle(
color:
textSecondary,
fontSize: 10.5,
height: 1.4,
),
),
),
const Icon(
Icons
.sensors_rounded,
color: neonGreen,
size: 17,
),
],
),
),
],
),
],
),
);
}

// ============================================================
// SECTION HEADER
// ============================================================

Widget sectionHeader(int count) {
return Padding(
padding: const EdgeInsets.fromLTRB(
18,
22,
18,
13,
),
child: Row(
children: [
Container(
width: 4,
height: 27,
decoration:
const BoxDecoration(
gradient:
LinearGradient(
colors: [
neonBlue,
neonPurple,
],
begin:
Alignment.topCenter,
end:
Alignment.bottomCenter,
),
borderRadius:
BorderRadius.all(
Radius.circular(8),
),
),
),
const SizedBox(width: 10),
const Expanded(
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
Text(
'ACTIVITY STREAM',
style: TextStyle(
color: neonCyan,
fontSize: 9,
fontWeight:
FontWeight.w900,
letterSpacing: 1.7,
),
),
SizedBox(height: 3),
Text(
'Recent Notifications',
style: TextStyle(
color: textPrimary,
fontSize: 17,
fontWeight:
FontWeight.w900,
),
),
],
),
),
Container(
padding:
const EdgeInsets.symmetric(
horizontal: 9,
vertical: 6,
),
decoration: BoxDecoration(
color: panel2,
borderRadius:
BorderRadius.circular(20),
border: Border.all(
color: border,
),
),
child: Text(
'$count ITEMS',
style: const TextStyle(
color: textSecondary,
fontSize: 8,
fontWeight:
FontWeight.w900,
letterSpacing: .8,
),
),
),
],
),
);
}

// ============================================================
// NOTIFICATION CARD
// ============================================================

Widget notificationCard(
Map<String, dynamic> data,
) {
final title =
(data['title'] ?? 'Notification')
.toString();

final message =
(data['message'] ?? '').toString();

final timestamp =
data['createdAt'] is Timestamp
? data['createdAt'] as Timestamp
: null;

final style =
getNotificationStyle(data);

final IconData icon =
style['icon'] as IconData;

final Color color =
style['color'] as Color;

final String label =
style['label'] as String;

final dateText =
formatDate(timestamp);

return Container(
margin:
const EdgeInsets.only(bottom: 12),
decoration: BoxDecoration(
color: panel,
borderRadius:
BorderRadius.circular(20),
border: Border.all(
color: color.withValues(
alpha: .16,
),
),
boxShadow: [
BoxShadow(
color: color.withValues(
alpha: .045,
),
blurRadius: 20,
),
],
),
child: Stack(
children: [
// Left neon line.
Positioned(
left: 0,
top: 15,
bottom: 15,
child: Container(
width: 3,
decoration: BoxDecoration(
color: color,
borderRadius:
const BorderRadius
.horizontal(
right:
Radius.circular(5),
),
boxShadow: [
BoxShadow(
color:
color.withValues(
alpha: .45,
),
blurRadius: 9,
),
],
),
),
),

Padding(
padding:
const EdgeInsets.fromLTRB(
15,
15,
14,
15,
),
child: Row(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
// ==========================================
// ICON
// ==========================================

Container(
width: 52,
height: 52,
decoration: BoxDecoration(
color: color.withValues(
alpha: .065,
),
borderRadius:
BorderRadius.circular(
15,
),
border: Border.all(
color: color.withValues(
alpha: .20,
),
),
),
child: Icon(
icon,
color: color,
size: 25,
),
),

const SizedBox(width: 13),

// ==========================================
// CONTENT
// ==========================================

Expanded(
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
Row(
crossAxisAlignment:
CrossAxisAlignment
.start,
children: [
Expanded(
child: Text(
title,
maxLines: 2,
overflow:
TextOverflow
.ellipsis,
style:
const TextStyle(
color:
textPrimary,
fontSize: 14,
fontWeight:
FontWeight.w800,
height: 1.3,
),
),
),
const SizedBox(
width: 7,
),
Container(
padding:
const EdgeInsets
.symmetric(
horizontal: 7,
vertical: 4,
),
decoration:
BoxDecoration(
color: color
.withValues(
alpha: .07,
),
borderRadius:
BorderRadius
.circular(
20,
),
border:
Border.all(
color: color
.withValues(
alpha: .18,
),
),
),
child: Text(
label,
style:
TextStyle(
color: color,
fontSize: 7,
fontWeight:
FontWeight
.w900,
letterSpacing:
.7,
),
),
),
],
),

const SizedBox(
height: 8,
),

Text(
message.isEmpty
? 'You have a new update from MMOC Teach.'
: message,
style:
const TextStyle(
color:
textSecondary,
fontSize: 11.5,
height: 1.5,
fontWeight:
FontWeight.w500,
),
),

const SizedBox(
height: 10,
),

if (dateText.isNotEmpty)
Row(
children: [
Icon(
Icons
.access_time_rounded,
size: 12,
color:
color.withValues(
alpha: .75,
),
),
const SizedBox(
width: 5,
),
Text(
dateText,
style:
const TextStyle(
color:
textSecondary,
fontSize: 8.5,
fontWeight:
FontWeight.w800,
letterSpacing:
.3,
),
),
],
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
  // EMPTY STATE
  // ============================================================

  Widget emptyState() {
    return CustomScrollView(
      physics:
      const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      slivers: [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: Padding(
              padding:
              const EdgeInsets.symmetric(
                horizontal: 30,
              ),
              child: Column(
                mainAxisAlignment:
                MainAxisAlignment.center,
                children: [
                  Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: panel,
                      border: Border.all(
                        color: neonBlue
                            .withValues(
                          alpha: .22,
                        ),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: neonBlue
                              .withValues(
                            alpha: .10,
                          ),
                          blurRadius: 30,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons
                          .notifications_none_rounded,
                      color: neonCyan,
                      size: 52,
                    ),
                  ),

                  const SizedBox(
                    height: 24,
                  ),

                  const Text(
                    'SYSTEM CLEAR',
                    style: TextStyle(
                      color: neonCyan,
                      fontSize: 10,
                      fontWeight:
                      FontWeight.w900,
                      letterSpacing: 2,
                    ),
                  ),

                  const SizedBox(
                    height: 8,
                  ),

                  const Text(
                    'No Notifications',
                    textAlign:
                    TextAlign.center,
                    style: TextStyle(
                      color: textPrimary,
                      fontSize: 22,
                      fontWeight:
                      FontWeight.w900,
                    ),
                  ),

                  const SizedBox(
                    height: 9,
                  ),

                  const Text(
                    'You are completely caught up. '
                        'New learning updates will appear here.',
                    textAlign:
                    TextAlign.center,
                    style: TextStyle(
                      color: textSecondary,
                      fontSize: 12,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(
                    height: 21,
                  ),

                  Container(
                    padding:
                    const EdgeInsets
                        .symmetric(
                      horizontal: 14,
                      vertical: 9,
                    ),
                    decoration:
                    BoxDecoration(
                      color: neonGreen
                          .withValues(
                        alpha: .05,
                      ),
                      borderRadius:
                      BorderRadius.circular(
                        13,
                      ),
                      border: Border.all(
                        color: neonGreen
                            .withValues(
                          alpha: .18,
                        ),
                      ),
                    ),
                    child: const Row(
                      mainAxisSize:
                      MainAxisSize.min,
                      children: [
                        Icon(
                          Icons
                              .check_circle_outline_rounded,
                          color: neonGreen,
                          size: 16,
                        ),
                        SizedBox(
                          width: 7,
                        ),
                        Text(
                          'ALL SIGNALS CLEARED',
                          style: TextStyle(
                            color: neonGreen,
                            fontSize: 8,
                            fontWeight:
                            FontWeight.w900,
                            letterSpacing:
                            .8,
                          ),
                        ),
                      ],
                    ),
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

  Widget errorState() {
    return CustomScrollView(
      physics:
      const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      slivers: [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: Padding(
              padding:
              const EdgeInsets.symmetric(
                horizontal: 30,
              ),
              child: Column(
                mainAxisAlignment:
                MainAxisAlignment.center,
                children: [
                  Container(
                    width: 94,
                    height: 94,
                    decoration:
                    BoxDecoration(
                      color: neonRed
                          .withValues(
                        alpha: .055,
                      ),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: neonRed
                            .withValues(
                          alpha: .22,
                        ),
                      ),
                    ),
                    child: const Icon(
                      Icons
                          .cloud_off_rounded,
                      color: neonRed,
                      size: 43,
                    ),
                  ),

                  const SizedBox(
                    height: 20,
                  ),

                  const Text(
                    'SIGNAL ERROR',
                    style: TextStyle(
                      color: neonRed,
                      fontSize: 9,
                      fontWeight:
                      FontWeight.w900,
                      letterSpacing: 1.7,
                    ),
                  ),

                  const SizedBox(
                    height: 7,
                  ),

                  const Text(
                    'Unable to Load Notifications',
                    textAlign:
                    TextAlign.center,
                    style: TextStyle(
                      color: textPrimary,
                      fontSize: 18,
                      fontWeight:
                      FontWeight.w900,
                    ),
                  ),

                  const SizedBox(
                    height: 9,
                  ),

                  const Text(
                    'Check your internet connection '
                        'and try again.',
                    textAlign:
                    TextAlign.center,
                    style: TextStyle(
                      color: textSecondary,
                      fontSize: 12,
                      height: 1.5,
                    ),
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
  // LOADING STATE
  // ============================================================

  Widget loadingState() {
    return ListView.builder(
      physics:
      const NeverScrollableScrollPhysics(),
      padding:
      const EdgeInsets.fromLTRB(
        18,
        20,
        18,
        30,
      ),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Container(
          height: 115,
          margin:
          const EdgeInsets.only(
            bottom: 12,
          ),
          decoration: BoxDecoration(
            color: panel,
            borderRadius:
            BorderRadius.circular(20),
            border: Border.all(
              color: border,
            ),
          ),
          child: Padding(
            padding:
            const EdgeInsets.all(15),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration:
                  BoxDecoration(
                    color: panel2,
                    borderRadius:
                    BorderRadius.circular(
                      15,
                    ),
                  ),
                ),
                const SizedBox(
                  width: 13,
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment:
                    MainAxisAlignment.center,
                    crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                    children: [
                      Container(
                        width: index.isEven
                            ? 165
                            : 125,
                        height: 12,
                        decoration:
                        BoxDecoration(
                          color:
                          const Color(
                            0xff162238,
                          ),
                          borderRadius:
                          BorderRadius
                              .circular(
                            8,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Container(
                        width:
                        double.infinity,
                        height: 9,
                        decoration:
                        BoxDecoration(
                          color:
                          const Color(
                            0xff111B2E,
                          ),
                          borderRadius:
                          BorderRadius
                              .circular(
                            8,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 7,
                      ),
                      Container(
                        width: 90,
                        height: 8,
                        decoration:
                        BoxDecoration(
                          color:
                          const Color(
                            0xff111B2E,
                          ),
                          borderRadius:
                          BorderRadius
                              .circular(
                            8,
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
      },
    );
  }

  // ============================================================
  // MAIN BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,

      // ========================================================
      // APP BAR
      // ========================================================

      appBar: AppBar(
        elevation: 0,
        backgroundColor: bg,
        foregroundColor: textPrimary,
        titleSpacing: 0,
        title: const Row(
          children: [
            Icon(
              Icons
                  .notifications_outlined,
              color: neonCyan,
              size: 20,
            ),
            SizedBox(width: 9),
            Text(
              'NOTIFICATIONS',
              style: TextStyle(
                color: textPrimary,
                fontSize: 15,
                fontWeight:
                FontWeight.w900,
                letterSpacing: 1.3,
              ),
            ),
          ],
        ),
      ),

      // ========================================================
      // FIRESTORE STREAM
      // ========================================================

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('notifications')
            .orderBy(
          'createdAt',
          descending: true,
        )
            .snapshots(),

        builder: (context, snapshot) {
          // ----------------------------------------------------
          // LOADING
          // ----------------------------------------------------

          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return loadingState();
          }

          // ----------------------------------------------------
          // ERROR
          // ----------------------------------------------------

          if (snapshot.hasError) {
            return errorState();
          }

          // ----------------------------------------------------
          // EMPTY
          // ----------------------------------------------------

          if (!snapshot.hasData ||
              snapshot.data!.docs.isEmpty) {
            return RefreshIndicator(
              color: neonCyan,
              backgroundColor: panel,
              onRefresh: () async {
                await FirebaseFirestore.instance
                    .collection(
                  'notifications',
                )
                    .orderBy(
                  'createdAt',
                  descending: true,
                )
                    .get();
              },
              child: emptyState(),
            );
          }

          final notifications =
              snapshot.data!.docs;

          // ----------------------------------------------------
          // MAIN DATA
          // ----------------------------------------------------

          return RefreshIndicator(
            color: neonCyan,
            backgroundColor: panel,

            onRefresh: () async {
              await FirebaseFirestore.instance
                  .collection(
                'notifications',
              )
                  .orderBy(
                'createdAt',
                descending: true,
              )
                  .get();
            },

            child: CustomScrollView(
              physics:
              const AlwaysScrollableScrollPhysics(
                parent:
                BouncingScrollPhysics(),
              ),
              slivers: [
                // =============================================
                // HEADER
                // =============================================

                SliverToBoxAdapter(
                  child: headerSection(
                    notifications.length,
                  ),
                ),

                // =============================================
                // SECTION
                // =============================================

                SliverToBoxAdapter(
                  child: sectionHeader(
                    notifications.length,
                  ),
                ),

                // =============================================
                // LIST
                // =============================================

                SliverPadding(
                  padding:
                  const EdgeInsets.fromLTRB(
                    18,
                    0,
                    18,
                    15,
                  ),
                  sliver: SliverList(
                    delegate:
                    SliverChildBuilderDelegate(
                          (context, index) {
                        final rawData =
                        notifications[index]
                            .data();

                        if (rawData
                        is! Map<String, dynamic>) {
                          return const SizedBox
                              .shrink();
                        }

                        return notificationCard(
                          rawData,
                        );
                      },
                      childCount:
                      notifications.length,
                    ),
                  ),
                ),

                // =============================================
                // FOOTER
                // =============================================

                const SliverToBoxAdapter(
                  child: Padding(
                    padding:
                    EdgeInsets.fromLTRB(
                      18,
                      4,
                      18,
                      35,
                    ),
                    child: Column(
                      children: [
                        Divider(
                          color: border,
                          height: 1,
                        ),
                        SizedBox(height: 17),
                        Row(
                          mainAxisAlignment:
                          MainAxisAlignment
                              .center,
                          children: [
                            Icon(
                              Icons
                                  .terminal_rounded,
                              color: neonBlue,
                              size: 14,
                            ),
                            SizedBox(width: 6),
                            Text(
                              'MMOC TEACH // NOTIFICATION SYSTEM ONLINE',
                              style: TextStyle(
                                color:
                                textSecondary,
                                fontSize: 7.5,
                                fontWeight:
                                FontWeight.w800,
                                letterSpacing:
                                1,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 5),
                        Text(
                          'LEARN • GROW • SUCCEED',
                          style: TextStyle(
                            color:
                            Color(0xff4F5D76),
                            fontSize: 7.5,
                            fontWeight:
                            FontWeight.w700,
                            letterSpacing:
                            1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}