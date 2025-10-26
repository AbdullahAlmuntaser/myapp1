import 'package:flutter/material.dart';
import '../database_helper.dart';
import '../student_model.dart';
import 'package:collection/collection.dart'; // For firstWhereOrNull
import 'package:provider/provider.dart';

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

  Future<void> fetchStudentsByParentUserId(int parentUserId) async {
    _students = await _dbHelper.getStudentsByParentUserId(parentUserId);
    notifyListeners();
  }

  Future<void> searchStudents(String query, {String? classId}) async {
    _students = await _dbHelper.searchStudents(query, classId: classId);
    notifyListeners();
  }

  Future<void> searchStudentsByParentUserId(int parentUserId, String query, {String? classId}) async {
    // This method assumes that getStudentsByParentUserId already filters by parent.
    // We then apply the additional search filters on the result.
    List<Student> parentStudents = await _dbHelper.getStudentsByParentUserId(parentUserId);
    _students = parentStudents.where((student) {
      final nameMatch = student.name.toLowerCase().contains(query.toLowerCase());
      final academicNumberMatch = student.academicNumber?.toLowerCase().contains(query.toLowerCase()) ?? false;
      final classIdMatch = classId == null || student.classId == classId;
      return (nameMatch || academicNumberMatch) && classIdMatch;
    }).toList();
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

  // Method to fetch data needed for a student's certificate for a specific academic year
  Future<Map<String, dynamic>> fetchStudentCertificateData(BuildContext context, int studentId, String yearTerm) async {
    final gradeProvider = Provider.of<GradeProvider>(context, listen: false);

    final student = students.firstWhereOrNull((s) => s.id == studentId);
    if (student == null) {
      throw Exception('Student not found.'); // Handle case where student is not in the list
    }
    
    // Fetch grades for the student in the specified academic year
    final gradesForYear = await gradeProvider.fetchGradesByClassAndYear(student.classId!, yearTerm); // This might need adj