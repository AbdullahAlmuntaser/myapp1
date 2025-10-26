import 'package:flutter/foundation.dart';
import '../database_helper.dart';
import '../assessment_type_model.dart';

class AssessmentTypeProvider with ChangeNotifier {
  List<AssessmentType> _assessmentTypes = [];
  final DatabaseHelper _dbHelper = DatabaseHelper();

  List<AssessmentType> get assessmentTypes => _assessmentTypes;

  Future<void> fetchAssessmentTypes() async {
    _assessmentTypes = await _dbHelper.getAssessmentTypes();
    notifyListeners();
  }

  Future<void> addAssessmentType(AssessmentType assessmentType) async {
    await _dbHelper.createAssessmentType(assessmentType);
    await fetchAssessmentTypes();
  }

  Future<void> updateAssessmentType(AssessmentType assessmentType) async {
    await _dbHelper.updateAssessmentType(assessmentType);
    await fetchAssessmentTypes();
  }

  Future<void> deleteAssessmentType(int id) async {
    await _dbHelper.deleteAssessmentType(id);
    await fetchAssessmentTypes();
  }
}
