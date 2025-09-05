import 'package:flutter/material.dart';
import '../database_helper.dart';
import '../subject_model.dart';

class SubjectProvider with ChangeNotifier {
  List<Subject> _subjects = [];
  final DatabaseHelper _dbHelper;

  SubjectProvider({DatabaseHelper? databaseHelper})
    : _dbHelper = databaseHelper ?? DatabaseHelper();

  List<Subject> get subjects => _subjects;

  Future<void> fetchSubjects() async {
    _subjects = await _dbHelper.getSubjects();
    notifyListeners();
  }

  Future<void> searchSubjects(String query) async {
    if (query.isEmpty) {
      await fetchSubjects();
    } else {
      _subjects = await _dbHelper.searchSubjects(query);
      notifyListeners();
    }
  }

  Future<void> addSubject(Subject subject) async {
    final existingSubjectByName = await _dbHelper.getSubjectByName(subject.name);
    if (existingSubjectByName != null) {
      throw Exception('اسم المادة موجود بالفعل.');
    }

    final existingSubjectById = await _dbHelper.getSubjectBySubjectId(subject.subjectId);
    if (existingSubjectById != null) {
      throw Exception('معرف المادة موجود بالفعل.');
    }

    await _dbHelper.createSubject(subject);
    await fetchSubjects();
  }

  Future<void> updateSubject(Subject subject) async {
    // Check for name uniqueness, excluding the current subject
    final existingSubjectByName = await _dbHelper.getSubjectByName(subject.name);
    if (existingSubjectByName != null && existingSubjectByName.id != subject.id) {
      throw Exception('اسم المادة موجود بالفعل.');
    }

    // Check for subjectId uniqueness, excluding the current subject
    final existingSubjectById = await _dbHelper.getSubjectBySubjectId(subject.subjectId);
    if (existingSubjectById != null && existingSubjectById.id != subject.id) {
      throw Exception('معرف المادة موجود بالفعل.');
    }

    await _dbHelper.updateSubject(subject);
    await fetchSubjects();
  }

  Future<void> deleteSubject(int id) async {
    await _dbHelper.deleteSubject(id);
    await fetchSubjects();
  }
}
