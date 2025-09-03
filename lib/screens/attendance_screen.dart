import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../student_model.dart';
import '../class_model.dart';
import '../subject_model.dart';
import '../teacher_model.dart';
import '../providers/attendance_provider.dart';
import '../providers/student_provider.dart';
import '../providers/class_provider.dart';
import '../providers/subject_provider.dart';
import '../providers/teacher_provider.dart';

class AttendanceScreen extends StatefulWidget {
  static const routeName = '/attendance-screen';
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  String _selectedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
  SchoolClass? _selectedClass;
  Subject? _selectedSubject;
  Teacher? _selectedTeacher;
  int? _selectedLessonNumber;
  bool _isLoading = false; // Added loading state

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
    final subjectProvider = Provider.of<SubjectProvider>(context, listen: false);
    final teacherProvider = Provider.of<TeacherProvider>(context, listen: false);

    await classProvider.fetchClasses();
    if (!mounted) return;
    await subjectProvider.fetchSubjects();
    if (!mounted) return;
    await teacherProvider.fetchTeachers();
    if (!mounted) return;

    // Ensure default selections only if lists are not empty
    if (classProvider.classes.isNotEmpty) {
      _selectedClass = classProvider.classes.first;
    }
    if (subjectProvider.subjects.isNotEmpty) {
      _selectedSubject = subjectProvider.subjects.first;
    }
    if (teacherProvider.teachers.isNotEmpty) {
      _selectedTeacher = teacherProvider.teachers.first;
    }

    await _loadAttendanceData();
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _loadAttendanceData() async {
    // Only set loading if not already loading from _fetchInitialData
    if (!_isLoading) {
      setState(() {
        _isLoading = true;
      });
    }

    if (_selectedClass == null ||
        _selectedSubject == null ||
        _selectedTeacher == null ||
        _selectedLessonNumber == null) {
      if (_isLoading) { // Only set to false if this function initiated the loading
        setState(() {
          _isLoading = false;
        });
      }
      return;
    }

    await Provider.of<AttendanceProvider>(context, listen: false).fetchAttendances(
      date: _selectedDate,
      classId: _selectedClass!.id,
      subjectId: _selectedSubject!.id,
      teacherId: _selectedTeacher!.id,
      lessonNumber: _selectedLessonNumber,
    );
    if (!mounted) return;
    await Provider.of<StudentProvider>(context, listen: false)
        .searchStudents('', classId: _selectedClass!.classId);
    if (!mounted) return;

    if (_isLoading) {
      setState(() {
        _isLoading = false;
      });
    }
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
      _loadAttendanceData();
    }
  }

  void _setStudentAttendance(
    Student student,
    String status,
  ) async {
    if (!mounted) return;
    if (_selectedClass == null ||
        _selectedSubject == null ||
        _selectedTeacher == null ||
        _selectedLessonNumber == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('الرجاء تحديد التاريخ والفصل والمادة ورقم الحصة أولاً.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final int classId = _selectedClass!.id!;
    final int subjectId = _selectedSubject!.id!;
    final int teacherId = _selectedTeacher!.id!;

    await Provider.of<AttendanceProvider>(context, listen: false).setAttendanceStatus(
      student.id!,
      classId,
      subjectId,
      teacherId,
      _selectedDate,
      _selectedLessonNumber!,
      status,
    );
  }

  @override
  Widget build(BuildContext context) {
    final classProvider = Provider.of<ClassProvider>(context);
    final subjectProvider = Provider.of<SubjectProvider>(context);
    final teacherProvider = Provider.of<TeacherProvider>(context);
    final studentProvider = Provider.of<StudentProvider>(context);
    final attendanceProvider = Provider.of<AttendanceProvider>(context);

    bool allFiltersSelected = _selectedClass != null &&
        _selectedSubject != null &&
        _selectedTeacher != null &&
        _selectedLessonNumber != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('تسجيل الحضور والغياب'),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 16.0,
                  runSpacing: 16.0,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => _selectDate(context),
                      icon: const Icon(Icons.calendar_today),
                      label: Text('التاريخ: $_selectedDate'), // Simplified date label
                    ),
                    DropdownButton<SchoolClass>(
                      value: _selectedClass,
                      hint: const Text('اختر الفصل'),
                      onChanged: classProvider.classes.isEmpty
                          ? null // Disable if no classes
                          : (newValue) {
                              setState(() {
                                _selectedClass = newValue;
                                _selectedSubject = null; // Reset subject when class changes
                              });
                              _loadAttendanceData();
                            },
                      items: classProvider.classes.map((c) {
                        return DropdownMenuItem(value: c, child: Text(c.name));
                      }).toList(),
                    ),
                    DropdownButton<Subject>(
                      value: _selectedSubject,
                      hint: const Text('اختر المادة'),
                      onChanged: subjectProvider.subjects.isEmpty
                          ? null // Disable if no subjects
                          : (newValue) {
                              setState(() {
                                _selectedSubject = newValue;
                              });
                              _loadAttendanceData();
                            },
                      items: subjectProvider.subjects.map((s) {
                        return DropdownMenuItem(value: s, child: Text(s.name));
                      }).toList(),
                    ),
                    DropdownButton<Teacher>(
                      value: _selectedTeacher,
                      hint: const Text('اختر المعلم'),
                      onChanged: teacherProvider.teachers.isEmpty
                          ? null // Disable if no teachers
                          : (newValue) {
                              setState(() {
                                _selectedTeacher = newValue;
                              });
                              _loadAttendanceData();
                            },
                      items: teacherProvider.teachers.map((t) {
                        return DropdownMenuItem(value: t, child: Text(t.name));
                      }).toList(),
                    ),
                    DropdownButton<int>(
                      value: _selectedLessonNumber,
                      hint: const Text('رقم الحصة'),
                      onChanged: (newValue) {
                        setState(() {
                          _selectedLessonNumber = newValue;
                        });
                        _loadAttendanceData();
                      },
                      items: List.generate(6, (index) => index + 1).map((lessonNum) {
                        return DropdownMenuItem(value: lessonNum, child: Text('الحصة $lessonNum'));
                      }).toList(),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  'الطلاب في الفصل ${_selectedClass?.name ?? 'المحدد'}',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: Builder(
                    builder: (context) {
                      if (_isLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (classProvider.classes.isEmpty) {
                        return const Center(child: Text('لا توجد فصول متاحة. الرجاء إضافة فصول أولاً.'));
                      }
                      if (subjectProvider.subjects.isEmpty) {
                        return const Center(child: Text('لا توجد مواد متاحة. الرجاء إضافة مواد أولاً.'));
                      }
                      if (teacherProvider.teachers.isEmpty) {
                        return const Center(child: Text('لا يوجد معلمون متاحون. الرجاء إضافة معلمين أولاً.'));
                      }
                      if (!allFiltersSelected) {
                        return const Center(child: Text('الرجاء تحديد جميع الفلاتر (الفصل, المادة, المعلم, رقم الحصة) لعرض قائمة الطلاب.'));
                      }
                      if (studentProvider.students.isEmpty) {
                        return const Center(child: Text('لا يوجد طلاب في هذا الفصل أو لم يتم العثور على طلاب مطابقين.'));
                      }
                      return ListView.builder(
                        itemCount: studentProvider.students.length,
                        itemBuilder: (context, index) {
                          final student = studentProvider.students[index];
                          final currentStatus = attendanceProvider.getAttendanceStatus(
                            student.id!,
                            _selectedDate,
                            _selectedLessonNumber ?? -1,
                          );

                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Row(
                                children: [
                                  Expanded(child: Text(student.name, style: const TextStyle(fontSize: 16))),
                                  const SizedBox(width: 10),
                                  DropdownButton<String>(
                                    value: currentStatus == 'unknown' ? null : currentStatus,
                                    hint: const Text('الحالة'),
                                    onChanged: allFiltersSelected
                                        ? (newValue) {
                                            if (newValue != null) {
                                              _setStudentAttendance(student, newValue);
                                            }
                                          }
                                        : null, // Disable if filters not selected
                                    items: const [
                                      DropdownMenuItem(value: 'present', child: Text('حاضر')),
                                      DropdownMenuItem(value: 'absent', child: Text('غائب')),
                                      DropdownMenuItem(value: 'late', child: Text('متأخر')),
                                      DropdownMenuItem(value: 'excused', child: Text('معتذر')),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          if (_isLoading && allFiltersSelected) // Show global loading only if filters are selected
            const Opacity(
              opacity: 0.6,
              child: ModalBarrier(dismissible: false, color: Colors.black),
            ),
          if (_isLoading && allFiltersSelected)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
