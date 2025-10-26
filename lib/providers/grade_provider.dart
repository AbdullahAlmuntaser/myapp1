import 'package:flutter/material.dart';
import '../grade_model.dart';
import '../database_helper.dart';

class GradeProvider with ChangeNotifier {
  List<Grade> _grades = [];
  final DatabaseHelper _dbHelper = DatabaseHelper();

  List<Grade> get grades => _grades;

  // Remove fetchGrades() from constructor
  // GradeProvider() {
  //   fetchGrades();
  // }

  Future<void> initialize() async {
    await fetchGrades();
  }

  Future<List<Grade>> fetchGradesByClassAndYear(int classId, String yearTerm) async {
    _grades = await _dbHelper.getGradesByClassAndYear(classId, yearTerm);
    notifyListeners();
    return _grades;
  }

  Future<void> fetchGrades({int? studentId, int? classId, int? subjectId, String? assessmentType}) async {
    // This method will be enhanced later to support filtering
    _grades = await _dbHelper.getGrades(); // For now, still fetches all
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

  // New method to calculate average grade for a student in a specific academic year
  Future<double?> getStudentAverageGradeForYear(int studentId, String yearTerm) async {
    final gradesForYear = await _dbHelper.getGradesByStudentAndYear(studentId, yearTerm);
    if (gradesForYear.isEmpty) {
      return null; // No grades found for this student in this year
    }

    double totalWeightedGrade = 0;
    double totalWeight = 0;

    for (var grade in gradesForYear) {
      // Ensure gradeValue and weight are not null and are valid numbers
      if (grade.gradeValue != null && grade.weight != null) {
        totalWeightedGrade += grade.gradeValue! * grade.weight!;
        totalWeight += grade.weight!;
      }
    }

    if (totalWeight == 0) {
      return null; // Avoid division by zero if no valid weights are found
    }

    return totalWeightedGrade / totalWeight;
  }

  // New method to calculate pass rate for a student in a specific academic year
  // Assuming a passing grade is >= 50 (this threshold might need to be configurable)
  Future<double?> getStudentPassRateForYear(int studentId, String yearTerm) async {
    final gradesForYear = await _dbHelper.getGradesByStudentAndYear(studentId, yearTerm);
    if (gradesForYear.isEmpty) {
      return null; // No grades found for this student in this year
    }

    int passedCount = 0;
    int totalSubjectsWithGrades = 0;

    for (var grade in gradesForYear) {
      // Consider only grades with valid values and weights
      if (grade.gradeValue != null && grade.weight != null) {
        totalSubjectsWithGrades++;
        if (grade.gradeValue! >= 50.0) { // Assuming 50 is the passing threshold
          passedCount++;
        }
      }
    }

    if (totalSubjectsWithGrades == 0) {
      return null; // Avoid division by zero
    }

    return (passedCount / totalSubjectsWithGrades) * 100.0;
  }
}
