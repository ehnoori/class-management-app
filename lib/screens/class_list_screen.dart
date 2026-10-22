import 'dart:io';

import 'package:excel/excel.dart' hide Border;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';

import '../database/isar_service.dart';
import '../models/class_model.dart';
import '../models/evaluation_model.dart';
import 'evaluation_screen.dart';
// ✅ این ایمپورت را حتماً اضافه کنید
import '../services/excel_export_service.dart';

class ClassListScreen extends StatefulWidget {
  const ClassListScreen({super.key});

  @override
  State<ClassListScreen> createState() => _ClassListScreenState();
}

class _ClassListScreenState extends State<ClassListScreen> {
  List<ClassModel> classes = [];
  bool isLoading = true;

  final Set<int> expandedClasses = {};

  /// شاگردانی که امتحان داده‌اند
  final Map<int, Set<String>> evaluatedStudentsByClass = {};

  /// صنف‌هایی که در حال ساخت Excel هستند
  final Set<int> exportingClasses = {};

  @override
  void initState() {
    super.initState();
    _loadClasses();
  }

  // ============================================================
  // LOAD CLASSES
  // ============================================================

  Future<void> _loadClasses() async {
    try {
      final result = await IsarService.getAllClasses();

      if (!mounted) return;

      setState(() {
        classes = result;
        isLoading = false;
      });

      await _loadAllEvaluationStatuses();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'خطا در دریافت صنف‌ها: $e',
            textDirection: TextDirection.rtl,
          ),
        ),
      );
    }
  }

  // ============================================================
  // LOAD ALL EVALUATION STATUS
  // ============================================================

  Future<void> _loadAllEvaluationStatuses() async {
    for (final classModel in classes) {
      await _loadEvaluationStatus(classModel.id);
    }
  }

  // ============================================================
  // LOAD EVALUATION STATUS FOR ONE CLASS
  // ============================================================

  Future<void> _loadEvaluationStatus(int classId) async {
    try {
      final evaluations = await IsarService.getClassEvaluations(classId);

      final names = evaluations
          .map((evaluation) => evaluation.studentName.trim())
          .where((name) => name.isNotEmpty)
          .toSet();

      if (!mounted) return;

      setState(() {
        evaluatedStudentsByClass[classId] = names;
      });
    } catch (e) {
      debugPrint('Error loading evaluations for class $classId: $e');
    }
  }

  // ============================================================
  // REFRESH
  // ============================================================

  Future<void> _refreshClasses() async {
    await _loadClasses();
  }

  // ============================================================
  // TOGGLE MEMBERS
  // ============================================================

  void _toggleMembers(int classId) {
    setState(() {
      if (expandedClasses.contains(classId)) {
        expandedClasses.remove(classId);
      } else {
        expandedClasses.add(classId);
      }
    });
  }

  // ============================================================
  // CHECK STUDENT EVALUATED
  // ============================================================

  bool _isStudentEvaluated(int classId, String studentName) {
    final students = evaluatedStudentsByClass[classId];

    if (students == null) {
      return false;
    }

    return students.contains(studentName.trim());
  }

  // ============================================================
  // CONFIRM START EVALUATION
  // ============================================================

  Future<void> _confirmStartEvaluation({
    required ClassModel classModel,
    required String studentName,
  }) async {
    final cleanName = studentName.trim();

    // اگر قبلاً امتحان داده باشد، هیچ کاری نکن
    if (_isStudentEvaluated(classModel.id, cleanName)) {
      return;
    }

    final shouldStart = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: Text(
            'شروع ارزیابی',
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.right,
            style: GoogleFonts.vazirmatn(
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'آیا از «$cleanName» امتحان می‌گیرید؟',
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.right,
            style: GoogleFonts.vazirmatn(
              fontSize: 14,
              color: const Color(0xFF26364D),
            ),
          ),
          actionsAlignment: MainAxisAlignment.start,
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: Text(
                'لغو',
                style: GoogleFonts.vazirmatn(
                  color: const Color(0xFF7A8797),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C5CE7),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'بلی',
                style: GoogleFonts.vazirmatn(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );

    if (shouldStart != true) {
      return;
    }

    if (!mounted) return;

    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) =>
            EvaluationScreen(classModel: classModel, studentName: cleanName),
      ),
    );

    // اگر ارزیابی با موفقیت ذخیره شد
    if (result == true) {
      await _loadEvaluationStatus(classModel.id);
    }
  }

  // ============================================================
  // EXPORT TO EXCEL (اصلاح شده)
  // ============================================================

  Future<void> _exportToExcel(ClassModel classModel) async {
    // جلوگیری از چند بار کلیک
    if (exportingClasses.contains(classModel.id)) {
      return;
    }

    if (classModel.members.isEmpty) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'این صنف شاگردی ندارد.',
            textDirection: TextDirection.rtl,
            style: GoogleFonts.vazirmatn(),
          ),
        ),
      );

      return;
    }

    // تازه‌سازی وضعیت شاگردان
    await _loadEvaluationStatus(classModel.id);

    if (!mounted) return;

    setState(() {
      exportingClasses.add(classModel.id);
    });

    try {
      // ========================================================
      // GET ALL EVALUATIONS
      // ========================================================
      final evaluations = await IsarService.getClassEvaluations(classModel.id);

      if (evaluations.isEmpty) {
        throw Exception('هنوز هیچ نتیجه‌ای برای این صنف ثبت نشده است.');
      }

      // ✅ فراخوانی سرویس اکسل (که خودش داده‌ها را فیلتر و بدون تکرار می‌سازد)
      final file = await ExcelExportService.export(
        classModel: classModel,
        evaluations: evaluations,
      );

      // ========================================================
      // SUCCESS
      // ========================================================

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'فایل Excel با موفقیت در مسیر ${file.path} ذخیره شد.',
            textDirection: TextDirection.rtl,
            style: GoogleFonts.vazirmatn(),
          ),
          duration: const Duration(seconds: 3),
        ),
      );
    } catch (e) {
      debugPrint('Excel export error: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'خطا در ساخت فایل Excel: $e',
            textDirection: TextDirection.rtl,
            style: GoogleFonts.vazirmatn(),
          ),
          duration: const Duration(seconds: 4),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          exportingClasses.remove(classModel.id);
        });
      }
    }
  }

  // ============================================================
  // FORMAT DATE
  // ============================================================

  String _formatDateTime(DateTime dateTime) {
    String twoDigits(int value) {
      return value.toString().padLeft(2, '0');
    }

    return '${dateTime.year}/'
        '${twoDigits(dateTime.month)}/'
        '${twoDigits(dateTime.day)} '
        '${twoDigits(dateTime.hour)}:'
        '${twoDigits(dateTime.minute)}';
  }

  // ============================================================
  // SAFE FILE NAME
  // ============================================================

  String _safeFileName(String value) {
    return value
        .trim()
        .replaceAll(RegExp(r'[\\/:*?"<>|]'), '_')
        .replaceAll(RegExp(r'\s+'), ' ');
  }

  // ============================================================
  // DELETE SHEET
  // ============================================================

  void _showDeleteSheet() {
    if (classes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'هیچ صنفی برای حذف وجود ندارد.',
            textDirection: TextDirection.rtl,
            style: GoogleFonts.vazirmatn(),
          ),
        ),
      );

      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD9DFE8),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),

                  const SizedBox(height: 18),

                  Text(
                    'حذف صنف',
                    textDirection: TextDirection.rtl,
                    style: GoogleFonts.vazirmatn(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF26364D),
                    ),
                  ),

                  const SizedBox(height: 14),

                  ...classes.map((classModel) {
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(
                        Icons.delete_outline_rounded,
                        color: Color(0xFFE53935),
                      ),
                      title: Text(
                        classModel.className,
                        textDirection: TextDirection.rtl,
                        textAlign: TextAlign.right,
                        style: GoogleFonts.vazirmatn(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(context);

                        _confirmDeleteClass(classModel);
                      },
                    );
                  }),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // CONFIRM DELETE
  // ============================================================

  Future<void> _confirmDeleteClass(ClassModel classModel) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: Text(
            'حذف صنف',
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.right,
            style: GoogleFonts.vazirmatn(fontWeight: FontWeight.bold),
          ),
          content: Text(
            'آیا مطمئن هستید که صنف «${classModel.className}» حذف شود؟',
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.right,
            style: GoogleFonts.vazirmatn(fontSize: 14),
          ),
          actionsAlignment: MainAxisAlignment.start,
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: Text('لغو', style: GoogleFonts.vazirmatn()),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE53935),
                foregroundColor: Colors.white,
                elevation: 0,
              ),
              child: Text(
                'حذف',
                style: GoogleFonts.vazirmatn(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    try {
      final isar = await IsarService.getInstance();

      // حذف تمام ارزیابی‌های صنف
      await IsarService.deleteClassEvaluations(classModel.id);

      // حذف خود صنف
      await isar.writeTxn(() async {
        await isar.classModels.delete(classModel.id);
      });

      // حذف فایل Excel مربوط به صنف
      try {
        final directory = await getApplicationDocumentsDirectory();

        final safeClassName = _safeFileName(classModel.className);

        final file = File('${directory.path}/نتایج_$safeClassName.xlsx');

        if (await file.exists()) {
          await file.delete();
        }
      } catch (e) {
        debugPrint('Excel delete error: $e');
      }

      if (!mounted) return;

      setState(() {
        classes.removeWhere((item) => item.id == classModel.id);

        evaluatedStudentsByClass.remove(classModel.id);

        expandedClasses.remove(classModel.id);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'صنف حذف شد.',
            textDirection: TextDirection.rtl,
            style: GoogleFonts.vazirmatn(),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'خطا در حذف صنف: $e',
            textDirection: TextDirection.rtl,
            style: GoogleFonts.vazirmatn(),
          ),
        ),
      );
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F7FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF3F7FC),
        elevation: 0,
        centerTitle: true,
        title: Text(
          'لیست صنوف',
          style: GoogleFonts.vazirmatn(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF26364D),
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
            color: Color(0xFF26364D),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert_rounded, color: Color(0xFF26364D)),
            onPressed: _showDeleteSheet,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshClasses,
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF7C4DFF)),
              )
            : classes.isEmpty
            ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  const SizedBox(height: 160),
                  Icon(
                    Icons.school_outlined,
                    size: 65,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 15),
                  Text(
                    'هنوز صنفی ایجاد نشده است.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.vazirmatn(
                      fontSize: 15,
                      color: const Color(0xFF7A8797),
                    ),
                  ),
                ],
              )
            : ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 30),
                itemCount: classes.length,
                itemBuilder: (context, index) {
                  final classModel = classes[index];

                  return _buildClassCard(classModel);
                },
              ),
      ),
    );
  }

  // ============================================================
  // CLASS CARD
  // ============================================================

  Widget _buildClassCard(ClassModel classModel) {
    final isExpanded = expandedClasses.contains(classModel.id);

    final evaluated = evaluatedStudentsByClass[classModel.id] ?? <String>{};

    final isExporting = exportingClasses.contains(classModel.id);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE6EBF2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            // ==================================================
            // CLASS INFORMATION
            // ==================================================

            Row(
              textDirection: TextDirection.rtl,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEDE9FF),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.school_rounded,
                    color: Color(0xFF7C4DFF),
                    size: 25,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        classModel.className,
                        textDirection: TextDirection.rtl,
                        textAlign: TextAlign.right,
                        style: GoogleFonts.vazirmatn(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF26364D),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'استاد: ${classModel.teacherName}',
                        textDirection: TextDirection.rtl,
                        textAlign: TextAlign.right,
                        style: GoogleFonts.vazirmatn(
                          fontSize: 11,
                          color: const Color(0xFF7A8797),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'زمان: ${classModel.classTime}',
                        textDirection: TextDirection.rtl,
                        textAlign: TextAlign.right,
                        style: GoogleFonts.vazirmatn(
                          fontSize: 11,
                          color: const Color(0xFF7A8797),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // ==================================================
            // MEMBERS BUTTON
            // ==================================================
            InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                _toggleMembers(classModel.id);
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 11,
                  horizontal: 12,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F8FC),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  textDirection: TextDirection.rtl,
                  children: [
                    const Icon(
                      Icons.groups_rounded,
                      size: 20,
                      color: Color(0xFF7C4DFF),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'اعضای صنف',
                        textDirection: TextDirection.rtl,
                        textAlign: TextAlign.right,
                        style: GoogleFonts.vazirmatn(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF26364D),
                        ),
                      ),
                    ),
                    Text(
                      '${classModel.members.length} نفر',
                      style: GoogleFonts.vazirmatn(
                        fontSize: 11,
                        color: const Color(0xFF7A8797),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(
                      isExpanded
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      color: const Color(0xFF7A8797),
                    ),
                  ],
                ),
              ),
            ),

            // ==================================================
            // MEMBERS LIST
            // ==================================================
            if (isExpanded) ...[
              const SizedBox(height: 10),

              ..._buildMembersList(classModel, evaluated),

              const SizedBox(height: 6),

              // ==================================================
              // EXPORT BUTTON
              // ==================================================
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton.icon(
                  onPressed: !isExporting
                      ? () {
                          _exportToExcel(classModel);
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C5CE7),
                    disabledBackgroundColor: const Color(0xFFE1E5EC),
                    disabledForegroundColor: const Color(0xFF9AA8BA),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: isExporting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.description_outlined, size: 20),
                  label: Text(
                    isExporting ? 'در حال ساخت Excel...' : 'تبدیل به اکسل',
                    style: GoogleFonts.vazirmatn(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ============================================================
  // MEMBERS LIST
  // ============================================================

  List<Widget> _buildMembersList(
    ClassModel classModel,
    Set<String> evaluatedStudents,
  ) {
    return List.generate(classModel.members.length, (index) {
      final student = classModel.members[index].trim();

      final isEvaluated = evaluatedStudents.contains(student);

      return Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 7),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFFAFBFD),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE8EDF4)),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: isEvaluated
              ? null
              : () {
                  _confirmStartEvaluation(
                    classModel: classModel,
                    studentName: student,
                  );
                },
          child: Row(
            textDirection: TextDirection.rtl,
            children: [
              Container(
                width: 29,
                height: 29,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFFE1EDFF),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Text(
                  '${index + 1}',
                  style: GoogleFonts.vazirmatn(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1565E8),
                  ),
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: Text(
                  student,
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.right,
                  style: GoogleFonts.vazirmatn(
                    fontSize: 12,
                    fontWeight: FontWeight.normal,
                    color: const Color(0xFF26364D),
                  ),
                ),
              ),

              // ==================================================
              // GREEN CHECKBOX FOR COMPLETED STUDENTS
              // ==================================================
              Checkbox(
                value: isEvaluated,
                activeColor: const Color(0xFF43A047),
                checkColor: Colors.white,
                side: BorderSide(
                  color: isEvaluated
                      ? const Color(0xFF43A047)
                      : const Color(0xFF9AA8BA),
                  width: 1.5,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
                onChanged: (_) {
                  if (isEvaluated) {
                    return;
                  }

                  _confirmStartEvaluation(
                    classModel: classModel,
                    studentName: student,
                  );
                },
              ),
            ],
          ),
        ),
      );
    });
  }
}