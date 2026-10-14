import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../models/class_model.dart';
import '../models/evaluation_model.dart';

class IsarService {
  static Isar? _isar;

  static Future<Isar> getInstance() async {
    if (_isar != null && _isar!.isOpen) {
      return _isar!;
    }

    final directory = await getApplicationDocumentsDirectory();

    _isar = await Isar.open([
      ClassModelSchema,
      EvaluationModelSchema,
    ], directory: directory.path);

    return _isar!;
  }

  // ذخیره ارزیابی
  static Future<void> saveEvaluation(EvaluationModel evaluation) async {
    final isar = await getInstance();

    final cleanName = evaluation.studentName.trim();

    if (cleanName.isEmpty) {
      throw Exception('نام شاگرد الزامی است.');
    }

    await isar.writeTxn(() async {
      await isar.evaluationModels.put(evaluation);
    });

    final saved = await isar.evaluationModels.get(evaluation.id);

    if (saved == null) {
      throw Exception('ذخیره ارزیابی ناموفق بود.');
    }
  }

  // دریافت تمام صنف‌ها
  static Future<List<ClassModel>> getAllClasses() async {
    final isar = await getInstance();
    return isar.classModels.where().findAll();
  }

  // دریافت تمام ارزیابی‌ها
  static Future<List<EvaluationModel>> getAllEvaluations() async {
    final isar = await getInstance();
    return isar.evaluationModels.where().findAll();
  }

  // دریافت ارزیابی‌های یک صنف مشخص
  static Future<List<EvaluationModel>> getClassEvaluations(int classId) async {
    final isar = await getInstance();

    final evaluations = await isar.evaluationModels
        .filter()
        .classIdEqualTo(classId)
        .findAll();

    evaluations.sort((a, b) => a.studentName.compareTo(b.studentName));

    return evaluations;
  }

  // دریافت ارزیابی شاگرد در یک صنف مشخص
  static Future<EvaluationModel?> getStudentEvaluation(
    int classId,
    String studentName,
  ) async {
    final isar = await getInstance();
    final cleanName = studentName.trim();

    if (cleanName.isEmpty) {
      return null;
    }

    final evaluations = await isar.evaluationModels
        .filter()
        .classIdEqualTo(classId)
        .findAll();

    for (final evaluation in evaluations) {
      if (evaluation.studentName.trim() == cleanName) {
        return evaluation;
      }
    }

    return null;
  }

  // بررسی ارزیابی شاگرد در همان صنف
  static Future<bool> isStudentEvaluated(
    int classId,
    String studentName,
  ) async {
    final evaluation = await getStudentEvaluation(classId, studentName);

    return evaluation != null;
  }

  // حذف ارزیابی شاگرد از یک صنف
  static Future<void> deleteStudentEvaluation(
    int classId,
    String studentName,
  ) async {
    final isar = await getInstance();

    final evaluation = await getStudentEvaluation(classId, studentName);

    if (evaluation == null) {
      return;
    }

    await isar.writeTxn(() async {
      await isar.evaluationModels.delete(evaluation.id);
    });
  }

  // حذف تمام ارزیابی‌های یک صنف
  static Future<void> deleteClassEvaluations(int classId) async {
    final isar = await getInstance();

    final evaluations = await isar.evaluationModels
        .filter()
        .classIdEqualTo(classId)
        .findAll();

    if (evaluations.isEmpty) {
      return;
    }

    final ids = evaluations.map((evaluation) => evaluation.id).toList();

    await isar.writeTxn(() async {
      await isar.evaluationModels.deleteAll(ids);
    });
  }
}
