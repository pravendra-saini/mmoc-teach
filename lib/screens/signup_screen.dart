import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../models/user_model.dart';
import 'home_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen>
    with SingleTickerProviderStateMixin {
  // ============================================================
  // CONTROLLERS
  // ============================================================

  final TextEditingController nameController =
  TextEditingController();

  final TextEditingController emailController =
  TextEditingController();

  final TextEditingController mobileController =
  TextEditingController();

  final TextEditingController passwordController =
  TextEditingController();

  final TextEditingController confirmPasswordController =
  TextEditingController();

  // ============================================================
  // STATES
  // ============================================================

  bool isLoading = false;
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;

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
  }

  // ============================================================
  // SIGNUP USER
  // ============================================================

  Future<void> signupUser() async {
    FocusScope.of(context).unfocus();

    final String name = nameController.text.trim();
    final String email = emailController.text.trim();
    final String mobile = mobileController.text.trim();
    final String password = passwordController.text;
    final String confirmPassword =
        confirmPasswordController.text;

    // ==========================================================
    // BASIC VALIDATION
    // ==========================================================

    if (name.isEmpty ||
        email.isEmpty ||
        mobile.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      _showMessage(
        "Please fill all fields",
        isError: true,
      );
      return;
    }

    if (name.length < 2) {
      _showMessage(
        "Please enter a valid name",
        isError: true,
      );
      return;
    }

    if (mobile.length != 10 ||
        !RegExp(r'^[0-9]+$').hasMatch(mobile)) {
      _showMessage(
        "Please enter a valid 10-digit mobile number",
        isError: true,
      );
      return;
    }

    if (password.length < 6) {
      _showMessage(
        "Password must contain at least 6 characters",
        isError: true,
      );
      return;
    }

    if (password != confirmPassword) {
      _showMessage(
        "Passwords do not match",
        isError: true,
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // ========================================================
      // CREATE FIREBASE ACCOUNT
      // ========================================================

      final user = await AuthService().signUp(
        email: email,
        password: password,
      );

      if (user == null) {
        if (!mounted) return;

        _showMessage(
          "Signup failed. Please try again.",
          isError: true,
        );

        return;
      }

      // ========================================================
      // SEND EMAIL VERIFICATION
      // ========================================================

      await user.sendEmailVerification();

      // ========================================================
      // CREATE USER MODEL
      // ========================================================

      final UserModel newUser = UserModel(
        uid: user.uid,
        name: name,
        email: email,
        mobile: mobile,

        // Keep existing admin behavior.
        role: email == "pravendrasaini303@gmail.com"
            ? "admin"
            : "student",
      );

      // ========================================================
      // SAVE USER TO FIRESTORE
      // ========================================================

      try {
        debugPrint("Before Save");

        await FirestoreService().saveUser(newUser);

        debugPrint("After Save");
      } catch (e) {
        debugPrint(
          "SAVE ERROR: $e",
        );
      }

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      // ========================================================
      // SUCCESS MESSAGE
      // ========================================================

      _showMessage(
        "Account created! Verification email sent to your Gmail.",
      );

      // ========================================================
      // OPEN HOME SCREEN
      // ========================================================

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const HomeScreen(),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      _showMessage(
        "Signup failed: $e",
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
    nameController.dispose();
    emailController.dispose();
    mobileController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();

    _animationController.dispose();

    super.dispose();
  }

  // ============================================================
  // BUILD
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
              painter: _SignupGridPainter(),
            ),
          ),

          // ======================================================
          // PURPLE GLOW
          // ======================================================

          Positioned(
            top: -160,
            right: -110,
            child: Container(
              height: 370,
              width: 370,
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
          // CYAN GLOW
          // ======================================================

          Positioned(
            bottom: -180,
            left: -130,
            child: Container(
              height: 400,
              width: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xff00E5FF)
                    .withValues(alpha: 0.07),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xff00E5FF)
                        .withValues(alpha: 0.16),
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
                22,
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
                      // TOP BAR
                      // ==================================================

                      Row(
                        mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                        children: [
                          _statusChip(
                            icon: Icons.person_add_alt_1_rounded,
                            text: "NEW USER",
                            color: const Color(0xff00E5FF),
                          ),
                          _statusChip(
                            icon: Icons.shield_outlined,
                            text: "SECURE",
                            color: const Color(0xff22C55E),
                          ),
                        ],
                      ),

                      const SizedBox(height: 22),

                      // ==================================================
                      // BACK BUTTON
                      // ==================================================

                      Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          style: IconButton.styleFrom(
                            backgroundColor:
                            const Color(0xff0A1024),
                            side: BorderSide(
                              color: const Color(0xff334B78)
                                  .withValues(alpha: 0.45),
                            ),
                          ),
                          icon: const Icon(
                            Icons.arrow_back_rounded,
                            color: Color(0xffB8C5DE),
                            size: 19,
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // ==================================================
                      // LOGO
                      // ==================================================

                      Container(
                        height: 112,
                        width: 112,
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xff0A1024),
                          border: Border.all(
                            color: const Color(0xff00E5FF)
                                .withValues(alpha: 0.70),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xff00E5FF)
                                  .withValues(alpha: 0.18),
                              blurRadius: 28,
                              spreadRadius: 3,
                            ),
                            BoxShadow(
                              color: const Color(0xffA855F7)
                                  .withValues(alpha: 0.12),
                              blurRadius: 40,
                              spreadRadius: 5,
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
                                color: Color(0xff00E5FF),
                                size: 55,
                              );
                            },
                          ),
                        ),
                      ),

                      const SizedBox(height: 18),

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
                            fontSize: 29,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1,
                          ),
                        ),
                      ),

                      const SizedBox(height: 7),

                      Text(
                        "CREATE YOUR LEARNING IDENTITY",
                        style: TextStyle(
                          color: Colors.white.withValues(
                            alpha: 0.45,
                          ),
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.8,
                        ),
                      ),

                      const SizedBox(height: 28),

                      // ==================================================
                      // SIGNUP PANEL
                      // ==================================================

                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xff080E20)
                              .withValues(alpha: 0.95),
                          borderRadius:
                          BorderRadius.circular(24),
                          border: Border.all(
                            color: const Color(0xff334B78)
                                .withValues(alpha: 0.45),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black
                                  .withValues(alpha: 0.38),
                              blurRadius: 35,
                              offset: const Offset(0, 18),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            // ==================================================
                            // PANEL HEADER
                            // ==================================================

                            Row(
                              children: [
                                Container(
                                  height: 38,
                                  width: 38,
                                  decoration: BoxDecoration(
                                    color: const Color(0xffA855F7)
                                        .withValues(alpha: 0.08),
                                    borderRadius:
                                    BorderRadius.circular(11),
                                    border: Border.all(
                                      color: const Color(0xffA855F7)
                                          .withValues(alpha: 0.25),
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.person_add_rounded,
                                    color: Color(0xffC084FC),
                                    size: 19,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "CREATE ACCOUNT",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 15,
                                        fontWeight:
                                        FontWeight.w900,
                                        letterSpacing: 0.8,
                                      ),
                                    ),
                                    SizedBox(height: 3),
                                    Text(
                                      "Join the MMOC learning network",
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
                            // NAME
                            // ==================================================

                            _fieldLabel(
                              "FULL NAME",
                              Icons.person_outline_rounded,
                            ),

                            const SizedBox(height: 8),

                            _cyberTextField(
                              controller: nameController,
                              hintText: "Enter your full name",
                              icon:
                              Icons.person_outline_rounded,
                              textCapitalization:
                              TextCapitalization.words,
                            ),

                            const SizedBox(height: 17),

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

                            const SizedBox(height: 17),

                            // ==================================================
                            // MOBILE
                            // ==================================================

                            _fieldLabel(
                              "MOBILE NUMBER",
                              Icons.phone_android_rounded,
                            ),

                            const SizedBox(height: 8),

                            _cyberTextField(
                              controller: mobileController,
                              hintText: "10-digit mobile number",
                              icon:
                              Icons.phone_android_rounded,
                              keyboardType:
                              TextInputType.phone,
                              maxLength: 10,
                            ),

                            const SizedBox(height: 17),

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
                              hintText: "Create a password",
                              icon:
                              Icons.lock_outline_rounded,
                              obscureText:
                              obscurePassword,
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

                            const SizedBox(height: 17),

                            // ==================================================
                            // CONFIRM PASSWORD
                            // ==================================================

                            _fieldLabel(
                              "CONFIRM PASSWORD",
                              Icons.verified_user_outlined,
                            ),

                            const SizedBox(height: 8),

                            _cyberTextField(
                              controller:
                              confirmPasswordController,
                              hintText:
                              "Re-enter your password",
                              icon:
                              Icons.verified_user_outlined,
                              obscureText:
                              obscureConfirmPassword,
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    obscureConfirmPassword =
                                    !obscureConfirmPassword;
                                  });
                                },
                                icon: Icon(
                                  obscureConfirmPassword
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

                            const SizedBox(height: 10),

                            // ==================================================
                            // PASSWORD INFO
                            // ==================================================

                            Row(
                              children: [
                                const Icon(
                                  Icons.info_outline_rounded,
                                  color: Color(0xff00E5FF),
                                  size: 12,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  "Password must contain at least 6 characters",
                                  style: TextStyle(
                                    color: Colors.white
                                        .withValues(
                                      alpha: 0.30,
                                    ),
                                    fontSize: 8,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 22),

                            // ==================================================
                            // CREATE ACCOUNT BUTTON
                            // ==================================================

                            _createAccountButton(),
                          ],
                        ),
                      ),

                      const SizedBox(height: 18),

                      // ==================================================
                      // LOGIN LINK
                      // ==================================================

                      Container(
                        width: double.infinity,
                        padding:
                        const EdgeInsets.symmetric(
                          vertical: 15,
                          horizontal: 14,
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
                              "ALREADY REGISTERED?",
                              style: TextStyle(
                                color: Colors.white
                                    .withValues(alpha: 0.42),
                                fontSize: 8,
                                fontWeight:
                                FontWeight.w700,
                                letterSpacing: 0.7,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
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
                                "SIGN IN",
                                style: TextStyle(
                                  color:
                                  Color(0xff00E5FF),
                                  fontSize: 9,
                                  fontWeight:
                                  FontWeight.w900,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // ==================================================
                      // SECURITY FOOTER
                      // ==================================================

                      Row(
                        mainAxisAlignment:
                        MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.shield_outlined,
                            color: Color(0xff22C55E),
                            size: 12,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            "YOUR ACCOUNT DATA IS SECURED",
                            style: TextStyle(
                              color: Colors.white
                                  .withValues(
                                alpha: 0.25,
                              ),
                              fontSize: 8,
                              fontWeight:
                              FontWeight.w700,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 11),

                      Text(
                        "MMOC TEACH  •  V1.0.0",
                        style: TextStyle(
                          color: Colors.white.withValues(
                            alpha: 0.18,
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
            size: 12,
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
            letterSpacing: 1,
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
    TextCapitalization textCapitalization =
        TextCapitalization.none,
    int? maxLength,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      maxLength: maxLength,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
      cursorColor: const Color(0xff00E5FF),
      decoration: InputDecoration(
        counterText: "",
        hintText: hintText,
        hintStyle: TextStyle(
          color: Colors.white.withValues(alpha: 0.24),
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
          borderRadius:
          BorderRadius.circular(13),
          borderSide: BorderSide(
            color: const Color(0xff263653)
                .withValues(alpha: 0.75),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(13),
          borderSide: const BorderSide(
            color: Color(0xff00E5FF),
            width: 1.3,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // CREATE ACCOUNT BUTTON
  // ============================================================

  Widget _createAccountButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius:
          BorderRadius.circular(14),
          gradient: const LinearGradient(
            colors: [
              Color(0xff7C3AED),
              Color(0xff2563EB),
              Color(0xff00B8D9),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xff7C3AED)
                  .withValues(alpha: 0.25),
              blurRadius: 22,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed:
          isLoading ? null : signupUser,
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
                Icons.rocket_launch_rounded,
                color: Colors.white,
                size: 19,
              ),
              SizedBox(width: 9),
              Text(
                "CREATE MY ACCOUNT",
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
}

// ================================================================
// CYBER GRID PAINTER
// ================================================================

class _SignupGridPainter extends CustomPainter {
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