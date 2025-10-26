import 'package:flutter/material.dart';
import '../database_helper.dart';
import '../class_model.dart';

class ClassProvider with ChangeNotifier {
  List<SchoolClass> _classes = [];
  final DatabaseHelper _dbHelper;

  ClassProvider({DatabaseHelper? databaseHelper})
    : _dbHelper = databaseHelper ?? DatabaseHelper();

  List<SchoolClass> get classes => _classes;

  Future<void> fetchClasses() async {
    _classes = await _dbHelper.getClasses();
    notifyListeners();
  }

  Future<void> searchClasses(String query) async {
    if (query.isEmpty) {
      await fetchClasses();
    } else {
      _classes = await _dbHelper.searchClasses(query);
      notifyListeners();
    }
  }

  Future<void> addClass(SchoolClass schoolClass) async {
    await _dbHelper.createClass(schoolClass);
    await fetchClasses();
  }

  Future<void> updateClass(SchoolClass schoolClass) async {
    await _dbHelper.updateClass(schoolClass);
    await fetchClasses();
  }

  Future<void> deleteClass(int id) async {
    await _dbHelper.deleteClass(id);
    await fetchClasses();
  }

  Future<SchoolClass?> getClassByClassIdString(String classId) async {
    // Assuming DatabaseHelper has a method to get a class by its string classId
    return await _dbHelper.getClassByClassIdString(classId);
  }
}
