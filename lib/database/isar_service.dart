import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../models/class_model.dart';
import '../models/evaluation_model.dart';

class IsarService {
  static Isar? _isar;

  // ============================================================
  // GET ISAR INSTANCE
  // ============================================================

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

  // ============================================================
  // SAVE EVALUATION
  // ============================================================

  static Future<void> saveEvaluation(EvaluationModel evaluation) async {
    final isar = await getInstance();

    await isar.writeTxn(() async {
      await isar.evaluationModels.put(evaluation);
    });

    final saved = await isar.evaluationModels.get(evaluation.id);

    if (saved == null) {
      throw Exception('Evaluation was not saved');
    }
  }

  // ============================================================
  // GET ALL CLASSES
  // ============================================================

  static Future<List<ClassModel>> getAllClasses() async {
    final isar = await getInstance();

    return await isar.classModels.where().findAll();
  }

  // ============================================================
  // GET ALL EVALUATIONS
  // ============================================================

  static Future<List<EvaluationModel>> getAllEvaluations() async {
    final isar = await getInstance();

    return await isar.evaluationModels.where().findAll();
  }

  // ============================================================
  // GET CLASS EVALUATIONS
  // ============================================================

  static Future<List<EvaluationModel>> getClassEvaluations(int classId) async {
    final isar = await getInstance();

    final evaluations = await isar.evaluationModels
        .filter()
        .classIdEqualTo(classId)
        .findAll();

    evaluations.sort((a, b) => a.studentName.compareTo(b.studentName));

    return evaluations;
  }

  // ============================================================
  // GET STUDENT EVALUATION IN SPECIFIC CLASS
  // ============================================================

  static Future<EvaluationModel?> getStudentEvaluation(
    int classId,
    String studentName,
  ) async {
    final isar = await getInstance();

    final cleanName = studentName.trim();

    return await isar.evaluationModels
        .filter()
        .classIdEqualTo(classId)
        .studentNameEqualTo(cleanName)
        .findFirst();
  }

  // ============================================================
  // CHECK STUDENT EVALUATED IN SPECIFIC CLASS
  // ============================================================

  static Future<bool> isStudentEvaluated(
    int classId,
    String studentName,
  ) async {
    final evaluation = await getStudentEvaluation(classId, studentName);

    return evaluation != null;
  }

  // ============================================================
  // DELETE STUDENT EVALUATION FROM SPECIFIC CLASS
  // ============================================================

  static Future<void> deleteStudentEvaluation(
    int classId,
    String studentName,
  ) async {
    final isar = await getInstance();

    final cleanName = studentName.trim();

    final evaluation = await isar.evaluationModels
        .filter()
        .classIdEqualTo(classId)
        .studentNameEqualTo(cleanName)
        .findFirst();

    if (evaluation == null) {
      return;
    }

    await isar.writeTxn(() async {
      await isar.evaluationModels.delete(evaluation.id);
    });
  }

  // ============================================================
  // DELETE ALL EVALUATIONS OF SPECIFIC CLASS
  // ============================================================

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
