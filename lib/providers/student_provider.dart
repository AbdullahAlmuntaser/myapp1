import 'package:flutter/material.dart';
import '../database_helper.dart';
import '../student_model.dart';

class StudentProvider with ChangeNotifier {
  List<Student> _students = [];
  
  @protected
  DatabaseHelper dbHelper = DatabaseHelper();

  List<Student> get students => _students;

  Future<void> fetchStudents() async {
    _students = await dbHelper.getStudents();
    notifyListeners();
  }

  Future<void> searchStudents(String query) async {
    if (query.isEmpty) {
      await fetchStudents();
    } else {
      _students = await dbHelper.searchStudents(query);
      notifyListeners();
    }
  }

  Future<void> addStudent(Student student) async {
    await dbHelper.createStudent(student);
    await fetchStudents(); // Refresh the list
  }

  Future<void> updateStudent(Student student) async {
    await dbHelper.updateStudent(student);
    await fetchStudents(); // Refresh the list
  }

  Future<void> deleteStudent(int id) async {
    await dbHelper.deleteStudent(id);
    await fetchStudents(); // Refresh the list
  }
}