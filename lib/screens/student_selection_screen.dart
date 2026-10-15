// import 'dart:io';

// import 'package:excel/excel.dart' hide Border;
// import 'package:flutter/material.dart';
// import 'package:path_provider/path_provider.dart';

// import '../database/isar_service.dart';
// import '../models/class_model.dart';
// import '../models/evaluation_model.dart';
// import '../styles/class_form_style.dart';
// import 'evaluation_screen.dart';
// import 'home_screen.dart';
// import '../services/excel_export_service.dart';
// class StudentSelectionScreen extends StatefulWidget {
//   final ClassModel classModel;

//   const StudentSelectionScreen({super.key, required this.classModel});

//   @override
//   State<StudentSelectionScreen> createState() => _StudentSelectionScreenState();
// }

// class _StudentSelectionScreenState extends State<StudentSelectionScreen> {
//   int? selectedIndex;
//   Set<String> evaluatedStudents = {};
//   bool isLoading = true;
//   bool isExporting = false;

//   @override
//   void initState() {
//     super.initState();
//     _loadEvaluatedStudents();
//   }

//   String _normalizeStudentName(String name) {
//     return name.trim().replaceAll(RegExp(r'\s+'), ' ').toLowerCase();
//   }

//   Future<List<EvaluationModel>> _getCurrentClassEvaluations() async {
//     final classId = widget.classModel.id;
//     final evaluations = await IsarService.getClassEvaluations(classId);

//     return evaluations
//         .where((evaluation) => evaluation.classId == classId)
//         .toList();
//   }

//   Future<void> _loadEvaluatedStudents() async {
//     try {
//       final evaluations = await _getCurrentClassEvaluations();

//       final names = evaluations
//           .map((e) => _normalizeStudentName(e.studentName))
//           .where((name) => name.isNotEmpty)
//           .toSet();

//       if (!mounted) return;

//       setState(() {
//         evaluatedStudents = names;
//         isLoading = false;
//       });
//     } catch (e, stackTrace) {
//       debugPrint('Load Evaluations Error: $e\n$stackTrace');

//       if (!mounted) return;

//       setState(() => isLoading = false);
//       _showMessage('خطا در دریافت اطلاعات ارزیابی');
//     }
//   }

//   Future<void> continueToQuestions() async {
//     if (selectedIndex == null) {
//       _showMessage('لطفاً یک شاگرد را انتخاب کنید');
//       return;
//     }

//     final studentName = widget.classModel.members[selectedIndex!].trim();
//     final normalizedName = _normalizeStudentName(studentName);

//     try {
//       final alreadyEvaluated = await IsarService.isStudentEvaluated(
//         widget.classModel.id,
//         studentName,
//       );

//       if (!mounted) return;

//       if (alreadyEvaluated || evaluatedStudents.contains(normalizedName)) {
//         await _loadEvaluatedStudents();

//         if (!mounted) return;

//         setState(() => selectedIndex = null);
//         _showMessage('این شاگرد قبلاً در این صنف ارزیابی شده است');
//         return;
//       }

//       final result = await Navigator.push<bool>(
//         context,
//         MaterialPageRoute(
//           builder: (_) => EvaluationScreen(
//             classModel: widget.classModel,
//             studentName: studentName,
//           ),
//         ),
//       );

//       if (result == true && mounted) {
//         await _loadEvaluatedStudents();

//         if (!mounted) return;

//         setState(() => selectedIndex = null);
//         await exportToExcel();
//       }
//     } catch (e, stackTrace) {
//       debugPrint('Start Evaluation Error: $e\n$stackTrace');

//       if (mounted) {
//         _showMessage('خطا در شروع ارزیابی');
//       }
//     }
//   }

//   void goHome() {
//     Navigator.pushAndRemoveUntil(
//       context,
//       MaterialPageRoute(builder: (_) => const HomeScreen()),
//       (route) => false,
//     );
//   }

//   Future<void> exportToExcel() async {
//     final students = widget.classModel.members;

//     if (students.isEmpty) {
//       _showMessage('هیچ شاگردی در این صنف وجود ندارد');
//       return;
//     }

//     if (isExporting) return;

//     setState(() => isExporting = true);

//     try {
//       final evaluations = await _getCurrentClassEvaluations();

//       if (evaluations.isEmpty) {
//         _showMessage('هنوز هیچ شاگردی ارزیابی نشده است');
//         return;
//       }

//       final evaluationMap = <String, EvaluationModel>{};

//       for (final evaluation in evaluations) {
//         final key = _normalizeStudentName(evaluation.studentName);
//         if (key.isEmpty) continue;

//         final previous = evaluationMap[key];

//         if (previous == null ||
//             evaluation.evaluatedAt.isAfter(previous.evaluatedAt)) {
//           evaluationMap[key] = evaluation;
//         }
//       }

//       final evaluatedCount = students.where((student) {
//         return evaluationMap.containsKey(_normalizeStudentName(student));
//       }).length;

//       final totalQuestions = evaluations.fold<int>(
//         0,
//         (max, e) => e.totalQuestions > max ? e.totalQuestions : max,
//       );

//       if (totalQuestions <= 0) {
//         _showMessage('تعداد سوالات معتبر نیست');
//         return;
//       }

//       final excel = Excel.createExcel();
//       const sheetName = 'نتایج پرسشنامه';
//       final sheet = excel[sheetName];
//       final defaultSheet = excel.getDefaultSheet();

//       if (defaultSheet != null &&
//           defaultSheet != sheetName &&
//           excel.tables.containsKey(defaultSheet)) {
//         excel.delete(defaultSheet);
//       }

//       sheet.appendRow([TextCellValue('نتایج پرسشنامه')]);
//       sheet.appendRow([
//         TextCellValue('نام صنف'),
//         TextCellValue(widget.classModel.className),
//       ]);
//       sheet.appendRow([
//         TextCellValue('تعداد شاگردان'),
//         IntCellValue(students.length),
//       ]);
//       sheet.appendRow([
//         TextCellValue('تعداد ارزیابی شده'),
//         IntCellValue(evaluatedCount),
//       ]);
//       sheet.appendRow([
//         TextCellValue('تعداد ارزیابی نشده'),
//         IntCellValue(students.length - evaluatedCount),
//       ]);
//       sheet.appendRow([
//         TextCellValue('تعداد سوالات'),
//         IntCellValue(totalQuestions),
//       ]);
//       sheet.appendRow([
//         TextCellValue('تاریخ خروجی'),
//         TextCellValue(_formatDate(DateTime.now())),
//       ]);
//       sheet.appendRow([]);

//       final header = <CellValue>[
//         TextCellValue('شماره'),
//         TextCellValue('نام شاگرد'),
//       ];

//       for (int q = 1; q <= totalQuestions; q++) {
//         header.add(TextCellValue('سوال $q'));
//       }

//       sheet.appendRow(header);

//       for (int i = 0; i < students.length; i++) {
//         final studentName = students[i].trim();
//         final evaluation = evaluationMap[_normalizeStudentName(studentName)];

//         final row = <CellValue>[
//           IntCellValue(i + 1),
//           TextCellValue(studentName),
//         ];

//         for (int q = 0; q < totalQuestions; q++) {
//           String answer = '-';

//           if (evaluation != null && q < evaluation.answers.length) {
//             final savedAnswer = evaluation.answers[q].trim();

//             if (savedAnswer.isNotEmpty && savedAnswer != '-1') {
//               answer = savedAnswer;
//             }
//           }

//           row.add(TextCellValue(answer));
//         }

//         sheet.appendRow(row);
//       }

//       sheet.setColumnWidth(0, 10);
//       sheet.setColumnWidth(1, 25);

//       for (int i = 2; i < totalQuestions + 2; i++) {
//         sheet.setColumnWidth(i, 25);
//       }

//       final bytes = excel.encode();

//       if (bytes == null || bytes.isEmpty) {
//         _showMessage('ساخت فایل اکسل ناموفق بود');
//         return;
//       }

//       final directory = await getApplicationDocumentsDirectory();
//       final safeName = _safeFileName(widget.classModel.className);
//       final file = File('${directory.path}/نتایج_$safeName.xlsx');

//       await file.writeAsBytes(bytes, flush: true);

//       if (!await file.exists() || await file.length() == 0) {
//         _showMessage('فایل اکسل ذخیره نشد');
//         return;
//       }

//       if (mounted) {
//         _showMessage('فایل اکسل همین صنف به‌روز شد');
//       }
//     } catch (e, stackTrace) {
//       debugPrint('Excel Export Error: $e\n$stackTrace');

//       if (mounted) {
//         _showMessage('خطا در ساخت فایل اکسل');
//       }
//     } finally {
//       if (mounted) {
//         setState(() => isExporting = false);
//       }
//     }
//   }

//   String _safeFileName(String name) {
//     final safeName = name.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_').trim();
//     return safeName.isEmpty ? 'صنف' : safeName;
//   }

//   String _formatDate(DateTime date) {
//     final day = date.day.toString().padLeft(2, '0');
//     final month = date.month.toString().padLeft(2, '0');
//     final hour = date.hour.toString().padLeft(2, '0');
//     final minute = date.minute.toString().padLeft(2, '0');

//     return '${date.year}/$month/$day - $hour:$minute';
//   }

//   void _showMessage(String message) {
//     if (!mounted) return;

//     ScaffoldMessenger.of(context)
//       ..hideCurrentSnackBar()
//       ..showSnackBar(
//         SnackBar(
//           content: Text(
//             message,
//             textDirection: TextDirection.rtl,
//             style: ClassFormStyle.snackBarTextStyle(),
//           ),
//           behavior: SnackBarBehavior.floating,
//         ),
//       );
//   }

//   Widget _buildStudentCard(String studentName, int index) {
//     final isSelected = selectedIndex == index;
//     final isEvaluated = evaluatedStudents.contains(
//       _normalizeStudentName(studentName),
//     );

//     return GestureDetector(
//       onTap: () {
//         setState(() {
//           selectedIndex = isEvaluated ? null : index;
//         });
//       },
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 200),
//         margin: const EdgeInsets.only(bottom: 10),
//         padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
//         decoration: ClassFormStyle.studentCardDecoration(
//           selected: isSelected,
//           evaluated: isEvaluated,
//         ),
//         child: Row(
//           children: [
//             Container(
//               width: 42,
//               height: 42,
//               alignment: Alignment.center,
//               decoration: ClassFormStyle.studentNumberDecoration(
//                 selected: isSelected,
//                 evaluated: isEvaluated,
//               ),
//               child: Text(
//                 '${index + 1}',
//                 style: ClassFormStyle.studentNumberStyle(
//                   selected: isSelected,
//                   evaluated: isEvaluated,
//                 ),
//               ),
//             ),
//             const SizedBox(width: 12),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     studentName,
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                     style: ClassFormStyle.studentNameStyle(),
//                   ),
//                   const SizedBox(height: 3),
//                   Text(
//                     isEvaluated ? 'ارزیابی تکمیل شده' : 'آماده برای ارزیابی',
//                     style: ClassFormStyle.studentStatusStyle(
//                       evaluated: isEvaluated,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(width: 8),
//             Icon(
//               isEvaluated
//                   ? Icons.check_circle_rounded
//                   : isSelected
//                   ? Icons.radio_button_checked
//                   : Icons.radio_button_unchecked,
//               color: isEvaluated
//                   ? ClassFormStyle.successColor
//                   : isSelected
//                   ? ClassFormStyle.primaryColor
//                   : Colors.grey.shade400,
//               size: 25,
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildStartButton() {
//     return SizedBox(
//       width: double.infinity,
//       height: 52,
//       child: ElevatedButton(
//         onPressed: selectedIndex != null ? continueToQuestions : null,
//         style: ClassFormStyle.actionButtonStyle(
//           color: ClassFormStyle.primaryColor,
//         ),
//         child: Text('شروع ارزیابی', style: ClassFormStyle.buttonTextStyle()),
//       ),
//     );
//   }

//   Widget _buildExcelButton(bool enabled) {
//     return SizedBox(
//       width: double.infinity,
//       height: 52,
//       child: ElevatedButton(
//         onPressed: enabled && !isExporting ? exportToExcel : null,
//         style: ClassFormStyle.actionButtonStyle(
//           color: ClassFormStyle.successColor,
//         ),
//         child: Text(
//           isExporting ? 'در حال ساخت...' : 'تبدیل به اکسل',
//           style: ClassFormStyle.buttonTextStyle(),
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final students = widget.classModel.members;

//     final evaluatedCount = students.where((student) {
//       return evaluatedStudents.contains(_normalizeStudentName(student));
//     }).length;

//     final allCompleted =
//         students.isNotEmpty && evaluatedCount == students.length;

//     return Directionality(
//       textDirection: TextDirection.rtl,
//       child: Scaffold(
//         backgroundColor: ClassFormStyle.backgroundColor,
//         appBar: AppBar(
//           backgroundColor: ClassFormStyle.backgroundColor,
//           elevation: 0,
//           centerTitle: true,
//           leading: IconButton(
//             onPressed: goHome,
//             icon: const Icon(Icons.home_outlined),
//           ),
//           title: Text('انتخاب شاگرد', style: ClassFormStyle.appBarTitleStyle()),
//           actions: [
//             IconButton(
//               onPressed: () => Navigator.pop(context),
//               icon: const Icon(Icons.arrow_forward_rounded),
//             ),
//           ],
//         ),
//         body: isLoading
//             ? const Center(child: CircularProgressIndicator())
//             : SafeArea(
//                 child: Column(
//                   children: [
//                     Padding(
//                       padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
//                       child: Container(
//                         width: double.infinity,
//                         padding: const EdgeInsets.all(16),
//                         decoration: ClassFormStyle.classInfoCardDecoration(),
//                         child: Row(
//                           children: [
//                             Container(
//                               width: 46,
//                               height: 46,
//                               decoration: ClassFormStyle.classIconDecoration(),
//                               child: const Icon(
//                                 Icons.groups_rounded,
//                                 color: ClassFormStyle.primaryColor,
//                               ),
//                             ),
//                             const SizedBox(width: 12),
//                             Expanded(
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(
//                                     widget.classModel.className,
//                                     style: ClassFormStyle.classNameStyle(),
//                                   ),
//                                   const SizedBox(height: 3),
//                                   Text(
//                                     allCompleted
//                                         ? 'تمام شاگردان ارزیابی شده‌اند'
//                                         : '$evaluatedCount شاگرد ارزیابی شده‌اند',
//                                     style: ClassFormStyle.secondaryTextStyle(),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                             Container(
//                               padding: const EdgeInsets.symmetric(
//                                 horizontal: 11,
//                                 vertical: 7,
//                               ),
//                               decoration:
//                                   ClassFormStyle.evaluationCountDecoration(
//                                     allCompleted: allCompleted,
//                                   ),
//                               child: Text(
//                                 '$evaluatedCount/${students.length}',
//                                 style: ClassFormStyle.evaluationCountStyle(
//                                   allCompleted: allCompleted,
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                     Padding(
//                       padding: const EdgeInsets.fromLTRB(20, 6, 20, 6),
//                       child: Row(
//                         children: [
//                           Text(
//                             'شاگردان',
//                             style: ClassFormStyle.sectionTitleStyle(),
//                           ),
//                           const Spacer(),
//                           Text(
//                             '${students.length} نفر',
//                             style: ClassFormStyle.secondaryTextStyle(),
//                           ),
//                         ],
//                       ),
//                     ),
//                     Expanded(
//                       child: students.isEmpty
//                           ? Center(
//                               child: Text(
//                                 'هیچ شاگردی در این صنف وجود ندارد',
//                                 style: ClassFormStyle.textStyle(fontSize: 14),
//                               ),
//                             )
//                           : ListView.builder(
//                               padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
//                               itemCount: students.length,
//                               itemBuilder: (context, index) =>
//                                   _buildStudentCard(students[index], index),
//                             ),
//                     ),
//                     Container(
//                       padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
//                       decoration: ClassFormStyle.bottomPanelDecoration(),
//                       child: Column(
//                         children: [
//                           _buildStartButton(),
//                           const SizedBox(height: 10),
//                           _buildExcelButton(evaluatedCount > 0),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';

import '../database/isar_service.dart';
import '../models/class_model.dart';
import '../models/evaluation_model.dart';
import '../styles/class_form_style.dart';
import '../services/excel_export_service.dart';

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

  String _normalizeStudentName(String name) {
    return name.trim().replaceAll(RegExp(r'\s+'), ' ').toLowerCase();
  }

  Future<List<EvaluationModel>> _getCurrentClassEvaluations() async {
    final classId = widget.classModel.id;
    final evaluations = await IsarService.getClassEvaluations(classId);

    return evaluations
        .where((evaluation) => evaluation.classId == classId)
        .toList();
  }

  Future<void> _loadEvaluatedStudents() async {
    try {
      final evaluations = await _getCurrentClassEvaluations();

      final names = evaluations
          .map((e) => _normalizeStudentName(e.studentName))
          .where((name) => name.isNotEmpty)
          .toSet();

      if (!mounted) return;

      setState(() {
        evaluatedStudents = names;
        isLoading = false;
      });
    } catch (e, stackTrace) {
      debugPrint('Load Evaluations Error: $e\n$stackTrace');

      if (!mounted) return;

      setState(() => isLoading = false);
      _showMessage('خطا در دریافت اطلاعات ارزیابی');
    }
  }

  Future<void> exportToExcel() async {
    if (widget.classModel.members.isEmpty) {
      _showMessage('هیچ شاگردی در این صنف وجود ندارد');
      return;
    }

    if (isExporting) return;

    setState(() => isExporting = true);

    try {
      final evaluations = await _getCurrentClassEvaluations();

      if (evaluations.isEmpty) {
        _showMessage('هنوز هیچ شاگردی ارزیابی نشده است');
        return;
      }

      final file = await ExcelExportService.export(
        classModel: widget.classModel,
        evaluations: evaluations,
      );

      if (!mounted) return;

      _showMessage('فایل اکسل همین صنف به‌روز شد');
      debugPrint('Excel saved: ${file.path}');
    } catch (e, stackTrace) {
      debugPrint('Excel Export Error: $e\n$stackTrace');

      if (mounted) {
        final message = e.toString().replaceFirst('Exception: ', '');
        _showMessage(message == 'null' ? 'خطا در ساخت فایل اکسل' : message);
      }
    } finally {
      if (mounted) {
        setState(() => isExporting = false);
      }
    }
  }

  Future<void> continueToQuestions() async {
    if (selectedIndex == null) {
      _showMessage('لطفاً یک شاگرد را انتخاب کنید');
      return;
    }

    final studentName = widget.classModel.members[selectedIndex!].trim();
    final normalizedName = _normalizeStudentName(studentName);

    try {
      final alreadyEvaluated = await IsarService.isStudentEvaluated(
        widget.classModel.id,
        studentName,
      );

      if (!mounted) return;

      if (alreadyEvaluated || evaluatedStudents.contains(normalizedName)) {
        await _loadEvaluatedStudents();

        if (!mounted) return;

        setState(() => selectedIndex = null);
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

        setState(() => selectedIndex = null);
        await exportToExcel();
      }
    } catch (e, stackTrace) {
      debugPrint('Start Evaluation Error: $e\n$stackTrace');

      if (mounted) {
        _showMessage('خطا در شروع ارزیابی');
      }
    }
  }

  void goHome() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      (route) => false,
    );
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
            style: ClassFormStyle.snackBarTextStyle(),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  Widget _buildStudentCard(String studentName, int index) {
    final isSelected = selectedIndex == index;
    final isEvaluated = evaluatedStudents.contains(
      _normalizeStudentName(studentName),
    );

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedIndex = isEvaluated ? null : index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: ClassFormStyle.studentCardDecoration(
          selected: isSelected,
          evaluated: isEvaluated,
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              alignment: Alignment.center,
              decoration: ClassFormStyle.studentNumberDecoration(
                selected: isSelected,
                evaluated: isEvaluated,
              ),
              child: Text(
                '${index + 1}',
                style: ClassFormStyle.studentNumberStyle(
                  selected: isSelected,
                  evaluated: isEvaluated,
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
                    style: ClassFormStyle.studentNameStyle(),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    isEvaluated ? 'ارزیابی تکمیل شده' : 'آماده برای ارزیابی',
                    style: ClassFormStyle.studentStatusStyle(
                      evaluated: isEvaluated,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              isEvaluated
                  ? Icons.check_circle_rounded
                  : isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: isEvaluated
                  ? ClassFormStyle.successColor
                  : isSelected
                  ? ClassFormStyle.primaryColor
                  : Colors.grey.shade400,
              size: 25,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStartButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: selectedIndex != null ? continueToQuestions : null,
        style: ClassFormStyle.actionButtonStyle(
          color: ClassFormStyle.primaryColor,
        ),
        child: Text('شروع ارزیابی', style: ClassFormStyle.buttonTextStyle()),
      ),
    );
  }

  Widget _buildExcelButton(bool enabled) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: enabled && !isExporting ? exportToExcel : null,
        style: ClassFormStyle.actionButtonStyle(
          color: ClassFormStyle.successColor,
        ),
        child: Text(
          isExporting ? 'در حال ساخت...' : 'تبدیل به اکسل',
          style: ClassFormStyle.buttonTextStyle(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final students = widget.classModel.members;

    final evaluatedCount = students.where((student) {
      return evaluatedStudents.contains(_normalizeStudentName(student));
    }).length;

    final allCompleted =
        students.isNotEmpty && evaluatedCount == students.length;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: ClassFormStyle.backgroundColor,
        appBar: AppBar(
          backgroundColor: ClassFormStyle.backgroundColor,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            onPressed: goHome,
            icon: const Icon(Icons.home_outlined),
          ),
          title: Text('انتخاب شاگرد', style: ClassFormStyle.appBarTitleStyle()),
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
                        decoration: ClassFormStyle.classInfoCardDecoration(),
                        child: Row(
                          children: [
                            Container(
                              width: 46,
                              height: 46,
                              decoration: ClassFormStyle.classIconDecoration(),
                              child: const Icon(
                                Icons.groups_rounded,
                                color: ClassFormStyle.primaryColor,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.classModel.className,
                                    style: ClassFormStyle.classNameStyle(),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    allCompleted
                                        ? 'تمام شاگردان ارزیابی شده‌اند'
                                        : '$evaluatedCount شاگرد ارزیابی شده‌اند',
                                    style: ClassFormStyle.secondaryTextStyle(),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 11,
                                vertical: 7,
                              ),
                              decoration:
                                  ClassFormStyle.evaluationCountDecoration(
                                    allCompleted: allCompleted,
                                  ),
                              child: Text(
                                '$evaluatedCount/${students.length}',
                                style: ClassFormStyle.evaluationCountStyle(
                                  allCompleted: allCompleted,
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
                            style: ClassFormStyle.sectionTitleStyle(),
                          ),
                          const Spacer(),
                          Text(
                            '${students.length} نفر',
                            style: ClassFormStyle.secondaryTextStyle(),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: students.isEmpty
                          ? Center(
                              child: Text(
                                'هیچ شاگردی در این صنف وجود ندارد',
                                style: ClassFormStyle.textStyle(fontSize: 14),
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
                      decoration: ClassFormStyle.bottomPanelDecoration(),
                      child: Column(
                        children: [
                          _buildStartButton(),
                          const SizedBox(height: 10),
                          _buildExcelButton(evaluatedCount > 0),
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
