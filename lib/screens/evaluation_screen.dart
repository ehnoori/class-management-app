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
  static const Color backgroundColor = Color(0xFFF0F6FF);

  static const Color primaryColor = Color(0xFF6C5CE7);

  // ============================================================
  // QUESTIONS
  // ============================================================

  final List<Map<String, dynamic>> questions = [
    {
      'question':
          'مقدار تحقیق روزانه شما در امور فناوری و اطلاعات چقدر است؟',
      'type': 'choice',
      'options': [
        'یک ساعت',
        'دو ساعت',
        'سه ساعت',
        'چهار ساعت',
      ],
    },
    {
      'question':
          'به صورت هفته وار، با چند برنامه کمپیوتری سروکار دارید؟',
      'type': 'number',
      'options': <String>[],
    },
    {
      'question':
          'به طور اوسط روزانه چند برنامه‌ی ICDL را به کار میبرید؟',
      'type': 'choice',
      'options': [
        '1 برنامه',
        '2 برنامه',
        '3 برنامه',
        '4 برنامه',
        '5 برنامه',
      ],
    },
    {
      'question':
          'آیا امروز از کمپیوتر استفاده نموده اید؟',
      'type': 'choice',
      'options': [
        'بلی',
        'خیر',
      ],
    },
    {
      'question':
          'چند روز در هفته را به بازی‌های کمپیوتری سپری میکنید؟',
      'type': 'choice',
      'options': [
        '1 روز',
        '2 روز',
        '3 روز و یا بیشتر',
      ],
    },
    {
      'question':
          'در هر هفته چند شب اخبار مربوط به تکنالوژی را دنبال میکنید؟',
      'type': 'choice',
      'options': [
        '1 شب',
        '2 شب',
        '3 شب',
        '4 و یا بیشتر',
      ],
    },
    {
      'question':
          'آیا در مقابل ویروس‌های کمپیوتری کدام اقدامی انجام می‌دهید برای حفظ اطلاعات خود؟',
      'type': 'choice',
      'options': [
        'بلی',
        'خیر',
        'گاهی (کم)',
      ],
    },
    {
      'question':
          'چند صفحه در هفته از مضامین تخصصی خود مطالعه دارید؟',
      'type': 'number',
      'options': <String>[],
    },
    {
      'question':
          'آیا تقسیم اوقات منظم برای مدیریت زمان و برنامه‌های درسی خود دارید؟',
      'type': 'choice',
      'options': [
        'بلی',
        'خیر',
      ],
    },
    {
      'question':
          'آیا به صورت تیمی با صنفی‌هایتان پروژه‌ای را کار کرده‌اید؟',
      'type': 'project',
      'options': [
        'بلی',
        'خیر',
      ],
    },
    {
      'question':
          'آیا به صورت منظم ویندوز و برنامه‌های خود را بروزرسانی میکنید؟',
      'type': 'choice',
      'options': [
        'بلی',
        'خیر',
        'اغلب (کم)',
      ],
    },
    {
      'question':
          'کدام مهارت از مهارت‌های زیر را برای پیشرفت در رشته خود را فرا میگیرید؟',
      'type': 'choice',
      'options': [
        'کمپیوتری',
        'هک و امنیت',
        'وب سایت',
        'موبایل آپ',
      ],
    },
    {
      'question':
          'نظر یا پیشنهادی که به بهتر شدن پوهنحی بیانجامد بنویسید.',
      'type': 'text',
      'options': <String>[],
    },
  ];

  // ============================================================
  // VARIABLES
  // ============================================================

  int currentQuestion = 0;

  late List<String?> answers;

  final TextEditingController textController =
      TextEditingController();

  final TextEditingController projectController =
      TextEditingController();

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    answers = List<String?>.filled(
      questions.length,
      null,
    );
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    textController.dispose();
    projectController.dispose();

    super.dispose();
  }

  // ============================================================
  // CURRENT QUESTION
  // ============================================================

  Map<String, dynamic> get currentQuestionData {
    return questions[currentQuestion];
  }

  // ============================================================
  // SELECT ANSWER
  // ============================================================

  void selectAnswer(String answer) {
    setState(() {
      answers[currentQuestion] = answer;
    });
  }

  // ============================================================
  // TEXT ANSWER
  // ============================================================

  void updateTextAnswer(String value) {
    answers[currentQuestion] = value;
  }

  // ============================================================
  // PROJECT QUESTION
  // ============================================================

  void selectProjectAnswer(String answer) {
    setState(() {
      answers[currentQuestion] = answer;

      if (answer == 'خیر') {
        projectController.clear();
      }
    });
  }

  // ============================================================
  // GET CURRENT ANSWER
  // ============================================================

  String? getCurrentAnswer() {
    final String type =
        currentQuestionData['type'];

    // -----------------------------
    // NUMBER / TEXT
    // -----------------------------

    if (type == 'number' || type == 'text') {
      final value = textController.text.trim();

      if (value.isEmpty) {
        return null;
      }

      return value;
    }

    // -----------------------------
    // PROJECT
    // -----------------------------

    if (type == 'project') {
      final selected =
          answers[currentQuestion];

      if (selected == null) {
        return null;
      }

      if (selected == 'بلی') {
        final projectName =
            projectController.text.trim();

        if (projectName.isEmpty) {
          return null;
        }

        return 'بلی - $projectName';
      }

      if (selected == 'خیر') {
        return 'خیر';
      }

      if (selected!.startsWith('بلی - ')) {
        return selected;
      }

      return null;
    }

    // -----------------------------
    // CHOICE
    // -----------------------------

    return answers[currentQuestion];
  }

  // ============================================================
  // LOAD TEXT
  // ============================================================

  void loadCurrentText() {
    final type =
        currentQuestionData['type'];

    if (type == 'number' || type == 'text') {
      textController.text =
          answers[currentQuestion] ?? '';

      textController.selection =
          TextSelection.fromPosition(
        TextPosition(
          offset: textController.text.length,
        ),
      );
    }

    if (type == 'project') {
      final answer =
          answers[currentQuestion];

      if (answer != null &&
          answer.startsWith('بلی - ')) {
        projectController.text =
            answer.substring(6);
      } else {
        projectController.clear();
      }
    }
  }

  // ============================================================
  // NEXT QUESTION
  // ============================================================

  Future<void> nextQuestion() async {
    final answer =
        getCurrentAnswer();

    if (answer == null ||
        answer.trim().isEmpty) {
      _showMessage(
        'لطفاً پاسخ این سوال را وارد کنید',
      );

      return;
    }

    answers[currentQuestion] =
        answer;

    if (currentQuestion <
        questions.length - 1) {
      setState(() {
        currentQuestion++;
      });

      loadCurrentText();

      return;
    }

    await submitEvaluation();
  }

  // ============================================================
  // PREVIOUS QUESTION
  // ============================================================

  void previousQuestion() {
    if (currentQuestion == 0) {
      return;
    }

    final answer =
        getCurrentAnswer();

    if (answer != null) {
      answers[currentQuestion] =
          answer;
    }

    setState(() {
      currentQuestion--;
    });

    loadCurrentText();
  }

  // ============================================================
  // SUBMIT EVALUATION
  // ============================================================

  Future<void> submitEvaluation() async {
    final currentAnswer =
        getCurrentAnswer();

    if (currentAnswer == null ||
        currentAnswer.trim().isEmpty) {
      _showMessage(
        'لطفاً پاسخ سوال را وارد کنید',
      );

      return;
    }

    answers[currentQuestion] =
        currentAnswer;

    // ==========================================================
    // CHECK ALL QUESTIONS
    // ==========================================================

    for (int i = 0;
        i < answers.length;
        i++) {
      if (answers[i] == null ||
          answers[i]!.trim().isEmpty) {
        setState(() {
          currentQuestion = i;
        });

        loadCurrentText();

        _showMessage(
          'لطفاً به تمام سوالات پاسخ دهید',
        );

        return;
      }
    }

    // ==========================================================
    // SAVE
    // ==========================================================

    try {
      final cleanStudentName =
          widget.studentName.trim();

      // مهم:
      // جستجو فقط در همین صنف انجام می‌شود.
      final existing =
          await IsarService.getStudentEvaluation(
        widget.classModel.id,
        cleanStudentName,
      );

      final EvaluationModel evaluation;

      // ========================================================
      // STUDENT ALREADY EXISTS IN THIS CLASS
      // ========================================================

      if (existing != null) {
        // نتیجه جدید جای نتیجه قبلی را می‌گیرد.
        evaluation = existing
          ..classId =
              widget.classModel.id
          ..className =
              widget.classModel.className
          ..studentName =
              cleanStudentName
          ..answers = answers
              .map(
                (answer) =>
                    answer ?? '',
              )
              .toList()
          ..totalQuestions =
              questions.length
          ..correctAnswers = 0
          ..evaluatedAt =
              DateTime.now();
      }

      // ========================================================
      // NEW STUDENT IN THIS CLASS
      // ========================================================

      else {
        evaluation =
            EvaluationModel()
              ..classId =
                  widget.classModel.id
              ..className =
                  widget.classModel.className
              ..studentName =
                  cleanStudentName
              ..answers = answers
                  .map(
                    (answer) =>
                        answer ?? '',
                  )
                  .toList()
              ..totalQuestions =
                  questions.length
              ..correctAnswers = 0
              ..evaluatedAt =
                  DateTime.now();
      }

      // ========================================================
      // SAVE TO ISAR
      // ========================================================

      await IsarService.saveEvaluation(
        evaluation,
      );

      if (!mounted) {
        return;
      }

      _showMessage(
        'ارزیابی با موفقیت ذخیره شد',
      );

      await Future.delayed(
        const Duration(
          milliseconds: 500,
        ),
      );

      if (!mounted) {
        return;
      }

      Navigator.pop(
        context,
        true,
      );
    } catch (e) {
      debugPrint(
        'Save Evaluation Error: $e',
      );

      if (!mounted) {
        return;
      }

      _showMessage(
        'خطا در ذخیره ارزیابی',
      );
    }
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(
    String message,
  ) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            textDirection:
                TextDirection.rtl,
            style:
                GoogleFonts.vazirmatn(
              fontSize: 13,
            ),
          ),
          behavior:
              SnackBarBehavior.floating,
        ),
      );
  }

  // ============================================================
  // QUESTION CARD
  // ============================================================

  Widget _buildQuestionCard() {
    final String question =
        currentQuestionData['question'];

    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withOpacity(
              0.04,
            ),
            blurRadius: 12,
            offset:
                const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        question,
        textDirection:
            TextDirection.rtl,
        style:
            GoogleFonts.vazirmatn(
          fontSize: 16,
          fontWeight:
              FontWeight.w600,
          height: 1.8,
        ),
      ),
    );
  }

  // ============================================================
  // OPTION CARD
  // ============================================================

  Widget _buildOptionCard(
    String option,
    int index,
  ) {
    final bool selected =
        answers[currentQuestion] ==
            option;

    final String letter =
        String.fromCharCode(
      65 + index,
    );

    return GestureDetector(
      onTap: () {
        selectAnswer(option);
      },
      child: AnimatedContainer(
        duration:
            const Duration(
          milliseconds: 180,
        ),
        margin:
            const EdgeInsets.only(
          bottom: 10,
        ),
        padding:
            const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 13,
        ),
        decoration:
            BoxDecoration(
          color: selected
              ? const Color(
                  0xFFEAE7FF,
                )
              : Colors.white,
          borderRadius:
              BorderRadius.circular(
            15,
          ),
          border: Border.all(
            color: selected
                ? primaryColor
                : const Color(
                    0xFFE5E7EB,
                  ),
            width:
                selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              alignment:
                  Alignment.center,
              decoration:
                  BoxDecoration(
                color: selected
                    ? primaryColor
                    : const Color(
                        0xFFF1F3F5,
                      ),
                shape:
                    BoxShape.circle,
              ),
              child: Text(
                letter,
                style:
                    GoogleFonts.vazirmatn(
                  color: selected
                      ? Colors.white
                      : Colors.black87,
                  fontWeight:
                      FontWeight.w600,
                ),
              ),
            ),

            const SizedBox(
              width: 12,
            ),

            Expanded(
              child: Text(
                option,
                textDirection:
                    TextDirection.rtl,
                style:
                    GoogleFonts.vazirmatn(
                  fontSize: 14,
                  fontWeight:
                      FontWeight.w400,
                ),
              ),
            ),

            Icon(
              selected
                  ? Icons
                      .radio_button_checked
                  : Icons
                      .radio_button_unchecked,
              color: selected
                  ? primaryColor
                  : Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // TEXT FIELD
  // ============================================================

  Widget _buildTextField() {
    final String type =
        currentQuestionData['type'];

    final bool number =
        type == 'number';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(15),
        border: Border.all(
          color:
              const Color(0xFFE5E7EB),
        ),
      ),
      child: TextField(
        controller:
            textController,
        keyboardType: number
            ? TextInputType.number
            : TextInputType.multiline,
        maxLines:
            number ? 1 : 5,
        textDirection:
            TextDirection.rtl,
        onChanged:
            updateTextAnswer,
        decoration:
            InputDecoration(
          hintText: number
              ? 'تعداد را وارد کنید'
              : 'پاسخ خود را بنویسید',
          hintStyle:
              GoogleFonts.vazirmatn(
            color:
                Colors.grey.shade500,
            fontSize: 13,
          ),
          border:
              InputBorder.none,
          contentPadding:
              const EdgeInsets.all(
            16,
          ),
        ),
        style:
            GoogleFonts.vazirmatn(
          fontSize: 14,
        ),
      ),
    );
  }

  // ============================================================
  // PROJECT QUESTION
  // ============================================================

  Widget _buildProjectQuestion() {
    final selected =
        answers[currentQuestion];

    return Column(
      children: [
        _buildOptionCard(
          'بلی',
          0,
        ),

        _buildOptionCard(
          'خیر',
          1,
        ),

        if (selected == 'بلی' ||
            (selected != null &&
                selected.startsWith(
                  'بلی - ',
                ))) ...[
          const SizedBox(
            height: 4,
          ),

          Container(
            decoration:
                BoxDecoration(
              color:
                  Colors.white,
              borderRadius:
                  BorderRadius.circular(
                15,
              ),
              border:
                  Border.all(
                color:
                    const Color(
                  0xFFE5E7EB,
                ),
              ),
            ),
            child:
                TextField(
              controller:
                  projectController,
              textDirection:
                  TextDirection.rtl,
              onChanged:
                  (value) {
                if (answers[
                        currentQuestion] ==
                    'بلی') {
                  answers[
                      currentQuestion] =
                      value.trim().isEmpty
                          ? 'بلی'
                          : 'بلی - ${value.trim()}';
                }
              },
              decoration:
                  InputDecoration(
                hintText:
                    'نام پروژه را بنویسید',
                hintStyle:
                    GoogleFonts
                        .vazirmatn(
                  fontSize:
                      13,
                  color: Colors
                      .grey
                      .shade500,
                ),
                border:
                    InputBorder
                        .none,
                contentPadding:
                    const EdgeInsets
                        .all(
                  16,
                ),
              ),
              style:
                  GoogleFonts
                      .vazirmatn(
                fontSize: 14,
              ),
            ),
          ),
        ],
      ],
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    final String type =
        currentQuestionData['type'];

    final options =
        currentQuestionData[
                'options']
            as List<String>;

    final double progress =
        (currentQuestion + 1) /
            questions.length;

    return Directionality(
      textDirection:
          TextDirection.rtl,
      child: Scaffold(
        backgroundColor:
            backgroundColor,

        appBar: AppBar(
          backgroundColor:
              backgroundColor,
          elevation: 0,
          centerTitle: true,
          title: Text(
            'ارزیابی شاگرد',
            style:
                GoogleFonts.vazirmatn(
              fontSize: 18,
              fontWeight:
                  FontWeight.w600,
            ),
          ),
        ),

        body: SafeArea(
          child: Column(
            children: [
              // ==================================================
              // STUDENT
              // ==================================================

              Padding(
                padding:
                    const EdgeInsets
                        .fromLTRB(
                  20,
                  4,
                  20,
                  10,
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons
                          .person_outline,
                      color:
                          primaryColor,
                    ),

                    const SizedBox(
                      width: 8,
                    ),

                    Expanded(
                      child: Text(
                        widget.studentName,
                        style:
                            GoogleFonts
                                .vazirmatn(
                          fontSize:
                              14,
                          fontWeight:
                              FontWeight
                                  .w500,
                        ),
                      ),
                    ),

                    Text(
                      '${currentQuestion + 1}/${questions.length}',
                      style:
                          GoogleFonts
                              .vazirmatn(
                        fontSize: 12,
                        color: Colors
                            .grey
                            .shade600,
                      ),
                    ),
                  ],
                ),
              ),

              // ==================================================
              // PROGRESS
              // ==================================================

              Padding(
                padding:
                    const EdgeInsets
                        .symmetric(
                  horizontal: 20,
                ),
                child:
                    LinearProgressIndicator(
                  value:
                      progress,
                  minHeight: 6,
                  backgroundColor:
                      Colors.grey
                          .shade300,
                  valueColor:
                      const AlwaysStoppedAnimation<
                          Color>(
                    primaryColor,
                  ),
                  borderRadius:
                      BorderRadius
                          .circular(
                    10,
                  ),
                ),
              ),

              const SizedBox(
                height: 18,
              ),

              // ==================================================
              // QUESTIONS
              // ==================================================

              Expanded(
                child:
                    SingleChildScrollView(
                  padding:
                      const EdgeInsets
                          .fromLTRB(
                    20,
                    0,
                    20,
                    20,
                  ),
                  child: Column(
                    children: [
                      _buildQuestionCard(),

                      const SizedBox(
                        height: 16,
                      ),

                      if (type ==
                          'choice')
                        ...options
                            .asMap()
                            .entries
                            .map(
                              (entry) =>
                                  _buildOptionCard(
                                entry.value,
                                entry.key,
                              ),
                            ),

                      if (type ==
                              'number' ||
                          type == 'text')
                        _buildTextField(),

                      if (type ==
                          'project')
                        _buildProjectQuestion(),
                    ],
                  ),
                ),
              ),

              // ==================================================
              // BUTTONS
              // ==================================================

              Container(
                padding:
                    const EdgeInsets
                        .fromLTRB(
                  20,
                  10,
                  20,
                  12,
                ),
                decoration:
                    const BoxDecoration(
                  color:
                      Colors.white,
                  borderRadius:
                      BorderRadius
                          .vertical(
                    top:
                        Radius.circular(
                      22,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child:
                          OutlinedButton(
                        onPressed:
                            currentQuestion >
                                    0
                                ? previousQuestion
                                : null,
                        style:
                            OutlinedButton
                                .styleFrom(
                          minimumSize:
                              const Size(
                            0,
                            50,
                          ),
                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius
                                    .circular(
                              15,
                            ),
                          ),
                        ),
                        child:
                            Text(
                          'قبلی',
                          style:
                              GoogleFonts
                                  .vazirmatn(
                            fontSize:
                                13,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(
                      width: 10,
                    ),

                    Expanded(
                      child:
                          ElevatedButton(
                        onPressed:
                            nextQuestion,
                        style:
                            ElevatedButton
                                .styleFrom(
                          backgroundColor:
                              primaryColor,
                          minimumSize:
                              const Size(
                            0,
                            50,
                          ),
                          elevation: 0,
                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius
                                    .circular(
                              15,
                            ),
                          ),
                        ),
                        child:
                            Text(
                          currentQuestion ==
                                  questions
                                          .length -
                                      1
                              ? 'ثبت ارزیابی'
                              : 'بعدی',
                          style:
                              GoogleFonts
                                  .vazirmatn(
                            color:
                                Colors.white,
                            fontSize:
                                13,
                            fontWeight:
                                FontWeight
                                    .w500,
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