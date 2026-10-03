import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'login_screen.dart';
import 'home_screen.dart';
import 'admin_dashboard.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _pulseController;
  late AnimationController _rotationController;

  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // ----------------------------------------------------------
    // MAIN INTRO ANIMATION
    // ----------------------------------------------------------
    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _mainController,
      curve: Curves.easeOutBack,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _mainController,
      curve: Curves.easeIn,
    );

    // ----------------------------------------------------------
    // NEON PULSE
    // ----------------------------------------------------------
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1700),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(
      begin: 0.75,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );

    // ----------------------------------------------------------
    // ROTATING CYBER RING
    // ----------------------------------------------------------
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    _mainController.forward();

    checkLogin();
  }

  @override
  void dispose() {
    _mainController.dispose();
    _pulseController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  // ==========================================================
  // LOGIN / ROLE CHECK
  // ==========================================================

  Future<void> checkLogin() async {
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    final User? user = FirebaseAuth.instance.currentUser;

    // ----------------------------------------------------------
    // USER NOT LOGGED IN
    // ----------------------------------------------------------
    if (user == null) {
      _goToLogin();
      return;
    }

    // ----------------------------------------------------------
    // CHECK USER ROLE
    // ----------------------------------------------------------
    try {
      final DocumentSnapshot<Map<String, dynamic>> doc =
      await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .get();

      if (!mounted) return;

      if (doc.exists) {
        final Map<String, dynamic>? data = doc.data();

        final String role =
            data?["role"]?.toString().trim().toLowerCase() ?? "student";

        if (role == "admin") {
          _goToAdminDashboard();
        } else {
          _goToHome();
        }
      } else {
        // If user document does not exist,
        // still allow authenticated user to enter the app.
        _goToHome();
      }
    } catch (e) {
      // Don't trap user on splash if Firestore
      // temporarily fails.
      if (!mounted) return;

      _goToHome();
    }
  }

  void _goToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      ),
    );
  }

  void _goToHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const HomeScreen(),
      ),
    );
  }

  void _goToAdminDashboard() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const AdminDashboard(),
      ),
    );
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff050816),
      body: Stack(
        children: [
          // ======================================================
          // DARK BACKGROUND
          // ======================================================

          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xff02040D),
                  Color(0xff071027),
                  Color(0xff0B0820),
                  Color(0xff03050F),
                ],
              ),
            ),
          ),

          // ======================================================
          // NEON GLOW — TOP RIGHT
          // ======================================================

          Positioned(
            top: -150,
            right: -100,
            child: Container(
              height: 360,
              width: 360,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xff7C3AED).withValues(alpha: 0.13),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xff7C3AED).withValues(alpha: 0.22),
                    blurRadius: 120,
                    spreadRadius: 35,
                  ),
                ],
              ),
            ),
          ),

          // ======================================================
          // NEON GLOW — BOTTOM LEFT
          // ======================================================

          Positioned(
            bottom: -170,
            left: -120,
            child: Container(
              height: 390,
              width: 390,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xff06B6D4).withValues(alpha: 0.10),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xff06B6D4).withValues(alpha: 0.20),
                    blurRadius: 130,
                    spreadRadius: 30,
                  ),
                ],
              ),
            ),
          ),

          // ======================================================
          // CYBER GRID
          // ======================================================

          Positioned.fill(
            child: CustomPaint(
              painter: _CyberGridPainter(),
            ),
          ),

          // ======================================================
          // TOP HUD
          // ======================================================

          Positioned(
            top: 54,
            left: 24,
            right: 24,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _hudLabel(
                  icon: Icons.memory_rounded,
                  text: "MMOC // CORE",
                ),
                _hudLabel(
                  icon: Icons.wifi_rounded,
                  text: "ONLINE",
                  color: const Color(0xff22C55E),
                ),
              ],
            ),
          ),

          // ======================================================
          // MAIN CONTENT
          // ======================================================

          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // ------------------------------------------------
                    // CYBER LOGO AREA
                    // ------------------------------------------------

                    AnimatedBuilder(
                      animation: Listenable.merge([
                        _pulseController,
                        _rotationController,
                      ]),
                      builder: (context, child) {
                        return SizedBox(
                          height: 210,
                          width: 210,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Outer rotating ring
                              Transform.rotate(
                                angle: _rotationController.value *
                                    2 *
                                    3.141592653589793,
                                child: CustomPaint(
                                  size: const Size(190, 190),
                                  painter: _NeonRingPainter(),
                                ),
                              ),

                              // Pulsing glow
                              Container(
                                height: 154,
                                width: 154,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xff00E5FF)
                                          .withValues(
                                        alpha: 0.28 *
                                            _pulseAnimation.value,
                                      ),
                                      blurRadius: 35,
                                      spreadRadius: 8,
                                    ),
                                    BoxShadow(
                                      color: const Color(0xff8B5CF6)
                                          .withValues(
                                        alpha: 0.20 *
                                            _pulseAnimation.value,
                                      ),
                                      blurRadius: 55,
                                      spreadRadius: 12,
                                    ),
                                  ],
                                ),
                              ),

                              // Logo container
                              Container(
                                height: 132,
                                width: 132,
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: const Color(0xff0B1228),
                                  border: Border.all(
                                    color: const Color(0xff00E5FF)
                                        .withValues(alpha: 0.8),
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xff00E5FF)
                                          .withValues(alpha: 0.30),
                                      blurRadius: 20,
                                      spreadRadius: 2,
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
                                        size: 65,
                                        color: Color(0xff00E5FF),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 24),

                    // ------------------------------------------------
                    // APP NAME
                    // ------------------------------------------------

                    ShaderMask(
                      shaderCallback: (bounds) {
                        return const LinearGradient(
                          colors: [
                            Color(0xff00E5FF),
                            Color(0xff7C3AED),
                            Color(0xffA855F7),
                          ],
                        ).createShader(bounds);
                      },
                      child: const Text(
                        "MMOC Teach",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 34,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // ------------------------------------------------
                    // TAGLINE
                    // ------------------------------------------------

                    Text(
                      "LEARN  •  BUILD  •  GROW",
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.70),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2.3,
                      ),
                    ),

                    const SizedBox(height: 38),

                    // ------------------------------------------------
                    // LOADING HUD
                    // ------------------------------------------------

                    Container(
                      width: 235,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 13,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xff0A1024)
                            .withValues(alpha: 0.88),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: const Color(0xff00E5FF)
                              .withValues(alpha: 0.28),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xff00E5FF)
                                .withValues(alpha: 0.07),
                            blurRadius: 20,
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                              const AlwaysStoppedAnimation<Color>(
                                Color(0xff00E5FF),
                              ),
                            ),
                          ),
                          const SizedBox(width: 13),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "INITIALIZING SYSTEM",
                                  style: TextStyle(
                                    color: Colors.white.withValues(
                                      alpha: 0.92,
                                    ),
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.1,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Preparing your learning experience...",
                                  style: TextStyle(
                                    color: Colors.white.withValues(
                                      alpha: 0.45,
                                    ),
                                    fontSize: 9,
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
            ),
          ),

          // ======================================================
          // BOTTOM HUD
          // ======================================================

          Positioned(
            left: 24,
            right: 24,
            bottom: 28,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "SYSTEM READY",
                  style: TextStyle(
                    color: const Color(0xff22C55E)
                        .withValues(alpha: 0.72),
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.3,
                  ),
                ),
                Text(
                  "V 1.0.0",
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.35),
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // HUD LABEL
  // ==========================================================

  Widget _hudLabel({
    required IconData icon,
    required String text,
    Color color = const Color(0xff00E5FF),
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: const Color(0xff071027).withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withValues(alpha: 0.25),
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
              color: color.withValues(alpha: 0.82),
              fontSize: 8,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}

// ================================================================
// CYBER GRID PAINTER
// ================================================================

class _CyberGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = const Color(0xff1E3A5F).withValues(alpha: 0.12)
      ..strokeWidth = 0.7;

    const double gridSize = 32;

    for (double x = 0; x <= size.width; x += gridSize) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }

    for (double y = 0; y <= size.height; y += gridSize) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }

    // Small cyber nodes
    final Paint nodePaint = Paint()
      ..color = const Color(0xff00E5FF).withValues(alpha: 0.20);

    for (double x = 0; x <= size.width; x += gridSize * 4) {
      for (double y = 0; y <= size.height; y += gridSize * 4) {
        canvas.drawCircle(
          Offset(x, y),
          1.4,
          nodePaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

// ================================================================
// NEON RING PAINTER
// ================================================================

class _NeonRingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = Offset(
      size.width / 2,
      size.height / 2,
    );

    final double radius = size.width / 2 - 8;

    // Main cyan arc
    final Paint cyanPaint = Paint()
      ..color = const Color(0xff00E5FF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(
        center: center,
        radius: radius,
      ),
      -0.5,
      1.8,
      false,
      cyanPaint,
    );

    // Purple arc
    final Paint purplePaint = Paint()
      ..color = const Color(0xffA855F7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(
        center: center,
        radius: radius,
      ),
      2.2,
      1.45,
      false,
      purplePaint,
    );

    // Small decorative dots
    final Paint dotPaint = Paint()
      ..color = const Color(0xff22C55E);

    for (int i = 0; i < 4; i++) {
      final double angle =
          (i * 3.141592653589793 / 2) + 0.4;

      final Offset point = Offset(
        center.dx + radius * 0.92 * MathCos.cos(angle),
        center.dy + radius * 0.92 * MathCos.sin(angle),
      );

      canvas.drawCircle(
        point,
        2.2,
        dotPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

// ================================================================
// SIMPLE MATH HELPER
// ================================================================

class MathCos {
  static double cos(double value) {
    // Lightweight approximation helper for decorative ring points.
    // Uses Dart's built-in trigonometric implementation indirectly
    // through a short Taylor approximation.
    double result = 1.0;
    double term = 1.0;

    for (int i = 1; i <= 7; i++) {
      term *= -value * value / ((2 * i - 1) * (2 * i));
      result += term;
    }

    return result;
  }

  static double sin(double value) {
    double result = value;
    double term = value;

    for (int i = 1; i <= 7; i++) {
      term *= -value * value / ((2 * i) * (2 * i + 1));
      result += term;
    }

    return result;
  }
}