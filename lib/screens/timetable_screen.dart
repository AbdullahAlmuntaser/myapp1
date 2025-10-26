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
import 'add_edit_timetable_screen.dart';

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

      // Set initial filters if lists are not empty
      if (classProvider.classes.isNotEmpty) {
        _selectedClass = classProvider.classes.first;
      }
      // Do not auto-select teacher, as it conflicts with class filter

      await _loadTimetableData();
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

  Future<void> _loadTimetableData() async {
    if (!mounted) return;
    if (!_isLoading) {
      setState(() {
        _isLoading = true;
      });
    }

    final timetableProvider = Provider.of<TimetableProvider>(context, listen: false);

    try {
      if (_selectedClass != null && _selectedTeacher != null) {
        // If both are selected, prioritize class filter for fetching then filter locally
        await timetableProvider.fetchTimetableEntriesByClass(_selectedClass!.id!);
        // Additional local filtering by teacher will happen in the Consumer
      } else if (_selectedClass != null) {
        await timetableProvider.fetchTimetableEntriesByClass(_selectedClass!.id!);
      } else if (_selectedTeacher != null) {
        await timetableProvider.fetchTimetableEntriesByTeacher(_selectedTeacher!.id!);
      } else {
        await timetableProvider.fetchTimetableEntries();
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل تحميل بيانات الجدول: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _navigateToAddEditTimetableEntry({
    TimetableEntry? entry,
  }) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddEditTimetableScreen(entry: entry),
      ),
    );
    if (!mounted) return;
    _loadTimetableData(); // Reload data after returning
  }

  @override
  Widget build(BuildContext context) {
    final classProvider = Provider.of<ClassProvider>(context);
    final teacherProvider = Provider.of<TeacherProvider>(context);
    final subjectProvider = Provider.of<SubjectProvider>(context);
    final timetableProvider = Provider.of<TimetableProvider>(context);

    // Filter timetable entries based on selected teacher if both class and teacher are selected
    List<TimetableEntry> currentTimetableEntries = timetableProvider.timetableEntries;
    if (_selectedClass != null && _selectedTeacher != null) {
      currentTimetableEntries = currentTimetableEntries.where((entry) =>
          entry.classId == _selectedClass!.id && entry.teacherId == _selectedTeacher!.id
      ).toList();
    } else if (_selectedClass != null) {
      currentTimetableEntries = currentTimetableEntries.where((entry) =>
          entry.classId == _selectedClass!.id
      ).toList();
    } else if (_selectedTeacher != null) {
      currentTimetableEntries = currentTimetableEntries.where((entry) =>
          entry.teacherId == _selectedTeacher!.id
      ).toList();
    }

    // Convert to a map for easy lookup by day and lesson number
    final Map<String, TimetableEntry> timetableMap = {};
    for (var entry in currentTimetableEntries) {
      timetableMap['${entry.dayOfWeek}_${entry.lessonNumber}'] = entry;
    }

    bool hasRequiredData = classProvider.classes.isNotEmpty &&
        teacherProvider.teachers.isNotEmpty &&
        subjectProvider.subjects.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'جدول الحصص',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.onPrimary,
              ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        centerTitle: true,
        elevation: 4,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'تصفية الجدول الدراسي',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 16.0,
                  runSpacing: 16.0,
                  children: [
                    _buildFilterDropdown<SchoolClass>(
                      context,
                      'الفصل',
                      _selectedClass,
                      classProvider.classes,
                      (newValue) {
                        setState(() {
                          _selectedClass = newValue;
                          _selectedTeacher = null;
                        });
                        _loadTimetableData();
                      },
                      (c) => c.name,
                      classProvider.classes.isEmpty ? 'لا توجد فصول' : null,
                    ),
                    _buildFilterDropdown<Teacher>(
                      context,
                      'المعلم',
                      _selectedTeacher,
                      teacherProvider.teachers,
                      (newValue) {
                        setState(() {
                          _selectedTeacher = newValue;
                          _selectedClass = null;
                        });
                        _loadTimetableData();
                      },
                      (t) => t.name,
                      teacherProvider.teachers.isEmpty ? 'لا يوجد معلمون' : null,
                    ),
                    IconButton(
                      icon: const Icon(Icons.clear_all),
                      onPressed: () {
                        setState(() {
                          _selectedClass = null;
                          _selectedTeacher = null;
                        });
                        _loadTimetableData();
                      },
                      tooltip: 'مسح جميع الفلاتر',
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : !hasRequiredData
                          ? _buildEmptyState(
                              context,
                              'الرجاء إضافة فصول ومعلمين ومواد لعرض جدول الحصص.',
                              Icons.calendar_month_outlined,
                            )
                          : currentTimetableEntries.isEmpty && (_selectedClass != null || _selectedTeacher != null) 
                            ? _buildEmptyState(context, 'لا توجد إدخالات لجدول الحصص بناءً على الفلاتر المختارة.', Icons.event_busy)
                            : SingleChildScrollView(
                              scrollDirection: Axis.vertical,
                              child: Card(
                                elevation: 2,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                                margin: EdgeInsets.zero,
                                child: Table(
                                  border: TableBorder.all(
                                    color: Theme.of(context).colorScheme.outline.withAlpha((0.5 * 255).round()),
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                  columnWidths: const {0: FlexColumnWidth(1.5)}, // Day column wider
                                  children: [
                                    TableRow(
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).colorScheme.primaryContainer.withAlpha((0.4 * 255).round()),
                                        borderRadius: const BorderRadius.vertical(top: Radius.circular(12.0)),
                                      ),
                                      children: [
                                        _buildHeaderCell(context, 'رقم الحصة/اليوم'),
                                        ..._daysOfWeek.map((day) => _buildHeaderCell(context, day)),
                                      ],
                                    ),
                                    for (int lessonNum = 1; lessonNum <= _maxLessonNumber; lessonNum++)
                                      TableRow(
                                        children: [
                                          _buildHeaderCell(context, 'الحصة $lessonNum'),
                                          for (String day in _daysOfWeek)
                                            _buildTimetableCell(
                                              context,
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
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isLoading ? null : () => _navigateToAddEditTimetableEntry(),
        tooltip: 'إضافة حصة لجدول الحصص',
        icon: const Icon(Icons.add),
        label: const Text('إضافة حصة'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
      ),
    );
  }

  Widget _buildHeaderCell(BuildContext context, String text) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withAlpha((0.1 * 255).round()),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildTimetableCell(
    BuildContext context,
    TimetableEntry? entry,
    List<Subject> allSubjects,
    List<Teacher> allTeachers,
    List<SchoolClass> allClasses,
  ) {
    String displayText = '-';
    Color bgColor = Theme.of(context).colorScheme.surface;
    TextStyle textStyle = Theme.of(context).textTheme.bodySmall!.copyWith(color: Theme.of(context).colorScheme.onSurface);

    if (entry != null) {
      final subject = allSubjects.firstWhere(
        (s) => s.id == entry.subjectId,
        orElse: () => Subject(name: 'غير معروفة', subjectId: ''),
      );

      String mainText;
      String subText = '${entry.startTime}-${entry.endTime}';

      if (_selectedClass != null) {
        // Display teacher name if filtering by class
        final teacher = allTeachers.firstWhere(
          (t) => t.id == entry.teacherId,
          orElse: () => Teacher(name: 'غير معروف', subject: '', phone: '', email: ''),
        );
        mainText = '${subject.name}\n${teacher.name}';
      } else if (_selectedTeacher != null) {
        // Display class name if filtering by teacher
        final schoolClass = allClasses.firstWhere(
          (c) => c.id == entry.classId,
          orElse: () => SchoolClass(name: 'غير معروف', classId: ''),
        );
        mainText = '${subject.name}\n${schoolClass.name}';
      } else {
        // Display both class and teacher if no filter selected or filtering by both
        final teacher = allTeachers.firstWhere(
          (t) => t.id == entry.teacherId,
          orElse: () => Teacher(name: 'غير معروف', subject: '', phone: '', email: ''),
        );
        final schoolClass = allClasses.firstWhere(
          (c) => c.id == entry.classId,
          orElse: () => SchoolClass(name: 'غير معروف', classId: ''),
        );
        mainText = '${subject.name}\n${schoolClass.name}\n${teacher.name}';
      }
      displayText = '$mainText\n($subText)';
      bgColor = Theme.of(context).colorScheme.surfaceContainerHighest.withAlpha((0.4 * 255).round()); // Subtle background for entries
      textStyle = Theme.of(context).textTheme.bodySmall!.copyWith(color: Theme.of(context).colorScheme.onSurface);
    }

    return GestureDetector(
      onTap: entry != null && !_isLoading ? () => _navigateToAddEditTimetableEntry(entry: entry) : null,
      child: Container(
        padding: const EdgeInsets.all(4.0),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: bgColor,
          border: Border.all(color: Theme.of(context).colorScheme.outline.withAlpha((0.2 * 255).round())),
        ),
        child: Text(
          displayText,
          style: textStyle,
          textAlign: TextAlign.center,
          maxLines: 4,
          overflow: TextOverflow.ellipsis,
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

  Widget _buildEmptyState(BuildContext context, String message, [IconData? icon]) {
    return Center(
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
    );
  }
}
