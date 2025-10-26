
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/attendance_provider.dart';
import '../providers/student_provider.dart';
import '../providers/class_provider.dart';
import '../student_model.dart';
import '../class_model.dart';
import '../attendance_model.dart';

class AttendanceHistoryScreen extends StatefulWidget {
  static const routeName = '/attendance-history';

  const AttendanceHistoryScreen({super.key});

  @override
  State<AttendanceHistoryScreen> createState() => _AttendanceHistoryScreenState();
}

class _AttendanceHistoryScreenState extends State<AttendanceHistoryScreen> {
  Student? _selectedStudent;
  SchoolClass? _selectedClass;
  DateTimeRange? _selectedDateRange;
  List<Attendance> _attendanceRecords = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Set default date range to the last 7 days
    final endDate = DateTime.now();
    final startDate = endDate.subtract(const Duration(days: 7));
    _selectedDateRange = DateTimeRange(start: startDate, end: endDate);
    // Fetch initial data without filters
    _fetchAttendanceHistory();
  }

  Future<void> _fetchAttendanceHistory() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    final attendanceProvider = Provider.of<AttendanceProvider>(context, listen: false);
    try {
      // This is a simplified fetch. Ideally, the provider and database layer
      // would be enhanced to accept a date range.
      // For now, we fetch all and filter locally.
      await attendanceProvider.fetchAttendances(
        studentId: _selectedStudent?.id,
        classId: _selectedClass?.id,
      );

      List<Attendance> records = attendanceProvider.attendances;

      if (_selectedDateRange != null) {
        records = records.where((record) {
          final recordDate = DateTime.parse(record.date);
          return recordDate.isAfter(_selectedDateRange!.start.subtract(const Duration(days: 1))) && 
                 recordDate.isBefore(_selectedDateRange!.end.add(const Duration(days: 1)));
        }).toList();
      }
      
      // Sort records by date descending
      records.sort((a, b) => b.date.compareTo(a.date));

      setState(() {
        _attendanceRecords = records;
      });

    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل تحميل سجل الحضور: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      initialDateRange: _selectedDateRange,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('ar', ''),
    );
    if (picked != null && picked != _selectedDateRange) {
      setState(() {
        _selectedDateRange = picked;
      });
      _fetchAttendanceHistory();
    }
  }

  @override
  Widget build(BuildContext context) {
    final studentProvider = Provider.of<StudentProvider>(context);
    final classProvider = Provider.of<ClassProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('سجل الحضور التاريخي'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Wrap(
              spacing: 16.0,
              runSpacing: 16.0,
              children: [
                // Student Filter
                SizedBox(
                  width: 200,
                  child: DropdownButtonFormField<Student>(
                    decoration: const InputDecoration(labelText: 'الطالب', border: OutlineInputBorder()),
                    initialValue: _selectedStudent,
                    items: studentProvider.students.map((student) {
                      return DropdownMenuItem(value: student, child: Text(student.name));
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedStudent = value;
                      });
                    },
                  ),
                ),
                // Class Filter
                SizedBox(
                  width: 200,
                  child: DropdownButtonFormField<SchoolClass>(
                    decoration: const InputDecoration(labelText: 'الفصل', border: OutlineInputBorder()),
                    initialValue: _selectedClass,
                    items: classProvider.classes.map((c) {
                      return DropdownMenuItem(value: c, child: Text(c.name));
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedClass = value;
                      });
                    },
                  ),
                ),
                // Date Range Picker
                ElevatedButton.icon(
                  onPressed: () => _selectDateRange(context),
                  icon: const Icon(Icons.calendar_today),
                  label: Text(_selectedDateRange == null 
                      ? 'اختر نطاق التاريخ' 
                      : '${DateFormat('yyyy/MM/dd').format(_selectedDateRange!.start)} - ${DateFormat('yyyy/MM/dd').format(_selectedDateRange!.end)}'),
                ),
                // Search Button
                FilledButton(onPressed: _fetchAttendanceHistory, child: const Text('بحث')),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _attendanceRecords.isEmpty
                    ? const Center(child: Text('لا توجد سجلات حضور تطابق البحث.'))
                    : ListView.builder(
                        itemCount: _attendanceRecords.length,
                        itemBuilder: (context, index) {
                          final record = _attendanceRecords[index];
                          final student = studentProvider.students.firstWhere((s) => s.id == record.studentId, orElse: () => Student(id: -1, name: 'طالب غير معروف', dob: '', phone: '', grade: ''));
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: ListTile(
                              title: Text('${student.name} - ${record.date}'),
                              subtitle: Text('الحصة: ${record.lessonNumber}, الحالة: ${record.status}'),
                              trailing: Text(record.lateMinutes != null && record.lateMinutes! > 0 ? 'متأخر ${record.lateMinutes} دقيقة' : '', style: TextStyle(color: Colors.orange.shade700)),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
