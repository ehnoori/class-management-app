import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../database/isar_service.dart';
import '../models/class_model.dart';
import '../models/evaluation_model.dart';

class EvaluationResultsScreen extends StatefulWidget {
  final ClassModel classModel;

  const EvaluationResultsScreen({super.key, required this.classModel});

  @override
  State<EvaluationResultsScreen> createState() =>
      _EvaluationResultsScreenState();
}

class _EvaluationResultsScreenState extends State<EvaluationResultsScreen> {
  List<EvaluationModel> evaluations = [];

  bool isLoading = true;

  // ==================================================
  // Init
  // ==================================================

  @override
  void initState() {
    super.initState();
    _loadResults();
  }

  // ==================================================
  // Load Results
  // ==================================================

  Future<void> _loadResults() async {
    try {
      final results = await IsarService.getClassEvaluations(
        widget.classModel.id,
      );

      if (!mounted) return;

      setState(() {
        evaluations = results;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      _showMessage('خطا در دریافت نتایج');

      debugPrint('Results Error: $e');
    }
  }

  // ==================================================
  // Refresh
  // ==================================================

  Future<void> _refreshResults() async {
    final results = await IsarService.getClassEvaluations(widget.classModel.id);

    if (!mounted) return;

    setState(() {
      evaluations = results;
    });
  }

  // ==================================================
  // Calculate Percentage
  // ==================================================

  double _getPercentage(EvaluationModel evaluation) {
    if (evaluation.totalQuestions == 0) {
      return 0;
    }

    return (evaluation.correctAnswers / evaluation.totalQuestions) * 100;
  }

  // ==================================================
  // Get Percentage Text
  // ==================================================

  String _getPercentageText(EvaluationModel evaluation) {
    return '${_getPercentage(evaluation).round()}%';
  }

  // ==================================================
  // Message
  // ==================================================

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          textDirection: TextDirection.rtl,
          style: GoogleFonts.notoSansArabic(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  // ==================================================
  // Build
  // ==================================================

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    final int totalStudents = widget.classModel.members.length;

    final int evaluatedStudents = evaluations.length;

    final int remainingStudents = totalStudents - evaluatedStudents;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F7FC),

      // ==================================================
      // AppBar
      // ==================================================
      appBar: AppBar(
        backgroundColor: const Color(0xFFF3F7FC),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,

        leading: Padding(
          padding: const EdgeInsets.only(left: 8),
          child: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: IconButton.styleFrom(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(13),
              ),
            ),
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 18,
              color: Color(0xFF172B5B),
            ),
          ),
        ),

        title: Text(
          'نتایج ارزیابی',
          style: GoogleFonts.notoSansArabic(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF172B5B),
          ),
        ),

        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton(
              onPressed: _refreshResults,
              style: IconButton.styleFrom(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13),
                ),
              ),
              icon: const Icon(
                Icons.refresh_rounded,
                size: 20,
                color: Color(0xFF1565E8),
              ),
            ),
          ),
        ],
      ),

      // ==================================================
      // Body
      // ==================================================
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            screenWidth * 0.055,
            8,
            screenWidth * 0.055,
            20,
          ),
          child: isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: Color(0xFF1565E8)),
                )
              : RefreshIndicator(
                  color: const Color(0xFF1565E8),
                  onRefresh: _refreshResults,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      // ==================================================
                      // Class Header
                      // ==================================================

                      _buildClassHeader(),

                      const SizedBox(height: 16),

                      // ==================================================
                      // Statistics
                      // ==================================================
                      _buildStatistics(
                        totalStudents: totalStudents,
                        evaluatedStudents: evaluatedStudents,
                        remainingStudents: remainingStudents,
                      ),

                      const SizedBox(height: 22),

                      // ==================================================
                      // Title
                      // ==================================================
                      Row(
                        textDirection: TextDirection.rtl,
                        children: [
                          const Icon(
                            Icons.people_alt_rounded,
                            color: Color(0xFF1565E8),
                            size: 21,
                          ),

                          const SizedBox(width: 8),

                          Text(
                            'نتیجه شاگردان',
                            textDirection: TextDirection.rtl,
                            style: GoogleFonts.notoSansArabic(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF172B5B),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // ==================================================
                      // Results
                      // ==================================================
                      if (evaluations.isEmpty)
                        _buildEmptyState()
                      else
                        ...List.generate(evaluations.length, (index) {
                          return _buildResultItem(
                            evaluation: evaluations[index],
                            index: index,
                          );
                        }),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  // ==================================================
  // Class Header
  // ==================================================

  Widget _buildClassHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3478F6), Color(0xFF1565E8)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(23),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1565E8).withOpacity(0.18),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.assessment_rounded,
              color: Colors.white,
              size: 31,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  widget.classModel.className,
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.right,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.notoSansArabic(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  'نتایج ارزیابی شاگردان',
                  textDirection: TextDirection.rtl,
                  style: GoogleFonts.notoSansArabic(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.88),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==================================================
  // Statistics
  // ==================================================

  Widget _buildStatistics({
    required int totalStudents,
    required int evaluatedStudents,
    required int remainingStudents,
  }) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.groups_rounded,
            value: '$totalStudents',
            title: 'کل شاگردان',
            iconColor: const Color(0xFF1565E8),
            iconBackground: const Color(0xFFE1EDFF),
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: _buildStatCard(
            icon: Icons.check_circle_rounded,
            value: '$evaluatedStudents',
            title: 'ارزیابی شده',
            iconColor: const Color(0xFF239B56),
            iconBackground: const Color(0xFFDDF3E5),
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: _buildStatCard(
            icon: Icons.pending_rounded,
            value: '$remainingStudents',
            title: 'باقی‌مانده',
            iconColor: const Color(0xFFE18B19),
            iconBackground: const Color(0xFFFFF0D6),
          ),
        ),
      ],
    );
  }

  // ==================================================
  // Stat Card
  // ==================================================

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String title,
    required Color iconColor,
    required Color iconBackground,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 7),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: const Color(0xFFE1E8F2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.025),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 39,
            height: 39,
            decoration: BoxDecoration(
              color: iconBackground,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 21),
          ),

          const SizedBox(height: 8),

          Text(
            value,
            style: GoogleFonts.notoSansArabic(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF172B5B),
            ),
          ),

          const SizedBox(height: 2),

          Text(
            title,
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.center,
            style: GoogleFonts.notoSansArabic(
              fontSize: 9.5,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF7C8DA8),
            ),
          ),
        ],
      ),
    );
  }

  // ==================================================
  // Result Item
  // ==================================================

  Widget _buildResultItem({
    required EvaluationModel evaluation,
    required int index,
  }) {
    final double percentage = _getPercentage(evaluation);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: const Color(0xFFE1E8F2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            textDirection: TextDirection.rtl,
            children: [
              // ==================================================
              // Student Icon
              // ==================================================

              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFE1EDFF),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person_rounded,
                  color: Color(0xFF1565E8),
                  size: 25,
                ),
              ),

              const SizedBox(width: 12),

              // ==================================================
              // Student Name
              // ==================================================
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      evaluation.studentName,
                      textDirection: TextDirection.rtl,
                      textAlign: TextAlign.right,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.notoSansArabic(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF172B5B),
                      ),
                    ),

                    const SizedBox(height: 3),

                    Text(
                      'ارزیابی شده',
                      textDirection: TextDirection.rtl,
                      style: GoogleFonts.notoSansArabic(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF239B56),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 10),

              // ==================================================
              // Percentage
              // ==================================================
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: _getPercentageBackground(percentage),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  _getPercentageText(evaluation),
                  style: GoogleFonts.notoSansArabic(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: _getPercentageColor(percentage),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // ==================================================
          // Score
          // ==================================================
          Row(
            textDirection: TextDirection.rtl,
            children: [
              Expanded(
                child: _buildScoreInfo(
                  icon: Icons.check_rounded,
                  title: 'جواب درست',
                  value: '${evaluation.correctAnswers}',
                  color: const Color(0xFF239B56),
                  background: const Color(0xFFDDF3E5),
                ),
              ),

              const SizedBox(width: 8),

              Expanded(
                child: _buildScoreInfo(
                  icon: Icons.quiz_rounded,
                  title: 'تعداد سوال',
                  value: '${evaluation.totalQuestions}',
                  color: const Color(0xFF1565E8),
                  background: const Color(0xFFE1EDFF),
                ),
              ),

              const SizedBox(width: 8),

              Expanded(
                child: _buildScoreInfo(
                  icon: Icons.calendar_today_rounded,
                  title: 'تاریخ',
                  value: _formatDate(evaluation.evaluatedAt),
                  color: const Color(0xFF7C5CDB),
                  background: const Color(0xFFEDE7FF),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // ==================================================
          // Progress
          // ==================================================
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                textDirection: TextDirection.rtl,
                children: [
                  Text(
                    'درصد موفقیت',
                    textDirection: TextDirection.rtl,
                    style: GoogleFonts.notoSansArabic(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF7C8DA8),
                    ),
                  ),

                  const Spacer(),

                  Text(
                    '${percentage.round()}%',
                    style: GoogleFonts.notoSansArabic(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: _getPercentageColor(percentage),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 6),

              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: percentage / 100,
                  minHeight: 7,
                  backgroundColor: const Color(0xFFE7EDF5),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _getPercentageColor(percentage),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==================================================
  // Score Info
  // ==================================================

  Widget _buildScoreInfo({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    required Color background,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 18),

          const SizedBox(height: 4),

          Text(
            value,
            textAlign: TextAlign.center,
            style: GoogleFonts.notoSansArabic(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),

          const SizedBox(height: 1),

          Text(
            title,
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.notoSansArabic(
              fontSize: 8.5,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF65748B),
            ),
          ),
        ],
      ),
    );
  }

  // ==================================================
  // Empty State
  // ==================================================

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 45, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE1E8F2)),
      ),
      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: const BoxDecoration(
              color: Color(0xFFEAF1FB),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.assessment_outlined,
              color: Color(0xFF7C8DA8),
              size: 34,
            ),
          ),

          const SizedBox(height: 15),

          Text(
            'هنوز نتیجه‌ای ثبت نشده است',
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.center,
            style: GoogleFonts.notoSansArabic(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF172B5B),
            ),
          ),

          const SizedBox(height: 7),

          Text(
            'بعد از ارزیابی شاگردان، نتایج آن‌ها در این صفحه نمایش داده می‌شود.',
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.center,
            style: GoogleFonts.notoSansArabic(
              fontSize: 12,
              height: 1.7,
              color: const Color(0xFF7C8DA8),
            ),
          ),
        ],
      ),
    );
  }

  // ==================================================
  // Percentage Color
  // ==================================================

  Color _getPercentageColor(double percentage) {
    if (percentage >= 80) {
      return const Color(0xFF239B56);
    }

    if (percentage >= 50) {
      return const Color(0xFFE18B19);
    }

    return const Color(0xFFD94B4B);
  }

  // ==================================================
  // Percentage Background
  // ==================================================

  Color _getPercentageBackground(double percentage) {
    if (percentage >= 80) {
      return const Color(0xFFDDF3E5);
    }

    if (percentage >= 50) {
      return const Color(0xFFFFF0D6);
    }

    return const Color(0xFFFFE1E1);
  }

  // ==================================================
  // Format Date
  // ==================================================

  String _formatDate(DateTime date) {
    final String day = date.day.toString().padLeft(2, '0');

    final String month = date.month.toString().padLeft(2, '0');

    return '$day/$month/${date.year}';
  }
}
