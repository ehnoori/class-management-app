import 'package:isar/isar.dart';

part 'evaluation_model.g.dart';

@collection
class EvaluationModel {
  Id id = Isar.autoIncrement;

  /// شناسه صنف؛ هر ارزیابی به یک صنف مشخص تعلق دارد.
  late int classId;

  /// نام صنف
  late String className;

  /// نام شاگرد
  late String studentName;

  /// پاسخ‌های پرسش‌نامه به شکل متن ذخیره می‌شوند.
  /// مثال: یک ساعت، 3، بلی، نام پروژه
  late List<String> answers;

  /// تعداد سوالات
  late int totalQuestions;

  /// این پرسش‌نامه پاسخ درست یا غلط ندارد.
  int correctAnswers = 0;

  /// تاریخ و زمان انجام ارزیابی
  late DateTime evaluatedAt;
}
