import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'signup_screen.dart';
import 'home_screen.dart';
import 'admin_dashboard.dart';
import 'admin_login_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  // ============================================================
  // CONTROLLERS
  // ============================================================

  final TextEditingController emailController =
  TextEditingController();

  final TextEditingController passwordController =
  TextEditingController();

  // ============================================================
  // STATES
  // ============================================================

  bool isLoading = false;
  bool isGoogleLoading = false;
  bool obscurePassword = true;

  // Hidden admin tap counter
  int adminTapCount = 0;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _animationController.forward();

    initializeGoogleSignIn();
  }

  // ============================================================
  // GOOGLE SIGN-IN INITIALIZATION
  // ============================================================

  Future<void> initializeGoogleSignIn() async {
    try {
      await GoogleSignIn.instance.initialize();
    } catch (e) {
      debugPrint(
        "Google Sign-In initialization error: $e",
      );
    }
  }

  // ============================================================
  // EMAIL + PASSWORD LOGIN
  // ============================================================

  Future<void> loginUser() async {
    FocusScope.of(context).unfocus();

    if (emailController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty) {
      _showMessage(
        "Please enter email and password",
        isError: true,
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final user = await _loginWithEmailPassword();

      if (!mounted) return;

      if (user != null) {
        await openUserHome(user);
      } else {
        _showMessage(
          "Invalid Email or Password",
          isError: true,
        );
      }
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        "Login failed: $e",
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<User?> _loginWithEmailPassword() async {
    try {
      final credential =
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      return credential.user;
    } on FirebaseAuthException {
      // Keep the same external behavior as the old screen.
      rethrow;
    }
  }

  // ============================================================
  // GOOGLE LOGIN
  // ============================================================

  Future<void> loginWithGoogle() async {
    FocusScope.of(context).unfocus();

    setState(() {
      isGoogleLoading = true;
    });

    try {
      final GoogleSignInAccount googleUser =
      await GoogleSignIn.instance.authenticate();

      final GoogleSignInAuthentication googleAuth =
          googleUser.authentication;

      final idToken = googleAuth.idToken;

      if (idToken == null) {
        throw Exception(
          "Google ID Token not found.",
        );
      }

      final credential = GoogleAuthProvider.credential(
        idToken: idToken,
      );

      final userCredential =
      await FirebaseAuth.instance.signInWithCredential(
        credential,
      );

      final user = userCredential.user;

      if (user == null) {
        throw Exception(
          "Google login failed.",
        );
      }

      // ========================================================
      // SAVE GOOGLE USER IN FIRESTORE
      // ========================================================

      await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .set(
        {
          "uid": user.uid,
          "email": user.email,
          "name": user.displayName ??
              googleUser.displayName ??
              "MMOC Student",
          "photoURL":
          user.photoURL ?? googleUser.photoUrl,
          "role": "student",
          "loginMethod": "google",
        },
        SetOptions(merge: true),
      );

      if (!mounted) return;

      _showMessage(
        "Google Login Successful",
      );

      await openUserHome(user);
    } on GoogleSignInException catch (e) {
      if (!mounted) return;

      debugPrint(
        "Google Sign-In Error: ${e.code}",
      );

      _showMessage(
        "Google Login Failed: "
            "${e.description ?? e.code}",
        isError: true,
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      _showMessage(
        "Firebase Login Failed: "
            "${e.message ?? e.code}",
        isError: true,
      );
    } catch (e) {
      if (!mounted) return;

      debugPrint(
        "Google Login Error: $e",
      );

      _showMessage(
        "Google Login Failed. Please try again.",
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          isGoogleLoading = false;
        });
      }
    }
  }

  // ============================================================
  // OPEN ADMIN / STUDENT HOME
  // ============================================================

  Future<void> openUserHome(User user) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .get();

      debugPrint("UID: ${user.uid}");
      debugPrint(
        "Document Exists: ${doc.exists}",
      );
      debugPrint(
        "Data: ${doc.data()}",
      );

      final data = doc.data();

      if (!mounted) return;

      if (data != null &&
          data["role"] == "admin") {
        debugPrint("ADMIN LOGIN");

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const AdminDashboard(),
          ),
        );
      } else {
        debugPrint("STUDENT LOGIN");

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const HomeScreen(),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        "Unable to load your profile. Please try again.",
        isError: true,
      );
    }
  }

  // ============================================================
  // FORGOT PASSWORD
  // ============================================================

  Future<void> forgotPassword() async {
    FocusScope.of(context).unfocus();

    final email = emailController.text.trim();

    if (email.isEmpty) {
      _showMessage(
        "Please enter your email first",
        isError: true,
      );
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: email,
      );

      if (!mounted) return;

      _showMessage(
        "Password reset link sent to your email",
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      String message =
          "Unable to send reset email.";

      if (e.code == "user-not-found") {
        message =
        "No account found with this email.";
      } else if (e.code == "invalid-email") {
        message =
        "Please enter a valid email.";
      }

      _showMessage(
        message,
        isError: true,
      );
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        "Something went wrong.",
        isError: true,
      );
    }
  }

  // ============================================================
  // SNACKBAR
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
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xff0B1228),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(
              color: isError
                  ? const Color(0xffFB7185)
                  : const Color(0xff22C55E),
              width: 1,
            ),
          ),
          content: Row(
            children: [
              Icon(
                isError
                    ? Icons.error_outline_rounded
                    : Icons.check_circle_outline_rounded,
                color: isError
                    ? const Color(0xffFB7185)
                    : const Color(0xff22C55E),
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
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
    emailController.dispose();
    passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  // ============================================================
  // UI
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff040713),
      body: Stack(
        children: [
          // ======================================================
          // BACKGROUND
          // ======================================================

          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xff02040D),
                  Color(0xff071027),
                  Color(0xff0A071B),
                  Color(0xff03050E),
                ],
              ),
            ),
          ),

          // ======================================================
          // CYBER GRID
          // ======================================================

          Positioned.fill(
            child: CustomPaint(
              painter: _LoginGridPainter(),
            ),
          ),

          // ======================================================
          // TOP RIGHT PURPLE GLOW
          // ======================================================

          Positioned(
            top: -150,
            right: -110,
            child: Container(
              height: 360,
              width: 360,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xff8B5CF6)
                    .withValues(alpha: 0.10),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xff8B5CF6)
                        .withValues(alpha: 0.20),
                    blurRadius: 120,
                    spreadRadius: 35,
                  ),
                ],
              ),
            ),
          ),

          // ======================================================
          // BOTTOM LEFT CYAN GLOW
          // ======================================================

          Positioned(
            bottom: -170,
            left: -120,
            child: Container(
              height: 390,
              width: 390,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xff00E5FF)
                    .withValues(alpha: 0.07),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xff00E5FF)
                        .withValues(alpha: 0.15),
                    blurRadius: 120,
                    spreadRadius: 30,
                  ),
                ],
              ),
            ),
          ),

          // ======================================================
          // MAIN CONTENT
          // ======================================================

          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                22,
                28,
                22,
                30,
              ),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Column(
                    children: [
                      // ==================================================
                      // TOP STATUS
                      // ==================================================

                      Row(
                        mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                        children: [
                          _statusChip(
                            icon: Icons.shield_outlined,
                            text: "SECURE ACCESS",
                            color: const Color(0xff00E5FF),
                          ),
                          _statusChip(
                            icon: Icons.circle,
                            text: "ONLINE",
                            color: const Color(0xff22C55E),
                            smallIcon: true,
                          ),
                        ],
                      ),

                      const SizedBox(height: 30),

                      // ==================================================
                      // LOGO + HIDDEN ADMIN
                      // ==================================================

                      GestureDetector(
                        onTap: () {
                          adminTapCount++;

                          if (adminTapCount >= 5) {
                            adminTapCount = 0;

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                const AdminLoginScreen(),
                              ),
                            );
                          }
                        },
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Outer neon ring
                            Container(
                              height: 154,
                              width: 154,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(0xff00E5FF)
                                      .withValues(alpha: 0.28),
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xff00E5FF)
                                        .withValues(alpha: 0.12),
                                    blurRadius: 30,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                            ),

                            // Purple inner ring
                            Container(
                              height: 140,
                              width: 140,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(0xffA855F7)
                                      .withValues(alpha: 0.32),
                                  width: 1,
                                ),
                              ),
                            ),

                            // Existing logo
                            Container(
                              height: 122,
                              width: 122,
                              padding:
                              const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                color: const Color(0xff0A1024),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(0xff00E5FF)
                                      .withValues(alpha: 0.72),
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xff00E5FF)
                                        .withValues(alpha: 0.20),
                                    blurRadius: 24,
                                  ),
                                ],
                              ),
                              child: ClipOval(
                                child: Image.asset(
                                  "assets/icons/app_logo.png",
                                  fit: BoxFit.cover,
                                  errorBuilder:
                                      (context, error, stackTrace) {
                                    return const Icon(
                                      Icons.school_rounded,
                                      size: 58,
                                      color: Color(0xff00E5FF),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 22),

                      // ==================================================
                      // APP NAME
                      // ==================================================

                      ShaderMask(
                        shaderCallback: (bounds) {
                          return const LinearGradient(
                            colors: [
                              Color(0xff00E5FF),
                              Color(0xff7C3AED),
                              Color(0xffC084FC),
                            ],
                          ).createShader(bounds);
                        },
                        child: const Text(
                          "MMOC Teach",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 31,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1,
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        "WELCOME BACK, LEARNER",
                        style: TextStyle(
                          color: Colors.white.withValues(
                            alpha: 0.48,
                          ),
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2,
                        ),
                      ),

                      const SizedBox(height: 32),

                      // ==================================================
                      // LOGIN PANEL
                      // ==================================================

                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xff080E20)
                              .withValues(alpha: 0.94),
                          borderRadius:
                          BorderRadius.circular(24),
                          border: Border.all(
                            color: const Color(0xff334B78)
                                .withValues(alpha: 0.45),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xff000000)
                                  .withValues(alpha: 0.35),
                              blurRadius: 35,
                              offset: const Offset(0, 18),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            // Panel heading
                            Row(
                              children: [
                                Container(
                                  height: 36,
                                  width: 36,
                                  decoration: BoxDecoration(
                                    color: const Color(0xff00E5FF)
                                        .withValues(alpha: 0.08),
                                    borderRadius:
                                    BorderRadius.circular(10),
                                    border: Border.all(
                                      color: const Color(0xff00E5FF)
                                          .withValues(alpha: 0.25),
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.login_rounded,
                                    color: Color(0xff00E5FF),
                                    size: 19,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "SIGN IN",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 15,
                                        fontWeight:
                                        FontWeight.w900,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                    SizedBox(height: 3),
                                    Text(
                                      "Access your learning hub",
                                      style: TextStyle(
                                        color:
                                        Color(0xff71809D),
                                        fontSize: 9,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),

                            const SizedBox(height: 24),

                            // ==================================================
                            // EMAIL
                            // ==================================================

                            _fieldLabel(
                              "EMAIL ADDRESS",
                              Icons.alternate_email_rounded,
                            ),

                            const SizedBox(height: 8),

                            _cyberTextField(
                              controller: emailController,
                              hintText: "Enter your email",
                              icon:
                              Icons.email_outlined,
                              keyboardType:
                              TextInputType.emailAddress,
                            ),

                            const SizedBox(height: 18),

                            // ==================================================
                            // PASSWORD
                            // ==================================================

                            _fieldLabel(
                              "PASSWORD",
                              Icons.lock_outline_rounded,
                            ),

                            const SizedBox(height: 8),

                            _cyberTextField(
                              controller: passwordController,
                              hintText: "Enter your password",
                              icon:
                              Icons.lock_outline_rounded,
                              obscureText: obscurePassword,
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    obscurePassword =
                                    !obscurePassword;
                                  });
                                },
                                icon: Icon(
                                  obscurePassword
                                      ? Icons
                                      .visibility_outlined
                                      : Icons
                                      .visibility_off_outlined,
                                  color:
                                  const Color(0xff71809D),
                                  size: 20,
                                ),
                              ),
                            ),

                            const SizedBox(height: 12),

                            // ==================================================
                            // FORGOT PASSWORD
                            // ==================================================

                            Align(
                              alignment:
                              Alignment.centerRight,
                              child: TextButton(
                                onPressed:
                                forgotPassword,
                                style: TextButton.styleFrom(
                                  padding:
                                  const EdgeInsets
                                      .symmetric(
                                    horizontal: 4,
                                    vertical: 4,
                                  ),
                                ),
                                child: const Text(
                                  "FORGOT PASSWORD?",
                                  style: TextStyle(
                                    color:
                                    Color(0xff00E5FF),
                                    fontSize: 9,
                                    fontWeight:
                                    FontWeight.w800,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 8),

                            // ==================================================
                            // LOGIN BUTTON
                            // ==================================================

                            _loginButton(),

                            const SizedBox(height: 22),

                            // ==================================================
                            // OR DIVIDER
                            // ==================================================

                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    height: 1,
                                    color: const Color(
                                      0xff263653,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding:
                                  const EdgeInsets
                                      .symmetric(
                                    horizontal: 13,
                                  ),
                                  child: Text(
                                    "OR",
                                    style: TextStyle(
                                      color: Colors.white
                                          .withValues(
                                        alpha: 0.35,
                                      ),
                                      fontSize: 9,
                                      fontWeight:
                                      FontWeight.w800,
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    height: 1,
                                    color: const Color(
                                      0xff263653,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 20),

                            // ==================================================
                            // GOOGLE BUTTON
                            // ==================================================

                            _googleButton(),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // ==================================================
                      // SIGN UP
                      // ==================================================

                      Container(
                        width: double.infinity,
                        padding:
                        const EdgeInsets.symmetric(
                          vertical: 15,
                          horizontal: 16,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xff080E20)
                              .withValues(alpha: 0.70),
                          borderRadius:
                          BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xff263653)
                                .withValues(alpha: 0.65),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment:
                          MainAxisAlignment.center,
                          children: [
                            Text(
                              "NEW TO MMOC?",
                              style: TextStyle(
                                color: Colors.white
                                    .withValues(alpha: 0.48),
                                fontSize: 9,
                                fontWeight:
                                FontWeight.w700,
                                letterSpacing: 0.8,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                    const SignupScreen(),
                                  ),
                                );
                              },
                              style: TextButton.styleFrom(
                                padding:
                                const EdgeInsets
                                    .symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                              ),
                              child: const Text(
                                "CREATE ACCOUNT",
                                style: TextStyle(
                                  color:
                                  Color(0xffA855F7),
                                  fontSize: 9,
                                  fontWeight:
                                  FontWeight.w900,
                                  letterSpacing: 0.7,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 22),

                      // ==================================================
                      // SECURITY FOOTER
                      // ==================================================

                      Row(
                        mainAxisAlignment:
                        MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.lock_outline_rounded,
                            size: 12,
                            color: Color(0xff22C55E),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            "YOUR CONNECTION IS SECURE",
                            style: TextStyle(
                              color: Colors.white
                                  .withValues(
                                alpha: 0.28,
                              ),
                              fontSize: 8,
                              fontWeight:
                              FontWeight.w700,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      Text(
                        "MMOC TEACH  •  V1.0.0",
                        style: TextStyle(
                          color: Colors.white.withValues(
                            alpha: 0.20,
                          ),
                          fontSize: 8,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
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
  // STATUS CHIP
  // ============================================================

  Widget _statusChip({
    required IconData icon,
    required String text,
    required Color color,
    bool smallIcon = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withValues(alpha: 0.18),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: smallIcon ? 7 : 12,
            color: color,
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: color.withValues(alpha: 0.72),
              fontSize: 7,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // FIELD LABEL
  // ============================================================

  Widget _fieldLabel(
      String text,
      IconData icon,
      ) {
    return Row(
      children: [
        Icon(
          icon,
          size: 12,
          color: const Color(0xff00E5FF),
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.58),
            fontSize: 8,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.1,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // CYBER TEXT FIELD
  // ============================================================

  Widget _cyberTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
      cursorColor: const Color(0xff00E5FF),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          color: Colors.white.withValues(alpha: 0.25),
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        prefixIcon: Icon(
          icon,
          color: const Color(0xff5E7195),
          size: 19,
        ),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: const Color(0xff050A18),
        contentPadding:
        const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 16,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: BorderSide(
            color: const Color(0xff263653)
                .withValues(alpha: 0.75),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: const BorderSide(
            color: Color(0xff00E5FF),
            width: 1.3,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // LOGIN BUTTON
  // ============================================================

  Widget _loginButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: const LinearGradient(
            colors: [
              Color(0xff00B8D9),
              Color(0xff2563EB),
              Color(0xff7C3AED),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xff2563EB)
                  .withValues(alpha: 0.25),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed:
          isLoading ? null : loginUser,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            disabledBackgroundColor:
            Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius:
              BorderRadius.circular(14),
            ),
          ),
          child: isLoading
              ? const SizedBox(
            height: 22,
            width: 22,
            child:
            CircularProgressIndicator(
              strokeWidth: 2,
              valueColor:
              AlwaysStoppedAnimation<
                  Color>(
                Colors.white,
              ),
            ),
          )
              : const Row(
            mainAxisAlignment:
            MainAxisAlignment.center,
            children: [
              Icon(
                Icons.login_rounded,
                color: Colors.white,
                size: 19,
              ),
              SizedBox(width: 9),
              Text(
                "ENTER LEARNING HUB",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight:
                  FontWeight.w900,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // GOOGLE BUTTON
  // ============================================================

  Widget _googleButton() {
    return SizedBox(
      width: double.infinity,
      height: 53,
      child: OutlinedButton(
        onPressed: isGoogleLoading
            ? null
            : loginWithGoogle,
        style: OutlinedButton.styleFrom(
          backgroundColor: const Color(0xff050A18),
          foregroundColor: Colors.white,
          side: BorderSide(
            color: const Color(0xff52617D)
                .withValues(alpha: 0.55),
          ),
          shape: RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(14),
          ),
        ),
        child: isGoogleLoading
            ? const SizedBox(
          height: 20,
          width: 20,
          child:
          CircularProgressIndicator(
            strokeWidth: 2,
            valueColor:
            AlwaysStoppedAnimation<
                Color>(
              Color(0xff00E5FF),
            ),
          ),
        )
            : Row(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            Container(
              height: 25,
              width: 25,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                BorderRadius.circular(7),
              ),
              child: const Text(
                "G",
                style: TextStyle(
                  color: Color(0xff4285F4),
                  fontSize: 16,
                  fontWeight:
                  FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              "CONTINUE WITH GOOGLE",
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight:
                FontWeight.w800,
                letterSpacing: 0.7,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ================================================================
// CYBER GRID PAINTER
// ================================================================

class _LoginGridPainter extends CustomPainter {
  @override
  void paint(
      Canvas canvas,
      Size size,
      ) {
    final Paint gridPaint = Paint()
      ..color =
      const Color(0xff1E3A5F)
          .withValues(alpha: 0.10)
      ..strokeWidth = 0.6;

    const double gridSize = 34;

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

    // Cyber nodes
    final Paint nodePaint = Paint()
      ..color =
      const Color(0xff00E5FF)
          .withValues(alpha: 0.18);

    for (
    double x = 0;
    x <= size.width;
    x += gridSize * 4
    ) {
      for (
      double y = 0;
      y <= size.height;
      y += gridSize * 4
      ) {
        canvas.drawCircle(
          Offset(x, y),
          1.2,
          nodePaint,
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