import 'package:isar/isar.dart';

part 'class_model.g.dart';

@collection
class ClassModel {
  Id id = Isar.autoIncrement;

  late String className;

  late String teacherName;

  late String classType;

  late List<String> members;
}