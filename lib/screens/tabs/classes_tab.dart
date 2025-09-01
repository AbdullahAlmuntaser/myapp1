import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/class_provider.dart';
import '../../class_model.dart';
import '../add_edit_class_screen.dart';

class ClassesTab extends StatefulWidget {
  const ClassesTab({super.key});

  @override
  ClassesTabState createState() => ClassesTabState();
}

class ClassesTabState extends State<ClassesTab> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Provider.of<ClassProvider>(context, listen: false).fetchClasses();
      }
    });
    _searchController.addListener(_filterClasses);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterClasses() {
    Provider.of<ClassProvider>(context, listen: false)
        .searchClasses(_searchController.text);
  }

  void _navigateToAddEditScreen([SchoolClass? schoolClass]) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddEditClassScreen(schoolClass: schoolClass),
      ),
    );
  }

  Future<void> _deleteClass(int id) async {
    final bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text('هل أنت متأكد أنك تريد حذف هذا الفصل؟'),
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
      await Provider.of<ClassProvider>(context, listen: false).deleteClass(id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم حذف الفصل بنجاح')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة تحكم الفصول'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'البحث باسم الفصل أو المعرف',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12.0)),
                ),
              ),
            ),
          ),
          Expanded(
            child: Consumer<ClassProvider>(
              builder: (context, classProvider, child) {
                if (classProvider.classes.isEmpty) {
                  return const Center(child: Text('لا توجد فصول حالياً.'));
                }
                return ListView.builder(
                  itemCount: classProvider.classes.length,
                  itemBuilder: (context, index) {
                    final schoolClass = classProvider.classes[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                      child: ListTile(
                        title: Text(schoolClass.name),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('معرف الفصل: ${schoolClass.classId}'),
                            if (schoolClass.teacherId != null && schoolClass.teacherId!.isNotEmpty)
                              Text('معرف المعلم المسؤول: ${schoolClass.teacherId}'),
                            if (schoolClass.capacity != null)
                              Text('السعة: ${schoolClass.capacity}'),
                            if (schoolClass.yearTerm != null && schoolClass.yearTerm!.isNotEmpty)
                              Text('السنة/الفصل الدراسي: ${schoolClass.yearTerm}'),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _navigateToAddEditScreen(schoolClass),
                              tooltip: 'تعديل',
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => _deleteClass(schoolClass.id!),
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
        tooltip: 'إضافة فصل جديد',
        child: const Icon(Icons.add),
      ),
    );
  }
}
