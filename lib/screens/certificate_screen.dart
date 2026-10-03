import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class CertificateScreen extends StatelessWidget {
  final String courseName;
  final String studentName;

  const CertificateScreen({
    super.key,
    required this.courseName,
    required this.studentName,
  });

  // ============================================================
  // CYBER-TECH THEME
  // ============================================================

  static const Color bg = Color(0xff050816);
  static const Color panel = Color(0xff0A1022);
  static const Color panel2 = Color(0xff0D1630);

  static const Color cyan = Color(0xff00E5FF);
  static const Color blue = Color(0xff2979FF);
  static const Color purple = Color(0xff8B5CF6);
  static const Color green = Color(0xff00E676);
  static const Color orange = Color(0xffffa726);

  static const Color gold = Color(0xffffd54f);
  static const Color goldDark = Color(0xffC89B24);

  static const Color textWhite = Color(0xffF4F7FF);
  static const Color textSoft = Color(0xffAAB6D3);
  static const Color textMuted = Color(0xff6F7C9D);

  static const Color border = Color(0xff1D2A4A);

  // ============================================================
  // PDF GENERATION + DOWNLOAD
  // ============================================================

  Future<void> _downloadCertificate(
      BuildContext context, {
        required String student,
        required String course,
        required String date,
      }) async {
    try {
      final doc = pw.Document(
        title: 'MMOC Teach Certificate',
        author: 'MMOC Teach',
      );

      const pdfBg = PdfColor.fromInt(0xff050816);
      const pdfPanel = PdfColor.fromInt(0xff0B1228);
      const pdfCyan = PdfColor.fromInt(0xff00E5FF);
      const pdfPurple = PdfColor.fromInt(0xff8B5CF6);
      const pdfGold = PdfColor.fromInt(0xffffd54f);
      const pdfWhite = PdfColor.fromInt(0xffF4F7FF);
      const pdfSoft = PdfColor.fromInt(0xffAAB6D3);
      const pdfMuted = PdfColor.fromInt(0xff6F7C9D);

      // Fixed A4 landscape page with zero margins (full page is used).
      final pageFormat = PdfPageFormat(
        PdfPageFormat.a4.height,
        PdfPageFormat.a4.width,
        marginAll: 0,
      );

      doc.addPage(
        pw.Page(
          pageFormat: pageFormat,
          margin: pw.EdgeInsets.zero,
          build: (pw.Context ctx) {
            return pw.SizedBox(
              width: pageFormat.width,
              height: pageFormat.height,
              child: pw.Container(
                color: pdfBg,
                padding: const pw.EdgeInsets.all(24),
                child: pw.Container(
                  decoration: pw.BoxDecoration(
                    color: pdfPanel,
                    border: pw.Border.all(color: pdfGold, width: 2),
                    borderRadius: pw.BorderRadius.circular(14),
                  ),
                  padding: const pw.EdgeInsets.all(6),
                  child: pw.Container(
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: pdfPurple, width: 1),
                      borderRadius: pw.BorderRadius.circular(10),
                    ),
                    padding: const pw.EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 14,
                    ),
                    child: pw.Column(
                      mainAxisAlignment: pw.MainAxisAlignment.center,
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      children: [
                        pw.Text(
                          'MMOC TEACH',
                          style: pw.TextStyle(
                            color: pdfWhite,
                            fontSize: 22,
                            fontWeight: pw.FontWeight.bold,
                            letterSpacing: 3,
                          ),
                        ),
                        pw.SizedBox(height: 12),
                        pw.Text(
                          'CERTIFICATE OF COMPLETION',
                          style: pw.TextStyle(
                            color: pdfGold,
                            fontSize: 16,
                            fontWeight: pw.FontWeight.bold,
                            letterSpacing: 2.5,
                          ),
                        ),
                        pw.SizedBox(height: 18),
                        pw.Text(
                          'THIS CERTIFICATE IS PROUDLY PRESENTED TO',
                          style: const pw.TextStyle(
                            color: pdfMuted,
                            fontSize: 10,
                            letterSpacing: 1.5,
                          ),
                        ),
                        pw.SizedBox(height: 10),
                        pw.Text(
                          student,
                          textAlign: pw.TextAlign.center,
                          style: pw.TextStyle(
                            color: pdfCyan,
                            fontSize: 32,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.SizedBox(height: 8),
                        pw.Container(
                          width: 190,
                          height: 1.2,
                          color: pdfCyan,
                        ),
                        pw.SizedBox(height: 16),
                        pw.Text(
                          'FOR SUCCESSFULLY COMPLETING THE COURSE',
                          style: const pw.TextStyle(
                            color: pdfSoft,
                            fontSize: 11,
                            letterSpacing: 1,
                          ),
                        ),
                        pw.SizedBox(height: 8),
                        pw.Text(
                          course,
                          textAlign: pw.TextAlign.center,
                          style: pw.TextStyle(
                            color: pdfWhite,
                            fontSize: 24,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.SizedBox(height: 14),
                        pw.Text(
                          'COMPLETED ON  $date',
                          style: const pw.TextStyle(
                            color: pdfSoft,
                            fontSize: 11,
                            letterSpacing: 1,
                          ),
                        ),
                        pw.SizedBox(height: 18),
                        pw.Text(
                          'MMOC TEACH',
                          style: pw.TextStyle(
                            color: pdfWhite,
                            fontSize: 14,
                            fontWeight: pw.FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                        pw.SizedBox(height: 3),
                        pw.Text(
                          'LEARN - GROW - SUCCEED',
                          style: const pw.TextStyle(
                            color: pdfMuted,
                            fontSize: 9,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      );

      final bytes = await doc.save();

      final safeName =
      student.replaceAll(RegExp(r'[^A-Za-z0-9]+'), '_').toLowerCase();

      await Printing.sharePdf(
        bytes: bytes,
        filename: 'mmoc_certificate_$safeName.pdf',
      );
    } catch (e) {
      debugPrint('CERTIFICATE PDF ERROR: $e');

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(
                Icons.error_outline_rounded,
                color: Colors.white,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  "Unable to create certificate PDF. Please try again.",
                ),
              ),
            ],
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: panel2,
          margin: const EdgeInsets.all(16),
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    final String date =
        "${now.day.toString().padLeft(2, '0')}/"
        "${now.month.toString().padLeft(2, '0')}/"
        "${now.year}";

    final String displayStudentName =
    studentName.trim().isEmpty ? "Student" : studentName.trim();

    final String displayCourseName =
    courseName.trim().isEmpty ? "Course" : courseName.trim();

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: bg,
        surfaceTintColor: Colors.transparent,
        foregroundColor: textWhite,
        centerTitle: false,
        titleSpacing: 8,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: textWhite,
            size: 19,
          ),
        ),
        title: const Row(
          children: [
            Icon(
              Icons.workspace_premium_rounded,
              color: gold,
              size: 22,
            ),
            SizedBox(width: 9),
            Text(
              "CERTIFICATE",
              style: TextStyle(
                color: textWhite,
                fontSize: 17,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: green.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: green.withValues(alpha: 0.35),
              ),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.circle,
                  color: green,
                  size: 7,
                ),
                SizedBox(width: 6),
                Text(
                  "VERIFIED",
                  style: TextStyle(
                    color: green,
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            // ==================================================
            // BACKGROUND GLOW
            // ==================================================

            Positioned(
              top: -100,
              right: -80,
              child: _glowCircle(
                color: purple,
                size: 230,
              ),
            ),

            Positioned(
              bottom: 80,
              left: -120,
              child: _glowCircle(
                color: cyan,
                size: 260,
              ),
            ),

            SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 35),
              child: Column(
                children: [
                  _buildStatusHeader(),
                  const SizedBox(height: 18),
                  _buildCertificate(
                    studentName: displayStudentName,
                    courseName: displayCourseName,
                    date: date,
                  ),
                  const SizedBox(height: 18),
                  _buildCertificateInfo(
                    courseName: displayCourseName,
                    date: date,
                  ),
                  const SizedBox(height: 18),
                  _buildDownloadButton(
                    context,
                    student: displayStudentName,
                    course: displayCourseName,
                    date: date,
                  ),
                  const SizedBox(height: 12),
                  _buildSecurityNote(),
                  const SizedBox(height: 24),
                  _buildFooter(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // GLOW
  // ============================================================

  Widget _glowCircle({
    required Color color,
    required double size,
  }) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.08),
              blurRadius: 100,
              spreadRadius: 35,
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // STATUS HEADER
  // ============================================================

  Widget _buildStatusHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xff0B1634),
            Color(0xff11133A),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: cyan.withValues(alpha: 0.25),
        ),
        boxShadow: [
          BoxShadow(
            color: cyan.withValues(alpha: 0.06),
            blurRadius: 25,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [
                  cyan,
                  blue,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: cyan.withValues(alpha: 0.25),
                  blurRadius: 18,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Icon(
              Icons.verified_rounded,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "COURSE COMPLETED",
                  style: TextStyle(
                    color: cyan,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  "Achievement unlocked",
                  style: TextStyle(
                    color: textWhite,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  "Your digital certificate is ready.",
                  style: TextStyle(
                    color: textSoft,
                    fontSize: 11.5,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.auto_awesome_rounded,
            color: gold,
            size: 25,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // MAIN CERTIFICATE
  // ============================================================

  Widget _buildCertificate({
    required String studentName,
    required String courseName,
    required String date,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [
            cyan,
            purple,
            gold,
            cyan,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: purple.withValues(alpha: 0.15),
            blurRadius: 30,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.all(7),
        decoration: BoxDecoration(
          color: panel,
          borderRadius: BorderRadius.circular(26),
        ),
        child: Container(
          padding: const EdgeInsets.fromLTRB(19, 28, 19, 25),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(21),
            gradient: const LinearGradient(
              colors: [
                Color(0xff0B1228),
                Color(0xff080D1E),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(
              color: gold.withValues(alpha: 0.28),
            ),
          ),
          child: Column(
            children: [
              _buildCertificateSeal(),

              const SizedBox(height: 20),

              // BRAND
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 27,
                    height: 27,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      gradient: const LinearGradient(
                        colors: [
                          cyan,
                          purple,
                        ],
                      ),
                    ),
                    child: const Icon(
                      Icons.school_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 9),
                  const Text(
                    "MMOC TEACH",
                    style: TextStyle(
                      color: textWhite,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.8,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 25),

              // CERTIFICATE LABEL
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 13,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: gold.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: gold.withValues(alpha: 0.30),
                  ),
                ),
                child: const Text(
                  "CERTIFICATE OF COMPLETION",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: gold,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.6,
                  ),
                ),
              ),

              const SizedBox(height: 25),

              const Text(
                "THIS CERTIFICATE IS PROUDLY PRESENTED TO",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: textMuted,
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ),

              const SizedBox(height: 13),

              // STUDENT NAME
              Text(
                studentName,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: cyan,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  height: 1.2,
                  shadows: [
                    Shadow(
                      color: Color(0x5500E5FF),
                      blurRadius: 12,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 9),

              Container(
                height: 1,
                width: 150,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      cyan.withValues(alpha: 0.7),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 25),

              const Text(
                "FOR SUCCESSFULLY COMPLETING THE COURSE",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: textSoft,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.4,
                ),
              ),

              const SizedBox(height: 13),

              // COURSE
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 17,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xff101A34),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: purple.withValues(alpha: 0.35),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: purple.withValues(alpha: 0.05),
                      blurRadius: 18,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.menu_book_rounded,
                      color: purple,
                      size: 24,
                    ),
                    const SizedBox(height: 9),
                    Text(
                      courseName,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: textWhite,
                        fontSize: 19,
                        fontWeight: FontWeight.w900,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              // DATE
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 13,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: cyan.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: cyan.withValues(alpha: 0.18),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.calendar_month_rounded,
                      color: cyan,
                      size: 16,
                    ),
                    const SizedBox(width: 7),
                    Text(
                      "COMPLETED ON  $date",
                      style: const TextStyle(
                        color: textSoft,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              Container(
                height: 1,
                width: double.infinity,
                color: border,
              ),

              const SizedBox(height: 20),

              // BRAND FOOTER
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.auto_awesome_rounded,
                    color: gold,
                    size: 15,
                  ),
                  SizedBox(width: 8),
                  Text(
                    "MMOC TEACH",
                    style: TextStyle(
                      color: textWhite,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(
                    Icons.auto_awesome_rounded,
                    color: gold,
                    size: 15,
                  ),
                ],
              ),

              const SizedBox(height: 5),

              const Text(
                "LEARN • GROW • SUCCEED",
                style: TextStyle(
                  color: textMuted,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),

              const SizedBox(height: 17),

              // AUTHORIZED
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: green.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: green.withValues(alpha: 0.25),
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.verified_rounded,
                      color: green,
                      size: 14,
                    ),
                    SizedBox(width: 6),
                    Text(
                      "AUTHORIZED CERTIFICATE",
                      style: TextStyle(
                        color: green,
                        fontSize: 8.5,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.7,
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
  // CERTIFICATE SEAL
  // ============================================================

  Widget _buildCertificateSeal() {
    return Container(
      height: 86,
      width: 86,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [
            Color(0xffFFF1A8),
            gold,
            goldDark,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: gold.withValues(alpha: 0.20),
            blurRadius: 22,
            spreadRadius: 3,
          ),
        ],
      ),
      child: Container(
        margin: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xff10152A),
          border: Border.all(
            color: gold.withValues(alpha: 0.55),
            width: 1.5,
          ),
        ),
        child: const Stack(
          alignment: Alignment.center,
          children: [
            Icon(
              Icons.workspace_premium_rounded,
              color: gold,
              size: 51,
            ),
            Positioned(
              bottom: 16,
              child: Icon(
                Icons.check_rounded,
                color: Colors.white,
                size: 17,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // CERTIFICATE INFO
  // ============================================================

  Widget _buildCertificateInfo({
    required String courseName,
    required String date,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: panel,
        borderRadius: BorderRadius.circular(21),
        border: Border.all(
          color: border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.data_object_rounded,
                color: cyan,
                size: 20,
              ),
              SizedBox(width: 9),
              Text(
                "CERTIFICATE DATA",
                style: TextStyle(
                  color: textWhite,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _infoRow(
            icon: Icons.school_rounded,
            title: "Institute",
            value: "MMOC Teach",
            color: cyan,
          ),
          _infoDivider(),
          _infoRow(
            icon: Icons.menu_book_rounded,
            title: "Course",
            value: courseName,
            color: purple,
          ),
          _infoDivider(),
          _infoRow(
            icon: Icons.calendar_today_rounded,
            title: "Completion",
            value: date,
            color: orange,
          ),
          _infoDivider(),
          _infoRow(
            icon: Icons.verified_rounded,
            title: "Status",
            value: "Completed",
            color: green,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // INFO ROW
  // ============================================================

  Widget _infoRow({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          width: 39,
          height: 39,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: color.withValues(alpha: 0.18),
            ),
          ),
          child: Icon(
            icon,
            color: color,
            size: 19,
          ),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: textMuted,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: textWhite,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // DIVIDER
  // ============================================================

  Widget _infoDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 11),
      child: Container(
        height: 1,
        color: border,
      ),
    );
  }

  // ============================================================
  // DOWNLOAD BUTTON
  // ============================================================

  Widget _buildDownloadButton(
      BuildContext context, {
        required String student,
        required String course,
        required String date,
      }) {
    return Container(
      width: double.infinity,
      height: 57,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(17),
        gradient: const LinearGradient(
          colors: [
            cyan,
            blue,
            purple,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: cyan.withValues(alpha: 0.15),
            blurRadius: 20,
            spreadRadius: 1,
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: () => _downloadCertificate(
          context,
          student: student,
          course: course,
          date: date,
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          shadowColor: Colors.transparent,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(17),
          ),
        ),
        icon: const Icon(
          Icons.download_rounded,
          size: 22,
        ),
        label: const Text(
          "DOWNLOAD CERTIFICATE",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.7,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // SECURITY NOTE
  // ============================================================

  Widget _buildSecurityNote() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: panel,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: cyan.withValues(alpha: 0.14),
        ),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.shield_rounded,
            color: cyan,
            size: 20,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              "This certificate confirms successful course completion on MMOC Teach.",
              style: TextStyle(
                color: textSoft,
                fontSize: 11.5,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // FOOTER
  // ============================================================

  Widget _buildFooter() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 7,
              height: 7,
              decoration: const BoxDecoration(
                color: cyan,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              "MMOC TEACH",
              style: TextStyle(
                color: textWhite,
                fontSize: 12,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.4,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 7,
              height: 7,
              decoration: const BoxDecoration(
                color: purple,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        const Text(
          "LEARN • GROW • SUCCEED",
          style: TextStyle(
            color: textMuted,
            fontSize: 9.5,
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }
}