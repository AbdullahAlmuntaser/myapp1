import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/timetable_provider.dart';
import '../../providers/class_provider.dart';
import '../../providers/teacher_provider.dart';
import '../../timetable_model.dart';
import '../../class_model.dart';
import '../../teacher_model.dart';
import '../../subject_model.dart';
import '../../providers/subject_provider.dart';
import 'add_edit_timetable_screen.dart'; // Import AddEditTimetableScreen

class TimetableScreen extends StatefulWidget {
  static const routeName = '/timetable-screen';
  const TimetableScreen({super.key});

  @override
  State<TimetableScreen> createState() => _TimetableScreenState();
}

class _TimetableScreenState extends State<TimetableScreen> {
  SchoolClass? _selectedClass;
  Teacher? _selectedTeacher;
  bool _isLoading = false;

  final List<String> _daysOfWeek = [
    'الأحد', 'الاثنين', 'الثلاثاء', 'الأربعاء', 'الخميس'
  ];
  final int _maxLessonNumber = 6;

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
  }

  Future<void> _fetchInitialData() async {
    setState(() {
      _isLoading = true;
    });

    final classProvider = Provider.of<ClassProvider>(context, listen: false);
    final teacherProvider = Provider.of<TeacherProvider>(context, listen: false);
    final subjectProvider = Provider.of<SubjectProvider>(context, listen: false);
    final timetableProvider = Provider.of<TimetableProvider>(context, listen: false);

    await classProvider.fetchClasses();
    if (!mounted) return;
    await teacherProvider.fetchTeachers();
    if (!mounted) return;
    await subjectProvider.fetchSubjects();
    if (!mounted) return;

    if (classProvider.classes.isNotEmpty) {
      _selectedClass = classProvider.classes.first;
    }
    if (teacherProvider.teachers.isNotEmpty) {
      _selectedTeacher = teacherProvider.teachers.first;
    }

    if (_selectedClass != null) {
      await timetableProvider.fetchTimetableEntriesByClass(_selectedClass!.id!);
    } else if (_selectedTeacher != null) {
      await timetableProvider.fetchTimetableEntriesByTeacher(_selectedTeacher!.id!);
    } else {
      await timetableProvider.fetchTimetableEntries();
    }
    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _loadTimetableData() async {
    if (!_isLoading) {
      setState(() {
        _isLoading = true;
      });
    }

    final timetableProvider = Provider.of<TimetableProvider>(context, listen: false);

    if (_selectedClass != null && _selectedTeacher != null) {
      await timetableProvider.fetchTimetableEntriesByClass(_selectedClass!.id!); 
    } else if (_selectedClass != null) {
      await timetableProvider.fetchTimetableEntriesByClass(_selectedClass!.id!);
    } else if (_selectedTeacher != null) {
      await timetableProvider.fetchTimetableEntriesByTeacher(_selectedTeacher!.id!);
    } else {
      await timetableProvider.fetchTimetableEntries();
    }
    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final classProvider = Provider.of<ClassProvider>(context);
    final teacherProvider = Provider.of<TeacherProvider>(context);
    final subjectProvider = Provider.of<SubjectProvider>(context);
    final timetableProvider = Provider.of<TimetableProvider>(context);

    final Map<String, TimetableEntry> timetableMap = {};
    for (var entry in timetableProvider.timetableEntries) {
      timetableMap['${entry.dayOfWeek}_${entry.lessonNumber}'] = entry;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('جدول الحصص'),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Wrap(
                  spacing: 16.0,
                  runSpacing: 16.0,
                  children: [
                    DropdownButton<SchoolClass>(
                      value: _selectedClass,
                      hint: const Text('تصفية حسب الفصل'),
                      onChanged: classProvider.classes.isEmpty ? null : (newValue) {
                        setState(() {
                          _selectedClass = newValue;
                          _selectedTeacher = null;
                        });
                        _loadTimetableData();
                      },
                      items: classProvider.classes.map((c) {
                        return DropdownMenuItem(value: c, child: Text(c.name));
                      }).toList(),
                    ),
                    DropdownButton<Teacher>(
                      value: _selectedTeacher,
                      hint: const Text('تصفية حسب المعلم'),
                      onChanged: teacherProvider.teachers.isEmpty ? null : (newValue) {
                        setState(() {
                          _selectedTeacher = newValue;
                          _selectedClass = null;
                        });
                        _loadTimetableData();
                      },
                      items: teacherProvider.teachers.map((t) {
                        return DropdownMenuItem(value: t, child: Text(t.name));
                      }).toList(),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : classProvider.classes.isEmpty || teacherProvider.teachers.isEmpty || subjectProvider.subjects.isEmpty
                          ? const Center(child: Text('الرجاء إضافة فصول ومعلمين ومواد لعرض جدول الحصص.'))
                          : SingleChildScrollView(
                              scrollDirection: Axis.vertical,
                              child: Table(
                                border: TableBorder.all(color: Colors.grey.shade300),
                                columnWidths: const {0: FlexColumnWidth(1.5)},
                                children: [
                                  TableRow(
                                    children: [
                                      _buildHeaderCell('رقم الحصة/اليوم'),
                                      ..._daysOfWeek.map((day) => _buildHeaderCell(day)),
                                    ],
                                  ),
                                  for (int lessonNum = 1; lessonNum <= _maxLessonNumber; lessonNum++)
                                    TableRow(
                                      children: [
                                        _buildHeaderCell('الحصة $lessonNum'),
                                        for (String day in _daysOfWeek)
                                          _buildTimetableCell(
                                            timetableMap['${day}_$lessonNum'],
                                            subjectProvider.subjects,
                                            teacherProvider.teachers,
                                            classProvider.classes,
                                          ),
                                      ],
                                    ),
                                ],
                              ),
                            ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddEditTimetableEntry(),
        tooltip: 'إضافة حصة لجدول الحصص',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildHeaderCell(String text) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      alignment: Alignment.center,
      color: Theme.of(context).primaryColor.withAlpha((255 * 0.1).round()),
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildTimetableCell(
    TimetableEntry? entry,
    List<Subject> allSubjects,
    List<Teacher> allTeachers,
    List<SchoolClass> allClasses,
  ) {
    String displayText = '-';
    Color bgColor = Colors.transparent;

    if (entry != null) {
      final subject = allSubjects.firstWhere(
        (s) => s.id == entry.subjectId,
        orElse: () => Subject(name: 'غير معروفة', subjectId: ''),
      );

      if (_selectedClass != null) {
        final teacher = allTeachers.firstWhere(
          (t) => t.id == entry.teacherId,
          orElse: () => Teacher(name: 'غير معروف', subject: '', phone: '', email: ''),
        );
        displayText = '${subject.name}\n${teacher.name}\n(${entry.startTime}-${entry.endTime})';
      } else if (_selectedTeacher != null) {
        final schoolClass = allClasses.firstWhere(
          (c) => c.id == entry.classId,
          orElse: () => SchoolClass(name: 'غير معروف', classId: ''),
        );
        displayText = '${subject.name}\n${schoolClass.name}\n(${entry.startTime}-${entry.endTime})';
      } else {
        final teacher = allTeachers.firstWhere(
          (t) => t.id == entry.teacherId,
          orElse: () => Teacher(name: 'غير معروف', subject: '', phone: '', email: ''),
        );
        final schoolClass = allClasses.firstWhere(
          (c) => c.id == entry.classId,
          orElse: () => SchoolClass(name: 'غير معروف', classId: ''),
        );
        displayText = '${subject.name}\n${schoolClass.name}\n${teacher.name}\n(${entry.startTime}-${entry.endTime})';
      }
      bgColor = Theme.of(context).colorScheme.primary.withAlpha((255 * 0.05).round());
    }

    return GestureDetector(
      onTap: entry != null ? () => _navigateToAddEditTimetableEntry(entry: entry) : null,
      child: Container(
        padding: const EdgeInsets.all(4.0),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: bgColor,
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Text(
          displayText,
          style: Theme.of(context).textTheme.bodySmall,
          textAlign: TextAlign.center,
          maxLines: 4,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  void _navigateToAddEditTimetableEntry({
    TimetableEntry? entry,
  }) async { // Make the function async
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddEditTimetableScreen(entry: entry),
      ),
    );
    if (!mounted) return; // Check mounted after push
    _loadTimetableData(); // Reload data after returning from add/edit screen
  }
}
