import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../data/default_quiz_data.dart';

class AddCourseScreen extends StatefulWidget {
  final String? docId;
  final Map<String, dynamic>? course;

  const AddCourseScreen({
    super.key,
    this.docId,
    this.course,
  });

  @override
  State<AddCourseScreen> createState() => _AddCourseScreenState();
}

class _AddCourseScreenState extends State<AddCourseScreen> {
  // ============================================================
  // CONTROLLERS
  // ============================================================

  final TextEditingController titleController = TextEditingController();
  final TextEditingController teacherController = TextEditingController();
  final TextEditingController durationController = TextEditingController();
  final TextEditingController ratingController = TextEditingController();
  final TextEditingController playlistController = TextEditingController();

  // ============================================================
  // CYBER TECH COLORS
  // ============================================================

  static const Color bg = Color(0xff050816);
  static const Color panel = Color(0xff0B1020);

  static const Color neonBlue = Color(0xff00B7FF);
  static const Color neonPurple = Color(0xff8B5CF6);
  static const Color neonCyan = Color(0xff00F5D4);
  static const Color neonGreen = Color(0xff39FF88);
  static const Color neonOrange = Color(0xffFF8A00);

  static const Color textWhite = Color(0xffF8FAFF);
  static const Color textMuted = Color(0xff8D98B2);
  static const Color border = Color(0xff1C2742);

  // ============================================================
  // STATE
  // ============================================================

  bool isSaving = false;

  // ============================================================
  // COURSE NOTES MAPPING
  // ============================================================

  static const Map<String, String> courseNotes = {
    'clanguage': 'assets/course_notes/C_Language_Complete_Notes.pdf',
    'computernetworks':
    'assets/course_notes/Computer_Networks_Complete_Notes.pdf',
    'cpp': 'assets/course_notes/CPP_Complete_Notes.pdf',
    'cplusplus': 'assets/course_notes/CPP_Complete_Notes.pdf',
    'cybersecurity': 'assets/course_notes/Cyber_Security_Complete_Notes.pdf',
    'dbms': 'assets/course_notes/DBMS_Complete_Notes.pdf',
    'dsa': 'assets/course_notes/DSA_Complete_Notes.pdf',
    'ethicalhacking':
    'assets/course_notes/Ethical_Hacking_Complete_Notes.pdf',
    'flutter': 'assets/course_notes/Flutter_Complete_Notes.pdf',
    'go': 'assets/course_notes/Go_Complete_Notes.pdf',
    'java': 'assets/course_notes/Java_Complete_Notes.pdf',
    'javascript': 'assets/course_notes/JavaScript_Complete_Notes.pdf',
    'kotlin': 'assets/course_notes/Kotlin_Complete_Notes.pdf',
    'matlab': 'assets/course_notes/MATLAB_Complete_Notes.pdf',
    'nodejs': 'assets/course_notes/NodeJS_Complete_Notes.pdf',
    'node': 'assets/course_notes/NodeJS_Complete_Notes.pdf',
    'operatingsystem':
    'assets/course_notes/Operating_System_Complete_Notes.pdf',
    'os': 'assets/course_notes/Operating_System_Complete_Notes.pdf',
    'php': 'assets/course_notes/PHP_Complete_Notes.pdf',
    'python': 'assets/course_notes/Python_Complete_Notes.pdf',
    'rlanguage': 'assets/course_notes/R_Language_Complete_Notes.pdf',
    'r': 'assets/course_notes/R_Language_Complete_Notes.pdf',
    'rust': 'assets/course_notes/Rust_Complete_Notes.pdf',
    'sql': 'assets/course_notes/SQL_Complete_Notes.pdf',
    'swift': 'assets/course_notes/Swift_Complete_Notes.pdf',
  };

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    final course = widget.course;

    if (course != null) {
      titleController.text = course['title']?.toString() ?? '';
      teacherController.text = course['teacher']?.toString() ?? '';
      durationController.text = course['duration']?.toString() ?? '';
      ratingController.text = course['rating']?.toString() ?? '';
      playlistController.text = course['playlistId']?.toString() ?? '';
    }

    titleController.addListener(_onTitleChanged);
  }

  void _onTitleChanged() {
    if (!mounted) return;
    setState(() {});
  }

  // ============================================================
  // HELPERS
  // ============================================================

  // Accepts a full YouTube link or a plain playlist ID.
  String _extractPlaylistId(String input) {
    final text = input.trim();
    if (text.isEmpty) return '';

    final uri = Uri.tryParse(text);
    final listParam = uri?.queryParameters['list'];

    if (listParam != null && listParam.isNotEmpty) {
      return listParam;
    }

    return text;
  }

  String _normalizeCourseName(String value) {
    return value
        .trim()
        .toLowerCase()
        .replaceAll('+', 'plus')
        .replaceAll(RegExp(r'[^a-z0-9]'), '');
  }

  String? _getNotesAsset(String courseTitle) {
    return courseNotes[_normalizeCourseName(courseTitle)];
  }

  String? _getNotesFileName(String courseTitle) {
    final assetPath = _getNotesAsset(courseTitle);
    if (assetPath == null) return null;
    return assetPath.split('/').last;
  }

  // ============================================================
  // CHECK ADMIN
  // ============================================================

  Future<bool> checkAdmin() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      showMessage('You are not logged in. Please login again.',
          isError: true);
      return false;
    }

    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!userDoc.exists) {
        showMessage('Admin profile not found in Firestore.', isError: true);
        return false;
      }

      final role = userDoc.data()?['role']?.toString().toLowerCase();

      if (role != 'admin') {
        showMessage('Access denied. You are not an admin.', isError: true);
        return false;
      }

      return true;
    } on FirebaseException catch (e) {
      debugPrint('ADMIN CHECK ERROR: ${e.code}');
      showMessage('Unable to verify admin access.', isError: true);
      return false;
    } catch (e) {
      debugPrint('ADMIN CHECK ERROR: $e');
      showMessage('Unable to verify admin access.', isError: true);
      return false;
    }
  }

  // ============================================================
  // SAVE COURSE
  // ============================================================

  Future<void> saveCourse() async {
    if (isSaving) return;

    final courseTitle = titleController.text.trim();
    final teacher = teacherController.text.trim();
    final duration = durationController.text.trim();
    final ratingText = ratingController.text.trim();

    if (courseTitle.isEmpty) {
      showMessage('Please enter course title.', isError: true);
      return;
    }

    if (teacher.isEmpty) {
      showMessage('Please enter teacher name.', isError: true);
      return;
    }

    if (duration.isEmpty) {
      showMessage('Please enter duration.', isError: true);
      return;
    }

    if (ratingText.isEmpty) {
      showMessage('Please enter rating.', isError: true);
      return;
    }

    final double? rating = double.tryParse(ratingText);

    if (rating == null) {
      showMessage('Please enter a valid rating.', isError: true);
      return;
    }

    if (rating < 0 || rating > 5) {
      showMessage('Rating must be between 0 and 5.', isError: true);
      return;
    }

    final notesAsset = _getNotesAsset(courseTitle);

    if (notesAsset == null) {
      showMessage(
        'No notes PDF is mapped for "$courseTitle". Please use the course name matching your PDF.',
        isError: true,
      );
      return;
    }

    if (!mounted) return;

    setState(() {
      isSaving = true;
    });

    try {
      final isAdmin = await checkAdmin();

      if (!isAdmin) {
        if (!mounted) return;
        setState(() {
          isSaving = false;
        });
        return;
      }

      final Map<String, dynamic> data = {
        'title': courseTitle,
        'teacher': teacher,
        'duration': duration,
        'rating': rating,
        'notesAsset': notesAsset,
      };

      // Playlist link / ID (optional)
      final playlistId = _extractPlaylistId(playlistController.text);

      if (playlistId.isNotEmpty) {
        data['playlistId'] = playlistId;
      }

      // ------------------------------------------------------
      // ADD NEW COURSE
      // ------------------------------------------------------

      if (widget.docId == null || widget.docId!.trim().isEmpty) {
        data['createdAt'] = FieldValue.serverTimestamp();

        final courseRef =
        await FirebaseFirestore.instance.collection('courses').add(data);

        debugPrint('COURSE CREATED: ${courseRef.id}');

        // AUTO QUIZ
        final courseName = courseTitle.toLowerCase();

        if (defaultQuizData.containsKey(courseName)) {
          final quizzes = defaultQuizData[courseName];

          if (quizzes != null) {
            for (final quiz in quizzes) {
              await FirebaseFirestore.instance.collection('quizzes').add({
                'courseId': courseRef.id,
                'courseName': courseName,
                'question': quiz['question'],
                'option1': quiz['option1'],
                'option2': quiz['option2'],
                'option3': quiz['option3'],
                'option4': quiz['option4'],
                'answer': quiz['answer'],
                'createdAt': FieldValue.serverTimestamp(),
              });
            }
          }
        }

        if (!mounted) return;

        setState(() {
          isSaving = false;
        });

        showMessage('Course added successfully.');
        Navigator.of(context).pop();
      }

      // ------------------------------------------------------
      // UPDATE EXISTING COURSE
      // ------------------------------------------------------

      else {
        final docId = widget.docId!.trim();

        await FirebaseFirestore.instance
            .collection('courses')
            .doc(docId)
            .update(data);

        debugPrint('COURSE UPDATED: $docId');

        if (!mounted) return;

        setState(() {
          isSaving = false;
        });

        showMessage('Course updated successfully.');
        Navigator.of(context).pop();
      }
    } on FirebaseException catch (e) {
      debugPrint('COURSE SAVE FIREBASE ERROR: ${e.code}');

      if (!mounted) return;

      setState(() {
        isSaving = false;
      });

      String message = 'Unable to save course.';

      if (e.code == 'permission-denied') {
        message = 'Permission denied. Please check Firestore rules.';
      } else if (e.code == 'unauthenticated') {
        message = 'Session expired. Please login again.';
      } else if (e.code == 'not-found') {
        message = 'Course document was not found.';
      } else if (e.message != null && e.message!.trim().isNotEmpty) {
        message = e.message!;
      }

      showMessage(message, isError: true);
    } catch (e) {
      debugPrint('COURSE SAVE ERROR: $e');

      if (!mounted) return;

      setState(() {
        isSaving = false;
      });

      showMessage('Unable to save course.', isError: true);
    }
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void showMessage(String message, {bool isError = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          backgroundColor: isError ? neonOrange : neonGreen,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    titleController.removeListener(_onTitleChanged);

    titleController.dispose();
    teacherController.dispose();
    durationController.dispose();
    ratingController.dispose();
    playlistController.dispose();

    super.dispose();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final bool isEditing =
        widget.docId != null && widget.docId!.trim().isNotEmpty;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        foregroundColor: textWhite,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: textWhite),
          onPressed: isSaving ? null : () => Navigator.maybePop(context),
        ),
        title: Text(
          isEditing ? 'EDIT COURSE' : 'ADD COURSE',
          style: const TextStyle(
            color: textWhite,
            fontSize: 18,
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCoursePreview(),
              const SizedBox(height: 22),
              _buildSectionTitle(
                icon: Icons.school_rounded,
                title: 'COURSE INFORMATION',
                subtitle: 'Configure your learning module',
              ),
              const SizedBox(height: 14),
              _buildTextField(
                controller: titleController,
                label: 'COURSE TITLE',
                hint: 'Example: Flutter',
                icon: Icons.menu_book_rounded,
              ),
              const SizedBox(height: 13),
              _buildTextField(
                controller: teacherController,
                label: 'TEACHER NAME',
                hint: 'Example: John Doe',
                icon: Icons.person_rounded,
              ),
              const SizedBox(height: 13),
              _buildTextField(
                controller: durationController,
                label: 'DURATION',
                hint: 'Example: 3 Months',
                icon: Icons.schedule_rounded,
              ),
              const SizedBox(height: 13),
              _buildTextField(
                controller: ratingController,
                label: 'RATING',
                hint: 'Example: 4.8',
                icon: Icons.star_rounded,
                keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 13),
              _buildTextField(
                controller: playlistController,
                label: 'YOUTUBE PLAYLIST LINK / ID',
                hint: 'Paste playlist link (optional)',
                icon: Icons.video_library_rounded,
                capitalization: TextCapitalization.none,
              ),
              const SizedBox(height: 24),
              _buildNotesSection(),
              const SizedBox(height: 28),
              _buildSaveButton(isEditing: isEditing),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // COURSE PREVIEW
  // ============================================================

  Widget _buildCoursePreview() {
    final title = titleController.text.trim();
    final displayTitle = title.isEmpty ? 'YOUR COURSE' : title;
    final initials = _getCourseInitials(displayTitle);

    return Container(
      width: double.infinity,
      height: 205,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xff071A35),
            Color(0xff101052),
            Color(0xff240D4F),
          ],
        ),
        border: Border.all(
          color: neonBlue.withValues(alpha: 0.55),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: neonBlue.withValues(alpha: 0.16),
            blurRadius: 28,
          ),
          BoxShadow(
            color: neonPurple.withValues(alpha: 0.12),
            blurRadius: 40,
            offset: const Offset(15, 15),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -35,
            top: -45,
            child: Container(
              width: 145,
              height: 145,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: neonPurple.withValues(alpha: 0.14),
              ),
            ),
          ),
          Positioned(
            left: -45,
            bottom: -60,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: neonCyan.withValues(alpha: 0.08),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(22),
            child: Row(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(26),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [neonBlue, neonPurple],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: neonBlue.withValues(alpha: 0.35),
                        blurRadius: 25,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      initials,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 27,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: neonCyan.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: neonCyan.withValues(alpha: 0.35),
                          ),
                        ),
                        child: const Text(
                          'COURSE PREVIEW',
                          style: TextStyle(
                            color: neonCyan,
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        displayTitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: textWhite,
                          fontSize: 23,
                          fontWeight: FontWeight.w900,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Row(
                        children: [
                          Icon(Icons.auto_awesome,
                              size: 15, color: neonOrange),
                          SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Dynamic cyber course identity',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: textMuted,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
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
          Positioned(
            right: 22,
            bottom: 18,
            child: Row(
              children: [
                _buildGlowDot(neonBlue),
                const SizedBox(width: 6),
                _buildGlowDot(neonPurple),
                const SizedBox(width: 6),
                _buildGlowDot(neonCyan),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getCourseInitials(String title) {
    final clean = title.trim();

    if (clean.isEmpty) return 'C';

    final words = clean.split(RegExp(r'\s+'));

    if (words.length == 1) {
      final word = words.first;

      if (word.length >= 2) {
        return word.substring(0, 2).toUpperCase();
      }

      return word.toUpperCase();
    }

    return words
        .take(2)
        .map((word) => word.isNotEmpty ? word[0].toUpperCase() : '')
        .join();
  }

  Widget _buildGlowDot(Color color) {
    return Container(
      width: 7,
      height: 7,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.75),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SECTION TITLE
  // ============================================================

  Widget _buildSectionTitle({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(13),
            gradient: const LinearGradient(
              colors: [neonBlue, neonPurple],
            ),
            boxShadow: [
              BoxShadow(
                color: neonBlue.withValues(alpha: 0.22),
                blurRadius: 16,
              ),
            ],
          ),
          child: Icon(icon, color: Colors.white, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: textWhite,
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  color: textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // TEXT FIELD
  // ============================================================

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    TextCapitalization capitalization = TextCapitalization.words,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: panel,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.22),
            blurRadius: 16,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        textCapitalization: capitalization,
        style: const TextStyle(
          color: textWhite,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        cursorColor: neonCyan,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          labelStyle: const TextStyle(
            color: textMuted,
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.7,
          ),
          hintStyle: const TextStyle(
            color: Color(0xff4E5A73),
            fontSize: 13,
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 14, right: 10),
            child: Icon(icon, color: neonBlue, size: 21),
          ),
          prefixIconConstraints: const BoxConstraints(minWidth: 48),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(17),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(17),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(17),
            borderSide: const BorderSide(color: neonBlue, width: 1.2),
          ),
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 18,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // NOTES SECTION
  // ============================================================

  Widget _buildNotesSection() {
    final title = titleController.text.trim();
    final notesAsset = _getNotesAsset(title);
    final fileName = _getNotesFileName(title);
    final bool hasNotes = notesAsset != null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: panel,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: neonPurple.withValues(alpha: 0.35)),
        boxShadow: [
          BoxShadow(
            color: neonPurple.withValues(alpha: 0.08),
            blurRadius: 25,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(13),
                  gradient: const LinearGradient(
                    colors: [neonPurple, neonBlue],
                  ),
                ),
                child: const Icon(
                  Icons.picture_as_pdf_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'COURSE NOTES',
                      style: TextStyle(
                        color: textWhite,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      hasNotes
                          ? 'Local PDF automatically attached'
                          : 'No PDF mapped for this course',
                      style: TextStyle(
                        color: hasNotes ? neonGreen : neonOrange,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          if (hasNotes)
            _buildAttachedPdfCard(fileName!)
          else
            _buildNoPdfCard(),
        ],
      ),
    );
  }

  Widget _buildAttachedPdfCard(String fileName) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: neonGreen.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: neonGreen.withValues(alpha: 0.30)),
      ),
      child: Row(
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.picture_as_pdf_rounded,
              color: Color(0xffFF4D67),
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fileName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: textWhite,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  'Automatically attached from app assets',
                  style: TextStyle(
                    color: neonGreen,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.check_circle_rounded, color: neonGreen, size: 22),
        ],
      ),
    );
  }

  Widget _buildNoPdfCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: neonOrange.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: neonOrange.withValues(alpha: 0.25)),
      ),
      child: const Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: neonOrange, size: 24),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'No notes PDF is mapped for this course name.',
              style: TextStyle(
                color: textMuted,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SAVE BUTTON
  // ============================================================

  Widget _buildSaveButton({required bool isEditing}) {
    return Container(
      width: double.infinity,
      height: 58,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(17),
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [neonBlue, neonPurple],
        ),
        boxShadow: [
          BoxShadow(
            color: neonBlue.withValues(alpha: 0.24),
            blurRadius: 22,
          ),
          BoxShadow(
            color: neonPurple.withValues(alpha: 0.18),
            blurRadius: 30,
            offset: const Offset(8, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: isSaving ? null : saveCourse,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          disabledBackgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          foregroundColor: Colors.white,
          disabledForegroundColor: Colors.white70,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(17),
          ),
        ),
        child: isSaving
            ? const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 12),
            Text(
              'SAVING...',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w900,
                letterSpacing: 1,
              ),
            ),
          ],
        )
            : Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isEditing
                  ? Icons.save_rounded
                  : Icons.add_circle_outline_rounded,
              size: 22,
            ),
            const SizedBox(width: 10),
            Text(
              isEditing ? 'UPDATE COURSE' : 'SAVE COURSE',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w900,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
