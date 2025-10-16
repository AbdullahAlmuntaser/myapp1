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
import '../add_edit_grade_dialog.dart'; // Will create this next

class GradesOverviewTab extends StatefulWidget {
  const GradesOverviewTab({super.key});

  @override
  State<GradesOverviewTab> createState() => _GradesOverviewTabState();
}

class _GradesOverviewTabState extends State<GradesOverviewTab> {
  String? _selectedStudentFilter;
  String? _selectedClassFilter;
  String? _selectedSubjectFilter;

  @override
  Widget build(BuildContext context) {
    return Consumer4<GradeProvider, StudentProvider, SubjectProvider, ClassProvider>(
      builder: (context, gradeProvider, studentProvider, subjectProvider, classProvider, child) {
        List<Grade> filteredGrades = gradeProvider.grades;

        // Apply filters
        if (_selectedStudentFilter != null) {
          final student = studentProvider.students.firstWhere(
            (s) => s.name == _selectedStudentFilter,
            orElse: () => Student(id: -1, name: '', dob: '', phone: '', grade: ''),
          );
          if (student.id != -1) {
            filteredGrades = filteredGrades.where((g) => g.studentId == student.id).toList();
          }
        }
        if (_selectedClassFilter != null) {
          final schoolClass = classProvider.classes.firstWhere(
            (c) => c.name == _selectedClassFilter,
            orElse: () => SchoolClass(id: -1, name: '', classId: ''),
          );
          if (schoolClass.id != -1) {
            filteredGrades = filteredGrades.where((g) => g.classId == schoolClass.id).toList();
          }
        }
        if (_selectedSubjectFilter != null) {
          final subject = subjectProvider.subjects.firstWhere(
            (s) => s.name == _selectedSubjectFilter,
            orElse: () => Subject(id: -1, name: '', subjectId: ''),
          );
          if (subject.id != -1) {
            filteredGrades = filteredGrades.where((g) => g.subjectId == subject.id).toList();
          }
        }

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'متوسط الدرجات لكل مادة',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 200,
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: gradeProvider.getAverageGradesBySubject(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('خطأ: ${snapshot.error}')); // Translated "Error:" to "خطأ:"
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text('لا توجد بيانات لعرض الرسم البياني.'));
                    } else {
                      final data = snapshot.data!;
                      return BarChart(
                        BarChartData(
                          barGroups: data.map((e) {
                            final averageGrade = e['averageGrade'] as double;
                            final index = data.indexOf(e);
                            return BarChartGroupData(
                              x: index,
                              barRods: [
                                BarChartRodData(
                                  toY: averageGrade,
                                  color: Colors.blue,
                                  width: 16,
                                ),
                              ],
                            );
                          }).toList(),
                          titlesData: FlTitlesData(
                            leftTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: true, interval: 20),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (double value, TitleMeta meta) {
                                  final index = value.toInt();
                                  if (index >= 0 && index < data.length) {
                                    return SideTitleWidget(
                                      axisSide: meta.axisSide,
                                      space: 8.0,
                                      child: Text(data[index]['subjectName']!),
                                    );
                                  }
                                  return const Text('');
                                },
                                reservedSize: 40,
                              ),
                            ),
                            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          ),
                          borderData: FlBorderData(show: false),
                          gridData: const FlGridData(show: false),
                        ),
                      );
                    }
                  },
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'جميع الدرجات المسجلة',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'فلتر الطالب'),
                      initialValue: _selectedStudentFilter,
                      items: studentProvider.students.map((s) => s.name).map((name) {
                        return DropdownMenuItem(value: name, child: Text(name));
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedStudentFilter = value;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'فلتر الفصل'),
                      initialValue: _selectedClassFilter,
                      items: classProvider.classes.map((c) => c.name).map((name) {
                        return DropdownMenuItem(value: name, child: Text(name));
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedClassFilter = value;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'فلتر المادة'),
                      initialValue: _selectedSubjectFilter,
                      items: subjectProvider.subjects.map((s) => s.name).map((name) {
                        return DropdownMenuItem(value: name, child: Text(name));
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedSubjectFilter = value;
                        });
                      },
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      setState(() {
                        _selectedStudentFilter = null;
                        _selectedClassFilter = null;
                        _selectedSubjectFilter = null;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
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
                        final student = studentProvider.students.firstWhere(
                          (s) => s.id == grade.studentId,
                          orElse: () => Student(id: -1, name: 'غير معروف', dob: '', phone: '', grade: ''),
                        );
                        final schoolClass = classProvider.classes.firstWhere(
                          (c) => c.id == grade.classId,
                          orElse: () => SchoolClass(id: -1, name: 'غير معروف', classId: ''),
                        );
                        final subject = subjectProvider.subjects.firstWhere(
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
                          DataCell(Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AddEditGradeDialog(grade: grade),
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () {
                                  gradeProvider.deleteGrade(grade.id!);
                                },
                              ),
                            ],
                          )),
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
    );
  }
}