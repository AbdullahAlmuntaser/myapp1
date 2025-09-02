import 'package:flutter/material.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:provider/provider.dart';
import '../providers/subject_provider.dart';
import '../providers/teacher_provider.dart';
import '../teacher_model.dart';
import '../subject_model.dart';

class AddEditTeacherScreen extends StatefulWidget {
  final Teacher? teacher;

  const AddEditTeacherScreen({super.key, this.teacher});

  @override
  _AddEditTeacherScreenState createState() => _AddEditTeacherScreenState();
}

class _AddEditTeacherScreenState extends State<AddEditTeacherScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _phoneController;
  late TextEditingController _qualificationController;
  List<Subject> _selectedSubjects = [];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.teacher?.name ?? '');
    _emailController = TextEditingController(text: widget.teacher?.email ?? '');
    _passwordController = TextEditingController();
    _phoneController = TextEditingController(text: widget.teacher?.phone ?? '');
    _qualificationController = TextEditingController(text: widget.teacher?.qualificationType ?? '');

    if (widget.teacher != null) {
      // Fetch subjects for the existing teacher
      final subjectProvider = Provider.of<SubjectProvider>(context, listen: false);
      final teacherSubjects = widget.teacher!.subject.split(',');
      _selectedSubjects = subjectProvider.subjects
          .where((subject) => teacherSubjects.contains(subject.name))
          .toList();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _qualificationController.dispose();
    super.dispose();
  }

  void _saveTeacher() {
    if (_formKey.currentState!.validate()) {
      final teacherProvider = Provider.of<TeacherProvider>(context, listen: false);
      final subjects = _selectedSubjects.map((s) => s.name).join(',');

      final newTeacher = Teacher(
        id: widget.teacher?.id,
        name: _nameController.text,
        email: _emailController.text,
        password: _passwordController.text,
        phone: _phoneController.text,
        qualificationType: _qualificationController.text,
        subject: subjects,
        responsibleClassId: widget.teacher?.responsibleClassId,
      );

      if (widget.teacher == null) {
        teacherProvider.addTeacher(newTeacher);
      } else {
        teacherProvider.updateTeacher(newTeacher);
      }
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final subjectProvider = Provider.of<SubjectProvider>(context);
    final allSubjects = subjectProvider.subjects;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.teacher == null ? 'Add Teacher' : 'Edit Teacher'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Full Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the teacher\'s name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an email';
                  }
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) {
                  if (widget.teacher == null && (value == null || value.isEmpty)) {
                    return 'Please enter a password';
                  }
                  return null;
                },
              ),
               TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Phone'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a phone number';
                  }
                  return null;
                },
              ),
               TextFormField(
                controller: _qualificationController,
                decoration: const InputDecoration(labelText: 'Qualification'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a qualification';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              MultiSelectDialogField<Subject>(
                items: allSubjects.map((s) => MultiSelectItem<Subject>(s, s.name)).toList(),
                title: const Text('Subjects'),
                selectedColor: Theme.of(context).primaryColor,
                onConfirm: (values) {
                  setState(() {
                    _selectedSubjects = values;
                  });
                },
                initialValue: _selectedSubjects,
                chipDisplay: MultiSelectChipDisplay(
                  items: _selectedSubjects.map((s) => MultiSelectItem<Subject>(s, s.name)).toList(),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveTeacher,
                child: const Text('Save Teacher'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
