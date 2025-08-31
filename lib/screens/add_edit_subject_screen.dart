import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/subject_provider.dart';
import '../../subject_model.dart';

class AddEditSubjectScreen extends StatefulWidget {
  final Subject? subject;

  const AddEditSubjectScreen({super.key, this.subject});

  @override
  AddEditSubjectScreenState createState() => AddEditSubjectScreenState();
}

class AddEditSubjectScreenState extends State<AddEditSubjectScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _subjectIdController;
  late TextEditingController _descriptionController;
  late TextEditingController _teacherIdController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.subject?.name ?? '');
    _subjectIdController = TextEditingController(text: widget.subject?.subjectId ?? '');
    _descriptionController = TextEditingController(text: widget.subject?.description ?? '');
    _teacherIdController = TextEditingController(text: widget.subject?.teacherId ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _subjectIdController.dispose();
    _descriptionController.dispose();
    _teacherIdController.dispose();
    super.dispose();
  }

  Future<void> _saveSubject() async {
    if (_formKey.currentState!.validate()) {
      final subject = Subject(
        id: widget.subject?.id,
        name: _nameController.text,
        subjectId: _subjectIdController.text,
        description: _descriptionController.text.isNotEmpty ? _descriptionController.text : null,
        teacherId: _teacherIdController.text.isNotEmpty ? _teacherIdController.text : null,
      );

      final provider = Provider.of<SubjectProvider>(context, listen: false);
      final message = widget.subject == null
          ? 'Subject added successfully'
          : 'Subject updated successfully';

      try {
        if (widget.subject == null) {
          await provider.addSubject(subject);
        } else {
          await provider.updateSubject(subject);
        }
        if (!mounted) return;
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to save subject: $e')),
          );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.subject == null ? 'Add Subject' : 'Edit Subject'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Subject Name', border: OutlineInputBorder()),
                  validator: (value) => value!.isEmpty ? 'Please enter a subject name' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _subjectIdController,
                  decoration: const InputDecoration(labelText: 'Subject ID (Unique)', border: OutlineInputBorder()),
                  validator: (value) => value!.isEmpty ? 'Please enter a unique subject ID' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: 'Description (Optional)', border: OutlineInputBorder()),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _teacherIdController,
                  decoration: const InputDecoration(labelText: 'Responsible Teacher ID (Optional)', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _saveSubject,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
                  ),
                  child: const Text('Save Subject'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
