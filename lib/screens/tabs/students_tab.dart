import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/student_provider.dart';
import '../../student_model.dart';
import '../add_edit_student_screen.dart';
import '../../providers/class_provider.dart'; // Added import for ClassProvider
import '../../class_model.dart'; // Added import for SchoolClass

class StudentsTab extends StatefulWidget {
  const StudentsTab({super.key});

  @override
  StudentsTabState createState() => StudentsTabState();
}

class StudentsTabState extends State<StudentsTab> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedClassId; // To filter students by class

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Provider.of<StudentProvider>(context, listen: false).fetchStudents();
        Provider.of<ClassProvider>(context, listen: false).fetchClasses(); // Fetch classes
      }
    });
    _searchController.addListener(_filterStudents);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterStudents() {
    Provider.of<StudentProvider>(context, listen: false)
        .searchStudents(_searchController.text, classId: _selectedClassId);
  }

  void _navigateToAddEditScreen([Student? student]) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddEditStudentScreen(student: student),
      ),
    );
  }

  Future<void> _deleteStudent(int id) async {
    final bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text('هل أنت متأكد أنك تريد حذف هذا الطالب؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('حذف'),
          ),
        ],
      ),
    );

    if (!mounted) return;

    if (confirm == true) {
      await Provider.of<StudentProvider>(context, listen: false).deleteStudent(id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم حذف الطالب بنجاح')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 600; // Define breakpoint for large screens

    return Scaffold(
      key: const Key('students_tab_view'),
      appBar: AppBar(
        title: const Text('لوحة تحكم الطلاب'),
        actions: const [], // No actions here, theme toggle is in dashboard
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      labelText: 'البحث بالاسم أو الرقم الأكاديمي',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12.0)),
                      ),
                    ),
                    onChanged: (value) => _filterStudents(),
                  ),
                ),
                const SizedBox(width: 12),
                Consumer<ClassProvider>(
                  builder: (context, classProvider, child) {
                    return DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedClassId,
                        hint: const Text('الفصل'),
                        items: [const DropdownMenuItem<String>(
                                value: null,
                                child: Text('جميع الفصول'),
                              ),
                              ...classProvider.classes.map((c) => DropdownMenuItem<String>(
                                value: c.classId,
                                child: Text(c.name),
                              )),
                             ].toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedClassId = newValue;
                            _filterStudents();
                          });
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: Consumer<StudentProvider>(
              builder: (context, studentProvider, child) {
                if (studentProvider.students.isEmpty) {
                  return const Center(child: Text('لا يوجد طلاب حالياً.'));
                }
                return isLargeScreen
                    ? _buildWebLayout(studentProvider.students)
                    : _buildMobileLayout(studentProvider.students);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddEditScreen(),
        tooltip: 'إضافة طالب جديد',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildMobileLayout(List<Student> students) {
    return ListView.builder(
      itemCount: students.length,
      itemBuilder: (context, index) {
        final student = students[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
          child: ListTile(
            leading: const CircleAvatar(child: Icon(Icons.person)), // Placeholder for student image
            title: Text(student.name),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('الرقم الأكاديمي: ${student.academicNumber ?? 'N/A'}'),
                Text('الصف: ${student.grade}'),
                if (student.classId != null)
                  Text('الفصل: ${Provider.of<ClassProvider>(context, listen: false).classes.firstWhere((c) => c.classId == student.classId, orElse: () => SchoolClass(name: 'غير معروف', classId: '')).name}'),
                Text('الحالة: ${student.status ? 'نشط' : 'غير نشط'}'),
              ],
            ),
            trailing: PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') {
                  _navigateToAddEditScreen(student);
                } else if (value == 'delete') {
                  _deleteStudent(student.id!); // Ensure id is not null
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Text('تعديل'),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Text('حذف'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWebLayout(List<Student> students) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: DataTable(
        columns: const [
          DataColumn(label: Text('الاسم')),
          DataColumn(label: Text('الرقم الأكاديمي')),
          DataColumn(label: Text('البريد الإلكتروني')),
          DataColumn(label: Text('الصف')),
          DataColumn(label: Text('الفصل')),
          DataColumn(label: Text('ولي الأمر')),
          DataColumn(label: Text('الحالة')),
          DataColumn(label: Text('الإجراءات')),
        ],
        rows: students.map((student) {
          final className = Provider.of<ClassProvider>(context, listen: false).classes.firstWhere(
            (c) => c.classId == student.classId, orElse: () => SchoolClass(name: 'غير معروف', classId: '')).name;

          return DataRow(
            cells: [
              DataCell(Text(student.name)),
              DataCell(Text(student.academicNumber ?? 'N/A')),
              DataCell(Text(student.email ?? 'N/A')),
              DataCell(Text(student.grade)),
              DataCell(Text(className)),
              DataCell(Text(student.parentName ?? 'N/A')),
              DataCell(Text(student.status ? 'نشط' : 'غير نشط')),
              DataCell(Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => _navigateToAddEditScreen(student),
                    tooltip: 'تعديل',
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _deleteStudent(student.id!),
                    tooltip: 'حذف',
                  ),
                ],
              )),
            ],
          );
        }).toList(),
      ),
    );
  }
}
