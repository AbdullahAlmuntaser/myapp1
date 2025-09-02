import 'package:flutter/material.dart';
import '../database_helper.dart';
import '../student_model.dart';

class StudentProvider with ChangeNotifier {
  List<Student> _students = [];

  final DatabaseHelper _dbHelper; // Made private and final

  // Constructor to allow injecting DatabaseHelper for testing
  StudentProvider({DatabaseHelper? databaseHelper})
    : _dbHelper = databaseHelper ?? DatabaseHelper();

  List<Student> get students => _students;

  Future<void> fetchStudents() async {
    _students = await _dbHelper.getStudents();
    notifyListeners();
  }

  Future<void> searchStudents(String query, {String? classId}) async {
    _students = await _dbHelper.searchStudents(query, classId: classId);
    notifyListeners();
  }

  Future<bool> addStudent(Student student) async {
    // Check for email uniqueness before adding
    if (student.email != null && student.email!.isNotEmpty) {
      final existingStudent = await _dbHelper.getStudentByEmail(student.email!);
      if (existingStudent != null) {
        throw Exception('البريد الإلكتروني موجود بالفعل.');
      }
    }
    await _dbHelper.createStudent(student);
    await fetchStudents(); // Refresh the list
    return true;
  }

  Future<bool> updateStudent(Student student) async {
    // Check for email uniqueness before updating, excluding the current student
    if (student.email != null && student.email!.isNotEmpty) {
      final existingStudent = await _dbHelper.getStudentByEmail(student.email!);
      if (existingStudent != null && existingStudent.id != student.id) {
        throw Exception('البريد الإلكتروني موجود بالفعل.');
      }
    }
    await _dbHelper.updateStudent(student);
    await fetchStudents(); // Refresh the list
    return true;
  }

  Future<void> deleteStudent(int id) async {
    await _dbHelper.deleteStudent(id);
    await fetchStudents(); // Refresh the list
  }

  // New method to check email uniqueness (can be used by UI directly)
  Future<bool> checkEmailUnique(String email, [int? currentStudentId]) async {
    final existingStudent = await _dbHelper.getStudentByEmail(email);
    if (existingStudent == null) {
      return true; // Email is unique
    }
    // If editing, allow the current student to keep their email
    return existingStudent.id == currentStudentId;
  }
}
