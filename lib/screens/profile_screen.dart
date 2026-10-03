import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'settings_screen.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
// ============================================================
// CYBER TECH THEME
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
// CONTROLLERS
// ============================================================

final TextEditingController nameController =
TextEditingController();

final TextEditingController mobileController =
TextEditingController();

final TextEditingController emailController =
TextEditingController();

// ============================================================
// STATE
// ============================================================

bool isLoading = true;
bool isSaving = false;

int enrolledCourses = 0;
int completedCourses = 0;
int wishlistCourses = 0;

String? photoURL;

// ============================================================
// INIT
// ============================================================

@override
void initState() {
super.initState();

loadUser();
loadStats();
}

// ============================================================
// LOAD USER
// ============================================================

Future<void> loadUser() async {
final user = FirebaseAuth.instance.currentUser;

if (user == null) {
if (!mounted) return;

setState(() {
isLoading = false;
});

return;
}

try {
emailController.text = user.email ?? '';

final doc = await FirebaseFirestore.instance
.collection('users')
.doc(user.uid)
.get();

if (doc.exists) {
final data = doc.data();

if (data != null) {
nameController.text =
(data['name'] ?? '').toString();

mobileController.text =
(data['mobile'] ?? '').toString();

final firestorePhoto =
(data['photoURL'] ?? '').toString().trim();

if (firestorePhoto.isNotEmpty) {
photoURL = firestorePhoto;
}
}
}

// Firebase Auth photo fallback.
if ((photoURL ?? '').trim().isEmpty) {
final authPhoto =
(user.photoURL ?? '').trim();

if (authPhoto.isNotEmpty) {
photoURL = authPhoto;
}
}

if (!mounted) return;

setState(() {
isLoading = false;
});
} catch (e) {
debugPrint('User Loading Error: $e');

if (!mounted) return;

setState(() {
isLoading = false;
});

showSnackBar(
'Unable to load profile',
isError: true,
);
}
}

// ============================================================
// LOAD STATS
// ============================================================

Future<void> loadStats() async {
final user = FirebaseAuth.instance.currentUser;

if (user == null) return;

try {
final firestore =
FirebaseFirestore.instance;

final results =
await Future.wait<QuerySnapshot>([
firestore
.collection('enrollments')
.where(
'uid',
isEqualTo: user.uid,
)
.get(),
firestore
.collection('wishlist')
.where(
'uid',
isEqualTo: user.uid,
)
.get(),
]);

final enrollments = results[0];
final wishlist = results[1];

int completed = 0;

for (final doc in enrollments.docs) {
final data =
doc.data() as Map<String, dynamic>;

final progress = data['progress'];

if (progress is num && progress >= 100) {
completed++;
}
}

if (!mounted) return;

setState(() {
enrolledCourses = enrollments.docs.length;
completedCourses = completed;
wishlistCourses = wishlist.docs.length;
});
} catch (e) {
debugPrint('Stats Loading Error: $e');
}
}

// ============================================================
// SAVE PROFILE
// ============================================================

Future<void> saveProfile() async {
final user =
FirebaseAuth.instance.currentUser;

if (user == null) {
showSnackBar(
'Please login again',
isError: true,
);
return;
}

final name =
nameController.text.trim();

final mobile =
mobileController.text.trim();

if (name.isEmpty) {
showSnackBar(
'Please enter your name',
isError: true,
);
return;
}

if (mobile.isNotEmpty &&
(mobile.length != 10 ||
!RegExp(r'^[0-9]+$').hasMatch(mobile))) {
showSnackBar(
'Please enter a valid 10-digit mobile number',
isError: true,
);
return;
}

if (isSaving) return;

setState(() {
isSaving = true;
});

try {
await FirebaseFirestore.instance
.collection('users')
.doc(user.uid)
.set(
{
'uid': user.uid,
'email': user.email,
'name': name,
'mobile': mobile,
'photoURL': photoURL,
},
SetOptions(merge: true),
);

// Keep Firebase Auth display name synced.
if (user.displayName != name) {
await user.updateDisplayName(name);
}

if (!mounted) return;

setState(() {
isSaving = false;
});

FocusScope.of(context).unfocus();

showSnackBar(
'Profile updated successfully',
);
} catch (e) {
debugPrint('Profile Save Error: $e');

if (!mounted) return;

setState(() {
isSaving = false;
});

showSnackBar(
'Profile update failed',
isError: true,
);
}
}

// ============================================================
// CYBER GLOW CONTAINER
// ============================================================

Widget cyberPanel({
required Widget child,
Color? glowColor,
EdgeInsetsGeometry padding =
const EdgeInsets.all(16),
double radius = 20,
}) {
final glow =
glowColor ?? neonBlue;

return Container(
width: double.infinity,
padding: padding,
decoration: BoxDecoration(
color: panel,
borderRadius:
BorderRadius.circular(radius),
border: Border.all(
color: border,
),
boxShadow: [
BoxShadow(
color: glow.withValues(
alpha: .055,
),
blurRadius: 25,
spreadRadius: 1,
),
],
),
child: child,
);
}

// ============================================================
// TOP CYBER HEADER
// ============================================================

Widget buildTopHeader() {
return Row(
children: [
Container(
width: 42,
height: 42,
decoration: BoxDecoration(
borderRadius:
BorderRadius.circular(13),
gradient:
const LinearGradient(
colors: [
neonBlue,
neonPurple,
],
begin: Alignment.topLeft,
end: Alignment.bottomRight,
),
boxShadow: [
BoxShadow(
color: neonBlue.withValues(
alpha: .28,
),
blurRadius: 18,
),
],
),
child: const Icon(
Icons.person_rounded,
color: Colors.white,
size: 23,
),
),
const SizedBox(width: 13),
Expanded(
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
Row(
children: [
const Text(
'PROFILE CORE',
style: TextStyle(
color: neonCyan,
fontSize: 11,
fontWeight:
FontWeight.w900,
letterSpacing: 2.1,
),
),
const SizedBox(width: 8),
Container(
width: 6,
height: 6,
decoration:
const BoxDecoration(
color: neonGreen,
shape: BoxShape.circle,
),
),
],
),
const SizedBox(height: 4),
Text(
'Manage your learning identity',
style: TextStyle(
color: textSecondary,
fontSize: 11,
fontWeight:
FontWeight.w500,
),
),
],
),
),
Container(
decoration: BoxDecoration(
color: panel2,
borderRadius:
BorderRadius.circular(13),
border: Border.all(
color: border,
),
),
child: IconButton(
tooltip: 'Settings',
onPressed: () {
Navigator.push(
context,
MaterialPageRoute(
builder: (_) =>
const SettingsScreen(),
),
);
},
icon: const Icon(
Icons.settings_outlined,
color: neonCyan,
size: 21,
),
),
),
],
);
}

// ============================================================
// PROFILE AVATAR
// ============================================================

Widget buildProfileImage() {
final hasPhoto =
photoURL != null &&
photoURL!.trim().isNotEmpty;

return Container(
padding: const EdgeInsets.all(3),
decoration: BoxDecoration(
shape: BoxShape.circle,
gradient:
const SweepGradient(
colors: [
neonBlue,
neonPurple,
neonCyan,
neonBlue,
],
),
boxShadow: [
BoxShadow(
color: neonBlue.withValues(
alpha: .28,
),
blurRadius: 30,
spreadRadius: 3,
),
BoxShadow(
color: neonPurple.withValues(
alpha: .18,
),
blurRadius: 45,
),
],
),
child: Container(
padding: const EdgeInsets.all(4),
decoration: const BoxDecoration(
shape: BoxShape.circle,
color: bg,
),
child: CircleAvatar(
radius: 58,
backgroundColor:
const Color(0xff111B31),
backgroundImage: hasPhoto
? NetworkImage(photoURL!)
: null,
child: hasPhoto
? null
: const Icon(
Icons.person_rounded,
size: 61,
color: neonCyan,
),
),
),
);
}

// ============================================================
// PROFILE HERO
// ============================================================

Widget profileHero(User? user) {
final displayName =
nameController.text.trim().isEmpty
? 'MMOC Student'
: nameController.text.trim();

return cyberPanel(
glowColor: neonPurple,
padding: const EdgeInsets.all(20),
radius: 26,
child: Stack(
children: [
Positioned(
top: -35,
right: -35,
child: Container(
width: 120,
height: 120,
decoration: BoxDecoration(
shape: BoxShape.circle,
gradient:
RadialGradient(
colors: [
neonPurple.withValues(
alpha: .16,
),
Colors.transparent,
],
),
),
),
),
Positioned(
bottom: -45,
left: -35,
child: Container(
width: 120,
height: 120,
decoration: BoxDecoration(
shape: BoxShape.circle,
gradient:
RadialGradient(
colors: [
neonBlue.withValues(
alpha: .12,
),
Colors.transparent,
],
),
),
),
),
Column(
children: [
buildProfileImage(),

const SizedBox(height: 16),

Text(
displayName,
textAlign: TextAlign.center,
maxLines: 1,
overflow:
TextOverflow.ellipsis,
style: const TextStyle(
color: textPrimary,
fontSize: 23,
fontWeight:
FontWeight.w900,
letterSpacing: .2,
),
),

const SizedBox(height: 6),

Text(
user?.email ?? 'No email',
textAlign: TextAlign.center,
maxLines: 1,
overflow:
TextOverflow.ellipsis,
style: const TextStyle(
color: textSecondary,
fontSize: 11.5,
),
),

const SizedBox(height: 15),

Container(
padding:
const EdgeInsets.symmetric(
horizontal: 13,
vertical: 7,
),
decoration: BoxDecoration(
color: neonBlue.withValues(
alpha: .08,
),
borderRadius:
BorderRadius.circular(30),
border: Border.all(
color: neonBlue.withValues(
alpha: .35,
),
),
),
child: const Row(
mainAxisSize:
MainAxisSize.min,
children: [
Icon(
Icons
.verified_rounded,
color: neonCyan,
size: 15,
),
SizedBox(width: 6),
Text(
'VERIFIED STUDENT',
style: TextStyle(
color: neonCyan,
fontSize: 9.5,
fontWeight:
FontWeight.w900,
letterSpacing: 1.1,
),
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
// STAT CARD
// ============================================================

Widget statCard({
required IconData icon,
required Color color,
required String value,
required String label,
}) {
return Expanded(
child: Container(
padding:
const EdgeInsets.symmetric(
vertical: 15,
horizontal: 5,
),
decoration: BoxDecoration(
color: panel,
borderRadius:
BorderRadius.circular(18),
border: Border.all(
color: color.withValues(
alpha: .20,
),
),
boxShadow: [
BoxShadow(
color: color.withValues(
alpha: .045,
),
blurRadius: 18,
),
],
),
child: Column(
children: [
Container(
width: 40,
height: 40,
decoration: BoxDecoration(
color: color.withValues(
alpha: .08,
),
borderRadius:
BorderRadius.circular(12),
border: Border.all(
color: color.withValues(
alpha: .18,
),
),
),
child: Icon(
icon,
color: color,
size: 20,
),
),
const SizedBox(height: 9),
Text(
value,
style: TextStyle(
color: textPrimary,
fontSize: 20,
fontWeight:
FontWeight.w900,
shadows: [
Shadow(
color: color.withValues(
alpha: .35,
),
blurRadius: 12,
),
],
),
),
const SizedBox(height: 3),
Text(
label,
textAlign: TextAlign.center,
style: const TextStyle(
color: textSecondary,
fontSize: 9.5,
fontWeight:
FontWeight.w700,
),
),
],
),
),
);
}

// ============================================================
// STATS SECTION
// ============================================================

Widget statsSection() {
return Row(
children: [
statCard(
icon: Icons.menu_book_rounded,
color: neonBlue,
value: '$enrolledCourses',
label: 'ENROLLED',
),
const SizedBox(width: 9),
statCard(
icon:
Icons.workspace_premium_rounded,
color: neonOrange,
value: '$completedCourses',
label: 'COMPLETED',
),
const SizedBox(width: 9),
statCard(
icon: Icons.favorite_rounded,
color: neonRed,
value: '$wishlistCourses',
label: 'WISHLIST',
),
],
);
}

// ============================================================
// SECTION TITLE
// ============================================================

Widget sectionTitle({
required String code,
required String title,
required String subtitle,
}) {
return Row(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
Container(
width: 4,
height: 44,
decoration: BoxDecoration(
gradient:
const LinearGradient(
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
alpha: .35,
),
blurRadius: 10,
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
code,
style: const TextStyle(
color: neonCyan,
fontSize: 9,
fontWeight:
FontWeight.w900,
letterSpacing: 1.6,
),
),
const SizedBox(height: 3),
Text(
title,
style: const TextStyle(
color: textPrimary,
fontSize: 19,
fontWeight:
FontWeight.w900,
),
),
const SizedBox(height: 3),
Text(
subtitle,
style: const TextStyle(
color: textSecondary,
fontSize: 10.5,
height: 1.35,
),
),
],
),
),
],
);
}

// ============================================================
// INPUT FIELD
// ============================================================

Widget inputField({
required TextEditingController controller,
required String label,
required String code,
required IconData icon,
bool enabled = true,
TextInputType? keyboardType,
}) {
return Container(
decoration: BoxDecoration(
color: panel2,
borderRadius:
BorderRadius.circular(16),
border: Border.all(
color: enabled
? border
: const Color(0xff172136),
),
),
child: TextField(
controller: controller,
enabled: enabled,
keyboardType: keyboardType,
cursorColor: neonCyan,
style: TextStyle(
color: enabled
? textPrimary
: textSecondary,
fontSize: 13,
fontWeight:
FontWeight.w600,
),
decoration: InputDecoration(
labelText: label,
labelStyle: TextStyle(
color: enabled
? textSecondary
: const Color(0xff526078),
fontSize: 11.5,
),
floatingLabelStyle:
const TextStyle(
color: neonCyan,
fontSize: 11,
fontWeight:
FontWeight.w700,
),
prefixIcon: Container(
margin:
const EdgeInsets.all(10),
width: 38,
height: 38,
decoration: BoxDecoration(
color: enabled
? neonBlue.withValues(
alpha: .07,
)
: const Color(
0xff111827,
),
borderRadius:
BorderRadius.circular(11),
border: Border.all(
color: enabled
? neonBlue.withValues(
alpha: .16,
)
: const Color(
0xff1A2335,
),
),
),
child: Icon(
icon,
color: enabled
? neonCyan
: const Color(
0xff526078,
),
size: 18,
),
),
suffixText: code,
suffixStyle: TextStyle(
color: enabled
? neonPurple.withValues(
alpha: .65,
)
: const Color(
0xff3E4A60,
),
fontSize: 8,
fontWeight:
FontWeight.w900,
letterSpacing: 1,
),
filled: true,
fillColor: Colors.transparent,
contentPadding:
const EdgeInsets.symmetric(
horizontal: 14,
vertical: 17,
),
border: OutlineInputBorder(
borderRadius:
BorderRadius.circular(16),
borderSide: BorderSide.none,
),
enabledBorder:
OutlineInputBorder(
borderRadius:
BorderRadius.circular(16),
borderSide: BorderSide.none,
),
focusedBorder:
OutlineInputBorder(
borderRadius:
BorderRadius.circular(16),
borderSide:
BorderSide(
color: neonBlue.withValues(
alpha: .55,
),
width: 1,
),
),
disabledBorder:
OutlineInputBorder(
borderRadius:
BorderRadius.circular(16),
borderSide: BorderSide.none,
),
),
),
);
}
  // ============================================================
  // ACCOUNT SECURITY CARD
  // ============================================================

  Widget accountInfoCard(User? user) {
    final verified =
        user?.emailVerified ?? false;

    return cyberPanel(
      glowColor: neonGreen,
      padding: const EdgeInsets.all(15),
      child: Row(
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: neonGreen.withValues(
                alpha: .07,
              ),
              borderRadius:
              BorderRadius.circular(13),
              border: Border.all(
                color: neonGreen.withValues(
                  alpha: .22,
                ),
              ),
            ),
            child: Icon(
              verified
                  ? Icons
                  .verified_user_rounded
                  : Icons
                  .shield_outlined,
              color: neonGreen,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                const Text(
                  'ACCOUNT SECURITY',
                  style: TextStyle(
                    color: neonGreen,
                    fontSize: 9,
                    fontWeight:
                    FontWeight.w900,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  user?.email ??
                      'Not available',
                  maxLines: 1,
                  overflow:
                  TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: textPrimary,
                    fontSize: 11.5,
                    fontWeight:
                    FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration:
                      BoxDecoration(
                        color: verified
                            ? neonGreen
                            : neonOrange,
                        shape:
                        BoxShape.circle,
                      ),
                    ),
                    const SizedBox(
                      width: 6,
                    ),
                    Text(
                      verified
                          ? 'EMAIL VERIFIED'
                          : 'EMAIL NOT VERIFIED',
                      style: TextStyle(
                        color: verified
                            ? neonGreen
                            : neonOrange,
                        fontSize: 8.5,
                        fontWeight:
                        FontWeight.w800,
                        letterSpacing:
                        .8,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Icon(
            Icons.lock_outline_rounded,
            color: textSecondary,
            size: 17,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SAVE BUTTON
  // ============================================================

  Widget saveButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient:
          const LinearGradient(
            colors: [
              neonBlue,
              Color(0xff4169FF),
              neonPurple,
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius:
          BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: neonBlue.withValues(
                alpha: .22,
              ),
              blurRadius: 22,
              offset:
              const Offset(0, 7),
            ),
          ],
        ),
        child: ElevatedButton.icon(
          onPressed:
          isSaving ? null : saveProfile,
          style:
          ElevatedButton.styleFrom(
            backgroundColor:
            Colors.transparent,
            disabledBackgroundColor:
            Colors.transparent,
            foregroundColor:
            Colors.white,
            shadowColor:
            Colors.transparent,
            elevation: 0,
            shape:
            RoundedRectangleBorder(
              borderRadius:
              BorderRadius.circular(16),
            ),
          ),
          icon: isSaving
              ? const SizedBox(
            width: 20,
            height: 20,
            child:
            CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white,
            ),
          )
              : const Icon(
            Icons
                .cloud_upload_outlined,
            size: 21,
          ),
          label: Text(
            isSaving
                ? 'SYNCING PROFILE...'
                : 'SAVE PROFILE',
            style: const TextStyle(
              fontSize: 12,
              fontWeight:
              FontWeight.w900,
              letterSpacing: 1.1,
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // LOGOUT BUTTON
  // ============================================================

  Widget logoutButton() {
    return SizedBox(
      width: double.infinity,
      height: 53,
      child: OutlinedButton.icon(
        onPressed: logoutUser,
        style:
        OutlinedButton.styleFrom(
          foregroundColor: neonRed,
          side: BorderSide(
            color: neonRed.withValues(
              alpha: .35,
            ),
          ),
          backgroundColor:
          neonRed.withValues(
            alpha: .025,
          ),
          shape:
          RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(16),
          ),
        ),
        icon: const Icon(
          Icons.power_settings_new_rounded,
          size: 20,
        ),
        label: const Text(
          'DISCONNECT ACCOUNT',
          style: TextStyle(
            fontSize: 11,
            fontWeight:
            FontWeight.w900,
            letterSpacing: 1.1,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // LOGOUT
  // ============================================================

  Future<void> logoutUser() async {
    final shouldLogout =
    await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor:
          Colors.transparent,
          child: Container(
            padding:
            const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: panel,
              borderRadius:
              BorderRadius.circular(22),
              border: Border.all(
                color: neonRed.withValues(
                  alpha: .28,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: neonRed.withValues(
                    alpha: .10,
                  ),
                  blurRadius: 30,
                ),
              ],
            ),
            child: Column(
              mainAxisSize:
              MainAxisSize.min,
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration:
                      BoxDecoration(
                        color: neonRed
                            .withValues(
                          alpha: .08,
                        ),
                        borderRadius:
                        BorderRadius
                            .circular(
                          12,
                        ),
                        border: Border.all(
                          color: neonRed
                              .withValues(
                            alpha: .25,
                          ),
                        ),
                      ),
                      child: const Icon(
                        Icons
                            .power_settings_new_rounded,
                        color: neonRed,
                        size: 21,
                      ),
                    ),
                    const SizedBox(
                      width: 12,
                    ),
                    const Expanded(
                      child: Text(
                        'DISCONNECT?',
                        style: TextStyle(
                          color:
                          textPrimary,
                          fontSize: 16,
                          fontWeight:
                          FontWeight.w900,
                          letterSpacing: .8,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 17,
                ),
                const Text(
                  'Are you sure you want to logout from your MMOC Teach account?',
                  style: TextStyle(
                    color:
                    textSecondary,
                    fontSize: 11.5,
                    height: 1.5,
                  ),
                ),
                const SizedBox(
                  height: 21,
                ),
                Row(
                  children: [
                    Expanded(
                      child:
                      OutlinedButton(
                        onPressed: () {
                          Navigator.pop(
                            dialogContext,
                            false,
                          );
                        },
                        style:
                        OutlinedButton
                            .styleFrom(
                          foregroundColor:
                          textSecondary,
                          side:
                          const BorderSide(
                            color: border,
                          ),
                          shape:
                          RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius
                                .circular(
                              12,
                            ),
                          ),
                        ),
                        child:
                        const Text(
                          'CANCEL',
                          style:
                          TextStyle(
                            fontSize: 10,
                            fontWeight:
                            FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child:
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(
                            dialogContext,
                            true,
                          );
                        },
                        style:
                        ElevatedButton
                            .styleFrom(
                          backgroundColor:
                          neonRed,
                          foregroundColor:
                          Colors.white,
                          elevation: 0,
                          shape:
                          RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius
                                .circular(
                              12,
                            ),
                          ),
                        ),
                        child:
                        const Text(
                          'LOGOUT',
                          style:
                          TextStyle(
                            fontSize: 10,
                            fontWeight:
                            FontWeight.w900,
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

    if (shouldLogout != true) return;

    try {
      await FirebaseAuth.instance
          .signOut();

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) =>
          const LoginScreen(),
        ),
            (route) => false,
      );
    } catch (e) {
      debugPrint(
        'Logout Error: $e',
      );

      if (!mounted) return;

      showSnackBar(
        'Logout failed',
        isError: true,
      );
    }
  }

  // ============================================================
  // SNACKBAR
  // ============================================================

  void showSnackBar(
      String message, {
        bool isError = false,
      }) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior:
          SnackBarBehavior.floating,
          margin:
          const EdgeInsets.all(16),
          backgroundColor: isError
              ? const Color(0xff8B1631)
              : const Color(0xff075985),
          shape:
          RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(13),
          ),
          content: Row(
            children: [
              Icon(
                isError
                    ? Icons
                    .error_outline_rounded
                    : Icons
                    .check_circle_outline_rounded,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style:
                  const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight:
                    FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    nameController.dispose();
    mobileController.dispose();
    emailController.dispose();

    super.dispose();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final user =
        FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: bg,

      // ========================================================
      // APP BAR
      // ========================================================

      appBar: AppBar(
        elevation: 0,
        backgroundColor: bg,
        foregroundColor: textPrimary,
        automaticallyImplyLeading: true,
        titleSpacing: 0,
        title: const Text(
          'MY PROFILE',
          style: TextStyle(
            color: textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
          ),
        ),
      ),

      // ========================================================
      // BODY
      // ========================================================

      body: isLoading
          ? const Center(
        child:
        CircularProgressIndicator(
          color: neonCyan,
          strokeWidth: 2.5,
        ),
      )
          : RefreshIndicator(
        color: neonCyan,
        backgroundColor: panel,
        onRefresh: () async {
          await Future.wait([
            loadUser(),
            loadStats(),
          ]);
        },
        child: Stack(
          children: [
            // Cyber background glow.
            Positioned(
              top: -90,
              right: -90,
              child: Container(
                width: 220,
                height: 220,
                decoration:
                BoxDecoration(
                  shape:
                  BoxShape.circle,
                  gradient:
                  RadialGradient(
                    colors: [
                      neonPurple
                          .withValues(
                        alpha: .12,
                      ),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            Positioned(
              top: 280,
              left: -110,
              child: Container(
                width: 230,
                height: 230,
                decoration:
                BoxDecoration(
                  shape:
                  BoxShape.circle,
                  gradient:
                  RadialGradient(
                    colors: [
                      neonBlue
                          .withValues(
                        alpha: .07,
                      ),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            SingleChildScrollView(
              physics:
              const AlwaysScrollableScrollPhysics(),
              padding:
              const EdgeInsets.fromLTRB(
                16,
                8,
                16,
                35,
              ),
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment
                    .start,
                children: [
                  // ======================================
                  // TOP HEADER
                  // ======================================

                  buildTopHeader(),

                  const SizedBox(
                    height: 18,
                  ),

                  // ======================================
                  // PROFILE HERO
                  // ======================================

                  profileHero(user),

                  const SizedBox(
                    height: 13,
                  ),

                  // ======================================
                  // STATS
                  // ======================================

                  statsSection(),

                  const SizedBox(
                    height: 28,
                  ),

                  // ======================================
                  // PERSONAL INFORMATION
                  // ======================================

                  sectionTitle(
                    code:
                    'USER_CONFIGURATION',
                    title:
                    'Personal Information',
                    subtitle:
                    'Update your profile data and keep your learning identity synchronized.',
                  ),

                  const SizedBox(
                    height: 17,
                  ),

                  inputField(
                    controller:
                    nameController,
                    label:
                    'Full Name',
                    code:
                    'NAME',
                    icon: Icons
                        .person_outline_rounded,
                  ),

                  const SizedBox(
                    height: 12,
                  ),

                  inputField(
                    controller:
                    emailController,
                    label:
                    'Email Address',
                    code:
                    'LOCKED',
                    icon: Icons
                        .email_outlined,
                    enabled: false,
                  ),

                  const SizedBox(
                    height: 12,
                  ),

                  inputField(
                    controller:
                    mobileController,
                    label:
                    'Mobile Number',
                    code:
                    'PHONE',
                    icon: Icons
                        .phone_outlined,
                    keyboardType:
                    TextInputType.phone,
                  ),

                  const SizedBox(
                    height: 13,
                  ),

                  accountInfoCard(
                    user,
                  ),

                  const SizedBox(
                    height: 18,
                  ),

                  // ======================================
                  // SAVE
                  // ======================================

                  saveButton(),

                  const SizedBox(
                    height: 12,
                  ),

                  // ======================================
                  // LOGOUT
                  // ======================================

                  logoutButton(),

                  const SizedBox(
                    height: 23,
                  ),

                  // ======================================
                  // FOOTER
                  // ======================================

                  Center(
                    child: Column(
                      children: [
                        Row(
                          mainAxisSize:
                          MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration:
                              const BoxDecoration(
                                color:
                                neonGreen,
                                shape:
                                BoxShape
                                    .circle,
                              ),
                            ),
                            const SizedBox(
                              width: 7,
                            ),
                            const Text(
                              'MMOC TEACH // SYSTEM ONLINE',
                              style:
                              TextStyle(
                                color:
                                textSecondary,
                                fontSize: 8,
                                fontWeight:
                                FontWeight.w800,
                                letterSpacing:
                                1.1,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 6,
                        ),
                        const Text(
                          'LEARN • GROW • SUCCEED',
                          style:
                          TextStyle(
                            color:
                            Color(
                              0xff4F5D76,
                            ),
                            fontSize: 8,
                            letterSpacing:
                            1.2,
                            fontWeight:
                            FontWeight.w700,
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
      ),
    );
  }
}