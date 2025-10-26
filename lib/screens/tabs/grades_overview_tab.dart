import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../grade_model.dart';
import '../../student_model.dart';
import '../../subject_model.dart';
import '../../class_model.dart';
import '../../providers/grade_provider.dart';
import '../../providers/student_provider.dart';
import '../../providers/class_provider.dart';
import '../../providers/subject_provider.dart';
import '../add_edit_grade_dialog.dart';

extension IterableExtension<T> on Iterable<T> {
  T? firstWhereOrNull(bool Function(T) test) {
    for (var element in this) {
      if (test(element)) {
        return element;
      }
    }
    return null;
  }
}

class GradesOverviewTab extends StatefulWidget {
  const GradesOverviewTab({super.key});

  @override
  State<GradesOverviewTab> createState() => _GradesOverviewTabState();
}

class _GradesOverviewTabState extends State<GradesOverviewTab> {
  String? _selectedStudentFilter;
  String? _selectedClassFilter;
  String? _selectedSubjectFilter;
  bool _isDataLoading = false; // To manage loading state for this tab's specific data

  @override
  void initState() {
    super.initState();
    // Initial data fetch for dropdowns is handled by GradesScreen, but we might need to refresh grades specific to this tab's filters
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _applyFiltersAndLoadGrades();
    });
  }

  Future<void> _applyFiltersAndLoadGrades() async {
    if (!mounted) return;
    setState(() {
      _isDataLoading = true;
    });

    final gradeProvider = Provider.of<GradeProvider>(context, listen: false);
    final studentProvider = Provider.of<StudentProvider>(context, listen: false);
    final classProvider = Provider.of<ClassProvider>(context, listen: false);
    final subjectProvider = Provider.of<SubjectProvider>(context, listen: false);

    int? studentIdFilter;
    if (_selectedStudentFilter != null) {
      final student = studentProvider.students
          .firstWhereOrNull((s) => s.name == _selectedStudentFilter);
      studentIdFilter = student?.id;
    }

    int? classIdFilter;
    if (_selectedClassFilter != null) {
      final schoolClass = classProvider.classes
          .firstWhereOrNull((c) => c.name == _selectedClassFilter);
      classIdFilter = schoolClass?.id;
    }

    int? subjectIdFilter;
    if (_selectedSubjectFilter != null) {
      final subject = subjectProvider.subjects
          .firstWhereOrNull((s) => s.name == _selectedSubjectFilter);
      subjectIdFilter = subject?.id;
    }

    await gradeProvider.fetchGrades(studentId: studentIdFilter, classId: classIdFilter, subjectId: subjectIdFilter);

    if (mounted) {
      setState(() {
        _isDataLoading = false;
      });
    }
  }

  Future<void> _addGrade() async {
    await showDialog(
      context: context,
      builder: (context) => const AddEditGradeDialog(), // No grade passed, so it's in 'add' mode
    );
    _applyFiltersAndLoadGrades(); // Refresh grades after add
  }

  Future<void> _editGrade(Grade grade) async {
    await showDialog(
      context: context,
      builder: (context) => AddEditGradeDialog(grade: grade),
    );
    _applyFiltersAndLoadGrades(); // Refresh grades after edit
  }

  Future<void> _deleteGrade(int id) async {
    final bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text('هل أنت متأكد أنك تريد حذف هذه الدرجة؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            child: const Text('حذف'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      if (!mounted) return;
      try {
        await Provider.of<GradeProvider>(context, listen: false).deleteGrade(id);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم حذف الدرجة بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
        _applyFiltersAndLoadGrades(); // Refresh grades after deletion
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل حذف الدرجة: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer4<GradeProvider, StudentProvider, SubjectProvider, ClassProvider>(
        builder: (context, gradeProvider, studentProvider, subjectProvider, classProvider, child) {
          // These lists are already populated by GradesScreen's initState
          final allStudents = studentProvider.students;
          final allClasses = classProvider.classes;
          final allSubjects = subjectProvider.subjects;

          if (_isDataLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final filteredGrades = gradeProvider.grades;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'متوسط الدرجات لكل مادة',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 250, // Increased height for better chart visibility
                  child: FutureBuilder<List<Map<String, dynamic>>>(
                    future: gradeProvider.getAverageGradesBySubject(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return _buildEmptyState(
                            context, 'خطأ في تحميل الرسم البياني: ${snapshot.error}', Icons.error_outline);
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return _buildEmptyState(context, 'لا توجد بيانات لعرض الرسم البياني.', Icons.bar_chart);
                      } else {
                        final data = snapshot.data!;
                        return Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: BarChart(
                              BarChartData(
                                barGroups: data.asMap().entries.map((entry) {
                                  final index = entry.key;
                                  final item = entry.value;
                                  final averageGrade = item['averageGrade'] as double;
                                  return BarChartGroupData(
                                    x: index,
                                    barRods: [
                                      BarChartRodData(
                                        toY: averageGrade,
                                        color: Theme.of(context).colorScheme.tertiaryContainer,
                                        width: 20, // Increased width for better visibility
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ],
                                  );
                                }).toList(),
                                titlesData: FlTitlesData(
                                  show: true,
                                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      getTitlesWidget: (double value, TitleMeta meta) {
                                        final index = value.toInt();
                                        if (index >= 0 && index < data.length) {
                                          return SideTitleWidget(
                                            space: 8.0,
                                            meta: meta,
                                            child: Text(data[index]['subjectName']!,
                                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                    color: Theme.of(context).colorScheme.onSurface)),
                                          );
                                        }
                                        return const Text('');
                                      },
                                      reservedSize: 40,
                                    ),
                                  ),
                                  leftTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      interval: 20,
                                      getTitlesWidget: (value, TitleMeta meta) {
                                        return SideTitleWidget(
                                          space: 8.0,
                                          meta: meta,
                                          child: Text(value.toInt().toString(),
                                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                  color: Theme.of(context).colorScheme.onSurface)),
                                        );
                                      },
                                      reservedSize: 28,
                                    ),
                                  ),
                                ),
                                borderData: FlBorderData(
                                  show: false,
                                ),
                                gridData: FlGridData(
                                  show: true,
                                  drawVerticalLine: false,
                                  getDrawingHorizontalLine: (value) => FlLine(
                                    color: Theme.of(context).colorScheme.onSurface.withAlpha(
                                      (((Theme.of(context).colorScheme.onSurface.toARGB32() >> 24) & 0xFF) * 0.2).round(),
                                    ),
                                    strokeWidth: 0.5,
                                  ),
                                  checkToShowHorizontalLine: (value) => value % 20 == 0,
                                ),
                                alignment: BarChartAlignment.spaceAround,
                                maxY: 100, // Assuming grades are out of 100
                              ),
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'جميع الدرجات المسجلة',
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
                    _buildFilterDropdown<Student>(
                      context,
                      'الطالب',
                      _selectedStudentFilter,
                      allStudents,
                      (newValue) {
                        setState(() {
                          _selectedStudentFilter = newValue?.name;
                        });
                        _applyFiltersAndLoadGrades();
                      },
                      (s) => s.name,
                      allStudents.isEmpty ? 'لا يوجد طلاب' : null,
                    ),
                    _buildFilterDropdown<SchoolClass>(
                      context,
                      'الفصل',
                      _selectedClassFilter,
                      allClasses,
                      (newValue) {
                        setState(() {
                          _selectedClassFilter = newValue?.name;
                        });
                        _applyFiltersAndLoadGrades();
                      },
                      (c) => c.name,
                      allClasses.isEmpty ? 'لا توجد فصول' : null,
                    ),
                    _buildFilterDropdown<Subject>(
                      context,
                      'المادة',
                      _selectedSubjectFilter,
                      allSubjects,
                      (newValue) {
                        setState(() {
                          _selectedSubjectFilter = newValue?.name;
                        });
                        _applyFiltersAndLoadGrades();
                      },
                      (s) => s.name,
                      allSubjects.isEmpty ? 'لا توجد مواد' : null,
                    ),
                    IconButton(
                      icon: const Icon(Icons.clear_all),
                      onPressed: () {
                        setState(() {
                          _selectedStudentFilter = null;
                          _selectedClassFilter = null;
                          _selectedSubjectFilter = null;
                        });
                        _applyFiltersAndLoadGrades();
                      },
                      tooltip: 'مسح جميع الفلاتر',
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: filteredGrades.isEmpty
                      ? _buildEmptyState(context, 'لا توجد درجات مسجلة بناءً على الفلاتر المختارة.', Icons.school_outlined)
                      : Card(
                          margin: EdgeInsets.zero,
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              headingTextStyle: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(fontWeight: FontWeight.bold,
                                      color: Theme.of(context).colorScheme.onSurface),
                              dataTextStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface),
                              columnSpacing: 24,
                              horizontalMargin: 24,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              columns: const [
                                DataColumn(label: Text('الطالب')),
                                DataColumn(label: Text('الفصل')),
                                DataColumn(label: Text('المادة')),
                                DataColumn(label: Text('نوع التقييم')),
                                DataColumn(label: Text('الدرجة')),
                                DataColumn(label: Text('الوزن النسبي')),
                                DataColumn(label: Text('إجراءات')),
                              ],
                              rows: filteredGrades.map((grade) {
                                final student = allStudents.firstWhere(
                                  (s) => s.id == grade.studentId,
                                  orElse: () => Student(id: -1, name: 'غير معروف', dob: '', phone: '', grade: ''),
                                );
                                final schoolClass = allClasses.firstWhere(
                                  (c) => c.id == grade.classId,
                                  orElse: () => SchoolClass(id: -1, name: 'غير معروف', classId: ''),
                                );
                                final subject = allSubjects.firstWhere(
                                  (s) => s.id == grade.subjectId,
                                  orElse: () => Subject(id: -1, name: 'غير معروف', subjectId: ''),
                                );

                                return DataRow(cells: [
                                  DataCell(Text(student.name)),
                                  DataCell(Text(schoolClass.name)),
                                  DataCell(Text(subject.name)),
                                  DataCell(Text(grade.assessmentType)),
                                  DataCell(Text(grade.gradeValue.toStringAsFixed(2))),
                                  DataCell(Text(grade.weight.toStringAsFixed(2))),
                                  DataCell(
                                    PopupMenuButton<String>(
                                      onSelected: (value) {
                                        if (value == 'edit') {
                                          _editGrade(grade);
                                        } else if (value == 'delete') {
                                          _deleteGrade(grade.id!);
                                        }
                                      },
                                      itemBuilder: (context) => [
                                        const PopupMenuItem(
                                          value: 'edit',
                                          child: Row(
                                            children: [
                                              Icon(Icons.edit),
                                              SizedBox(width: 8),
                                              Text('تعديل'),
                                            ],
                                          ),
                                        ),
                                        PopupMenuItem(
                                          value: 'delete',
                                          child: Row(
                                            children: [
                                              Icon(Icons.delete, color: Theme.of(context).colorScheme.error),
                                              SizedBox(width: 8),
                                              Text('حذف', style: TextStyle(color: Theme.of(context).colorScheme.error)),
                                            ],
                                          ),
                                        ),
                                      ],
                                      icon: const Icon(Icons.more_vert),
                                      tooltip: 'المزيد من الإجراءات',
                                    ),
                                  ),
                                ]);
                              }).toList(),
                            ),
                          ),
                        ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addGrade,
        tooltip: 'إضافة درجة فردية',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildFilterDropdown<T>(
    BuildContext context,
    String label,
    String? selectedValueName, // Expecting name string for current selected value
    List<T> items,
    ValueChanged<T?> onChanged,
    String Function(T) itemText,
    String? emptyMessage,
  ) {
    // Find the actual selected object from the list based on its name
    T? selectedObject;
    if (selectedValueName != null) {
      try {
        selectedObject = items.firstWhere((item) => itemText(item) == selectedValueName);
      } catch (e) {
        // If selectedValueName doesn't match any item, keep selectedObject null
        selectedObject = null;
      }
    }

    return SizedBox(
      width: 200, // Fixed width for consistency
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
        isEmpty: selectedObject == null,
        child: DropdownButtonHideUnderline(
          child: DropdownButton<T>(
            value: selectedObject,
            hint: items.isEmpty
                ? Text(emptyMessage ?? 'لا توجد خيارات')
                : Text('اختر $label'),
            isExpanded: true,
            onChanged: items.isEmpty ? null : onChanged,
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
