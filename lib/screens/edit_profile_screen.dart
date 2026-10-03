import 'dart:math' as math;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  // ============================================================
  // CYBER TECH THEME
  // ============================================================

  static const Color cyberBlack = Color(0xff050711);
  static const Color cyberNavy = Color(0xff080D1C);
  static const Color panel = Color(0xff0D1426);
  static const Color panelLight = Color(0xff121B31);

  static const Color neonBlue = Color(0xff00A8FF);
  static const Color electricBlue = Color(0xff2F6BFF);
  static const Color neonPurple = Color(0xff9B5CFF);
  static const Color neonCyan = Color(0xff00F0FF);
  static const Color neonGreen = Color(0xff00F5A0);
  static const Color neonOrange = Color(0xffff9D2E);
  static const Color neonPink = Color(0xffff3CAC);

  static const Color textPrimary = Color(0xffF4F7FF);
  static const Color textSecondary = Color(0xff8D9AB8);
  static const Color textMuted = Color(0xff56627D);
  static const Color border = Color(0xff1B2945);

  // ============================================================
  // CONTROLLERS
  // ============================================================

  final TextEditingController nameController =
  TextEditingController();

  final TextEditingController mobileController =
  TextEditingController();

  final User? user = FirebaseAuth.instance.currentUser;

  bool isLoading = true;
  bool isSaving = false;

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  @override
  void dispose() {
    nameController.dispose();
    mobileController.dispose();
    super.dispose();
  }

  // ============================================================
  // LOAD USER
  // ============================================================

  Future<void> loadUser() async {
    if (user == null) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      return;
    }

    try {
      final doc = await FirebaseFirestore.instance
          .collection("users")
          .doc(user!.uid)
          .get();

      if (doc.exists) {
        final data = doc.data();

        if (data != null) {
          nameController.text =
              data["name"]?.toString() ?? "";

          mobileController.text =
              data["mobile"]?.toString() ?? "";
        }
      } else {
        nameController.text =
            user!.displayName ?? "";
      }
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        "Unable to load profile. Please try again.",
        isError: true,
      );
    }

    if (!mounted) return;

    setState(() {
      isLoading = false;
    });
  }

  // ============================================================
  // SAVE PROFILE
  // ============================================================

  Future<void> saveProfile() async {
    final name = nameController.text.trim();
    final mobile = mobileController.text.trim();

    if (user == null) {
      _showMessage(
        "Please login again.",
        isError: true,
      );
      return;
    }

    if (name.isEmpty) {
      _showMessage(
        "Please enter your name.",
        isError: true,
      );
      return;
    }

    if (name.length < 2) {
      _showMessage(
        "Name should contain at least 2 characters.",
        isError: true,
      );
      return;
    }

    if (mobile.isNotEmpty) {
      if (mobile.length != 10 ||
          !RegExp(r'^[0-9]+$').hasMatch(mobile)) {
        _showMessage(
          "Please enter a valid 10-digit mobile number.",
          isError: true,
        );
        return;
      }
    }

    FocusScope.of(context).unfocus();

    if (!mounted) return;

    setState(() {
      isSaving = true;
    });

    try {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(user!.uid)
          .set(
        {
          "uid": user!.uid,
          "email": user!.email ?? "",
          "name": name,
          "mobile": mobile,
          "photoURL": user!.photoURL,
        },
        SetOptions(merge: true),
      );

      await user!.updateDisplayName(name);

      await user!.reload();

      if (!mounted) return;

      _showMessage(
        "PROFILE UPDATED SUCCESSFULLY",
        isError: false,
      );

      await Future.delayed(
        const Duration(milliseconds: 700),
      );

      if (!mounted) return;

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        "Unable to update profile. Please try again.",
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(
      String message, {
        required bool isError,
      }) {
    if (!mounted) return;

    final Color color =
    isError ? neonPink : neonGreen;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                isError
                    ? Icons.error_outline_rounded
                    : Icons.check_circle_outline_rounded,
                color: color,
                size: 21,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: textPrimary,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: panelLight,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(
              color: color.withValues(alpha: 0.45),
            ),
          ),
        ),
      );
  }

  // ============================================================
  // APP BAR
  // ============================================================

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: cyberBlack,
      surfaceTintColor: Colors.transparent,
      foregroundColor: textPrimary,
      centerTitle: false,
      titleSpacing: 18,
      title: Row(
        children: [
          Container(
            height: 38,
            width: 38,
            decoration: BoxDecoration(
              color: neonPurple.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(11),
              border: Border.all(
                color: neonPurple.withValues(alpha: 0.30),
              ),
              boxShadow: [
                BoxShadow(
                  color: neonPurple.withValues(alpha: 0.13),
                  blurRadius: 14,
                ),
              ],
            ),
            child: const Icon(
              Icons.manage_accounts_rounded,
              color: neonPurple,
              size: 21,
            ),
          ),
          const SizedBox(width: 11),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "MMOC // PROFILE",
                style: TextStyle(
                  color: textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.8,
                ),
              ),
              SizedBox(height: 2),
              Text(
                "ACCOUNT CONFIGURATION",
                style: TextStyle(
                  color: textMuted,
                  fontSize: 8,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PROFILE HEADER
  // ============================================================

  Widget _buildHeader() {
    final String displayName =
    nameController.text.trim().isNotEmpty
        ? nameController.text.trim()
        : "STUDENT";

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        20,
        10,
        20,
        25,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xff09152D),
            Color(0xff10132D),
            Color(0xff17102F),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        border: Border(
          bottom: BorderSide(
            color: neonPurple.withValues(alpha: 0.25),
          ),
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -35,
            top: -35,
            child: Container(
              height: 130,
              width: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: neonPurple.withValues(alpha: 0.08),
                  width: 18,
                ),
              ),
            ),
          ),

          Positioned(
            right: 22,
            bottom: 8,
            child: Icon(
              Icons.account_circle_rounded,
              size: 90,
              color: neonBlue.withValues(alpha: 0.035),
            ),
          ),

          Column(
            children: [
              _buildProfileImage(),

              const SizedBox(height: 15),

              Text(
                displayName,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),

              const SizedBox(height: 5),

              Text(
                user?.email ?? "",
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: textSecondary,
                  fontSize: 10.5,
                ),
              ),

              const SizedBox(height: 13),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 13,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: neonGreen.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: neonGreen.withValues(alpha: 0.24),
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.verified_user_rounded,
                      color: neonGreen,
                      size: 14,
                    ),
                    SizedBox(width: 6),
                    Text(
                      "STUDENT PROFILE",
                      style: TextStyle(
                        color: neonGreen,
                        fontSize: 8.5,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.8,
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
  // PROFILE IMAGE
  // ============================================================

  Widget _buildProfileImage() {
    final String? photoUrl = user?.photoURL;

    return Container(
      width: 108,
      height: 108,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [
            neonBlue,
            neonPurple,
            neonCyan,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: neonBlue.withValues(alpha: 0.20),
            blurRadius: 25,
          ),
          BoxShadow(
            color: neonPurple.withValues(alpha: 0.14),
            blurRadius: 25,
          ),
        ],
      ),
      child: Container(
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: cyberNavy,
        ),
        child: ClipOval(
          child: photoUrl != null &&
              photoUrl.trim().isNotEmpty
              ? Image.network(
            photoUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) {
              return const Icon(
                Icons.person_rounded,
                size: 53,
                color: neonBlue,
              );
            },
          )
              : const Icon(
            Icons.person_rounded,
            size: 53,
            color: neonBlue,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // SECTION HEADER
  // ============================================================

  Widget _sectionTitle(
      String tag,
      String title,
      String subtitle,
      Color color,
      IconData icon,
      ) {
    return Row(
      children: [
        Container(
          height: 42,
          width: 42,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.09),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: color.withValues(alpha: 0.25),
            ),
          ),
          child: Icon(
            icon,
            color: color,
            size: 21,
          ),
        ),

        const SizedBox(width: 11),

        Expanded(
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    tag,
                    style: TextStyle(
                      color: color,
                      fontSize: 8,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(width: 7),
                  Container(
                    width: 16,
                    height: 1,
                    color: color.withValues(alpha: 0.45),
                  ),
                  const SizedBox(width: 7),
                  Text(
                    title,
                    style: const TextStyle(
                      color: textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.6,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: const TextStyle(
                  color: textSecondary,
                  fontSize: 9.5,
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

  Widget _buildInputField({
    required String label,
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    required Color accentColor,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    TextCapitalization textCapitalization =
        TextCapitalization.none,
    int? maxLength,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              color: accentColor,
              size: 15,
            ),
            const SizedBox(width: 6),
            Text(
              label.toUpperCase(),
              style: TextStyle(
                color: accentColor,
                fontSize: 9,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        TextField(
          controller: controller,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          textCapitalization: textCapitalization,
          maxLength: maxLength,
          style: const TextStyle(
            color: textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
          cursorColor: accentColor,
          onChanged: (_) {
            if (label == "Full Name" && mounted) {
              setState(() {});
            }
          },
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              color: textMuted,
              fontSize: 12.5,
            ),
            counterText: "",
            prefixIcon: Icon(
              icon,
              color: accentColor,
              size: 20,
            ),
            filled: true,
            fillColor: cyberBlack,
            contentPadding:
            const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius:
              BorderRadius.circular(15),
              borderSide: BorderSide(
                color: border,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius:
              BorderRadius.circular(15),
              borderSide: BorderSide(
                color: border,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius:
              BorderRadius.circular(15),
              borderSide: BorderSide(
                color: accentColor,
                width: 1.3,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // EMAIL FIELD
  // ============================================================

  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.email_outlined,
              color: neonCyan,
              size: 15,
            ),
            const SizedBox(width: 6),
            const Text(
              "EMAIL ADDRESS",
              style: TextStyle(
                color: neonCyan,
                fontSize: 9,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 15,
          ),
          decoration: BoxDecoration(
            color: cyberBlack,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: border,
            ),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.email_outlined,
                color: neonCyan,
                size: 20,
              ),

              const SizedBox(width: 11),

              Expanded(
                child: Text(
                  user?.email ??
                      "No email available",
                  maxLines: 1,
                  overflow:
                  TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: textPrimary,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              const SizedBox(width: 8),

              Container(
                padding:
                const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: neonCyan
                      .withValues(alpha: 0.07),
                  borderRadius:
                  BorderRadius.circular(9),
                  border: Border.all(
                    color: neonCyan
                        .withValues(alpha: 0.15),
                  ),
                ),
                child: const Icon(
                  Icons.lock_outline_rounded,
                  size: 15,
                  color: textMuted,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),

        Row(
          children: [
            const Icon(
              Icons.info_outline_rounded,
              size: 13,
              color: textMuted,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                "Email is linked to your account and cannot be edited here.",
                style: const TextStyle(
                  fontSize: 9.5,
                  color: textMuted,
                  height: 1.35,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ============================================================
  // SECURITY CARD
  // ============================================================

  Widget _buildSecurityCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: panel,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(
          color: neonGreen.withValues(alpha: 0.20),
        ),
        boxShadow: [
          BoxShadow(
            color: neonGreen.withValues(alpha: 0.05),
            blurRadius: 18,
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Container(
            width: 43,
            height: 43,
            decoration: BoxDecoration(
              color: neonGreen.withValues(alpha: 0.08),
              borderRadius:
              BorderRadius.circular(12),
              border: Border.all(
                color: neonGreen.withValues(alpha: 0.20),
              ),
            ),
            child: const Icon(
              Icons.security_rounded,
              color: neonGreen,
              size: 21,
            ),
          ),

          const SizedBox(width: 12),

          const Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  "SECURITY STATUS",
                  style: TextStyle(
                    color: neonGreen,
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.9,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  "Your profile information is securely stored in your MMOC Teach account.",
                  style: TextStyle(
                    color: textSecondary,
                    fontSize: 10.5,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),

          const Icon(
            Icons.check_circle_rounded,
            color: neonGreen,
            size: 18,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SAVE BUTTON
  // ============================================================

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: isSaving
            ? null
            : saveProfile,
        style: ElevatedButton.styleFrom(
          backgroundColor: neonBlue,
          disabledBackgroundColor:
          const Color(0xff20314B),
          foregroundColor: cyberBlack,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(16),
            side: BorderSide(
              color: neonBlue.withValues(alpha: 0.55),
            ),
          ),
          shadowColor:
          neonBlue.withValues(alpha: 0.30),
        ),
        child: isSaving
            ? const Row(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 21,
              height: 21,
              child:
              CircularProgressIndicator(
                strokeWidth: 2.3,
                color: cyberBlack,
              ),
            ),
            SizedBox(width: 11),
            Text(
              "SYNCING PROFILE...",
              style: TextStyle(
                fontSize: 11,
                fontWeight:
                FontWeight.w900,
                letterSpacing: 0.8,
              ),
            ),
          ],
        )
            : const Row(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            Icon(
              Icons.save_rounded,
              size: 20,
            ),
            SizedBox(width: 9),
            Text(
              "SAVE CHANGES",
              style: TextStyle(
                fontSize: 12,
                fontWeight:
                FontWeight.w900,
                letterSpacing: 0.9,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // LOADING SCREEN
  // ============================================================

  Widget _loadingScreen() {
    return Scaffold(
      backgroundColor: cyberBlack,
      body: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _CyberGridPainter(),
            ),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 65,
                  width: 65,
                  child: CustomPaint(
                    painter: _LoadingPainter(),
                  ),
                ),
                const SizedBox(height: 17),
                const Text(
                  "LOADING PROFILE...",
                  style: TextStyle(
                    color: neonBlue,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.3,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  "Connecting to account database",
                  style: TextStyle(
                    color: textMuted,
                    fontSize: 9,
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
  // LOGIN REQUIRED
  // ============================================================

  Widget _loginRequiredScreen() {
    return Scaffold(
      backgroundColor: cyberBlack,
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _CyberGridPainter(),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(30),
              child: Container(
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  color: panel,
                  borderRadius:
                  BorderRadius.circular(23),
                  border: Border.all(
                    color:
                    neonPink.withValues(alpha: 0.25),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: neonPink
                          .withValues(alpha: 0.08),
                      blurRadius: 25,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize:
                  MainAxisSize.min,
                  children: [
                    Container(
                      height: 78,
                      width: 78,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: neonPink
                            .withValues(alpha: 0.08),
                        border: Border.all(
                          color: neonPink
                              .withValues(alpha: 0.28),
                        ),
                      ),
                      child: const Icon(
                        Icons.person_off_rounded,
                        size: 37,
                        color: neonPink,
                      ),
                    ),

                    const SizedBox(height: 18),

                    const Text(
                      "ACCESS DENIED",
                      style: TextStyle(
                        color: textPrimary,
                        fontSize: 19,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.9,
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      "Please login again to edit your profile.",
                      textAlign:
                      TextAlign.center,
                      style: TextStyle(
                        color: textSecondary,
                        fontSize: 10.5,
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 14),

                    const Text(
                      "AUTH_REQUIRED // 401",
                      style: TextStyle(
                        color: neonPink,
                        fontSize: 8,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.8,
                      ),
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

  // ============================================================
  // MAIN BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return _loadingScreen();
    }

    if (user == null) {
      return _loginRequiredScreen();
    }

    return Scaffold(
      backgroundColor: cyberBlack,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: _CyberGridPainter(),
                ),
              ),
            ),

            SingleChildScrollView(
              keyboardDismissBehavior:
              ScrollViewKeyboardDismissBehavior
                  .onDrag,
              physics:
              const BouncingScrollPhysics(),
              child: Column(
                children: [
                  _buildHeader(),

                  Padding(
                    padding:
                    const EdgeInsets.fromLTRB(
                      18,
                      24,
                      18,
                      35,
                    ),
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        _sectionTitle(
                          "01",
                          "IDENTITY CORE",
                          "Update your personal information",
                          neonBlue,
                          Icons.person_outline_rounded,
                        ),

                        const SizedBox(height: 14),

                        Container(
                          width: double.infinity,
                          padding:
                          const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: panel,
                            borderRadius:
                            BorderRadius.circular(
                              22,
                            ),
                            border: Border.all(
                              color: border,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: neonBlue
                                    .withValues(
                                  alpha: 0.04,
                                ),
                                blurRadius: 22,
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              _buildInputField(
                                label: "Full Name",
                                hint:
                                "Enter your full name",
                                icon: Icons
                                    .person_outline_rounded,
                                controller:
                                nameController,
                                accentColor:
                                neonBlue,
                                textInputAction:
                                TextInputAction
                                    .next,
                                textCapitalization:
                                TextCapitalization
                                    .words,
                              ),

                              const SizedBox(
                                height: 20,
                              ),

                              _buildInputField(
                                label:
                                "Mobile Number",
                                hint:
                                "Enter 10-digit mobile number",
                                icon: Icons
                                    .phone_outlined,
                                controller:
                                mobileController,
                                accentColor:
                                neonPurple,
                                keyboardType:
                                TextInputType.phone,
                                textInputAction:
                                TextInputAction
                                    .next,
                                maxLength: 10,
                              ),

                              const SizedBox(
                                height: 20,
                              ),

                              _buildEmailField(),
                            ],
                          ),
                        ),

                        const SizedBox(height: 23),

                        _sectionTitle(
                          "02",
                          "SECURITY CORE",
                          "Account protection information",
                          neonGreen,
                          Icons.security_rounded,
                        ),

                        const SizedBox(height: 14),

                        _buildSecurityCard(),

                        const SizedBox(height: 25),

                        _buildSaveButton(),

                        const SizedBox(height: 13),

                        Center(
                          child: Row(
                            mainAxisAlignment:
                            MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.cloud_done_rounded,
                                size: 14,
                                color: neonGreen,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                "FIREBASE SYNC READY",
                                style: TextStyle(
                                  color: textMuted,
                                  fontSize: 8.5,
                                  fontWeight:
                                  FontWeight.w800,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 28),

                        const Center(
                          child: Column(
                            children: [
                              Text(
                                "MMOC // TEACH",
                                style: TextStyle(
                                  color: neonBlue,
                                  fontSize: 11,
                                  fontWeight:
                                  FontWeight.w900,
                                  letterSpacing: 1.8,
                                ),
                              ),
                              SizedBox(height: 5),
                              Text(
                                "LEARN • GROW • SUCCEED",
                                style: TextStyle(
                                  color: textMuted,
                                  fontSize: 7.5,
                                  fontWeight:
                                  FontWeight.w700,
                                  letterSpacing: 1,
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
          ],
        ),
      ),
    );
  }
}

// ============================================================
// CYBER GRID PAINTER
// ============================================================

class _CyberGridPainter extends CustomPainter {
  @override
  void paint(
      Canvas canvas,
      Size size,
      ) {
    final Paint gridPaint = Paint()
      ..color = const Color(0xff16213A)
          .withValues(alpha: 0.30)
      ..strokeWidth = 0.5;

    const double spacing = 28;

    for (double x = 0;
    x <= size.width;
    x += spacing) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        gridPaint,
      );
    }

    for (double y = 0;
    y <= size.height;
    y += spacing) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        gridPaint,
      );
    }

    final Paint dotPaint = Paint()
      ..color = neonBlue.withValues(alpha: 0.11);

    for (double x = 14;
    x < size.width;
    x += 56) {
      for (double y = 14;
      y < size.height;
      y += 56) {
        canvas.drawCircle(
          Offset(x, y),
          1,
          dotPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(
      covariant CustomPainter oldDelegate,
      ) {
    return false;
  }
}

// ============================================================
// LOADING PAINTER
// ============================================================

class _LoadingPainter extends CustomPainter {
  @override
  void paint(
      Canvas canvas,
      Size size,
      ) {
    final Offset center = Offset(
      size.width / 2,
      size.height / 2,
    );

    final double radius =
        size.width / 2 - 5;

    final Paint outer = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round
      ..color = neonBlue;

    canvas.drawArc(
      Rect.fromCircle(
        center: center,
        radius: radius,
      ),
      -math.pi / 2,
      math.pi * 1.45,
      false,
      outer,
    );

    final Paint inner = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color =
      neonPurple.withValues(alpha: 0.35);

    canvas.drawCircle(
      center,
      radius - 10,
      inner,
    );
  }

  @override
  bool shouldRepaint(
      covariant CustomPainter oldDelegate,
      ) {
    return false;
  }
}