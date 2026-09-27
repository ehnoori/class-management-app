import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../models/class_model.dart';
import '../models/evaluation_model.dart';

class IsarService {
  static Isar? _isar;

  static Future<Isar> getInstance() async {
    if (_isar != null) {
      return _isar!;
    }

    final directory = await getApplicationDocumentsDirectory();

    _isar = await Isar.open(
      [
        ClassModelSchema,
        EvaluationModelSchema,
      ],
      directory: directory.path,
    );

    return _isar!;
  }

  // ذخیره نتیجه ارزیابی
  static Future<void> saveEvaluation(
    EvaluationModel evaluation,
  ) async {
    final isar = await getInstance();

    await isar.writeTxn(() async {
      await isar.evaluationModels.put(evaluation);
    });
  }



static Future<List<ClassModel>> getAllClasses() async {
  final isar = await getInstance();

  return await isar.classModels.where().findAll();
}
  // دریافت تمام ارزیابی‌ها
  static Future<List<EvaluationModel>> getAllEvaluations() async {
    final isar = await getInstance();

    return await isar.evaluationModels.where().findAll();
  }

  // دریافت ارزیابی‌های یک صنف
  static Future<List<EvaluationModel>> getClassEvaluations(
    int classId,
  ) async {
    final isar = await getInstance();

    return await isar.evaluationModels
        .filter()
        .classIdEqualTo(classId)
        .findAll();
  }

  // پیدا کردن ارزیابی یک شاگرد
  static Future<EvaluationModel?> getStudentEvaluation(
    int classId,
    String studentName,
  ) async {
    final isar = await getInstance();

    return await isar.evaluationModels
        .filter()
        .classIdEqualTo(classId)
        .studentNameEqualTo(studentName)
        .findFirst();
  }

  // بررسی اینکه شاگرد قبلاً ارزیابی شده یا نه
  static Future<bool> isStudentEvaluated(
    int classId,
    String studentName,
  ) async {
    final evaluation = await getStudentEvaluation(
      classId,
      studentName,
    );

    return evaluation != null;
  }
}