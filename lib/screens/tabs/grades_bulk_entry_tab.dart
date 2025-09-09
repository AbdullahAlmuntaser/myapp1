import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../grade_model.dart';
import '../../student_model.dart';
import '../../class_model.dart';
import '../../subject_model.dart';
import '../../providers/grade_provider.dart';
import '../../providers/student_provider.dart';
import '../../providers/class_provider.dart';
import '../../providers/subject_provider.dart';

class GradesBulkEntryTab extends StatefulWidget {
  const GradesBulkEntryTab({super.key});

  @override
  State<GradesBulkEntryTab> createState() => _GradesBulkEntryTabState();
}

class _GradesBulkEntryTabState extends State<GradesBulkEntryTab> {
  SchoolClass? _selectedClass;
  Subject? _selectedSubject;
  String? _selectedAssessmentType;
  final Map<int, TextEditingController> _gradeControllers = {};

  final List<String> _assessmentTypes = ['واجب', 'اختبار', 'مشروع', 'مشاركة'];

  @override
  void dispose() {
    _gradeControllers.forEach((key, controller) => controller.dispose());
    super.dispose();
  }

  Future<void> _saveGrades() async {
    if (_selectedClass == null || _selectedSubject == null || _selectedAssessmentType == null) {
      if (!mounted) return; // Add this check
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء اختيار الفصل والمادة ونوع التقييم.')),
      );
      return;
    }

    final gradeProvider = Provider.of<GradeProvider>(context, listen: false);
    final studentProvider = Provider.of<StudentProvider>(context, listen: false);

    final studentsInClass = studentProvider.students
        .where((s) => s.classId == _selectedClass!.classId)
        .toList();

    for (var student in studentsInClass) {
      final controller = _gradeControllers[student.id];
      if (controller != null && controller.text.isNotEmpty) {
        final gradeValue = double.tryParse(controller.text);
        if (gradeValue != null) {
          // Check if a grade already exists for this student, subject, class, and assessment type
          final existingGrades = await gradeProvider.getGradesByStudent(student.id!);
          final existingGrade = existingGrades.firstWhere(
            (g) =>
                g.subjectId == _selectedSubject!.id &&
                g.classId == _selectedClass!.id &&
                g.assessmentType == _selectedAssessmentType,
            orElse: () => Grade(
              studentId: -1,
              subjectId: -1,
              classId: -1,
              assessmentType: '',
              gradeValue: 0.0,
              weight: 0.0,
            ),
          );

          if (existingGrade.studentId != -1) {
            // Update existing grade
            await gradeProvider.updateGrade(existingGrade.copyWith(
              gradeValue: gradeValue,
              // You might want to allow updating weight here too, or keep it fixed
            ));
          } else {
            // Add new grade
            final newGrade = Grade(
              studentId: student.id!,
              subjectId: _selectedSubject!.id!,
              classId: _selectedClass!.id!,
              assessmentType: _selectedAssessmentType!,
              gradeValue: gradeValue,
              weight: 1.0, // Default weight, can be made configurable
            );
            await gradeProvider.addGrade(newGrade);
          }
        }
      }
    }
    if (!mounted) return; // Add this check
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم حفظ الدرجات بنجاح!')),
    );
    // Clear controllers after saving
    _gradeControllers.forEach((key, controller) => controller.clear());
    setState(() {}); // Refresh UI
  }

  @override
  Widget build(BuildContext context) {
    return Consumer3<StudentProvider, ClassProvider, SubjectProvider>(
      builder: (context, studentProvider, classProvider, subjectProvider, child) {
        final studentsInSelectedClass = _selectedClass == null
            ? <Student>[]
            : studentProvider.students
                .where((s) => s.classId == _selectedClass!.classId)
                .toList();

        // Initialize controllers for new students or clear for removed students
        _gradeControllers.keys.where((studentId) => !studentsInSelectedClass.any((s) => s.id == studentId)).toList().forEach((id) {
          _gradeControllers[id]?.dispose();
          _gradeControllers.remove(id);
        });
        for (var student in studentsInSelectedClass) {
          _gradeControllers.putIfAbsent(student.id!, () => TextEditingController());
        }

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              DropdownButtonFormField<SchoolClass>(
                decoration: const InputDecoration(labelText: 'الفصل'),
                initialValue: _selectedClass,
                items: classProvider.classes.map((schoolClass) {
                  return DropdownMenuItem(
                    value: schoolClass,
                    child: Text(schoolClass.name),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedClass = value;
                    _gradeControllers.forEach((key, controller) => controller.clear()); // Clear grades when class changes
                  });
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<Subject>(
                decoration: const InputDecoration(labelText: 'المادة'),
                initialValue: _selectedSubject,
                items: subjectProvider.subjects.map((subject) {
                  return DropdownMenuItem(
                    value: subject,
                    child: Text(subject.name),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedSubject = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'نوع التقييم'),
                initialValue: _selectedAssessmentType,
                items: _assessmentTypes.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedAssessmentType = value;
                  });
                },
              ),
              const SizedBox(height: 24),
              Expanded(
                child: ListView.builder(
                  itemCount: studentsInSelectedClass.length,
                  itemBuilder: (context, index) {
                    final student = studentsInSelectedClass[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Text(student.name),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 1,
                            child: TextFormField(
                              controller: _gradeControllers[student.id],
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'الدرجة',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveGrades,
                child: const Text('حفظ الدرجات'),
              ),
            ],
          ),
        );
      },
    );
  }
}
