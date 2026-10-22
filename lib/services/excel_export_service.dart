import 'dart:io';

import 'package:excel/excel.dart' hide Border;
import 'package:path_provider/path_provider.dart';

import '../models/class_model.dart';
import '../models/evaluation_model.dart';
import '../styles/excel_export_style.dart'; // مطمئن شوید این فایل وجود دارد

class ExcelExportService {
  ExcelExportService._();

  static String normalizeName(String name) {
    return name.trim().replaceAll(RegExp(r'\s+'), ' ').toLowerCase();
  }

  static String safeFileName(String name) {
    final result = name.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_').trim();
    return result.isEmpty ? 'صنف' : result;
  }

  static String formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '${date.year}/$month/$day - $hour:$minute';
  }

  static Future<File> export({
    required ClassModel classModel,
    required List<EvaluationModel> evaluations,
  }) async {
    final students = classModel.members;

    if (students.isEmpty) {
      throw Exception('هیچ شاگردی در این صنف وجود ندارد');
    }

    // 1. فقط ارزیابی‌های این صنف را جدا می‌کنیم
    final classEvaluations = evaluations
        .where((evaluation) => evaluation.classId == classModel.id)
        .toList();

    if (classEvaluations.isEmpty) {
      throw Exception('هیچ ارزیابی برای این صنف ثبت نشده است');
    }

    // 2. پیدا کردن بیشترین تعداد سوال
    final totalQuestions = classEvaluations.fold<int>(
      0,
      (max, evaluation) =>
          evaluation.totalQuestions > max ? evaluation.totalQuestions : max,
    );

    if (totalQuestions <= 0) {
      throw Exception('تعداد سوالات معتبر نیست');
    }

    // 3. منطق ادغام داده‌ها (فقط یک رکورد نهایی برای هر شاگرد)
    final studentFinalAnswers = <String, List<String>>{};
    for (final student in students) {
      studentFinalAnswers[normalizeName(student)] = List.filled(totalQuestions, '-');
    }

    // مرتب‌سازی از قدیمی به جدید تا پاسخ‌های قبلی حفظ شوند
    classEvaluations.sort((a, b) => a.evaluatedAt.compareTo(b.evaluatedAt));

    for (final evaluation in classEvaluations) {
      final key = normalizeName(evaluation.studentName);
      if (!studentFinalAnswers.containsKey(key)) continue;

      final currentAnswers = studentFinalAnswers[key]!;

      for (int i = 0; i < totalQuestions && i < evaluation.answers.length; i++) {
        final ans = evaluation.answers[i].trim();
        if (ans.isNotEmpty && ans != '-1') {
          currentAnswers[i] = ans;
        }
      }
    }

    final evaluatedCount = studentFinalAnswers.values.where((answers) {
      return answers.any((a) => a != '-' && a != '-1' && a.isNotEmpty);
    }).length;

    if (evaluatedCount == 0) {
      throw Exception('هنوز هیچ شاگردی در این صنف ارزیابی نشده است');
    }

    // 4. ساخت فایل اکسل جدید
    final excel = Excel.createExcel();
    const sheetName = 'نتایج پرسشنامه';
    final sheet = excel[sheetName];

    final defaultSheet = excel.getDefaultSheet();
    if (defaultSheet != null && defaultSheet != sheetName && excel.tables.containsKey(defaultSheet)) {
      excel.delete(defaultSheet);
    }

    final infoLabelCol = 0; 
    final infoValueCol = 1;
    final tableStartCol = 0; 
    final lastTableColumn = tableStartCol + totalQuestions + 1; 

    // --- بخش اطلاعات (بالا) ---
    sheet.merge(
      CellIndex.indexByColumnRow(columnIndex: infoLabelCol, rowIndex: 0),
      CellIndex.indexByColumnRow(columnIndex: infoValueCol, rowIndex: 0),
    );
    var titleCell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: infoLabelCol, rowIndex: 0));
    titleCell.value = TextCellValue('نتایج پرسشنامه');
    titleCell.cellStyle = ExcelExportStyle.sectionHeader;

    final metadata = [
      ['نام صنف', classModel.className],
      ['تعداد شاگردان', students.length.toString()],
      ['تعداد ارزیابی شده', evaluatedCount.toString()],
      ['تعداد ارزیابی نشده', (students.length - evaluatedCount).toString()],
      ['تعداد سوالات', totalQuestions.toString()],
      ['تاریخ خروجی', formatDate(DateTime.now())],
    ];

    for (int i = 0; i < metadata.length; i++) {
      int currentRow = i + 1;
      var labelCell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: infoLabelCol, rowIndex: currentRow));
      labelCell.value = TextCellValue(metadata[i][0]);
      labelCell.cellStyle = ExcelExportStyle.label;

      var valueCell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: infoValueCol, rowIndex: currentRow));
      valueCell.value = TextCellValue(metadata[i][1]);
      valueCell.cellStyle = ExcelExportStyle.value;
    }

    // --- بخش جدول (پایین) ---
    int currentRow = 7;

    // هدر اول
    sheet.merge(
      CellIndex.indexByColumnRow(columnIndex: tableStartCol, rowIndex: currentRow),
      CellIndex.indexByColumnRow(columnIndex: tableStartCol + 1, rowIndex: currentRow),
    );
    var groupHeader = sheet.cell(CellIndex.indexByColumnRow(columnIndex: tableStartCol, rowIndex: currentRow));
    groupHeader.value = TextCellValue('اسامی اعضای صنف');
    groupHeader.cellStyle = ExcelExportStyle.sectionHeader;
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: tableStartCol + 1, rowIndex: currentRow)).cellStyle = ExcelExportStyle.sectionHeader;

    for (int q = 1; q <= totalQuestions; q++) {
      var qHeader = sheet.cell(CellIndex.indexByColumnRow(columnIndex: tableStartCol + 1 + q, rowIndex: currentRow));
      qHeader.value = TextCellValue('سوال $q');
      qHeader.cellStyle = ExcelExportStyle.sectionHeader;
    }

    // هدر دوم
    currentRow++; 
    var idHeader = sheet.cell(CellIndex.indexByColumnRow(columnIndex: tableStartCol, rowIndex: currentRow));
    idHeader.value = TextCellValue('شماره');
    idHeader.cellStyle = ExcelExportStyle.label;

    var nameHeader = sheet.cell(CellIndex.indexByColumnRow(columnIndex: tableStartCol + 1, rowIndex: currentRow));
    nameHeader.value = TextCellValue('نام شاگرد');
    nameHeader.cellStyle = ExcelExportStyle.label;

    for (int q = 1; q <= totalQuestions; q++) {
       var c = sheet.cell(CellIndex.indexByColumnRow(columnIndex: tableStartCol + 1 + q, rowIndex: currentRow));
       c.cellStyle = ExcelExportStyle.label;
    }

    // --- داده‌های شاگردان ---
    currentRow++;

    for (int index = 0; index < students.length; index++) {
      final name = students[index].trim();
      final answers = studentFinalAnswers[normalizeName(name)] ?? List.filled(totalQuestions, '-');

      var idCell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: tableStartCol, rowIndex: currentRow));
      idCell.value = IntCellValue(index + 1);
      idCell.cellStyle = ExcelExportStyle.data;

      var nameCell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: tableStartCol + 1, rowIndex: currentRow));
      nameCell.value = TextCellValue(name);
      nameCell.cellStyle = ExcelExportStyle.data;

      for (int q = 0; q < totalQuestions; q++) {
        var answerCell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: tableStartCol + 2 + q, rowIndex: currentRow));
        answerCell.value = TextCellValue(answers[q]);
        answerCell.cellStyle = ExcelExportStyle.data;
      }

      currentRow++;
    }

    // تنظیم عرض ستون‌ها
    sheet.setColumnWidth(infoLabelCol, 18);
    sheet.setColumnWidth(infoValueCol, 22);
    sheet.setColumnWidth(tableStartCol, ExcelExportStyle.numberWidth);
    sheet.setColumnWidth(tableStartCol + 1, ExcelExportStyle.studentNameWidth);

    for (int col = tableStartCol + 2; col <= lastTableColumn; col++) {
      sheet.setColumnWidth(col, ExcelExportStyle.questionWidth);
    }

    // 5. ذخیره فایل
    final bytes = excel.encode();
    if (bytes == null || bytes.isEmpty) {
      throw Exception('ساخت فایل اکسل ناموفق بود');
    }

    final directory = await getApplicationDocumentsDirectory();
    final fileName = 'نتایج_${safeFileName(classModel.className)}.xlsx';
    final file = File('${directory.path}/$fileName');

    await file.writeAsBytes(bytes, flush: true);

    return file;
  }
}