import 'package:flutter/material.dart';
import '../grade_model.dart';
import '../database_helper.dart';

class GradeProvider with ChangeNotifier {
  List<Grade> _grades = [];
  final DatabaseHelper _dbHelper = DatabaseHelper();

  List<Grade> get grades => _grades;

  GradeProvider() {
    fetchGrades();
  }

  Future<void> fetchGrades() async {
    _grades = await _dbHelper.getGrades();
    notifyListeners();
  }

  Future<void> addGrade(Grade grade) async {
    await _dbHelper.createGrade(grade);
    await fetchGrades();
  }

  Future<void> updateGrade(Grade grade) async {
    await _dbHelper.updateGrade(grade);
    await fetchGrades();
  }

  Future<void> deleteGrade(int id) async {
    await _dbHelper.deleteGrade(id);
    await fetchGrades();
  }

  Future<List<Grade>> getGradesByStudent(int studentId) async {
    return await _dbHelper.getGradesByStudent(studentId);
  }

  Future<List<Grade>> getGradesByClass(int classId) async {
    return await _dbHelper.getGradesByClass(classId);
  }

  Future<List<Grade>> getGradesBySubject(int subjectId) async {
    return await _dbHelper.getGradesBySubject(subjectId);
  }

  Future<List<Map<String, dynamic>>> getAverageGradesBySubject() async {
    return await _dbHelper.getAverageGradesBySubject();
  }
}
