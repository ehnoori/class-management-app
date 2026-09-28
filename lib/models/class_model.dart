import 'package:isar/isar.dart';

part 'class_model.g.dart';

@collection
class ClassModel {
  Id id = Isar.autoIncrement;

  late String className;

  late String teacherName;

  String classTime = '';

  List<String> members = [];
}