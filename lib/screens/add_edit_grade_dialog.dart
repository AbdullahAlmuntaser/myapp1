import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../grade_model.dart';
import '../student_model.dart';
import '../subject_model.dart';
import '../class_model.dart';
import '../assessment_type_model.dart';
import '../providers/grade_provider.dart';
import '../providers/student_provider.dart';
import '../providers/subject_provider.dart';
import '../providers/class_provider.dart';
import '../providers/assessment_type_provider.dart';

class AddEditGradeDialog extends StatefulWidget {
  final Grade? grade; // Null for adding, non-null for editing

  const AddEditGradeDialog({super.key, this.grade});

  @override
  State<AddEditGradeDialog> createState() => _AddEditGradeDialogState();
}

class _AddEditGradeDialogState extends State<AddEditGradeDialog> {
  final _formKey = GlobalKey<FormState>();
  Student? _selectedStudent;
  Subject? _selectedSubject;
  SchoolClass? _selectedClass;
  AssessmentType? _selectedAssessmentType;
  final TextEditingController _gradeValueController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _maxGradeController = TextEditingController();
  String _selectedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

  @override
  void initState() {
    super.initState();
    // Fetch assessment types when the dialog is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AssessmentTypeProvider>(context, listen: false).fetchAssessmentTypes();
    });

    if (widget.grade != null) {
      // Editing existing grade
      _gradeValueController.text = widget.grade!.gradeValue.toString();
      _weightController.text = widget.grade!.weight.toString();
      _selectedDate = widget.grade!.date;
      _descriptionController.text = widget.grade!.description ?? '';
      _maxGradeController.text = widget.grade!.maxGrade?.toString() ?? '';

      // Set initial dropdown values based on existing grade
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final studentProvider = Provider.of<StudentProvider>(context, listen: false);
        final subjectProvider = Provider.of<SubjectProvider>(context, listen: false);
        final classProvider = Provider.of<ClassProvider>(context, listen: false);
        final assessmentTypeProvider = Provider.of<AssessmentTypeProvider>(context, listen: false);

        setState(() {
          _selectedStudent = studentProvider.students.firstWhere((s) => s.id == widget.grade!.studentId, orElse: () => Student(id: -1, name: '', dob: '', phone: '', grade: ''));
          _selectedSubject = subjectProvider.subjects.firstWhere((s) => s.id == widget.grade!.subjectId, orElse: () => Subject(id: -1, name: '', subjectId: ''));
          _selectedClass = classProvider.classes.firstWhere((c) => c.id == widget.grade!.classId, orElse: () => SchoolClass(id: -1, name: '', classId: ''));
          _selectedAssessmentType = assessmentTypeProvider.assessmentTypes.firstWhere((t) => t.name == widget.grade!.assessmentType, orElse: () => AssessmentType(id: -1, name: '', weight: 0));
        });
      });
    }
  }

  @override
  void dispose() {
    _gradeValueController.dispose();
    _weightController.dispose();
    _descriptionController.dispose();
    _maxGradeController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.parse(_selectedDate),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && DateFormat('yyyy-MM-dd').format(picked) != _selectedDate) {
      setState(() {
        _selectedDate = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _saveGrade() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedStudent == null || _selectedSubject == null || _selectedClass == null || _selectedAssessmentType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء ملء جميع الحقول المطلوبة.')),
      );
      return;
    }

    final gradeProvider = Provider.of<GradeProvider>(context, listen: false);

    final gradeValue = double.parse(_gradeValueController.text);
    final weight = double.parse(_weightController.text);
    final description = _descriptionController.text.isEmpty ? null : _descriptionController.text;
    final maxGrade = double.tryParse(_maxGradeController.text);

    if (widget.grade == null) {
      // Add new grade
      final newGrade = Grade(
        studentId: _selectedStudent!.id!,
        subjectId: _selectedSubject!.id!,
        classId: _selectedClass!.id!,
        assessmentType: _selectedAssessmentType!.name,
        gradeValue: gradeValue,
        weight: weight,
        date: _selectedDate,
        description: description,
        maxGrade: maxGrade,
      );
      await gradeProvider.addGrade(newGrade);
    } else {
      // Update existing grade
      final updatedGrade = widget.grade!.copyWith(
        studentId: _selectedStudent!.id!,
        subjectId: _selectedSubject!.id!,
        classId: _selectedClass!.id!,
        assessmentType: _selectedAssessmentType!.name,
        gradeValue: gradeValue,
        weight: weight,
        date: _selectedDate,
        description: description,
        maxGrade: maxGrade,
      );
      await gradeProvider.updateGrade(updatedGrade);
    }

    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.grade == null ? 'إضافة درجة جديدة' : 'تعديل درجة'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Consumer<StudentProvider>(
                builder: (context, studentProvider, child) {
                  return DropdownButtonFormField<Student>(
                    decoration: const InputDecoration(labelText: 'الطالب'),
                    initialValue: _selectedStudent,
                    items: studentProvider.students.map((student) {
                      return DropdownMenuItem(
                        value: student,
                        child: Text(student.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedStudent = value;
                      });
                    },
                    validator: (value) => value == null ? 'الرجاء اختيار طالب' : null,
                  );
                },
              ),
              const SizedBox(height: 16),
              Consumer<SubjectProvider>(
                builder: (context, subjectProvider, child) {
                  return DropdownButtonFormField<Subject>(
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
                    validator: (value) => value == null ? 'الرجاء اختيار مادة' : null,
                  );
                },
              ),
              const SizedBox(height: 16),
              Consumer<ClassProvider>(
                builder: (context, classProvider, child) {
                  return DropdownButtonFormField<SchoolClass>(
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
                      });
                    },
                    validator: (value) => value == null ? 'الرجاء اختيار فصل' : null,
                  );
                },
              ),
              const SizedBox(height: 16),
              Consumer<AssessmentTypeProvider>(
                builder: (context, assessmentTypeProvider, child) {
                  return DropdownButtonFormField<AssessmentType>(
                    decoration: const InputDecoration(labelText: 'نوع التقييم'),
                    initialValue: _selectedAssessmentType,
                    items: assessmentTypeProvider.assessmentTypes.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(type.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedAssessmentType = value;
                        if (value != null) {
                          _weightController.text = value.weight.toString();
                        }
                      });
                    },
                    validator: (value) => value == null ? 'الرجاء اختيار نوع التقييم' : null,
                  );
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => _selectDate(context),
                icon: const Icon(Icons.calendar_today),
                label: Text('تاريخ التقييم: $_selectedDate'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _gradeValueController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'الدرجة',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء إدخال الدرجة';
                  }
                  if (double.tryParse(value) == null) {
                    return 'الرجاء إدخال رقم صحيح';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _maxGradeController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'الدرجة القصوى (اختياري)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value != null && value.isNotEmpty && double.tryParse(value) == null) {
                    return 'الرجاء إدخال رقم صحيح';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _weightController,
                keyboardType: TextInputType.number,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'الوزن النسبي (يتم تحديده تلقائياً)',
                  border: OutlineInputBorder(),
                  fillColor: Colors.black12,
                  filled: true,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء اختيار نوع تقييم ليتم تحديد الوزن';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'الوصف (اختياري)',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('إلغاء'),
        ),
        ElevatedButton(
          onPressed: _saveGrade,
          child: const Text('حفظ'),
        ),
      ],
    );
  }
}
