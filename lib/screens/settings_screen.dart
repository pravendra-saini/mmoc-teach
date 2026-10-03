import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'login_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

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
  // LOGOUT
  // ============================================================

  Future<void> _logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();

      if (!context.mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        ),
            (route) => false,
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Logout failed: $e",
            style: const TextStyle(
              color: white,
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: const Color(0xFF24101A),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(
              color: Colors.redAccent.withValues(alpha: 0.45),
            ),
          ),
        ),
      );
    }
  }

  // ============================================================
  // ABOUT
  // ============================================================

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return _CyberDialog(
          icon: Icons.school_rounded,
          iconColor: blue,
          title: "ABOUT MMOC TEACH",
          child: const Text(
            "MMOC Teach is an educational platform designed to help "
                "students learn, grow and succeed through structured courses "
                "and learning resources.\n\n"
                "Version 1.0",
            style: TextStyle(
              color: muted,
              fontSize: 14,
              height: 1.7,
            ),
          ),
          actions: [
            _dialogButton(
              text: "CLOSE",
              color: blue,
              onPressed: () => Navigator.pop(dialogContext),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // PRIVACY
  // ============================================================

  void _showPrivacyPolicy(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return _CyberDialog(
          icon: Icons.shield_rounded,
          iconColor: cyan,
          title: "PRIVACY POLICY",
          child: const SingleChildScrollView(
            child: Text(
              "MMOC Teach respects your privacy.\n\n"
                  "Your account information is used to provide you with "
                  "learning services and personalize your experience.\n\n"
                  "We do not intentionally share your personal information "
                  "with unauthorized third parties.\n\n"
                  "For privacy-related questions, please contact us at "
                  "support@mmocteach.com.",
              style: TextStyle(
                color: muted,
                fontSize: 14,
                height: 1.7,
              ),
            ),
          ),
          actions: [
            _dialogButton(
              text: "CLOSE",
              color: cyan,
              onPressed: () => Navigator.pop(dialogContext),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // RATE
  // ============================================================

  void _showRateMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(
              Icons.star_rounded,
              color: orange,
            ),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                "App rating will be available soon.",
                style: TextStyle(
                  color: white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: panel2,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(
            color: orange.withValues(alpha: 0.35),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // CONTACT
  // ============================================================

  void _showContactMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(
              Icons.mail_rounded,
              color: cyan,
            ),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                "Contact us at support@mmocteach.com",
                style: TextStyle(
                  color: white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: panel2,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(
            color: cyan.withValues(alpha: 0.35),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // SECTION TITLE
  // ============================================================

  Widget _sectionTitle(
      String title, {
        required Color color,
        required String number,
      }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
      child: Row(
        children: [
          Container(
            height: 24,
            width: 24,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(7),
              border: Border.all(
                color: color.withValues(alpha: 0.35),
              ),
            ),
            child: Text(
              number,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            title.toUpperCase(),
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.8,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    color.withValues(alpha: 0.35),
                    Colors.transparent,
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
  // SETTING CARD
  // ============================================================

  Widget _settingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required Color color,
    required String tag,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: panel,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: color.withValues(alpha: 0.18),
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.05),
            blurRadius: 18,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          splashColor: color.withValues(alpha: 0.08),
          highlightColor: color.withValues(alpha: 0.04),
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Row(
              children: [
                // Icon
                Container(
                  height: 52,
                  width: 52,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: color.withValues(alpha: 0.22),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.10),
                        blurRadius: 14,
                      ),
                    ],
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 24,
                  ),
                ),

                const SizedBox(width: 15),

                // Text
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: white,
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.07),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Text(
                              tag,
                              style: TextStyle(
                                color: color,
                                fontSize: 8,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.7,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text(
                        subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: muted,
                          fontSize: 11,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 10),

                // Arrow
                Container(
                  height: 32,
                  width: 32,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.06),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: color.withValues(alpha: 0.14),
                    ),
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 12,
                    color: color.withValues(alpha: 0.75),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // LOGOUT CARD
  // ============================================================

  Widget _logoutTile(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF160B15),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.redAccent.withValues(alpha: 0.28),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.redAccent.withValues(alpha: 0.07),
            blurRadius: 20,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => _showLogoutDialog(context),
          splashColor: Colors.redAccent.withValues(alpha: 0.08),
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Row(
              children: [
                Container(
                  height: 52,
                  width: 52,
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: Colors.redAccent.withValues(alpha: 0.25),
                    ),
                  ),
                  child: const Icon(
                    Icons.power_settings_new_rounded,
                    color: Colors.redAccent,
                    size: 25,
                  ),
                ),
                const SizedBox(width: 15),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "LOGOUT",
                        style: TextStyle(
                          color: Colors.redAccent,
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.8,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        "Sign out from your MMOC Teach account",
                        style: TextStyle(
                          color: muted,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 32,
                  width: 32,
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withValues(alpha: 0.06),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.redAccent.withValues(alpha: 0.18),
                    ),
                  ),
                  child: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Colors.redAccent,
                    size: 12,
                  ),
                ),
              ],
            ),
          ),
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

      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: white,
        titleSpacing: 6,
        title: const Row(
          children: [
            Text(
              "SETTINGS",
              style: TextStyle(
                color: white,
                fontSize: 20,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
              ),
            ),
            SizedBox(width: 8),
            Text(
              "//",
              style: TextStyle(
                color: blue,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),

      body: SafeArea(
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(
            top: 8,
            bottom: 35,
          ),
          children: [
            // ======================================================
            // TOP CYBER HEADER
            // ======================================================

            Container(
              margin: const EdgeInsets.fromLTRB(18, 8, 18, 4),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF09162C),
                    Color(0xFF10102A),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: blue.withValues(alpha: 0.25),
                ),
                boxShadow: [
                  BoxShadow(
                    color: blue.withValues(alpha: 0.09),
                    blurRadius: 30,
                    spreadRadius: 2,
                  ),
                  BoxShadow(
                    color: purple.withValues(alpha: 0.06),
                    blurRadius: 40,
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Decorative glow
                  Positioned(
                    right: -25,
                    top: -35,
                    child: Container(
                      height: 120,
                      width: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: purple.withValues(alpha: 0.07),
                      ),
                    ),
                  ),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            height: 58,
                            width: 58,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  blue,
                                  purple,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(17),
                              boxShadow: [
                                BoxShadow(
                                  color: blue.withValues(alpha: 0.25),
                                  blurRadius: 18,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.settings_rounded,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 15),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "APP CONTROL",
                                  style: TextStyle(
                                    color: blue,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 2,
                                  ),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  "Settings",
                                  style: TextStyle(
                                    color: white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 18),

                      Container(
                        height: 1,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              blue.withValues(alpha: 0.45),
                              purple.withValues(alpha: 0.20),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 14),

                      const Row(
                        children: [
                          Icon(
                            Icons.terminal_rounded,
                            color: cyan,
                            size: 15,
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "Manage your MMOC Teach experience",
                              style: TextStyle(
                                color: muted,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ======================================================
            // GENERAL
            // ======================================================

            _sectionTitle(
              "General",
              color: blue,
              number: "01",
            ),

            _settingsTile(
              icon: Icons.info_outline_rounded,
              title: "About App",
              subtitle: "MMOC Teach v1.0",
              color: blue,
              tag: "INFO",
              onTap: () => _showAboutDialog(context),
            ),

            _settingsTile(
              icon: Icons.mail_outline_rounded,
              title: "Contact Us",
              subtitle: "support@mmocteach.com",
              color: cyan,
              tag: "MAIL",
              onTap: () => _showContactMessage(context),
            ),

            // ======================================================
            // APP
            // ======================================================

            _sectionTitle(
              "Application",
              color: purple,
              number: "02",
            ),

            _settingsTile(
              icon: Icons.shield_outlined,
              title: "Privacy Policy",
              subtitle: "Learn how your information is handled",
              color: cyan,
              tag: "SAFE",
              onTap: () => _showPrivacyPolicy(context),
            ),

            _settingsTile(
              icon: Icons.star_outline_rounded,
              title: "Rate App",
              subtitle: "Share your experience with MMOC Teach",
              color: orange,
              tag: "RATE",
              onTap: () => _showRateMessage(context),
            ),

            // ======================================================
            // ACCOUNT
            // ======================================================

            _sectionTitle(
              "Account",
              color: green,
              number: "03",
            ),

            _logoutTile(context),

            const SizedBox(height: 28),

            // ======================================================
            // FOOTER
            // ======================================================

            Center(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: 5,
                        width: 5,
                        decoration: const BoxDecoration(
                          color: green,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 7),
                      const Text(
                        "MMOC TEACH SYSTEM ONLINE",
                        style: TextStyle(
                          color: muted,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.4,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "LEARN  •  GROW  •  SUCCEED",
                    style: TextStyle(
                      color: Color(0xFF4D5B73),
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
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
  // LOGOUT DIALOG
  // ============================================================

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return _CyberDialog(
          icon: Icons.power_settings_new_rounded,
          iconColor: Colors.redAccent,
          title: "CONFIRM LOGOUT",
          child: const Text(
            "Are you sure you want to logout from MMOC Teach?",
            style: TextStyle(
              color: muted,
              fontSize: 14,
              height: 1.5,
            ),
          ),
          actions: [
            _dialogButton(
              text: "CANCEL",
              color: muted,
              onPressed: () => Navigator.pop(dialogContext),
            ),
            _dialogButton(
              text: "LOGOUT",
              color: Colors.redAccent,
              onPressed: () async {
                Navigator.pop(dialogContext);
                await _logout(context);
              },
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // DIALOG BUTTON
  // ============================================================

  static Widget _dialogButton({
    required String text,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: color,
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 10,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(
            color: color.withValues(alpha: 0.25),
          ),
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w900,
          letterSpacing: 1,
        ),
      ),
    );
  }
}

// ================================================================
// CYBER DIALOG WIDGET
// ================================================================

class _CyberDialog extends StatelessWidget {
  const _CyberDialog({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.child,
    required this.actions,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final Widget child;
  final List<Widget> actions;

  static const Color panel = Color(0xFF0A1020);
  static const Color white = Color(0xFFF4F8FF);
  static const Color border = Color(0xFF172B4D);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(
        horizontal: 22,
        vertical: 24,
      ),
      child: Container(
        constraints: const BoxConstraints(
          maxHeight: 560,
        ),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: panel,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: iconColor.withValues(alpha: 0.28),
          ),
          boxShadow: [
            BoxShadow(
              color: iconColor.withValues(alpha: 0.10),
              blurRadius: 30,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  height: 45,
                  width: 45,
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(13),
                    border: Border.all(
                      color: iconColor.withValues(alpha: 0.22),
                    ),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: 23,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: iconColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    iconColor.withValues(alpha: 0.30),
                    border,
                    Colors.transparent,
                  ],
                ),
              ),
            ),

            const SizedBox(height: 18),

            Flexible(
              child: child,
            ),

            const SizedBox(height: 18),

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: actions,
            ),
          ],
        ),
      ),
    );
  }
}