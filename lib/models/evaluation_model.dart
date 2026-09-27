import 'package:isar/isar.dart';

part 'evaluation_model.g.dart';

@collection
class EvaluationModel {
  Id id = Isar.autoIncrement;

  // شناسه صنف
  late int classId;

  // نام صنف
  late String className;

  // نام شاگرد
  late String studentName;

  // تعداد جواب‌های درست
  late int correctAnswers;

  // تعداد کل سوالات
  late int totalQuestions;

  // جواب‌های انتخاب‌شده
  late List<int> answers;

  // تاریخ ارزیابی
  late DateTime evaluatedAt;
}