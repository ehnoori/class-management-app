import 'dart:io';

import 'package:excel/excel.dart' hide Border;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';

import '../database/isar_service.dart';
import '../models/class_model.dart';
import '../models/evaluation_model.dart';
import 'evaluation_screen.dart';
import 'home_screen.dart';

class StudentSelectionScreen extends StatefulWidget {
  final ClassModel classModel;

  const StudentSelectionScreen({super.key, required this.classModel});

  @override
  State<StudentSelectionScreen> createState() => _StudentSelectionScreenState();
}

class _StudentSelectionScreenState extends State<StudentSelectionScreen> {
  int? selectedIndex;

  /// شاگردانی که در همین صنف ارزیابی شده‌اند
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
      final evaluations = await IsarService.getClassEvaluations(
        widget.classModel.id,
      );

      final Set<String> names = evaluations
          .map((evaluation) => evaluation.studentName.trim())
          .toSet();

      if (!mounted) return;

      setState(() {
        evaluatedStudents = names;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Load Evaluations Error: $e');

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      _showMessage('خطا در دریافت اطلاعات ارزیابی');
    }
  }

  // ============================================================
  // START EVALUATION
  // ============================================================

  Future<void> continueToQuestions() async {
    if (selectedIndex == null) {
      _showMessage('لطفاً یک شاگرد را انتخاب کنید');

      return;
    }

    final String studentName = widget.classModel.members[selectedIndex!].trim();

    // ==========================================================
    // CHECK:
    // THIS STUDENT ALREADY EVALUATED IN THIS CLASS
    // ==========================================================

    if (evaluatedStudents.contains(studentName)) {
      _showMessage('این شاگرد قبلاً در این صنف ارزیابی شده است');

      return;
    }

    // ==========================================================
    // OPEN EVALUATION SCREEN
    // ==========================================================

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EvaluationScreen(
          classModel: widget.classModel,
          studentName: studentName,
        ),
      ),
    );

    // ==========================================================
    // AFTER RETURN
    // ==========================================================

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
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      (route) => false,
    );
  }

  // ============================================================
  // EXPORT EXCEL
  // ============================================================

  Future<void> exportToExcel() async {
    final List<String> students = widget.classModel.members;

    // ==========================================================
    // NO STUDENTS
    // ==========================================================

    if (students.isEmpty) {
      _showMessage('هیچ شاگردی در این صنف وجود ندارد');

      return;
    }

    // ==========================================================
    // AT LEAST ONE STUDENT MUST BE EVALUATED
    // ==========================================================

    if (evaluatedStudents.isEmpty) {
      _showMessage('هنوز هیچ شاگردی ارزیابی نشده است');

      return;
    }

    // ==========================================================
    // PREVENT DOUBLE EXPORT
    // ==========================================================

    if (isExporting) return;

    setState(() {
      isExporting = true;
    });

    try {
      // ========================================================
      // GET ONLY THIS CLASS EVALUATIONS
      // ========================================================

      final List<EvaluationModel> evaluations =
          await IsarService.getClassEvaluations(widget.classModel.id);

      if (evaluations.isEmpty) {
        _showMessage('هیچ نتیجه‌ای برای خروجی وجود ندارد');

        return;
      }

      // ========================================================
      // CREATE SET OF EVALUATED STUDENTS
      //
      // فقط شاگردانی که در همین صنف ارزیابی شده‌اند.
      // ========================================================

      final Set<String> evaluatedNames = evaluations
          .map((evaluation) => evaluation.studentName.trim())
          .toSet();

      // ========================================================
      // CALCULATE COUNTS
      //
      // تعداد ارزیابی شده را از روی خود students محاسبه
      // می‌کنیم، نه فقط evaluations.length.
      // ========================================================

      final int evaluatedCount = students
          .map((student) => student.trim())
          .where((student) => evaluatedNames.contains(student))
          .length;

      final int notEvaluatedCount = students.length - evaluatedCount;

      // ========================================================
      // FIND MAX QUESTION COUNT
      // ========================================================

      final int totalQuestions = evaluations.fold<int>(0, (max, evaluation) {
        return evaluation.totalQuestions > max
            ? evaluation.totalQuestions
            : max;
      });

      if (totalQuestions <= 0) {
        _showMessage('تعداد سوالات معتبر نیست');

        return;
      }

      // ========================================================
      // CREATE EXCEL
      // ========================================================

      final Excel excel = Excel.createExcel();

      const String sheetName = 'نتایج پرسشنامه';

      final Sheet sheet = excel[sheetName];

      // ========================================================
      // DELETE DEFAULT SHEET
      // ========================================================

      final String? defaultSheet = excel.getDefaultSheet();

      if (defaultSheet != null &&
          defaultSheet != sheetName &&
          excel.tables.containsKey(defaultSheet)) {
        excel.delete(defaultSheet);
      }

      // ========================================================
      // INFORMATION
      // ========================================================

      sheet.appendRow([TextCellValue('نتایج پرسشنامه')]);

      sheet.appendRow([
        TextCellValue('نام صنف'),
        TextCellValue(widget.classModel.className),
      ]);

      sheet.appendRow([
        TextCellValue('تعداد شاگردان'),
        IntCellValue(students.length),
      ]);

      sheet.appendRow([
        TextCellValue('تعداد ارزیابی شده'),
        IntCellValue(evaluatedCount),
      ]);

      sheet.appendRow([
        TextCellValue('تعداد ارزیابی نشده'),
        IntCellValue(notEvaluatedCount),
      ]);

      sheet.appendRow([
        TextCellValue('تعداد سوالات'),
        IntCellValue(totalQuestions),
      ]);

      sheet.appendRow([
        TextCellValue('تاریخ خروجی'),
        TextCellValue(_formatDate(DateTime.now())),
      ]);

      sheet.appendRow([]);

      // ========================================================
      // HEADER
      // ========================================================

      final List<CellValue> header = [
        TextCellValue('شماره'),
        TextCellValue('نام شاگرد'),
      ];

      for (int i = 0; i < totalQuestions; i++) {
        header.add(TextCellValue('سوال ${i + 1}'));
      }

      sheet.appendRow(header);

      // ========================================================
      // CREATE EVALUATION MAP
      //
      // فقط نتایج همین صنف داخل evaluations هستند.
      // ========================================================

      final Map<String, EvaluationModel> evaluationMap = {
        for (final evaluation in evaluations)
          evaluation.studentName.trim(): evaluation,
      };

      // ========================================================
      // ADD ALL STUDENTS
      // ========================================================

      for (int i = 0; i < students.length; i++) {
        final String studentName = students[i].trim();

        final EvaluationModel? evaluation = evaluationMap[studentName];

        final List<CellValue> row = [
          IntCellValue(i + 1),
          TextCellValue(studentName),
        ];

        // ======================================================
        // STUDENT NOT EVALUATED
        // ======================================================

        if (evaluation == null) {
          for (int q = 0; q < totalQuestions; q++) {
            row.add(TextCellValue('-'));
          }

          sheet.appendRow(row);

          continue;
        }

        // ======================================================
        // STUDENT EVALUATED
        // ======================================================

        for (int q = 0; q < totalQuestions; q++) {
          String answer = '-';

          if (q < evaluation.answers.length) {
            answer = evaluation.answers[q];

            if (answer.trim().isEmpty) {
              answer = '-';
            }
          }

          row.add(TextCellValue(answer));
        }

        sheet.appendRow(row);
      }

      // ========================================================
      // COLUMN WIDTH
      // ========================================================

      sheet.setColumnWidth(0, 10);

      sheet.setColumnWidth(1, 25);

      for (int i = 2; i < totalQuestions + 2; i++) {
        sheet.setColumnWidth(i, 25);
      }

      // ========================================================
      // ENCODE
      // ========================================================

      final List<int>? fileBytes = excel.encode();

      if (fileBytes == null || fileBytes.isEmpty) {
        _showMessage('ساخت فایل اکسل ناموفق بود');

        return;
      }

      // ========================================================
      // GET APP DIRECTORY
      // ========================================================

      final Directory directory = await getApplicationDocumentsDirectory();

      // ========================================================
      // SAFE CLASS NAME
      // ========================================================

      final String safeClassName = _safeFileName(widget.classModel.className);

      // ========================================================
      // FILE NAME
      // ========================================================

      final String fileName =
          'نتایج_${safeClassName}_'
          '${DateTime.now().millisecondsSinceEpoch}.xlsx';

      final String filePath = '${directory.path}/$fileName';

      // ========================================================
      // SAVE FILE
      // ========================================================

      final File file = File(filePath);

      await file.writeAsBytes(fileBytes, flush: true);

      // ========================================================
      // VERIFY FILE
      // ========================================================

      if (!await file.exists() || await file.length() == 0) {
        _showMessage('فایل اکسل ذخیره نشد');

        return;
      }

      // ========================================================
      // DO NOT OPEN EXCEL
      // ========================================================

      if (!mounted) return;

      _showMessage('فایل اکسل با موفقیت تبدیل و ذخیره شد');
    } catch (e, stackTrace) {
      debugPrint('Excel Export Error: $e');

      debugPrint('$stackTrace');

      if (!mounted) return;

      _showMessage('خطا در ساخت فایل اکسل');
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
    return name.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_');
  }

  // ============================================================
  // DATE
  // ============================================================

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');

    final month = date.month.toString().padLeft(2, '0');

    final year = date.year.toString();

    final hour = date.hour.toString().padLeft(2, '0');

    final minute = date.minute.toString().padLeft(2, '0');

    return '$year/$month/$day - '
        '$hour:$minute';
  }

  // ============================================================
  // MESSAGE
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
            style: GoogleFonts.vazirmatn(fontSize: 13),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  // ============================================================
  // STUDENT CARD
  // ============================================================

  Widget _buildStudentCard(String studentName, int index) {
    final bool isSelected = selectedIndex == index;

    final bool isEvaluated = evaluatedStudents.contains(studentName.trim());

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedIndex = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
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
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 3),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    studentName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.vazirmatn(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 3),

                  Text(
                    isEvaluated ? 'ارزیابی تکمیل شده' : 'آماده برای ارزیابی',
                    style: GoogleFonts.vazirmatn(
                      fontSize: 11,
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
  // START BUTTON
  // ============================================================

  Widget _buildStartButton() {
    final bool enabled = selectedIndex != null;

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: enabled ? continueToQuestions : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6655D9),
          disabledBackgroundColor: const Color(0xFFD9DDE3),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
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
  // EXCEL BUTTON
  // ============================================================

  Widget _buildExcelButton(bool enabled) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: enabled && !isExporting ? exportToExcel : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF43A047),
          disabledBackgroundColor: const Color(0xFFD9DDE3),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: Text(
          isExporting ? 'در حال ساخت...' : 'تبدیل به اکسل',
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
    final List<String> students = widget.classModel.members;

    // ==========================================================
    // EXCEL:
    // فقط یک شاگرد هم ارزیابی شده باشد، فعال است.
    // ==========================================================

    final bool canExport = evaluatedStudents.isNotEmpty;

    final bool allCompleted =
        students.isNotEmpty && evaluatedStudents.length == students.length;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F8FC),

        appBar: AppBar(
          backgroundColor: const Color(0xFFF5F8FC),
          elevation: 0,
          centerTitle: true,

          leading: IconButton(
            onPressed: goHome,
            icon: const Icon(Icons.home_outlined),
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
              icon: const Icon(Icons.arrow_forward_rounded),
            ),
          ],
        ),

        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : SafeArea(
                child: Column(
                  children: [
                    // ==================================================
                    // CLASS INFORMATION
                    // ==================================================

                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 46,
                              height: 46,
                              decoration: BoxDecoration(
                                color: const Color(0xFFEAE7FF),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(
                                Icons.groups_rounded,
                                color: Color(0xFF6655D9),
                              ),
                            ),

                            const SizedBox(width: 12),

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.classModel.className,
                                    style: GoogleFonts.vazirmatn(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),

                                  const SizedBox(height: 3),

                                  Text(
                                    allCompleted
                                        ? 'تمام شاگردان ارزیابی شده‌اند'
                                        : '${evaluatedStudents.length} شاگرد ارزیابی شده‌اند',
                                    style: GoogleFonts.vazirmatn(
                                      fontSize: 11,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 11,
                                vertical: 7,
                              ),
                              decoration: BoxDecoration(
                                color: allCompleted
                                    ? const Color(0xFFE8F5E9)
                                    : const Color(0xFFF0EDFF),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '${evaluatedStudents.length}/${students.length}',
                                style: GoogleFonts.vazirmatn(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: allCompleted
                                      ? const Color(0xFF43A047)
                                      : const Color(0xFF6655D9),
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
                      padding: const EdgeInsets.fromLTRB(20, 6, 20, 6),
                      child: Row(
                        children: [
                          Text(
                            'شاگردان',
                            style: GoogleFonts.vazirmatn(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),

                          const Spacer(),

                          Text(
                            '${students.length} نفر',
                            style: GoogleFonts.vazirmatn(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ==================================================
                    // STUDENT LIST
                    // ==================================================
                    Expanded(
                      child: students.isEmpty
                          ? Center(
                              child: Text(
                                'هیچ شاگردی در این صنف وجود ندارد',
                                style: GoogleFonts.vazirmatn(fontSize: 14),
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                              itemCount: students.length,
                              itemBuilder: (context, index) {
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
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(22),
                        ),
                      ),
                      child: Column(
                        children: [
                          _buildStartButton(),

                          const SizedBox(height: 10),

                          _buildExcelButton(canExport),
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
