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

  /// تعداد جواب‌های درست
  late int correctAnswers;

  /// تعداد کل سوالات
  late int totalQuestions;

  /// جواب‌های انتخاب‌شده
  ///
  /// 0 = A
  /// 1 = B
  /// 2 = C
  /// 3 = D
  /// -1 = بدون جواب
  late List<int> answers;

  /// تاریخ انجام ارزیابی
  late DateTime evaluatedAt;
}
