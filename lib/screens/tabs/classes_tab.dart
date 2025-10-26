import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/class_provider.dart';
import '../../class_model.dart';
import '../add_edit_class_screen.dart';
import '../../providers/subject_provider.dart';
import '../../subject_model.dart';

class ClassesTab extends StatefulWidget {
  const ClassesTab({super.key});

  @override
  ClassesTabState createState() => ClassesTabState();
}

class ClassesTabState extends State<ClassesTab> {
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchData();
    _searchController.addListener(_filterClasses);
  }

  Future<void> _fetchData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });
    try {
      await Provider.of<ClassProvider>(context, listen: false).fetchClasses();
      if (!mounted) return; // Added mounted check
      await Provider.of<SubjectProvider>(context, listen: false).fetchSubjects();
      if (!mounted) return; // Added mounted check
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل تحميل البيانات: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterClasses() {
    if (_isLoading) return; // Prevent search when loading
    Provider.of<ClassProvider>(context, listen: false).searchClasses(_searchController.text);
  }

  void _navigateToAddEditScreen([SchoolClass? schoolClass]) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddEditClassScreen(schoolClass: schoolClass),
      ),
    );
    // Refresh data after returning from add/edit screen
    _fetchData();
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
      setState(() {
        _isLoading = true;
      });
      try {
        await Provider.of<ClassProvider>(context, listen: false).deleteClass(id);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم حذف الفصل بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
        _fetchData(); // Refresh data after deletion
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل حذف الفصل: $e'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

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
    final isLargeScreen = screenWidth > 700; // Adjusted breakpoint for large screens

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'إدارة الفصول',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.onPrimary,
              ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        centerTitle: true,
        elevation: 4,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'البحث باسم الفصل أو المعرف',
                hintText: 'ادخل اسم الفصل أو المعرف للبحث',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _filterClasses();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2.0,
                  ),
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withAlpha((0.2 * 255).round()),
              ),
              onChanged: (value) => _filterClasses(),
              enabled: !_isLoading,
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Consumer2<ClassProvider, SubjectProvider>(
                    builder: (context, classProvider, subjectProvider, child) {
                      final filteredClasses = classProvider.classes.where((c) {
                        final searchText = _searchController.text.toLowerCase();
                        return c.name.toLowerCase().contains(searchText) ||
                               c.classId.toLowerCase().contains(searchText);
                      }).toList();

                      if (filteredClasses.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.school_outlined,
                                size: 80,
                                color: Theme.of(context).colorScheme.onSurface.withAlpha((0.5 * 255).round()),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _searchController.text.isEmpty
                                    ? 'لا توجد فصول حالياً. ابدأ بإضافة فصل جديد!'
                                    : 'لا توجد فصول تطابق بحثك.',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      color: Theme.of(context).colorScheme.onSurface.withAlpha((0.7 * 255).round()),
                                    ),
                                textAlign: TextAlign.center,
                              ),
                              if (_searchController.text.isNotEmpty) ...[
                                const SizedBox(height: 16),
                                FilledButton.icon(
                                  onPressed: () {
                                    _searchController.clear();
                                    _filterClasses();
                                  },
                                  icon: const Icon(Icons.clear),
                                  label: const Text('مسح البحث'),
                                ),
                              ],
                            ],
                          ),
                        );
                      }
                      return isLargeScreen
                          ? _buildDataTable(filteredClasses, subjectProvider.subjects)
                          : _buildListView(filteredClasses, subjectProvider.subjects);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isLoading ? null : () => _navigateToAddEditScreen(),
        tooltip: 'إضافة فصل جديد',
        icon: const Icon(Icons.add),
        label: const Text('إضافة فصل'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
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
            horizontal: 16.0,
            vertical: 8.0,
          ),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(12.0),
            onTap: _isLoading ? null : () => _navigateToAddEditScreen(schoolClass),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    schoolClass.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text('معرف الفصل: ${schoolClass.classId}', style: Theme.of(context).textTheme.bodyMedium),
                  if (schoolClass.teacherId != null && schoolClass.teacherId!.isNotEmpty)
                    Text(
                      'معرف المعلم المسؤول: ${schoolClass.teacherId}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  if (schoolClass.capacity != null)
                    Text(
                      'السعة: ${schoolClass.capacity}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  if (schoolClass.yearTerm != null && schoolClass.yearTerm!.isNotEmpty)
                    Text(
                      'السنة/الفصل الدراسي: ${schoolClass.yearTerm}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  Text(
                    'المواد: $subjectNames',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'edit') {
                          _navigateToAddEditScreen(schoolClass);
                        } else if (value == 'delete') {
                          _deleteClass(schoolClass.id!);
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
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDataTable(List<SchoolClass> classes, List<Subject> allSubjects) {
    return Card(
      margin: const EdgeInsets.all(16.0),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingTextStyle: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
          dataTextStyle: Theme.of(context).textTheme.bodyMedium,
          columnSpacing: 24,
          horizontalMargin: 24,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.0),
          ),
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
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        _navigateToAddEditScreen(schoolClass);
                      } else if (value == 'delete') {
                        _deleteClass(schoolClass.id!);
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
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
