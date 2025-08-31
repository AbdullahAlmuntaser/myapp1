import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/class_provider.dart';
import '../../class_model.dart';

class AddEditClassScreen extends StatefulWidget {
  final SchoolClass? schoolClass;

  const AddEditClassScreen({super.key, this.schoolClass});

  @override
  AddEditClassScreenState createState() => AddEditClassScreenState();
}

class AddEditClassScreenState extends State<AddEditClassScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _classIdController;
  late TextEditingController _teacherIdController;
  late TextEditingController _capacityController;
  late TextEditingController _yearTermController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.schoolClass?.name ?? '');
    _classIdController = TextEditingController(text: widget.schoolClass?.classId ?? '');
    _teacherIdController = TextEditingController(text: widget.schoolClass?.teacherId ?? '');
    _capacityController = TextEditingController(text: widget.schoolClass?.capacity?.toString() ?? '');
    _yearTermController = TextEditingController(text: widget.schoolClass?.yearTerm ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _classIdController.dispose();
    _teacherIdController.dispose();
    _capacityController.dispose();
    _yearTermController.dispose();
    super.dispose();
  }

  Future<void> _saveClass() async {
    if (_formKey.currentState!.validate()) {
      final schoolClass = SchoolClass(
        id: widget.schoolClass?.id,
        name: _nameController.text,
        classId: _classIdController.text,
        teacherId: _teacherIdController.text.isNotEmpty ? _teacherIdController.text : null,
        capacity: int.tryParse(_capacityController.text),
        yearTerm: _yearTermController.text.isNotEmpty ? _yearTermController.text : null,
      );

      final provider = Provider.of<ClassProvider>(context, listen: false);
      final message = widget.schoolClass == null
          ? 'Class added successfully'
          : 'Class updated successfully';

      try {
        if (widget.schoolClass == null) {
          await provider.addClass(schoolClass);
        } else {
          await provider.updateClass(schoolClass);
        }
        if (!mounted) return;
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to save class: $e')),
          );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.schoolClass == null ? 'Add Class' : 'Edit Class'),
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
                  decoration: const InputDecoration(labelText: 'Class Name', border: OutlineInputBorder()),
                  validator: (value) => value!.isEmpty ? 'Please enter a class name' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _classIdController,
                  decoration: const InputDecoration(labelText: 'Class ID (Unique)', border: OutlineInputBorder()),
                  validator: (value) => value!.isEmpty ? 'Please enter a unique class ID' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _teacherIdController,
                  decoration: const InputDecoration(labelText: 'Responsible Teacher ID (Optional)', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _capacityController,
                  decoration: const InputDecoration(labelText: 'Capacity (Number of Students) (Optional)', border: OutlineInputBorder()),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) return null;
                    if (int.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _yearTermController,
                  decoration: const InputDecoration(labelText: 'Academic Year/Term (Optional)', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _saveClass,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
                  ),
                  child: const Text('Save Class'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
