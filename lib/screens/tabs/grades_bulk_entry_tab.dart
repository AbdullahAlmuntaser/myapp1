import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../grade_model.dart';
import '../../student_model.dart';
import '../../class_model.dart';
import '../../subject_model.dart';
import '../../assessment_type_model.dart';
import '../../providers/grade_provider.dart';
import '../../providers/student_provider.dart';
import '../../providers/class_provider.dart';
import '../../providers/subject_provider.dart';
import '../../providers/assessment_type_provider.dart';
import 'package:intl/intl.dart';

class GradesBulkEntryTab extends StatefulWidget {
  const GradesBulkEntryTab({super.key});

  @override
  State<GradesBulkEntryTab> createState() => _GradesBulkEntryTabState();
}

class _GradesBulkEntryTabState extends State<GradesBulkEntryTab> {
  SchoolClass? _selectedClass;
  Subject? _selectedSubject;
  AssessmentType? _selectedAssessmentType;
  final Map<int, TextEditingController> _gradeControllers = {};
  bool _isSaving = false;
  bool _isLoadingStudents = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AssessmentTypeProvider>(context, listen: false).fetchAssessmentTypes();
    });
  }

  @override
  void dispose() {
    _gradeControllers.forEach((key, controller) => controller.dispose());
    super.dispose();
  }

  Future<void> _loadStudentGrades() async {
    if (!mounted) return;

    setState(() {
      _isLoadingStudents = true;
    });

    _gradeControllers.forEach((key, controller) => controller.clear());

    if (_selectedClass == null || _selectedSubject == null || _selectedAssessmentType == null) {
      setState(() {
        _isLoadingStudents = false;
      });
      return;
    }

    final studentProvider = Provider.of<StudentProvider>(context, listen: false);
    final gradeProvider = Provider.of<GradeProvider>(context, listen: false);

    final studentsInClass = studentProvider.students.where((s) => s.classId == _selectedClass!.classId).toList();

    for (var student in studentsInClass) {
      _gradeControllers.putIfAbsent(student.id!, () => TextEditingController());
      final existingGrades = await gradeProvider.getGradesByStudent(student.id!);
      final existingGrade = existingGrades.firstWhere(
        (g) =>
            g.subjectId == _selectedSubject!.id &&
            g.classId == _selectedClass!.id &&
            g.assessmentType == _selectedAssessmentType!.name,
        orElse: () => Grade(studentId: -1, subjectId: -1, classId: -1, assessmentType: '', gradeValue: 0.0, weight: 0.0, date: ''),
      );

      if (existingGrade.studentId != -1) {
        _gradeControllers[student.id!]?.text = existingGrade.gradeValue.toString();
      }
    }

    if (mounted) {
      setState(() {
        _isLoadingStudents = false;
      });
    }
  }

  Future<void> _saveGrades() async {
    if (!mounted) return;

    if (_selectedClass == null || _selectedSubject == null || _selectedAssessmentType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء اختيار الفصل والمادة ونوع التقييم.'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final gradeProvider = Provider.of<GradeProvider>(context, listen: false);
    final studentProvider = Provider.of<StudentProvider>(context, listen: false);

    final studentsInClass = studentProvider.students.where((s) => s.classId == _selectedClass!.classId).toList();

    bool allSaved = true;
    for (var student in studentsInClass) {
      final controller = _gradeControllers[student.id];
      if (controller != null && controller.text.isNotEmpty) {
        final gradeValue = double.tryParse(controller.text);
        if (gradeValue != null && gradeValue >= 0 && gradeValue <= 100) {
          final existingGrades = await gradeProvider.getGradesByStudent(student.id!);
          final existingGrade = existingGrades.firstWhere(
            (g) =>
                g.subjectId == _selectedSubject!.id &&
                g.classId == _selectedClass!.id &&
                g.assessmentType == _selectedAssessmentType!.name,
            orElse: () => Grade(studentId: -1, subjectId: -1, classId: -1, assessmentType: '', gradeValue: 0.0, weight: 0.0, date: ''),
          );

          if (existingGrade.studentId != -1) {
            await gradeProvider.updateGrade(existingGrade.copyWith(
              gradeValue: gradeValue,
              date: DateFormat('yyyy-MM-dd').format(DateTime.now()),
              weight: _selectedAssessmentType!.weight,
            ));
          } else {
            final newGrade = Grade(
              studentId: student.id!,
              subjectId: _selectedSubject!.id!,
              classId: _selectedClass!.id!,
              assessmentType: _selectedAssessmentType!.name,
              gradeValue: gradeValue,
              weight: _selectedAssessmentType!.weight,
              date: DateFormat('yyyy-MM-dd').format(DateTime.now()),
            );
            await gradeProvider.addGrade(newGrade);
          }
        } else {
          allSaved = false;
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('الرجاء إدخال درجة صالحة (0-100) للطالب ${student.name}.'),
                backgroundColor: Colors.orange),
          );
        }
      }
    }
    if (!mounted) return;
    setState(() {
      _isSaving = false;
    });

    if (allSaved) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم حفظ الدرجات بنجاح!'), backgroundColor: Colors.green),
      );
      _gradeControllers.forEach((key, controller) => controller.clear());
      Provider.of<GradeProvider>(context, listen: false).fetchGrades();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer4<StudentProvider, ClassProvider, SubjectProvider, AssessmentTypeProvider>(
      builder: (context, studentProvider, classProvider, subjectProvider, assessmentTypeProvider, child) {
        final allStudents = studentProvider.students;
        final allClasses = classProvider.classes;
        final allSubjects = subjectProvider.subjects;
        final allAssessmentTypes = assessmentTypeProvider.assessmentTypes;

        final studentsInSelectedClass = _selectedClass == null
            ? <Student>[]
            : allStudents.where((s) => s.classId == _selectedClass!.classId).toList();

        _gradeControllers.keys
            .where((studentId) => !studentsInSelectedClass.any((s) => s.id == studentId))
            .toList()
            .forEach((id) {
          _gradeControllers[id]?.dispose();
          _gradeControllers.remove(id);
        });
        for (var student in studentsInSelectedClass) {
          _gradeControllers.putIfAbsent(student.id!, () => TextEditingController());
        }

        bool allFiltersSelected = _selectedClass != null && _selectedSubject != null && _selectedAssessmentType != null;

        return Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'إدخال الدرجات الجماعي',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  _buildFilterDropdown<SchoolClass>(
                    context,
                    'الفصل',
                    _selectedClass,
                    allClasses,
                    (newValue) {
                      setState(() {
                        _selectedClass = newValue;
                        _loadStudentGrades();
                      });
                    },
                    (c) => c.name,
                    allClasses.isEmpty ? 'لا توجد فصول' : null,
                  ),
                  _buildFilterDropdown<Subject>(
                    context,
                    'المادة',
                    _selectedSubject,
                    allSubjects,
                    (newValue) {
                      setState(() {
                        _selectedSubject = newValue;
                        _loadStudentGrades();
                      });
                    },
                    (s) => s.name,
                    allSubjects.isEmpty ? 'لا توجد مواد' : null,
                  ),
                  _buildFilterDropdown<AssessmentType>(
                    context,
                    'نوع التقييم',
                    _selectedAssessmentType,
                    allAssessmentTypes,
                    (newValue) {
                      setState(() {
                        _selectedAssessmentType = newValue;
                        _loadStudentGrades();
                      });
                    },
                    (type) => type.name,
                    allAssessmentTypes.isEmpty ? 'لا توجد أنواع تقييم' : null,
                  ),
                  const SizedBox(height: 24),
                  if (!allFiltersSelected) ...[
                    _buildEmptyState(context, 'الرجاء تحديد الفصل والمادة ونوع التقييم لعرض قائمة الطلاب.', Icons.filter_alt),
                  ] else if (_isLoadingStudents) ...[
                    const Center(child: CircularProgressIndicator()),
                  ] else if (studentsInSelectedClass.isEmpty) ...[
                    _buildEmptyState(context, 'لا يوجد طلاب في هذا الفصل.', Icons.person_off),
                  ] else ...[
                    Expanded(
                      child: ListView.builder(
                        itemCount: studentsInSelectedClass.length,
                        itemBuilder: (context, index) {
                          final student = studentsInSelectedClass[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8.0),
                            elevation: 1,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      student.name,
                                      style: Theme.of(context).textTheme.titleMedium,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    flex: 1,
                                    child: TextFormField(
                                      controller: _gradeControllers[student.id],
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        labelText: 'الدرجة (0-100)',
                                        border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8.0))),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8.0),
                                          borderSide: BorderSide(
                                            color: Theme.of(context).colorScheme.primary,
                                            width: 2.0,
                                          ),
                                        ),
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return null;
                                        }
                                        final grade = double.tryParse(value);
                                        if (grade == null || grade < 0 || grade > 100) {
                                          return 'أدخل درجة صالحة (0-100)';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                    Align(
                      alignment: Alignment.center,
                      child: FilledButton.icon(
                        onPressed: _isSaving ? null : _saveGrades,
                        icon: _isSaving
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.save),
                        label: Text(_isSaving ? 'جارٍ الحفظ...' : 'حفظ الدرجات'),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                          textStyle: Theme.of(context).textTheme.titleMedium,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (_isSaving)
              const Opacity(
                opacity: 0.6,
                child: ModalBarrier(dismissible: false, color: Colors.black54),
              ),
            if (_isSaving)
              const Center(child: CircularProgressIndicator()),
          ],
        );
      },
    );
  }

  Widget _buildFilterDropdown<T>(
    BuildContext context,
    String label,
    T? selectedValue,
    List<T> items,
    ValueChanged<T?> onChanged,
    String Function(T) itemText, [
    String? emptyMessage,
  ]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(color: Theme.of(context).colorScheme.outline.withAlpha((0.7 * 255).round())),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2.0),
          ),
          filled: true,
          fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withAlpha((0.2 * 255).round()),
        ),
        isEmpty: selectedValue == null,
        child: DropdownButtonHideUnderline(
          child: DropdownButton<T>(
            value: selectedValue,
            hint: emptyMessage != null ? Text(emptyMessage) : Text('اختر $label'),
            isExpanded: true,
            onChanged: items.isEmpty || _isSaving ? null : onChanged,
            items: items.map<DropdownMenuItem<T>>((T value) {
              return DropdownMenuItem<T>(
                value: value,
                child: Text(itemText(value)),
              );
            }).toList(),
            icon: const Icon(Icons.arrow_drop_down),
            elevation: 2,
            style: Theme.of(context).textTheme.bodyLarge,
            dropdownColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, String message, [IconData? icon]) {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon ?? Icons.info_outline,
              size: 80,
              color: Theme.of(context).colorScheme.onSurface.withAlpha((0.5 * 255).round()),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withAlpha((0.7 * 255).round()),
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
