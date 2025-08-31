
import 'package:flutter/material.dart';
import '../database_helper.dart';
import '../teacher_model.dart';

class TeacherProvider with ChangeNotifier {
  List<Teacher> _teachers = [];
  final DatabaseHelper _dbHelper = DatabaseHelper();

  List<Teacher> get teachers => _teachers;

  Future<void> fetchTeachers() async {
    _teachers = await _dbHelper.getTeachers();
    notifyListeners();
  }

  Future<void> searchTeachers(String query) async {
    if (query.isEmpty) {
      await fetchTeachers();
    } else {
      _teachers = await _dbHelper.searchTeachers(query);
      notifyListeners();
    }
  }

  Future<void> addTeacher(Teacher teacher) async {
    await _dbHelper.createTeacher(teacher);
    await fetchTeachers();
  }

  Future<void> updateTeacher(Teacher teacher) async {
    await _dbHelper.updateTeacher(teacher);
    await fetchTeachers();
  }

  Future<void> deleteTeacher(int id) async {
    await _dbHelper.deleteTeacher(id);
    await fetchTeachers();
  }
}
