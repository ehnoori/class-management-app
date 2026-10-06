import 'dart:io';

import 'package:excel/excel.dart' hide Border;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

import '../database/isar_service.dart';
import '../models/class_model.dart';
import '../models/evaluation_model.dart';
import 'evaluation_screen.dart';
import 'home_screen.dart';


class StudentSelectionScreen extends StatefulWidget {
  final ClassModel classModel;

  const StudentSelectionScreen({
    super.key,
    required this.classModel,
  });

  @override
  State<StudentSelectionScreen> createState() =>
      _StudentSelectionScreenState();
}

class _StudentSelectionScreenState
    extends State<StudentSelectionScreen> {
  // ============================================================
  // VARIABLES
  // ============================================================

  int? selectedIndex;

  Set<String> evaluatedStudents = {};

  bool isLoading = true;

  bool isExporting = false;

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();
    _loadEvaluatedStudents();
  }

  // ============================================================
  // LOAD EVALUATED STUDENTS
  // ============================================================

  Future<void> _loadEvaluatedStudents() async {
    try {
      final evaluations =
          await IsarService.getClassEvaluations(
        widget.classModel.id,
      );

      final Set<String> names = evaluations
          .map(
            (evaluation) =>
                evaluation.studentName.trim(),
          )
          .toSet();

      debugPrint(
        'Loaded evaluations: ${evaluations.length}',
      );
      debugPrint(
        'Evaluated students: $names',
      );

      if (!mounted) return;

      setState(() {
        evaluatedStudents = names;
        isLoading = false;
      });
    } catch (e, stackTrace) {
      debugPrint(
        'Load Evaluations Error: $e',
      );
      debugPrint('$stackTrace');

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      _showMessage(
        'خطا در دریافت اطلاعات ارزیابی',
      );
    }
  }

  // ============================================================
  // START EVALUATION
  // ============================================================

  Future<void> continueToQuestions() async {
    if (selectedIndex == null) {
      _showMessage(
        'لطفاً یک شاگرد را انتخاب کنید',
      );
      return;
    }

    final String studentName =
        widget.classModel.members[selectedIndex!].trim();

    if (evaluatedStudents.contains(studentName)) {
      _showMessage(
        'این شاگرد قبلاً ارزیابی شده است',
      );
      return;
    }

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EvaluationScreen(
          classModel: widget.classModel,
          studentName: studentName,
        ),
      ),
    );

    if (result == true && mounted) {
      await _loadEvaluatedStudents();

      if (!mounted) return;

      setState(() {
        selectedIndex = null;
      });
    }
  }

  // ============================================================
  // HOME
  // ============================================================

  void goHome() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const HomeScreen(),
      ),
      (route) => false,
    );
  }

  // ============================================================
  // EXPORT TO EXCEL
  // ============================================================

  Future<void> exportToExcel() async {
    final List<String> students =
        widget.classModel.members;

    if (students.isEmpty) {
      _showMessage(
        'هیچ شاگردی در این صنف وجود ندارد',
      );
      return;
    }

    if (evaluatedStudents.length != students.length) {
      _showMessage(
        'ابتدا باید تمام شاگردان ارزیابی شوند',
      );
      return;
    }

    if (isExporting) {
      return;
    }

    setState(() {
      isExporting = true;
    });

    try {
      final List<EvaluationModel> evaluations =
          await IsarService.getClassEvaluations(
        widget.classModel.id,
      );

      debugPrint('======================================');
      debugPrint('EXCEL EXPORT');
      debugPrint(
        'Class ID: ${widget.classModel.id}',
      );
      debugPrint(
        'Students: ${students.length}',
      );
      debugPrint(
        'Evaluations: ${evaluations.length}',
      );
      debugPrint('======================================');

      for (final evaluation in evaluations) {
        debugPrint(
          'Student: ${evaluation.studentName} | '
          'Answers: ${evaluation.answers} | '
          'Score: '
          '${evaluation.correctAnswers}/'
          '${evaluation.totalQuestions}',
        );
      }

      if (evaluations.isEmpty) {
        _showMessage(
          'هیچ نتیجه‌ای برای خروجی وجود ندارد',
        );
        return;
      }

      final int totalQuestions =
          evaluations.fold<int>(
        0,
        (max, evaluation) {
          if (evaluation.totalQuestions > max) {
            return evaluation.totalQuestions;
          }

          return max;
        },
      );

      if (totalQuestions <= 0) {
        _showMessage(
          'تعداد سوالات معتبر نیست',
        );
        return;
      }

      final Excel excel =
          Excel.createExcel();

      const String sheetName =
          'نتایج امتحان';

      final Sheet sheet =
          excel[sheetName];

      final String? defaultSheet =
          excel.getDefaultSheet();

      if (defaultSheet != null &&
          defaultSheet != sheetName &&
          excel.tables.containsKey(defaultSheet)) {
        excel.delete(defaultSheet);
      }

      // ========================================================
      // TITLE
      // ========================================================

      sheet.appendRow([
        TextCellValue('نتایج امتحان'),
      ]);

      // ========================================================
      // CLASS NAME
      // ========================================================

      sheet.appendRow([
        TextCellValue('نام صنف'),
        TextCellValue(
          widget.classModel.className,
        ),
      ]);

      // ========================================================
      // STUDENT COUNT
      // ========================================================

      sheet.appendRow([
        TextCellValue('تعداد شاگردان'),
        IntCellValue(students.length),
      ]);

      // ========================================================
      // EVALUATED COUNT
      // ========================================================

      sheet.appendRow([
        TextCellValue('تعداد ارزیابی شده'),
        IntCellValue(evaluations.length),
      ]);

      // ========================================================
      // QUESTION COUNT
      // ========================================================

      sheet.appendRow([
        TextCellValue('تعداد سوالات'),
        IntCellValue(totalQuestions),
      ]);

      // ========================================================
      // EXPORT DATE
      // ========================================================

      sheet.appendRow([
        TextCellValue('تاریخ خروجی'),
        TextCellValue(
          _formatDate(DateTime.now()),
        ),
      ]);

      sheet.appendRow([]);

      // ========================================================
      // HEADER
      // ========================================================

      final List<CellValue> header = [
        TextCellValue('شماره'),
        TextCellValue('نام شاگرد'),
      ];

      for (int i = 0;
          i < totalQuestions;
          i++) {
        header.add(
          TextCellValue(
            'سوال ${i + 1}',
          ),
        );
      }

      header.add(
        TextCellValue('جواب درست'),
      );

      header.add(
        TextCellValue('تعداد سوالات'),
      );

      header.add(
        TextCellValue('نمره'),
      );

      sheet.appendRow(header);

      // ========================================================
      // CREATE MAP
      // ========================================================

      final Map<String, EvaluationModel>
          evaluationMap = {
        for (final evaluation in evaluations)
          evaluation.studentName.trim():
              evaluation,
      };

      // ========================================================
      // ADD STUDENTS
      // ========================================================

      int exportedRows = 0;

      for (
        int studentIndex = 0;
        studentIndex < students.length;
        studentIndex++
      ) {
        final String studentName =
            students[studentIndex].trim();

        final EvaluationModel? evaluation =
            evaluationMap[studentName];

        if (evaluation == null) {
          debugPrint(
            'WARNING: Evaluation not found for "$studentName"',
          );

          final List<CellValue> row = [
            IntCellValue(studentIndex + 1),
            TextCellValue(studentName),
          ];

          for (
            int i = 0;
            i < totalQuestions;
            i++
          ) {
            row.add(
              TextCellValue('-'),
            );
          }

          row.add(
            IntCellValue(0),
          );

          row.add(
            IntCellValue(totalQuestions),
          );

          row.add(
            TextCellValue('بدون ارزیابی'),
          );

          sheet.appendRow(row);

          continue;
        }

        // ======================================================
        // BASIC COLUMNS
        // ======================================================

        final List<CellValue> row = [
          IntCellValue(studentIndex + 1),
          TextCellValue(studentName),
        ];

        // ======================================================
        // ANSWERS
        // ======================================================

        for (
          int questionIndex = 0;
          questionIndex < totalQuestions;
          questionIndex++
        ) {
          String answerLetter = '-';

          if (
            questionIndex <
            evaluation.answers.length
          ) {
            final int answerIndex =
                evaluation.answers[
                  questionIndex
                ];

            switch (answerIndex) {
              case 0:
                answerLetter = 'A';
                break;

              case 1:
                answerLetter = 'B';
                break;

              case 2:
                answerLetter = 'C';
                break;

              case 3:
                answerLetter = 'D';
                break;

              default:
                answerLetter = '-';
            }
          }

          row.add(
            TextCellValue(answerLetter),
          );
        }

        // ======================================================
        // CORRECT ANSWERS
        // ======================================================

        row.add(
          IntCellValue(
            evaluation.correctAnswers,
          ),
        );

        // ======================================================
        // TOTAL QUESTIONS
        // ======================================================

        row.add(
          IntCellValue(
            evaluation.totalQuestions,
          ),
        );

        // ======================================================
        // SCORE
        // ======================================================

        row.add(
          TextCellValue(
            '${evaluation.correctAnswers}/'
            '${evaluation.totalQuestions}',
          ),
        );

        sheet.appendRow(row);

        exportedRows++;

        debugPrint(
          'Exported: $studentName | '
          '${evaluation.answers}',
        );
      }

      // ========================================================
      // COLUMN WIDTHS
      // ========================================================

      sheet.setColumnWidth(0, 10);

      sheet.setColumnWidth(1, 25);

      for (
        int i = 2;
        i < totalQuestions + 2;
        i++
      ) {
        sheet.setColumnWidth(i, 12);
      }

      sheet.setColumnWidth(
        totalQuestions + 2,
        15,
      );

      sheet.setColumnWidth(
        totalQuestions + 3,
        17,
      );

      sheet.setColumnWidth(
        totalQuestions + 4,
        15,
      );

      // ========================================================
      // ENCODE EXCEL
      // ========================================================

      final List<int>? fileBytes =
          excel.encode();

      debugPrint(
        'Excel rows exported: $exportedRows',
      );

      debugPrint(
        'Excel bytes: ${fileBytes?.length ?? 0}',
      );

      if (
        fileBytes == null ||
        fileBytes.isEmpty
      ) {
        _showMessage(
          'ساخت فایل اکسل ناموفق بود',
        );
        return;
      }

      // ========================================================
      // SAVE FILE
      // ========================================================

      final Directory directory =
          await getApplicationDocumentsDirectory();

      final String safeClassName =
          _safeFileName(
        widget.classModel.className,
      );

      final String fileName =
          'نتایج_${safeClassName}_'
          '${DateTime.now().millisecondsSinceEpoch}.xlsx';

      final String filePath =
          '${directory.path}/$fileName';

      final File file =
          File(filePath);

      await file.writeAsBytes(
        fileBytes,
        flush: true,
      );

      // ========================================================
      // VERIFY FILE
      // ========================================================

      final bool exists =
          await file.exists();

      final int fileSize =
          exists ? await file.length() : 0;

      debugPrint(
        'Excel file exists: $exists',
      );

      debugPrint(
        'Excel file size: $fileSize',
      );

      debugPrint(
        'Excel path: $filePath',
      );

      if (!exists || fileSize == 0) {
        _showMessage(
          'فایل اکسل ذخیره نشد',
        );
        return;
      }

      // ========================================================
      // SUCCESS
      // ========================================================

      if (!mounted) return;

      _showMessage(
        'فایل اکسل با موفقیت ساخته شد',
      );

      await Future.delayed(
        const Duration(milliseconds: 500),
      );

      if (!mounted) return;

      await OpenFilex.open(filePath);
    } catch (e, stackTrace) {
      debugPrint(
        '======================================',
      );
      debugPrint(
        'Excel Export Error: $e',
      );
      debugPrint('$stackTrace');
      debugPrint(
        '======================================',
      );

      if (!mounted) return;

      _showMessage(
        'خطا در ساخت فایل اکسل',
      );
    } finally {
      if (mounted) {
        setState(() {
          isExporting = false;
        });
      }
    }
  }

  // ============================================================
  // SAFE FILE NAME
  // ============================================================

  String _safeFileName(String name) {
    return name.replaceAll(
      RegExp(r'[<>:"/\\|?*]'),
      '_',
    );
  }

  // ============================================================
  // FORMAT DATE
  // ============================================================

  String _formatDate(DateTime date) {
    final String day =
        date.day.toString().padLeft(2, '0');

    final String month =
        date.month.toString().padLeft(2, '0');

    final String year =
        date.year.toString();

    final String hour =
        date.hour.toString().padLeft(2, '0');

    final String minute =
        date.minute.toString().padLeft(2, '0');

    return '$year/$month/$day - '
        '$hour:$minute';
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
            style: GoogleFonts.vazirmatn(
              fontSize: 13,
              fontWeight: FontWeight.w400,
            ),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  // ============================================================
  // STUDENT CARD
  // ============================================================

  Widget _buildStudentCard(
    String studentName,
    int index,
  ) {
    final bool isSelected =
        selectedIndex == index;

    final bool isEvaluated =
        evaluatedStudents.contains(
      studentName.trim(),
    );

    return GestureDetector(
      onTap: isEvaluated
          ? null
          : () {
              setState(() {
                selectedIndex = index;
              });
            },
      child: AnimatedContainer(
        duration:
            const Duration(milliseconds: 200),
        margin:
            const EdgeInsets.only(bottom: 10),
        padding:
            const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF6655D9)
                : isEvaluated
                    ? const Color(0xFFB7DFC0)
                    : const Color(0xFFE5E7EB),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color:
                  Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset:
                  const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isEvaluated
                    ? const Color(0xFFE8F5E9)
                    : isSelected
                        ? const Color(0xFFEAE7FF)
                        : const Color(0xFFF1F3F5),
                shape: BoxShape.circle,
              ),
              child: Text(
                '${index + 1}',
                style: GoogleFonts.vazirmatn(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isEvaluated
                      ? const Color(0xFF43A047)
                      : isSelected
                          ? const Color(0xFF6655D9)
                          : Colors.black87,
                ),
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    studentName,
                    maxLines: 1,
                    overflow:
                        TextOverflow.ellipsis,
                    style: GoogleFonts.vazirmatn(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 3),

                  Text(
                    isEvaluated
                        ? 'ارزیابی تکمیل شده'
                        : 'آماده برای ارزیابی',
                    style: GoogleFonts.vazirmatn(
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                      color: isEvaluated
                          ? const Color(0xFF43A047)
                          : Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            if (isEvaluated)
              const Icon(
                Icons.check_circle_rounded,
                color: Color(0xFF43A047),
                size: 25,
              )
            else
              Icon(
                isSelected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color: isSelected
                    ? const Color(0xFF6655D9)
                    : Colors.grey.shade400,
                size: 25,
              ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // START EVALUATION BUTTON
  // ============================================================

  Widget _buildStartButton() {
    final bool enabled =
        selectedIndex != null;

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed:
            enabled ? continueToQuestions : null,
        style: ElevatedButton.styleFrom(
          backgroundColor:
              const Color(0xFF6655D9),
          disabledBackgroundColor:
              const Color(0xFFD9DDE3),
          elevation: 0,
          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(15),
          ),
        ),
        child: Text(
          'شروع ارزیابی',
          style: GoogleFonts.vazirmatn(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // EXPORT TO EXCEL BUTTON
  // ============================================================

  Widget _buildExcelButton(
    bool enabled,
  ) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed:
            enabled && !isExporting
                ? exportToExcel
                : null,
        style: ElevatedButton.styleFrom(
          backgroundColor:
              const Color(0xFF43A047),
          disabledBackgroundColor:
              const Color(0xFFD9DDE3),
          elevation: 0,
          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(15),
          ),
        ),
        child: Text(
          isExporting
              ? 'در حال ساخت...'
              : 'تبدیل به اکسل',
          style: GoogleFonts.vazirmatn(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
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
    final List<String> students =
        widget.classModel.members;

    final bool allCompleted =
        students.isNotEmpty &&
        evaluatedStudents.length ==
            students.length;

    final int remaining =
        students.length -
        evaluatedStudents.length;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor:
            const Color(0xFFF5F8FC),

        appBar: AppBar(
          backgroundColor:
              const Color(0xFFF5F8FC),
          elevation: 0,
          centerTitle: true,

          leading: IconButton(
            onPressed: goHome,
            icon: const Icon(
              Icons.home_outlined,
              size: 24,
            ),
          ),

          title: Text(
            'انتخاب شاگرد',
            style: GoogleFonts.vazirmatn(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),

          actions: [
            IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(
                Icons.arrow_forward_rounded,
              ),
            ),
          ],
        ),

        body: isLoading
            ? const Center(
                child:
                    CircularProgressIndicator(),
              )
            : SafeArea(
                child: Column(
                  children: [
                    // ==================================================
                    // CLASS INFORMATION
                    // ==================================================

                    Padding(
                      padding:
                          const EdgeInsets.fromLTRB(
                        20,
                        4,
                        20,
                        8,
                      ),
                      child: Container(
                        width: double.infinity,
                        padding:
                            const EdgeInsets.all(16),
                        decoration:
                            BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black
                                  .withOpacity(0.03),
                              blurRadius: 10,
                              offset:
                                  const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 46,
                              height: 46,
                              decoration:
                                  BoxDecoration(
                                color:
                                    const Color(
                                  0xFFEAE7FF,
                                ),
                                borderRadius:
                                    BorderRadius
                                        .circular(14),
                              ),
                              child: const Icon(
                                Icons.groups_rounded,
                                color:
                                    Color(0xFF6655D9),
                              ),
                            ),

                            const SizedBox(
                              width: 12,
                            ),

                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,
                                children: [
                                  Text(
                                    widget.classModel
                                        .className,
                                    style: GoogleFonts
                                        .vazirmatn(
                                      fontSize: 16,
                                      fontWeight:
                                          FontWeight.w500,
                                    ),
                                  ),

                                  const SizedBox(
                                    height: 3,
                                  ),

                                  Text(
                                    remaining == 0
                                        ? 'تمام شاگردان ارزیابی شده‌اند'
                                        : '$remaining شاگرد باقی مانده',
                                    style: GoogleFonts
                                        .vazirmatn(
                                      fontSize: 11,
                                      fontWeight:
                                          FontWeight.w400,
                                      color: Colors
                                          .grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            Container(
                              padding:
                                  const EdgeInsets
                                      .symmetric(
                                horizontal: 11,
                                vertical: 7,
                              ),
                              decoration:
                                  BoxDecoration(
                                color: allCompleted
                                    ? const Color(
                                        0xFFE8F5E9)
                                    : const Color(
                                        0xFFF0EDFF),
                                borderRadius:
                                    BorderRadius
                                        .circular(20),
                              ),
                              child: Text(
                                '${evaluatedStudents.length}/${students.length}',
                                style: GoogleFonts
                                    .vazirmatn(
                                  fontSize: 12,
                                  fontWeight:
                                      FontWeight.w500,
                                  color: allCompleted
                                      ? const Color(
                                          0xFF43A047)
                                      : const Color(
                                          0xFF6655D9),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // ==================================================
                    // STUDENTS TITLE
                    // ==================================================

                    Padding(
                      padding:
                          const EdgeInsets.fromLTRB(
                        20,
                        6,
                        20,
                        6,
                      ),
                      child: Row(
                        children: [
                          Text(
                            'شاگردان',
                            style: GoogleFonts
                                .vazirmatn(
                              fontSize: 15,
                              fontWeight:
                                  FontWeight.w500,
                            ),
                          ),

                          const Spacer(),

                          Text(
                            '${students.length} نفر',
                            style: GoogleFonts
                                .vazirmatn(
                              fontSize: 11,
                              fontWeight:
                                  FontWeight.w400,
                              color:
                                  Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ==================================================
                    // STUDENTS LIST
                    // ==================================================

                    Expanded(
                      child: students.isEmpty
                          ? Center(
                              child: Text(
                                'هیچ شاگردی در این صنف وجود ندارد',
                                style: GoogleFonts
                                    .vazirmatn(
                                  fontSize: 14,
                                  fontWeight:
                                      FontWeight.w400,
                                ),
                              ),
                            )
                          : ListView.builder(
                              padding:
                                  const EdgeInsets
                                      .fromLTRB(
                                20,
                                4,
                                20,
                                12,
                              ),
                              itemCount:
                                  students.length,
                              itemBuilder:
                                  (context, index) {
                                return _buildStudentCard(
                                  students[index],
                                  index,
                                );
                              },
                            ),
                    ),

                    // ==================================================
                    // BOTTOM BUTTONS
                    // ==================================================

                    Container(
                      padding:
                          const EdgeInsets.fromLTRB(
                        20,
                        10,
                        20,
                        12,
                      ),
                      decoration:
                          const BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.vertical(
                          top: Radius.circular(22),
                        ),
                      ),
                      child: Column(
                        children: [
                          _buildStartButton(),

                          const SizedBox(
                            height: 10,
                          ),

                          _buildExcelButton(
                            allCompleted,
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