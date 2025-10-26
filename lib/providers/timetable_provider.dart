import 'package:flutter/material.dart';
import '../timetable_model.dart';
import '../database_helper.dart';

class TimetableProvider with ChangeNotifier {
  final DatabaseHelper _databaseHelper = DatabaseHelper(); // Corrected instantiation
  List<TimetableEntry> _timetableEntries = [];

  List<TimetableEntry> get timetableEntries => _timetableEntries;

  // Fetch all timetable entries
  Future<void> fetchTimetableEntries() async {
    final data = await _databaseHelper.getTimetableEntries();
    _timetableEntries = data.map((e) => TimetableEntry.fromMap(e)).toList();
    notifyListeners();
  }

  // Fetch timetable entries by class ID
  Future<void> fetchTimetableEntriesByClass(int classId) async {
    final data = await _databaseHelper.getTimetableEntriesByClass(classId);
    _timetableEntries = data.map((e) => TimetableEntry.fromMap(e)).toList();
    notifyListeners();
  }

  // Fetch timetable entries by teacher ID
  Future<void> fetchTimetableEntriesByTeacher(int teacherId) async {
    final data = await _databaseHelper.getTimetableEntriesByTeacher(teacherId);
    _timetableEntries = data.map((e) => TimetableEntry.fromMap(e)).toList();
    notifyListeners();
  }

  // Add a new timetable entry
  Future<void> addTimetableEntry(TimetableEntry entry) async {
    await _databaseHelper.insertTimetableEntry(entry.toMap());
    await fetchTimetableEntries(); // Refresh the list
  }

  // Update an existing timetable entry
  Future<void> updateTimetableEntry(TimetableEntry entry) async {
    await _databaseHelper.updateTimetableEntry(entry.toMap());
    await fetchTimetableEntries(); // Refresh the list
  }

  // Delete a timetable entry
  Future<void> deleteTimetableEntry(int id) async {
    await _databaseHelper.deleteTimetableEntry(id);
    await fetchTimetableEntries(); // Refresh the list
  }
}
