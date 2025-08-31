
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/teacher_provider.dart';
import '../../teacher_model.dart';

class AddEditTeacherScreen extends StatefulWidget {
  final Teacher? teacher;

  const AddEditTeacherScreen({super.key, this.teacher});

  @override
  AddEditTeacherScreenState createState() => AddEditTeacherScreenState();
}

class AddEditTeacherScreenState extends State<AddEditTeacherScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _subjectController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _qualificationTypeController;
  late TextEditingController _responsibleClassIdController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.teacher?.name ?? '');
    _subjectController = TextEditingController(text: widget.teacher?.subject ?? '');
    _phoneController = TextEditingController(text: widget.teacher?.phone ?? '');
    _emailController = TextEditingController(text: widget.teacher?.email ?? '');
    _passwordController = TextEditingController(text: widget.teacher?.password ?? '');
    _qualificationTypeController = TextEditingController(text: widget.teacher?.qualificationType ?? '');
    _responsibleClassIdController = TextEditingController(text: widget.teacher?.responsibleClassId ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _subjectController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _qualificationTypeController.dispose();
    _responsibleClassIdController.dispose();
    super.dispose();
  }

  Future<void> _saveTeacher() async {
    if (_formKey.currentState!.validate()) {
      final teacher = Teacher(
        id: widget.teacher?.id,
        name: _nameController.text,
        subject: _subjectController.text,
        phone: _phoneController.text,
        email: _emailController.text.isNotEmpty ? _emailController.text : null,
        password: _passwordController.text.isNotEmpty ? _passwordController.text : null,
        qualificationType: _qualificationTypeController.text.isNotEmpty ? _qualificationTypeController.text : null,
        responsibleClassId: _responsibleClassIdController.text.isNotEmpty ? _responsibleClassIdController.text : null,
      );

      final provider = Provider.of<TeacherProvider>(context, listen: false);
      try {
        if (widget.teacher == null) {
          await provider.addTeacher(teacher);
        } else {
          await provider.updateTeacher(teacher);
        }
        if (!mounted) return; // Added mounted check
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.teacher == null ? 'Teacher added successfully' : 'Teacher updated successfully')),
        );
      } catch (e) {
        if (!mounted) return; // Added mounted check
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save teacher: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.teacher == null ? 'Add Teacher' : 'Edit Teacher'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Name', border: OutlineInputBorder()),
                  validator: (value) => value!.isEmpty ? 'Please enter a name' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _subjectController,
                  decoration: const InputDecoration(labelText: 'Subject/Specialization', border: OutlineInputBorder()),
                  validator: (value) => value!.isEmpty ? 'Please enter a subject/specialization' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(labelText: 'Phone', border: OutlineInputBorder()),
                  keyboardType: TextInputType.phone,
                  validator: (value) => value!.isEmpty ? 'Please enter a phone number' : null,
                ),
                const SizedBox(height: 16),
                // New fields for Teacher
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an email';
                    }
                    if (!RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(value)) {
                      return 'Please enter a valid email address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder()),
                  obscureText: true,
                  validator: (value) => value!.isEmpty ? 'Please enter a password' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _qualificationTypeController,
                  decoration: const InputDecoration(labelText: 'Qualification Type', border: OutlineInputBorder()),
                  validator: (value) => value!.isEmpty ? 'Please enter a qualification type' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _responsibleClassIdController,
                  decoration: const InputDecoration(labelText: 'Responsible Class ID', border: OutlineInputBorder()),
                  validator: (value) => value!.isEmpty ? 'Please enter the responsible class ID' : null,
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _saveTeacher,
                  child: const Text('Save'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
