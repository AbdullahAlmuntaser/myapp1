
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/teacher_provider.dart';
import '../../teacher_model.dart';
import '../add_edit_teacher_screen.dart';

class TeachersTab extends StatefulWidget {
  const TeachersTab({super.key});

  @override
  TeachersTabState createState() => TeachersTabState();
}

class TeachersTabState extends State<TeachersTab> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Fetch teachers after the first frame is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Provider.of<TeacherProvider>(context, listen: false).fetchTeachers();
      }
    });
    _searchController.addListener(_filterTeachers);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterTeachers() {
    Provider.of<TeacherProvider>(context, listen: false)
        .searchTeachers(_searchController.text);
  }

  void _navigateToAddEditScreen([Teacher? teacher]) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddEditTeacherScreen(teacher: teacher),
      ),
    );
  }

  Future<void> _deleteTeacher(int id) async {
    final bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text('هل أنت متأكد أنك تريد حذف هذا المعلم؟'),
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
      await Provider.of<TeacherProvider>(context, listen: false).deleteTeacher(id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم حذف المعلم بنجاح')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة تحكم المعلمين'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'البحث بالاسم',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12.0)),
                ),
              ),
            ),
          ),
          Expanded(
            child: Consumer<TeacherProvider>(
              builder: (context, teacherProvider, child) {
                if (teacherProvider.teachers.isEmpty) {
                  return const Center(child: Text('لا يوجد معلمون حالياً.'));
                }
                return ListView.builder(
                  itemCount: teacherProvider.teachers.length,
                  itemBuilder: (context, index) {
                    final teacher = teacherProvider.teachers[index];
                    return Card(
                      child: ListTile(
                        title: Text(teacher.name),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('المادة: ${teacher.subject}'),
                            if (teacher.email != null && teacher.email!.isNotEmpty)
                              Text('البريد الإلكتروني: ${teacher.email}'),
                            if (teacher.qualificationType != null && teacher.qualificationType!.isNotEmpty)
                              Text('المؤهل: ${teacher.qualificationType}'),
                            if (teacher.responsibleClassId != null && teacher.responsibleClassId!.isNotEmpty)
                              Text('مسؤول عن الفصل: ${teacher.responsibleClassId}'),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _navigateToAddEditScreen(teacher),
                              tooltip: 'تعديل',
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => _deleteTeacher(teacher.id!),
                              tooltip: 'حذف',
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddEditScreen(),
        tooltip: 'إضافة معلم جديد',
        child: const Icon(Icons.add),
      ),
    );
  }
}
