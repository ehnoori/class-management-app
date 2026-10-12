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

  Set<String> evaluatedStudents = {};

  bool isLoading = true;
  bool isExporting = false;

  @override
  void initState() {
    super.initState();
    _loadEvaluatedStudents();
  }

  // بارگذاری شاگردان ارزیابی‌شده در همین صنف
  Future<void> _loadEvaluatedStudents() async {
    try {
      final evaluations = await IsarService.getClassEvaluations(
        widget.classModel.id,
      );

      final names = evaluations.map((e) => e.studentName.trim()).toSet();

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

  // شروع امتحان شاگرد
  Future<void> continueToQuestions() async {
    if (selectedIndex == null) {
      _showMessage('لطفاً یک شاگرد را انتخاب کنید');
      return;
    }

    final studentName = widget.classModel.members[selectedIndex!].trim();

    if (evaluatedStudents.contains(studentName)) {
      _showMessage('این شاگرد قبلاً در این صنف ارزیابی شده است');
      return;
    }

    final result = await Navigator.push<bool>(
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

      // بعد از ارزیابی هر شاگرد، Excel ساخته یا به‌روز شود.
      await exportToExcel();
    }
  }

  void goHome() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      (route) => false,
    );
  }

  // ساخت یا به‌روزرسانی فایل Excel
  Future<void> exportToExcel() async {
    final students = widget.classModel.members;

    if (students.isEmpty) {
      _showMessage('هیچ شاگردی در این صنف وجود ندارد');
      return;
    }

    if (isExporting) return;

    setState(() {
      isExporting = true;
    });

    try {
      final evaluations = await IsarService.getClassEvaluations(
        widget.classModel.id,
      );

      if (evaluations.isEmpty) {
        _showMessage('هنوز هیچ شاگردی ارزیابی نشده است');
        return;
      }

      final evaluatedNames = evaluations
          .map((e) => e.studentName.trim())
          .toSet();

      final evaluatedCount = students
          .map((s) => s.trim())
          .where((s) => evaluatedNames.contains(s))
          .length;

      final notEvaluatedCount = students.length - evaluatedCount;

      final totalQuestions = evaluations.fold<int>(
        0,
        (maximum, evaluation) => evaluation.totalQuestions > maximum
            ? evaluation.totalQuestions
            : maximum,
      );

      if (totalQuestions <= 0) {
        _showMessage('تعداد سوالات معتبر نیست');
        return;
      }

      final excel = Excel.createExcel();

      const sheetName = 'نتایج پرسشنامه';

      final sheet = excel[sheetName];

      final defaultSheet = excel.getDefaultSheet();

      if (defaultSheet != null &&
          defaultSheet != sheetName &&
          excel.tables.containsKey(defaultSheet)) {
        excel.delete(defaultSheet);
      }

      // معلومات عمومی صنف
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

      // سرستون‌ها
      final List<CellValue> header = [
        TextCellValue('شماره'),
        TextCellValue('نام شاگرد'),
      ];

      for (int i = 0; i < totalQuestions; i++) {
        header.add(TextCellValue('سوال ${i + 1}'));
      }

      sheet.appendRow(header);

      // نتایج شاگردان همین صنف
      final Map<String, EvaluationModel> evaluationMap = {
        for (final evaluation in evaluations)
          evaluation.studentName.trim(): evaluation,
      };

      // تمام شاگردان درج می‌شوند، حتی اگر امتحان نداده باشند.
      for (int i = 0; i < students.length; i++) {
        final studentName = students[i].trim();

        final evaluation = evaluationMap[studentName];

        final List<CellValue> row = [
          IntCellValue(i + 1),
          TextCellValue(studentName),
        ];

        for (int q = 0; q < totalQuestions; q++) {
          String answer = '-';

          if (evaluation != null && q < evaluation.answers.length) {
            final savedAnswer = evaluation.answers[q].trim();

            if (savedAnswer.isNotEmpty) {
              answer = savedAnswer;
            }
          }

          row.add(TextCellValue(answer));
        }

        sheet.appendRow(row);
      }

      // عرض ستون‌ها
      sheet.setColumnWidth(0, 10);
      sheet.setColumnWidth(1, 25);

      for (int i = 2; i < totalQuestions + 2; i++) {
        sheet.setColumnWidth(i, 25);
      }

      final fileBytes = excel.encode();

      if (fileBytes == null || fileBytes.isEmpty) {
        _showMessage('ساخت فایل اکسل ناموفق بود');
        return;
      }

      final directory = await getApplicationDocumentsDirectory();

      final safeClassName = _safeFileName(widget.classModel.className);

      // نام ثابت: برای هر صنف فقط یک فایل
      final fileName = 'نتایج_$safeClassName.xlsx';

      final file = File('${directory.path}/$fileName');

      // اگر فایل وجود داشته باشد، محتوای آن به‌روز می‌شود.
      await file.writeAsBytes(fileBytes, flush: true);

      if (!await file.exists() || await file.length() == 0) {
        _showMessage('فایل اکسل ذخیره نشد');
        return;
      }

      if (!mounted) return;

      _showMessage('فایل اکسل با موفقیت ساخته یا به‌روز شد');
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

  String _safeFileName(String name) {
    return name.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_').trim();
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');

    return '$year/$month/$day - $hour:$minute';
  }

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

  // کارت شاگرد؛ طراحی اصلی حفظ شده است.
  Widget _buildStudentCard(String studentName, int index) {
    final isSelected = selectedIndex == index;

    final isEvaluated = evaluatedStudents.contains(studentName.trim());

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

  Widget _buildStartButton() {
    final enabled = selectedIndex != null;

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

  @override
  Widget build(BuildContext context) {
    final students = widget.classModel.members;

    final canExport = evaluatedStudents.isNotEmpty;

    final allCompleted =
        students.isNotEmpty &&
        students.every((student) => evaluatedStudents.contains(student.trim()));

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
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_forward_rounded),
            ),
          ],
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : SafeArea(
                child: Column(
                  children: [
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
                                        : '${students.where((s) => evaluatedStudents.contains(s.trim())).length} شاگرد ارزیابی شده‌اند',
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
                                '${students.where((s) => evaluatedStudents.contains(s.trim())).length}/${students.length}',
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
                              itemBuilder: (context, index) =>
                                  _buildStudentCard(students[index], index),
                            ),
                    ),
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
