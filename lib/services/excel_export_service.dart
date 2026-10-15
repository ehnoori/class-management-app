import 'dart:io';

import 'package:excel/excel.dart' hide Border;
import 'package:path_provider/path_provider.dart';

import '../models/class_model.dart';
import '../models/evaluation_model.dart';
import '../styles/excel_export_style.dart';

class ExcelExportService {
  ExcelExportService._();

  // یکسان‌سازی نام شاگرد برای مقایسه
  static String normalizeName(String name) {
    return name.trim().replaceAll(RegExp(r'\s+'), ' ').toLowerCase();
  }

  // پاک‌سازی نام فایل
  static String safeFileName(String name) {
    final result = name.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_').trim();
    return result.isEmpty ? 'صنف' : result;
  }

  // قالب‌بندی تاریخ
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

    // آخرین ارزیابی هر شاگرد در همین صنف
    final evaluationMap = <String, EvaluationModel>{};
    for (final evaluation in evaluations) {
      if (evaluation.classId != classModel.id) continue;
      final key = normalizeName(evaluation.studentName);
      if (key.isEmpty) continue;
      final previous = evaluationMap[key];
      if (previous == null || evaluation.evaluatedAt.isAfter(previous.evaluatedAt)) {
        evaluationMap[key] = evaluation;
      }
    }

    // تعداد شاگردان ارزیابی‌شده
    final evaluatedCount = students.where((student) {
      return evaluationMap.containsKey(normalizeName(student));
    }).length;

    if (evaluatedCount == 0) {
      throw Exception('هنوز هیچ شاگردی در این صنف ارزیابی نشده است');
    }

    // ارزیابی‌های همین صنف
    final classEvaluations = evaluations
        .where((evaluation) => evaluation.classId == classModel.id)
        .toList();

    // بیشترین تعداد سوال
    final totalQuestions = classEvaluations.fold<int>(
      0,
      (max, evaluation) =>
          evaluation.totalQuestions > max ? evaluation.totalQuestions : max,
    );

    if (totalQuestions <= 0) {
      throw Exception('تعداد سوالات معتبر نیست');
    }

    // ایجاد فایل اکسل
    final excel = Excel.createExcel();
    const sheetName = 'نتایج پرسشنامه';
    final sheet = excel[sheetName];

    // حذف شیت پیش‌فرض
    final defaultSheet = excel.getDefaultSheet();
    if (defaultSheet != null && defaultSheet != sheetName && excel.tables.containsKey(defaultSheet)) {
      excel.delete(defaultSheet);
    }

    // -------------------------------------------------------------------------
    // چیدمان نهایی: اطلاعات در بالا (ستون 0 و 1) و جدول دقیقاً در زیر آن
    // -------------------------------------------------------------------------
    
    final infoLabelCol = 0; 
    final infoValueCol = 1;
    
    // جدول از همان ستون 0 شروع می‌شود
    final tableStartCol = 0; 
    // آخرین ستون جدول: 2 ستون (شماره و نام) + تعداد سوالات
    final lastTableColumn = tableStartCol + totalQuestions + 1; 

    // --- 1. بخش اطلاعات پرسشنامه (بالا) ---
    
    // ردیف 0: عنوان "نتایج پرسشنامه"
    sheet.merge(
      CellIndex.indexByColumnRow(columnIndex: infoLabelCol, rowIndex: 0),
      CellIndex.indexByColumnRow(columnIndex: infoValueCol, rowIndex: 0),
    );
    var titleCell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: infoLabelCol, rowIndex: 0));
    titleCell.value = TextCellValue('نتایج پرسشنامه');
    titleCell.cellStyle = ExcelExportStyle.sectionHeader;

    // ردیف‌های 1 تا 6: اطلاعات
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

    // --- 2. بخش جدول اصلی (دقیقاً در زیر اطلاعات، بدون فاصله) ---
    // شروع جدول از ردیف 7 (بلافاصله بعد از 6 ردیف اطلاعات + 1 ردیف عنوان)
    int currentRow = 7;

    // ردیف هدر اول: "اسامی اعضای صنف" و "سوال X"
    // ادغام ستون شماره و نام برای "اسامی اعضای صنف"
    sheet.merge(
      CellIndex.indexByColumnRow(columnIndex: tableStartCol, rowIndex: currentRow),
      CellIndex.indexByColumnRow(columnIndex: tableStartCol + 1, rowIndex: currentRow),
    );
    var groupHeader = sheet.cell(CellIndex.indexByColumnRow(columnIndex: tableStartCol, rowIndex: currentRow));
    groupHeader.value = TextCellValue('اسامی اعضای صنف');
    groupHeader.cellStyle = ExcelExportStyle.sectionHeader;
    
    // پر کردن سلول ادغام شده دوم با استایل
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: tableStartCol + 1, rowIndex: currentRow)).cellStyle = ExcelExportStyle.sectionHeader;

    // هدر سوالات
    for (int q = 1; q <= totalQuestions; q++) {
      var qHeader = sheet.cell(CellIndex.indexByColumnRow(columnIndex: tableStartCol + 1 + q, rowIndex: currentRow));
      qHeader.value = TextCellValue('سوال $q');
      qHeader.cellStyle = ExcelExportStyle.sectionHeader;
    }

    // ردیف هدر دوم: "شماره" و "نام شاگرد"
    currentRow++; 

    var idHeader = sheet.cell(CellIndex.indexByColumnRow(columnIndex: tableStartCol, rowIndex: currentRow));
    idHeader.value = TextCellValue('شماره');
    idHeader.cellStyle = ExcelExportStyle.label;

    var nameHeader = sheet.cell(CellIndex.indexByColumnRow(columnIndex: tableStartCol + 1, rowIndex: currentRow));
    nameHeader.value = TextCellValue('نام شاگرد');
    nameHeader.cellStyle = ExcelExportStyle.label;

    // سلول‌های خالی زیر سوالات در ردیف هدر دوم
    for (int q = 1; q <= totalQuestions; q++) {
       var c = sheet.cell(CellIndex.indexByColumnRow(columnIndex: tableStartCol + 1 + q, rowIndex: currentRow));
       c.cellStyle = ExcelExportStyle.label;
    }

    // --- 3. داده‌های شاگردان ---
    currentRow++;

    for (int index = 0; index < students.length; index++) {
      final name = students[index].trim();
      final evaluation = evaluationMap[normalizeName(name)];

      // شماره
      var idCell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: tableStartCol, rowIndex: currentRow));
      idCell.value = IntCellValue(index + 1);
      idCell.cellStyle = ExcelExportStyle.data;

      // نام
      var nameCell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: tableStartCol + 1, rowIndex: currentRow));
      nameCell.value = TextCellValue(name);
      nameCell.cellStyle = ExcelExportStyle.data;

      // پاسخ‌ها
      for (int q = 0; q < totalQuestions; q++) {
        String answer = '-';
        if (evaluation != null && q < evaluation.answers.length) {
          final savedAnswer = evaluation.answers[q].trim();
          if (savedAnswer.isNotEmpty && savedAnswer != '-1') {
            answer = savedAnswer;
          }
        }
        
        var answerCell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: tableStartCol + 2 + q, rowIndex: currentRow));
        answerCell.value = TextCellValue(answer);
        answerCell.cellStyle = ExcelExportStyle.data;
      }

      currentRow++;
    }

    // -------------------------------------------------------------------------
    // تنظیم عرض ستون‌ها
    // -------------------------------------------------------------------------
    // ستون‌های اطلاعات
    sheet.setColumnWidth(infoLabelCol, 18);
    sheet.setColumnWidth(infoValueCol, 22);
    
    // ستون شماره (جدول)
    sheet.setColumnWidth(tableStartCol, ExcelExportStyle.numberWidth);
    
    // ستون نام (جدول)
    sheet.setColumnWidth(tableStartCol + 1, ExcelExportStyle.studentNameWidth);

    // ستون‌های سوالات
    for (int col = tableStartCol + 2; col <= lastTableColumn; col++) {
      sheet.setColumnWidth(col, ExcelExportStyle.questionWidth);
    }

    // تولید فایل اکسل
    final bytes = excel.encode();
    if (bytes == null || bytes.isEmpty) {
      throw Exception('ساخت فایل اکسل ناموفق بود');
    }

    // ذخیره در پوشه اسناد برنامه
    final directory = await getApplicationDocumentsDirectory();
    final fileName = 'نتایج_${safeFileName(classModel.className)}.xlsx';
    final file = File('${directory.path}/$fileName');

    await file.writeAsBytes(bytes, flush: true);

    if (!await file.exists() || await file.length() == 0) {
      throw Exception('فایل اکسل ذخیره نشد');
    }

    return file;
  }
}