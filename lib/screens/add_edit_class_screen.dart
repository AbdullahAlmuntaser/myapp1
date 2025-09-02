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
    _nameController = TextEditingController(
      text: widget.schoolClass?.name ?? '',
    );
    _classIdController = TextEditingController(
      text: widget.schoolClass?.classId ?? '',
    );
    _teacherIdController = TextEditingController(
      text: widget.schoolClass?.teacherId ?? '',
    );
    _capacityController = TextEditingController(
      text: widget.schoolClass?.capacity?.toString() ?? '',
    );
    _yearTermController = TextEditingController(
      text: widget.schoolClass?.yearTerm ?? '',
    );
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
        teacherId: _teacherIdController.text.isNotEmpty
            ? _teacherIdController.text
            : null,
        capacity: int.tryParse(_capacityController.text),
        yearTerm: _yearTermController.text.isNotEmpty
            ? _yearTermController.text
            : null,
      );

      final provider = Provider.of<ClassProvider>(context, listen: false);
      final message = widget.schoolClass == null
          ? 'تم إضافة الصف بنجاح'
          : 'تم تحديث الصف بنجاح';

      try {
        if (widget.schoolClass == null) {
          await provider.addClass(schoolClass);
        } else {
          await provider.updateClass(schoolClass);
        }
        if (!mounted) return;
        Navigator.of(context).pop();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('فشل حفظ الصف: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.schoolClass == null ? 'إضافة صف' : 'تعديل صف'),
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
                  decoration: const InputDecoration(
                    labelText: 'اسم الصف',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? 'الرجاء إدخال اسم الصف' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _classIdController,
                  decoration: const InputDecoration(
                    labelText: 'معرف الصف (فريد)',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? 'الرجاء إدخال معرف صف فريد' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _teacherIdController,
                  decoration: const InputDecoration(
                    labelText: 'معرف المعلم المسؤول (اختياري)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _capacityController,
                  decoration: const InputDecoration(
                    labelText: 'السعة (عدد الطلاب) (اختياري)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) return null;
                    if (int.tryParse(value) == null) {
                      return 'الرجاء إدخال رقم صحيح';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _yearTermController,
                  decoration: const InputDecoration(
                    labelText: 'السنة/الفصل الدراسي (اختياري)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _saveClass,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  child: const Text('حفظ الصف'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
