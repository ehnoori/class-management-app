import 'package:isar/isar.dart';

part 'evaluation_model.g.dart';

@collection
class EvaluationModel {
  Id id = Isar.autoIncrement;

  /// شناسه صنف
  late int classId;

  /// نام صنف
  late String className;

  /// نام شاگرد
  late String studentName;

  /// پاسخ‌های 13 سؤال
  ///
  /// مثال:
  /// A
  /// 3
  /// بلی
  /// پروژه Flutter
  late List<String> answers;

  /// تعداد سوالات
  late int totalQuestions;

  /// برای سازگاری با ساختار قبلی
  /// چون این پرسش‌نامه جواب درست/غلط ندارد همیشه 0 است.
  int correctAnswers = 0;

  /// تاریخ انجام ارزیابی
  late DateTime evaluatedAt;
}