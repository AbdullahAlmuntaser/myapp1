import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/subject_provider.dart';
import '../../providers/teacher_provider.dart';
import '../../teacher_model.dart';
import '../add_edit_teacher_screen.dart';

class TeachersTab extends StatefulWidget {
  const TeachersTab({super.key});

  @override
  _TeachersTabState createState() => _TeachersTabState();
}

class _TeachersTabState extends State<TeachersTab> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedSubject;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    // Load initial data
    Provider.of<TeacherProvider>(context, listen: false).fetchTeachers();
    Provider.of<SubjectProvider>(context, listen: false).fetchSubjects();
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    Provider.of<TeacherProvider>(context, listen: false)
        .searchTeachers(_searchController.text, subject: _selectedSubject);
  }

  void _onFilterChanged(String? subject) {
    setState(() {
      _selectedSubject = subject;
    });
    Provider.of<TeacherProvider>(context, listen: false)
        .searchTeachers(_searchController.text, subject: _selectedSubject);
  }

  @override
  Widget build(BuildContext context) {
    final teacherProvider = Provider.of<TeacherProvider>(context);
    final subjectProvider = Provider.of<SubjectProvider>(context);
    final isLargeScreen = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      labelText: 'Search Teachers',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                DropdownButton<String>(
                  value: _selectedSubject,
                  hint: const Text('Filter by Subject'),
                  onChanged: (value) => _onFilterChanged(value),
                  items: [
                    const DropdownMenuItem<String>(
                      value: null,
                      child: Text('All Subjects'),
                    ),
                    ...subjectProvider.subjects.map((subject) {
                      return DropdownMenuItem<String>(
                        value: subject.name,
                        child: Text(subject.name),
                      );
                    }).toList(),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: teacherProvider.teachers.isEmpty
                ? const Center(child: Text('No teachers found.'))
                : isLargeScreen
                    ? _buildDataTable(teacherProvider.teachers)
                    : _buildListView(teacherProvider.teachers),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddEditScreen(null),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _navigateToAddEditScreen(Teacher? teacher) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddEditTeacherScreen(teacher: teacher),
      ),
    );
  }

  Widget _buildListView(List<Teacher> teachers) {
    return ListView.builder(
      itemCount: teachers.length,
      itemBuilder: (context, index) {
        final teacher = teachers[index];
        return Card(
          margin: const EdgeInsets.all(8.0),
          child: ListTile(
            leading: CircleAvatar(
              child: Text(teacher.name[0]),
            ),
            title: Text(teacher.name),
            subtitle: Text(teacher.subject),
            trailing: PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') {
                  _navigateToAddEditScreen(teacher);
                } else if (value == 'delete') {
                  _deleteTeacher(teacher);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'edit', child: Text('Edit')),
                const PopupMenuItem(value: 'delete', child: Text('Delete')),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDataTable(List<Teacher> teachers) {
    return DataTable(
      columns: const [
        DataColumn(label: Text('Name')),
        DataColumn(label: Text('Subjects')),
        DataColumn(label: Text('Email')),
        DataColumn(label: Text('Phone')),
        DataColumn(label: Text('Actions')),
      ],
      rows: teachers.map((teacher) {
        return DataRow(
          cells: [
            DataCell(Text(teacher.name)),
            DataCell(Text(teacher.subject)),
            DataCell(Text(teacher.email ?? '')),
            DataCell(Text(teacher.phone)),
            DataCell(
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') {
                    _navigateToAddEditScreen(teacher);
                  } else if (value == 'delete') {
                    _deleteTeacher(teacher);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'edit', child: Text('Edit')),
                  const PopupMenuItem(value: 'delete', child: Text('Delete')),
                ],
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  void _deleteTeacher(Teacher teacher) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Teacher'),
        content: const Text('Are you sure you want to delete this teacher?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Provider.of<TeacherProvider>(context, listen: false)
                  .deleteTeacher(teacher.id!);
              Navigator.of(context).pop();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
