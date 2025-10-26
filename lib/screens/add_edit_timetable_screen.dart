import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/timetable_provider.dart';
import '../../timetable_model.dart';
import '../../class_model.dart';
import '../../teacher_model.dart';
import '../../subject_model.dart';
import '../../providers/class_provider.dart';
import '../../providers/teacher_provider.dart';
import '../../providers/subject_provider.dart';

class AddEditTimetableScreen extends StatefulWidget {
  final TimetableEntry? entry;

  const AddEditTimetableScreen({super.key, this.entry});

  @override
  State<AddEditTimetableScreen> createState() => _AddEditTimetableScreenState();
}

class _AddEditTimetableScreenState extends State<AddEditTimetableScreen> {
  final _formKey = GlobalKey<FormState>();
  SchoolClass? _selectedClass;
  Subject? _selectedSubject;
  Teacher? _selectedTeacher;
  String? _selectedDayOfWeek;
  int? _selectedLessonNumber;
  final TextEditingController _startTimeController = TextEditingController();
  final TextEditingController _endTimeController = TextEditingController();

  final List<String> _daysOfWeek = [
    'الأحد', 'الاثنين', 'الثلاثاء', 'الأربعاء', 'الخميس'
  ];
  final List<int> _lessonNumbers = List.generate(6, (index) => index + 1);

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
  }

  Future<void> _fetchInitialData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    try {
      final classProvider = Provider.of<ClassProvider>(context, listen: false);
      final teacherProvider = Provider.of<TeacherProvider>(context, listen: false);
      final subjectProvider = Provider.of<SubjectProvider>(context, listen: false);

      await classProvider.fetchClasses();
      if (!mounted) return;
      await teacherProvider.fetchTeachers();
      if (!mounted) return;
      await subjectProvider.fetchSubjects();
      if (!mounted) return;

      if (widget.entry != null) {
        _selectedClass = classProvider.classes
            .firstWhere((c) => c.id == widget.entry!.classId);
        _selectedSubject = subjectProvider.subjects
            .firstWhere((s) => s.id == widget.entry!.subjectId);
        _selectedTeacher = teacherProvider.teachers
            .firstWhere((t) => t.id == widget.entry!.teacherId);
        _selectedDayOfWeek = widget.entry!.dayOfWeek;
        _selectedLessonNumber = widget.entry!.lessonNumber;
        _startTimeController.text = widget.entry!.startTime;
        _endTimeController.text = widget.entry!.endTime;
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل تحميل البيانات الأولية: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _selectTime(BuildContext context, TextEditingController controller) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: Theme.of(context).colorScheme.primary,
                  onPrimary: Theme.of(context).colorScheme.onPrimary,
                  surface: Theme.of(context).colorScheme.surface,
                  onSurface: Theme.of(context).colorScheme.onSurface,
                ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.primary,
              ),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      if (!mounted) return;
      setState(() {
        controller.text = picked.format(context);
      });
    }
  }

  Future<void> _saveTimetableEntry() async {
    if (!mounted) return;
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedClass == null ||
        _selectedSubject == null ||
        _selectedTeacher == null ||
        _selectedDayOfWeek == null ||
        _selectedLessonNumber == null ||
        _startTimeController.text.isEmpty ||
        _endTimeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('الرجاء ملء جميع الحقول المطلوبة.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final timetableEntry = TimetableEntry(
      id: widget.entry?.id,
      classId: _selectedClass!.id!,
      subjectId: _selectedSubject!.id!,
      teacherId: _selectedTeacher!.id!,
      dayOfWeek: _selectedDayOfWeek!,
      lessonNumber: _selectedLessonNumber!,
      startTime: _startTimeController.text,
      endTime: _endTimeController.text,
    );

    try {
      final timetableProvider = Provider.of<TimetableProvider>(context, listen: false);
      if (widget.entry == null) {
        await timetableProvider.addTimetableEntry(timetableEntry);
      } else {
        await timetableProvider.updateTimetableEntry(timetableEntry);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.entry == null
                ? 'تمت إضافة الحصة بنجاح.'
                : 'تم تحديث الحصة بنجاح.',
          ),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('فشل حفظ الحصة: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final classProvider = Provider.of<ClassProvider>(context);
    final teacherProvider = Provider.of<TeacherProvider>(context);
    final subjectProvider = Provider.of<SubjectProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.entry == null ? 'إضافة حصة جديدة' : 'تعديل حصة',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.onPrimary,
              ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        centerTitle: true,
        elevation: 4,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    _buildFilterDropdown<SchoolClass>(
                      context,
                      'الفصل',
                      _selectedClass,
                      classProvider.classes,
                      (newValue) {
                        setState(() {
                          _selectedClass = newValue;
                        });
                      },
                      (c) => c.name,
                      classProvider.classes.isEmpty ? 'لا توجد فصول' : null,
                      'الرجاء اختيار فصل',
                    ),
                    _buildFilterDropdown<Subject>(
                      context,
                      'المادة',
                      _selectedSubject,
                      subjectProvider.subjects,
                      (newValue) {
                        setState(() {
                          _selectedSubject = newValue;
                        });
                      },
                      (s) => s.name,
                      subjectProvider.subjects.isEmpty ? 'لا توجد مواد' : null,
                      'الرجاء اختيار مادة',
                    ),
                    _buildFilterDropdown<Teacher>(
                      context,
                      'المعلم',
                      _selectedTeacher,
                      teacherProvider.teachers,
                      (newValue) {
                        setState(() {
                          _selectedTeacher = newValue;
                        });
                      },
                      (t) => t.name,
                      teacherProvider.teachers.isEmpty ? 'لا يوجد معلمون' : null,
                      'الرجاء اختيار معلم',
                    ),
                    _buildFilterDropdown<String>(
                      context,
                      'اليوم',
                      _selectedDayOfWeek,
                      _daysOfWeek,
                      (newValue) {
                        setState(() {
                          _selectedDayOfWeek = newValue;
                        });
                      },
                      (day) => day,
                      _daysOfWeek.isEmpty ? 'لا توجد أيام' : null,
                      'الرجاء اختيار يوم',
                    ),
                    _buildFilterDropdown<int>(
                      context,
                      'رقم الحصة',
                      _selectedLessonNumber,
                      _lessonNumbers,
                      (newValue) {
                        setState(() {
                          _selectedLessonNumber = newValue; 
                        });
                      },
                      (lessonNum) => 'الحصة $lessonNum',
                      _lessonNumbers.isEmpty ? 'لا توجد أرقام حصص' : null,
                      'الرجاء اختيار رقم الحصة',
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _startTimeController,
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: 'وقت البدء',
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.access_time),
                          onPressed: () => _selectTime(context, _startTimeController),
                        ),
                        border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                            width: 2.0,
                          ),
                        ),
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withAlpha((0.2 * 255).round()),
                      ),
                      validator: (value) => value == null || value.isEmpty ? 'الرجاء تحديد وقت البدء' : null,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _endTimeController,
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: 'وقت الانتهاء',
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.access_time),
                          onPressed: () => _selectTime(context, _endTimeController),
                        ),
                        border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                            width: 2.0,
                          ),
                        ),
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withAlpha((0.2 * 255).round()),
                      ),
                      validator: (value) => value == null || value.isEmpty ? 'الرجاء تحديد وقت الانتهاء' : null,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: _isLoading ? null : _saveTimetableEntry,
                      icon: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : const Icon(Icons.save),
                      label: Text(widget.entry == null ? 'إضافة حصة' : 'تحديث الحصة'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                        textStyle: Theme.of(context).textTheme.titleMedium,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildFilterDropdown<T>(
    BuildContext context,
    String label,
    T? selectedValue,
    List<T> items,
    ValueChanged<T?> onChanged,
    String Function(T) itemText,
    String? emptyMessage, [
    String? validatorMessage,
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
            onChanged: items.isEmpty || _isLoading ? null : onChanged, // Disable during loading
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
}
