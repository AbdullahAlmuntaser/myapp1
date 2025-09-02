import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/class_provider.dart';
import '../../class_model.dart';
import '../add_edit_class_screen.dart';
import '../../providers/subject_provider.dart'; // Added import
import '../../subject_model.dart'; // Added import

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
        Provider.of<SubjectProvider>(context, listen: false).fetchSubjects(); // Fetch subjects
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
    Provider.of<ClassProvider>(
      context,
      listen: false,
    ).searchClasses(_searchController.text);
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
      try {
        await Provider.of<ClassProvider>(context, listen: false).deleteClass(id);
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(
          const SnackBar(
            content: Text('تم حذف الفصل بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(
          SnackBar(
            content: Text('فشل حذف الفصل: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Helper to get subject names from IDs
  String _getSubjectNames(List<String>? subjectIds, List<Subject> allSubjects) {
    if (subjectIds == null || subjectIds.isEmpty) {
      return 'لا توجد مواد';
    }
    final names = subjectIds.map((id) {
      final subject = allSubjects.firstWhere(
        (s) => s.subjectId == id,
        orElse: () => Subject(name: 'غير معروف', subjectId: ''),
      );
      return subject.name;
    }).toList();
    return names.join(', ');
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 600; // Define breakpoint for large screens

    return Scaffold(
      appBar: AppBar(title: const Text('لوحة تحكم الفصول')),
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
            child: Consumer2<ClassProvider, SubjectProvider>(
              builder: (context, classProvider, subjectProvider, child) {
                if (classProvider.classes.isEmpty) {
                  return const Center(child: Text('لا توجد فصول حالياً.'));
                }
                return isLargeScreen
                    ? _buildDataTable(classProvider.classes, subjectProvider.subjects)
                    : _buildListView(classProvider.classes, subjectProvider.subjects);
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

  Widget _buildListView(List<SchoolClass> classes, List<Subject> allSubjects) {
    return ListView.builder(
      itemCount: classes.length,
      itemBuilder: (context, index) {
        final schoolClass = classes[index];
        final subjectNames = _getSubjectNames(
          schoolClass.subjectIds,
          allSubjects,
        );
        return Card(
          margin: const EdgeInsets.symmetric(
            horizontal: 12.0,
            vertical: 6.0,
          ),
          child: ListTile(
            title: Text(schoolClass.name),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('معرف الفصل: ${schoolClass.classId}'),
                if (schoolClass.teacherId != null &&
                    schoolClass.teacherId!.isNotEmpty)
                  Text(
                    'معرف المعلم المسؤول: ${schoolClass.teacherId}',
                  ),
                if (schoolClass.capacity != null)
                  Text('السعة: ${schoolClass.capacity}'),
                if (schoolClass.yearTerm != null &&
                    schoolClass.yearTerm!.isNotEmpty)
                  Text(
                    'السنة/الفصل الدراسي: ${schoolClass.yearTerm}',
                  ),
                Text('المواد: $subjectNames'), // Display subject names
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () =>
                      _navigateToAddEditScreen(schoolClass),
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
  }

  Widget _buildDataTable(List<SchoolClass> classes, List<Subject> allSubjects) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: DataTable(
        columns: const [
          DataColumn(label: Text('اسم الفصل')),
          DataColumn(label: Text('معرف الفصل')),
          DataColumn(label: Text('المعلم المسؤول')),
          DataColumn(label: Text('السعة')),
          DataColumn(label: Text('السنة/الفصل الدراسي')),
          DataColumn(label: Text('المواد')),
          DataColumn(label: Text('الإجراءات')),
        ],
        rows: classes.map((schoolClass) {
          final subjectNames = _getSubjectNames(
            schoolClass.subjectIds,
            allSubjects,
          );
          return DataRow(
            cells: [
              DataCell(Text(schoolClass.name)),
              DataCell(Text(schoolClass.classId)),
              DataCell(Text(schoolClass.teacherId ?? 'N/A')),
              DataCell(Text(schoolClass.capacity?.toString() ?? 'N/A')),
              DataCell(Text(schoolClass.yearTerm ?? 'N/A')),
              DataCell(Text(subjectNames)),
              DataCell(
                Row(
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
            ],
          );
        }).toList(),
      ),
    );
  }
}
