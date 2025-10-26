import 'package:flutter/material.dart';
import '../database_helper.dart';
import 'dart:developer' as developer;

class DashboardProvider with ChangeNotifier {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  int _totalStudents = 0;
  int _totalTeachers = 0;
  int _totalClasses = 0;
  int _totalSubjects = 0;
  double _passPercentage = 0.0; // This will need more complex calculation
  List<Map<String, dynamic>> _attendanceSummary = [];

  int get totalStudents => _totalStudents;
  int get totalTeachers => _totalTeachers;
  int get totalClasses => _totalClasses;
  int get totalSubjects => _totalSubjects;
  double get passPercentage => _passPercentage;
  List<Map<String, dynamic>> get attendanceSummary => _attendanceSummary;

  Future<void> fetchDashboardData() async {
    developer.log('DashboardProvider: Fetching dashboard data...', name: 'DashboardProvider');
    try {
      _totalStudents = await _databaseHelper.getTotalStudentsCount();
      _totalTeachers = await _databaseHelper.getTotalTeachersCount();
      _totalClasses = await _databaseHelper.getTotalClassesCount();
      _totalSubjects = await _databaseHelper.getTotalSubjectsCount();
      _attendanceSummary = await _databaseHelper.getAttendanceSummaryByDate();

      // TODO: Implement actual pass percentage calculation
      // For now, we'll use a placeholder. A proper calculation would involve
      // fetching grades for all students, calculating their average, and determining pass/fail status.
      // This might require a new method in DatabaseHelper to get aggregated student results.
      _passPercentage = await _calculateOverallPassPercentage(); // Call the new method

      notifyListeners();
      developer.log('DashboardProvider: Dashboard data fetched successfully.', name: 'DashboardProvider');
    } catch (e, s) {
      developer.log(
        'DashboardProvider: Error fetching dashboard data: $e',
        name: 'DashboardProvider',
        level: 1000,
        error: e,
        stackTrace: s,
      );
    }
  }

  Future<double> _calculateOverallPassPercentage() async {
    try {
      final students = await _databaseHelper.getStudents();
      final latestYear = await _databaseHelper.getLatestAcademicYear();

      if (students.isEmpty || latestYear == null) {
        return 0.0; // No students or no academic year found
      }

      int passedStudents = 0;
      int totalStudentsWithGrades = 0;

      for (var student in students) {
        final gradesForYear = await _databaseHelper.getGradesByStudentAndYear(student.id!, latestYear);

        if (gradesForYear.isNotEmpty) {
          totalStudentsWithGrades++;
          double studentAverage = 0.0;
          double totalWeightedGrade = 0;
          double totalWeight = 0;

          for (var grade in gradesForYear) {
            if (grade.gradeValue != null && grade.weight != null) {
              totalWeightedGrade += grade.gradeValue! * grade.weight!;
              totalWeight += grade.weight!;
            }
          }

          if (totalWeight > 0) {
            studentAverage = totalWeightedGrade / totalWeight;
          }

          // Assuming a passing grade is >= 50
          if (studentAverage >= 50.0) {
            passedStudents++;
          }
        }
      }

      if (totalStudentsWithGrades == 0) {
        return 0.0; // Avoid division by zero
      }

      return (passedStudents / totalStudentsWithGrades) * 100.0;

    } catch (e, s) {
      developer.log(
        'DashboardProvider: Error calculating pass percentage: $e',
        name: 'DashboardProvider',
        level: 1000,
        error: e,
        stackTrace: s,
      );
      return 0.0; // Return 0.0 in case of error
    }
  }
}
