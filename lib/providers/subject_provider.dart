import 'package:flutter/material.dart';
import '../database_helper.dart';
import '../subject_model.dart';

class SubjectProvider with ChangeNotifier {
  List<Subject> _subjects = [];
  final DatabaseHelper _dbHelper;

  SubjectProvider({DatabaseHelper? databaseHelper}) : _dbHelper = databaseHelper ?? DatabaseHelper();

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
    await _dbHelper.createSubject(subject);
    await fetchSubjects();
  }

  Future<void> updateSubject(Subject subject) async {
    await _dbHelper.updateSubject(subject);
    await fetchSubjects();
  }

  Future<void> deleteSubject(int id) async {
    await _dbHelper.deleteSubject(id);
    await fetchSubjects();
  }
}
