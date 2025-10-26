import 'package:flutter/material.dart';
import '../attendance_model.dart';
import '../database_helper.dart';

class AttendanceProvider with ChangeNotifier {
  List<Attendance> _attendances = [];
  List<Map<String, dynamic>> _attendanceSummary = []; // New variable for summary
  final DatabaseHelper _dbHelper = DatabaseHelper();

  List<Attendance> get attendances => _attendances;
  List<Map<String, dynamic>> get attendanceSummary => _attendanceSummary; // New getter

  Future<void> initialize() async {
    await fetchAttendances();
    await fetchAttendanceSummaryByDate(); // Fetch summary on initialization
  }

  Future<void> fetchAttendances({
    String? date,
    int? classId,
    int? subjectId,
    int? teacherId,
    int? studentId,
    int? lessonNumber,
  }) async {
    _attendances = await _dbHelper.getAttendancesByFilters(
      date: date,
      classId: classId,
      subjectId: subjectId,
      teacherId: teacherId,
      studentId: studentId,
      lessonNumber: lessonNumber,
    );
    notifyListeners();
  }

  // New method to fetch attendance summary
  Future<void> fetchAttendanceSummaryByDate() async {
    _attendanceSummary = await _dbHelper.getAttendanceSummaryByDate();
    notifyListeners();
  }

  Future<void> addAttendance(Attendance attendance) async {
    await _dbHelper.createAttendance(attendance);
    await fetchAttendances(); // Refresh the list
    await fetchAttendanceSummaryByDate(); // Refresh summary as well
  }

  Future<void> updateAttendance(Attendance attendance) async {
    await _dbHelper.updateAttendance(attendance);
    await fetchAttendances(); // Refresh the list
    await fetchAttendanceSummaryByDate(); // Refresh summary as well
  }

  Future<void> deleteAttendance(int id) async {
    await _dbHelper.deleteAttendance(id);
    await fetchAttendances(); // Refresh the list
    await fetchAttendanceSummaryByDate(); // Refresh summary as well
  }

  // Method to get attendance status for a specific student, date, and lesson
  String getAttendanceStatus(
    int studentId,
    String date,
    int lessonNumber,
  ) {
    final attendanceRecord = _attendances.firstWhere(
      (att) =>
          att.studentId == studentId &&
          att.date == date &&
          att.lessonNumber == lessonNumber,
      orElse: () => Attendance(
        studentId: studentId,
        classId: -1, // Dummy values as orElse must return a complete object
        subjectId: -1,
        teacherId: -1,
        date: date,
        lessonNumber: lessonNumber,
        status: 'unknown',
        lateMinutes: 0, // Default for unknown
      ), // Return a dummy attendance if not found
    );
    return attendanceRecord.status;
  }

  // Helper method to set attendance for a student, date, and lesson
  Future<void> setAttendanceStatus(
    int studentId,
    int classId,
    int subjectId,
    int teacherId,
    String date,
    int lessonNumber,
    String status, {
    int? lateMinutes, // New optional parameter
  }) async {
    final existingAttendance = _attendances.firstWhere(
      (att) =>
          att.studentId == studentId &&
          att.date == date &&
          att.lessonNumber == lessonNumber,
      orElse: () => Attendance(
        studentId: -1,
        classId: -1,
        subjectId: -1,
        teacherId: -1,
        date: '',
        lessonNumber: -1,
        status: '',
        lateMinutes: null,
      ), // Return a dummy if not found
    );

    if (existingAttendance.studentId != -1) {
      // Update existing record
      existingAttendance.status = status;
      existingAttendance.lateMinutes = lateMinutes; // Update lateMinutes
      await updateAttendance(existingAttendance);
    } else {
      // Create new record
      final newAttendance = Attendance(
        studentId: studentId,
        classId: classId,
        subjectId: subjectId,
        teacherId: teacherId,
        date: date,
        lessonNumber: lessonNumber,
        status: status,
        lateMinutes: lateMinutes, // Set lateMinutes for new record
      );
      await addAttendance(newAttendance);
    }
  }
}
