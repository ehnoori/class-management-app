import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../database/isar_service.dart';
import '../models/class_model.dart';
import '../models/evaluation_model.dart';

class EvaluationScreen extends StatefulWidget {
  final ClassModel classModel;
  final String studentName;

  const EvaluationScreen({
    super.key,
    required this.classModel,
    required this.studentName,
  });

  @override
  State<EvaluationScreen> createState() => _EvaluationScreenState();
}

class _EvaluationScreenState extends State<EvaluationScreen> {
  int currentQuestionIndex = 0;

  bool isSaving = false;

  // ==================================================
  // Questions
  // ==================================================

  final List<String> questions = [
    'کمپیوتر چیست؟',
    'کدام یک از موارد زیر یک وسیله ورودی کمپیوتر است؟',
    'کدام وسیله برای نمایش تصویر استفاده می‌شود؟',
    'سیستم‌عامل چیست؟',
    'کدام یک از موارد زیر سیستم‌عامل است؟',
    'کیبورد برای چه کاری استفاده می‌شود؟',
    'ماوس در کمپیوتر چه کاربردی دارد؟',
    'فایل چیست؟',
    'اینترنت چیست؟',
    'کدام وسیله برای ذخیره اطلاعات استفاده می‌شود؟',
  ];

  // ==================================================
  // Options
  // ==================================================

  final List<List<String>> options = [
    [
      'یک دستگاه برای پردازش اطلاعات',
      'یک نوع بازی',
      'یک نوع اینترنت',
      'یک نوع برنامه',
    ],
    ['کیبورد', 'مانیتور', 'اسپیکر', 'پرینتر'],
    ['مانیتور', 'کیبورد', 'ماوس', 'اسکنر'],
    [
      'برنامه‌ای برای مدیریت کامپیوتر',
      'یک وسیله ورودی',
      'یک نوع فایل',
      'یک نوع اینترنت',
    ],
    ['Windows', 'Word', 'Chrome', 'Photoshop'],
    [
      'برای وارد کردن متن و اطلاعات',
      'برای نمایش تصویر',
      'برای چاپ کردن',
      'برای ذخیره برق',
    ],
    [
      'برای کنترل و انتخاب موارد روی صفحه',
      'برای چاپ اسناد',
      'برای ذخیره فایل',
      'برای نمایش تصویر',
    ],
    [
      'مجموعه‌ای از اطلاعات ذخیره‌شده',
      'یک وسیله کامپیوتری',
      'یک نوع سیستم‌عامل',
      'یک نوع اینترنت',
    ],
    [
      'شبکه‌ای برای ارتباط و تبادل اطلاعات',
      'یک نوع کیبورد',
      'یک نوع سیستم‌عامل',
      'یک نوع فایل',
    ],
    ['فلش‌دیسک', 'مانیتور', 'ماوس', 'اسپیکر'],
  ];

  // ==================================================
  // Correct Answers
  // ==================================================

  // شماره گزینه صحیح هر سوال
  //
  // 0 = گزینه اول
  // 1 = گزینه دوم
  // 2 = گزینه سوم
  // 3 = گزینه چهارم
  //
  final List<int> correctAnswers = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0];

  // ==================================================
  // Selected Answers
  // ==================================================

  late List<int?> selectedAnswers;

  // ==================================================
  // Init
  // ==================================================

  @override
  void initState() {
    super.initState();

    selectedAnswers = List<int?>.filled(questions.length, null);
  }

  // ==================================================
  // Select Answer
  // ==================================================

  void selectAnswer(int optionIndex) {
    if (isSaving) return;

    setState(() {
      selectedAnswers[currentQuestionIndex] = optionIndex;
    });
  }

  // ==================================================
  // Next Question
  // ==================================================

  void nextQuestion() {
    if (selectedAnswers[currentQuestionIndex] == null) {
      _showMessage('لطفاً یکی از گزینه‌ها را انتخاب کنید');
      return;
    }

    if (currentQuestionIndex == questions.length - 1) {
      submitEvaluation();
      return;
    }

    setState(() {
      currentQuestionIndex++;
    });
  }

  // ==================================================
  // Previous Question
  // ==================================================

  void previousQuestion() {
    if (currentQuestionIndex == 0 || isSaving) {
      return;
    }

    setState(() {
      currentQuestionIndex--;
    });
  }

  // ==================================================
  // Submit Evaluation
  // ==================================================

  Future<void> submitEvaluation() async {
    // بررسی تمام جواب‌ها
    final bool allAnswered = selectedAnswers.every((answer) => answer != null);

    if (!allAnswered) {
      _showMessage('لطفاً به تمام سوالات پاسخ دهید');
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      // محاسبه تعداد جواب‌های درست
      int correctCount = 0;

      for (int i = 0; i < questions.length; i++) {
        if (selectedAnswers[i] == correctAnswers[i]) {
          correctCount++;
        }
      }

      // ==================================================
      // ساخت EvaluationModel
      // ==================================================

      final EvaluationModel evaluation = EvaluationModel()
        ..classId = widget.classModel.id
        ..className = widget.classModel.className
        ..studentName = widget.studentName
        ..correctAnswers = correctCount
        ..totalQuestions = questions.length
        ..answers = selectedAnswers.map((answer) => answer ?? -1).toList()
        ..evaluatedAt = DateTime.now();

      // ==================================================
      // ذخیره در Isar
      // ==================================================

      await IsarService.saveEvaluation(evaluation);

      if (!mounted) return;

      // ==================================================
      // بازگشت به صفحه شاگردان
      // ==================================================

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isSaving = false;
      });

      _showMessage('خطا در ذخیره ارزیابی');

      debugPrint('Evaluation Error: $e');
    }
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

    final int questionNumber = currentQuestionIndex + 1;

    final String currentQuestion = questions[currentQuestionIndex];

    final List<String> currentOptions = options[currentQuestionIndex];

    final int? selectedOption = selectedAnswers[currentQuestionIndex];

    final double progress = questionNumber / questions.length;

    return PopScope(
      canPop: !isSaving,
      child: Scaffold(
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
              onPressed: isSaving
                  ? null
                  : () {
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
            'ارزیابی شاگرد',
            style: GoogleFonts.notoSansArabic(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF172B5B),
            ),
          ),
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
            child: Column(
              children: [
                _buildStudentHeader(),

                const SizedBox(height: 18),

                _buildProgress(questionNumber, progress),

                const SizedBox(height: 22),

                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        _buildQuestionCard(questionNumber, currentQuestion),

                        const SizedBox(height: 18),

                        ...List.generate(currentOptions.length, (index) {
                          return _buildOption(
                            index: index,
                            text: currentOptions[index],
                            isSelected: selectedOption == index,
                          );
                        }),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                _buildNavigationButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==================================================
  // Student Header
  // ==================================================

  Widget _buildStudentHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE1E8F2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: const Color(0xFFE1EDFF),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.person_rounded,
              color: Color(0xFF1565E8),
              size: 28,
            ),
          ),

          const SizedBox(width: 13),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  widget.studentName,
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.right,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.notoSansArabic(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF172B5B),
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  widget.classModel.className,
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.right,
                  style: GoogleFonts.notoSansArabic(
                    fontSize: 12,
                    color: const Color(0xFF7C8DA8),
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
  // Progress
  // ==================================================

  Widget _buildProgress(int questionNumber, double progress) {
    return Column(
      children: [
        Row(
          textDirection: TextDirection.rtl,
          children: [
            Text(
              'سوال $questionNumber از ${questions.length}',
              textDirection: TextDirection.rtl,
              style: GoogleFonts.notoSansArabic(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF172B5B),
              ),
            ),

            const Spacer(),

            Text(
              '${(progress * 100).round()}%',
              style: GoogleFonts.notoSansArabic(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1565E8),
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: const Color(0xFFE0E8F3),
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF1565E8)),
          ),
        ),
      ],
    );
  }

  // ==================================================
  // Question Card
  // ==================================================

  Widget _buildQuestionCard(int questionNumber, String question) {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            textDirection: TextDirection.rtl,
            children: [
              Container(
                width: 38,
                height: 38,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '$questionNumber',
                  style: GoogleFonts.notoSansArabic(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),

              const SizedBox(width: 10),

              Text(
                'سوال ارزیابی',
                textDirection: TextDirection.rtl,
                style: GoogleFonts.notoSansArabic(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),

          const SizedBox(height: 17),

          Text(
            question,
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.right,
            style: GoogleFonts.notoSansArabic(
              fontSize: 17,
              height: 1.8,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // ==================================================
  // Option
  // ==================================================

  Widget _buildOption({
    required int index,
    required String text,
    required bool isSelected,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 11),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: isSelected ? const Color(0xFF1565E8) : const Color(0xFFE1E8F2),
          width: isSelected ? 1.6 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.025),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(17),
        onTap: isSaving ? null : () => selectAnswer(index),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            textDirection: TextDirection.rtl,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 25,
                height: 25,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected
                      ? const Color(0xFF1565E8)
                      : Colors.transparent,
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF1565E8)
                        : const Color(0xFFB8C5D6),
                    width: 1.7,
                  ),
                ),
                child: isSelected
                    ? const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 17,
                      )
                    : null,
              ),

              const SizedBox(width: 13),

              Expanded(
                child: Text(
                  text,
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.right,
                  style: GoogleFonts.notoSansArabic(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected
                        ? const Color(0xFF1565E8)
                        : const Color(0xFF172B5B),
                  ),
                ),
              ),

              const SizedBox(width: 10),

              Container(
                width: 30,
                height: 30,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFFE1EDFF)
                      : const Color(0xFFF3F6FA),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Text(
                  String.fromCharCode(65 + index),
                  style: GoogleFonts.notoSansArabic(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isSelected
                        ? const Color(0xFF1565E8)
                        : const Color(0xFF7C8DA8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==================================================
  // Navigation Buttons
  // ==================================================

  Widget _buildNavigationButtons() {
    final bool isFirstQuestion = currentQuestionIndex == 0;

    final bool isLastQuestion = currentQuestionIndex == questions.length - 1;

    return Row(
      children: [
        if (!isFirstQuestion) ...[
          SizedBox(
            height: 56,
            width: 56,
            child: OutlinedButton(
              onPressed: isSaving ? null : previousQuestion,
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.zero,
                side: const BorderSide(color: Color(0xFFD6E0EC)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(17),
                ),
              ),
              child: const Icon(
                Icons.arrow_forward_rounded,
                color: Color(0xFF172B5B),
              ),
            ),
          ),

          const SizedBox(width: 10),
        ],

        Expanded(
          child: SizedBox(
            height: 56,
            child: ElevatedButton.icon(
              onPressed: isSaving ? null : nextQuestion,

              icon: isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Icon(
                      isLastQuestion
                          ? Icons.check_rounded
                          : Icons.arrow_back_rounded,
                      color: Colors.white,
                    ),

              label: Text(
                isSaving
                    ? 'در حال ذخیره...'
                    : isLastQuestion
                    ? 'ذخیره ارزیابی'
                    : 'سوال بعدی',
                textDirection: TextDirection.rtl,
                style: GoogleFonts.notoSansArabic(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1565E8),
                disabledBackgroundColor: const Color(0xFF9DB8E5),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(17),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
