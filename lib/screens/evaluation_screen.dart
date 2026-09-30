import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:isar/isar.dart';

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
  // ============================================================
  // QUESTIONS
  // ============================================================

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

  // ============================================================
  // OPTIONS
  // ============================================================

  final List<List<String>> options = [
    ['یک دستگاه الکترونیکی', 'یک نوع غذا', 'یک وسیله ورزشی', 'یک کتاب'],
    ['کیبورد', 'مانیتور', 'پرینتر', 'اسپیکر'],
    ['مانیتور', 'کیبورد', 'ماوس', 'اسکنر'],
    [
      'برنامه‌ای برای مدیریت سخت‌افزار و نرم‌افزار',
      'یک بازی',
      'یک فایل تصویری',
      'یک وسیله ورودی',
    ],
    ['Windows', 'Photoshop', 'Chrome', 'Word'],
    [
      'برای وارد کردن متن و اطلاعات',
      'برای نمایش تصویر',
      'برای چاپ',
      'برای ذخیره برق',
    ],
    [
      'برای حرکت دادن نشانگر و انتخاب موارد',
      'برای چاپ اسناد',
      'برای نمایش تصویر',
      'برای ذخیره اطلاعات',
    ],
    [
      'مجموعه‌ای از اطلاعات ذخیره‌شده',
      'یک وسیله سخت‌افزاری',
      'یک کابل',
      'یک صفحه نمایش',
    ],
    [
      'شبکه‌ای جهانی از کامپیوترها',
      'یک سیستم‌عامل',
      'یک وسیله ورودی',
      'یک نوع فایل',
    ],
    ['هارد دیسک', 'مانیتور', 'کیبورد', 'ماوس'],
  ];

  // ============================================================
  // CORRECT ANSWERS
  // ============================================================

  final List<int> correctAnswers = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0];

  // ============================================================
  // SELECTED ANSWERS
  // ============================================================

  late List<int?> selectedAnswers;

  // ============================================================
  // CURRENT QUESTION
  // ============================================================

  int currentQuestion = 0;

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    selectedAnswers = List<int?>.filled(questions.length, null);
  }

  // ============================================================
  // SELECT ANSWER
  // ============================================================

  void selectAnswer(int optionIndex) {
    setState(() {
      selectedAnswers[currentQuestion] = optionIndex;
    });
  }

  // ============================================================
  // NEXT QUESTION
  // ============================================================

  void nextQuestion() {
    if (selectedAnswers[currentQuestion] == null) {
      _showMessage('لطفاً ابتدا یک گزینه را انتخاب کنید');
      return;
    }

    if (currentQuestion < questions.length - 1) {
      setState(() {
        currentQuestion++;
      });
    } else {
      submitEvaluation();
    }
  }

  // ============================================================
  // PREVIOUS QUESTION
  // ============================================================

  void previousQuestion() {
    if (currentQuestion > 0) {
      setState(() {
        currentQuestion--;
      });
    }
  }

  // ============================================================
  // SUBMIT EVALUATION
  // ============================================================

  Future<void> submitEvaluation() async {
    final bool allAnswered = selectedAnswers.every((answer) => answer != null);

    if (!allAnswered) {
      _showMessage('لطفاً به تمام سوالات پاسخ دهید');
      return;
    }

    int correctCount = 0;

    for (int i = 0; i < questions.length; i++) {
      if (selectedAnswers[i] == correctAnswers[i]) {
        correctCount++;
      }
    }

    try {
      final EvaluationModel evaluation = EvaluationModel()
        ..classId = widget.classModel.id
        ..className = widget.classModel.className
        ..studentName = widget.studentName
        ..correctAnswers = correctCount
        ..totalQuestions = questions.length
        ..answers = selectedAnswers.map((answer) => answer ?? -1).toList()
        ..evaluatedAt = DateTime.now();

      await IsarService.saveEvaluation(evaluation);

      if (!mounted) return;

      Navigator.pop(context, true);
    } catch (e) {
      debugPrint('Save Evaluation Error: $e');

      if (!mounted) return;

      _showMessage('ذخیره ارزیابی با خطا مواجه شد');
    }
  }

  // ============================================================
  // SHOW MESSAGE
  // ============================================================

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            textDirection: TextDirection.rtl,
            style: GoogleFonts.notoSansArabic(),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  // ============================================================
  // OPTION LETTER
  // ============================================================

  String optionLetter(int index) {
    return String.fromCharCode(65 + index);
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final String question = questions[currentQuestion];

    final List<String> currentOptions = options[currentQuestion];

    final int? selected = selectedAnswers[currentQuestion];

    final double progress = (currentQuestion + 1) / questions.length;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF0F6FF),

        appBar: AppBar(
          elevation: 0,
          backgroundColor: const Color(0xFFF0F6FF),

          title: Text(
            'ارزیابی شاگرد',
            style: GoogleFonts.notoSansArabic(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),

          centerTitle: true,
        ),

        body: SafeArea(
          child: Column(
            children: [
              // ==================================================
              // STUDENT NAME
              // ==================================================

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),

                child: Row(
                  children: [
                    const Icon(Icons.person_rounded, size: 22),

                    const SizedBox(width: 8),

                    Expanded(
                      child: Text(
                        widget.studentName,
                        style: GoogleFonts.notoSansArabic(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    Text(
                      '${currentQuestion + 1}/${questions.length}',
                      style: GoogleFonts.notoSansArabic(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // ==================================================
              // PROGRESS
              // ==================================================
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),

                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),

                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: Colors.grey.shade300,
                  ),
                ),
              ),

              // ==================================================
              // CONTENT
              // ==================================================
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,

                    children: [
                      // ==================================================
                      // QUESTION CARD
                      // ==================================================

                      Container(
                        padding: const EdgeInsets.all(20),

                        decoration: BoxDecoration(
                          color: Colors.white,

                          borderRadius: BorderRadius.circular(20),

                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),

                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: [
                            Text(
                              'سوال ${currentQuestion + 1}',
                              style: GoogleFonts.notoSansArabic(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF6C5CE7),
                              ),
                            ),

                            const SizedBox(height: 12),

                            Text(
                              question,
                              style: GoogleFonts.notoSansArabic(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // ==================================================
                      // OPTIONS
                      // ==================================================
                      ...List.generate(currentOptions.length, (index) {
                        final bool isSelected = selected == index;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),

                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),

                            onTap: () {
                              selectAnswer(index);
                            },

                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),

                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 15,
                              ),

                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFFEDE9FF)
                                    : Colors.white,

                                borderRadius: BorderRadius.circular(16),

                                border: Border.all(
                                  color: isSelected
                                      ? const Color(0xFF6C5CE7)
                                      : Colors.grey.shade300,

                                  width: isSelected ? 2 : 1,
                                ),
                              ),

                              child: Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,

                                    alignment: Alignment.center,

                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,

                                      color: isSelected
                                          ? const Color(0xFF6C5CE7)
                                          : Colors.grey.shade200,
                                    ),

                                    child: Text(
                                      optionLetter(index),

                                      style: GoogleFonts.notoSansArabic(
                                        fontWeight: FontWeight.bold,

                                        color: isSelected
                                            ? Colors.white
                                            : Colors.black87,
                                      ),
                                    ),
                                  ),

                                  const SizedBox(width: 14),

                                  Expanded(
                                    child: Text(
                                      currentOptions[index],

                                      style: GoogleFonts.notoSansArabic(
                                        fontSize: 14,
                                        fontWeight: isSelected
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                      ),
                                    ),
                                  ),

                                  if (isSelected)
                                    const Icon(
                                      Icons.check_circle_rounded,
                                      color: Color(0xFF6C5CE7),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),

              // ==================================================
              // BOTTOM BUTTONS
              // ==================================================
              Container(
                padding: const EdgeInsets.all(20),

                decoration: BoxDecoration(
                  color: Colors.white,

                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),

                      blurRadius: 10,

                      offset: const Offset(0, -4),
                    ),
                  ],
                ),

                child: Row(
                  children: [
                    if (currentQuestion > 0)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: previousQuestion,

                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(0, 52),

                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),

                          child: Text(
                            'قبلی',
                            style: GoogleFonts.notoSansArabic(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                    if (currentQuestion > 0) const SizedBox(width: 12),

                    Expanded(
                      flex: 2,

                      child: ElevatedButton(
                        onPressed: nextQuestion,

                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(0, 52),

                          backgroundColor: const Color(0xFF6C5CE7),

                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),

                        child: Text(
                          currentQuestion == questions.length - 1
                              ? 'ثبت ارزیابی'
                              : 'سوال بعدی',

                          style: GoogleFonts.notoSansArabic(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
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
}
