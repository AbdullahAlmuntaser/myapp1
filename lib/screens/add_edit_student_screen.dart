import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/student_provider.dart';
import '../../student_model.dart';
import '../../providers/class_provider.dart'; // Added import for ClassProvider
import '../../class_model.dart'; // Added import for SchoolClass

class AddEditStudentScreen extends StatefulWidget {
  final Student? student;

  const AddEditStudentScreen({super.key, this.student});

  @override
  AddEditStudentScreenState createState() => AddEditStudentScreenState();
}

class AddEditStudentScreenState extends State<AddEditStudentScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _dobController;
  late TextEditingController _phoneController;
  late TextEditingController _gradeController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _academicNumberController;
  late TextEditingController _sectionController;
  late TextEditingController _parentNameController;
  late TextEditingController _parentPhoneController;
  late TextEditingController _addressController;

  String? _selectedClassId; // For DropdownButton
  bool _status = true; // Default student status to active

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.student?.name ?? '');
    _dobController = TextEditingController(text: widget.student?.dob ?? '');
    _phoneController = TextEditingController(text: widget.student?.phone ?? '');
    _gradeController = TextEditingController(text: widget.student?.grade ?? '');
    _emailController = TextEditingController(text: widget.student?.email ?? '');
    _passwordController = TextEditingController(
      text: widget.student?.password ?? '',
    );
    // New controllers initialization
    _academicNumberController = TextEditingController(
      text: widget.student?.academicNumber ?? '',
    );
    _sectionController = TextEditingController(
      text: widget.student?.section ?? '',
    );
    _parentNameController = TextEditingController(
      text: widget.student?.parentName ?? '',
    );
    _parentPhoneController = TextEditingController(
      text: widget.student?.parentPhone ?? '',
    );
    _addressController = TextEditingController(
      text: widget.student?.address ?? '',
    );

    _selectedClassId = widget.student?.classId; // Initialize selected class ID
    _status = widget.student?.status ?? true; // Initialize status

    // Fetch classes when the screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ClassProvider>(context, listen: false).fetchClasses();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dobController.dispose();
    _phoneController.dispose();
    _gradeController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _academicNumberController.dispose();
    _sectionController.dispose();
    _parentNameController.dispose();
    _parentPhoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: Theme.of(context).primaryColor,
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
            ),
            buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      if (!mounted) return;
      setState(() {
        _dobController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _saveStudent() async {
    if (_formKey.currentState!.validate()) {
      final student = Student(
        id: widget.student?.id,
        name: _nameController.text,
        dob: _dobController.text,
        phone: _phoneController.text,
        grade: _gradeController.text,
        email: _emailController.text.isNotEmpty ? _emailController.text : null,
        password: _passwordController.text.isNotEmpty
            ? _passwordController.text
            : null,
        classId: _selectedClassId, // Use selected class ID
        academicNumber: _academicNumberController.text.isNotEmpty
            ? _academicNumberController.text
            : null,
        section: _sectionController.text.isNotEmpty
            ? _sectionController.text
            : null,
        parentName: _parentNameController.text.isNotEmpty
            ? _parentNameController.text
            : null,
        parentPhone: _parentPhoneController.text.isNotEmpty
            ? _parentPhoneController.text
            : null,
        address: _addressController.text.isNotEmpty
            ? _addressController.text
            : null,
        status: _status,
      );

      final provider = Provider.of<StudentProvider>(context, listen: false);
      String message;

      try {
        if (widget.student == null) {
          await provider.addStudent(student);
          message = 'تم إضافة الطالب بنجاح';
        } else {
          await provider.updateStudent(student);
          message = 'تم تحديث الطالب بنجاح';
        }
        if (!mounted) return;
        Navigator.of(context).pop();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل حفظ الطالب: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.student == null ? 'إضافة طالب' : 'تعديل طالب'),
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
                    labelText: 'الاسم الكامل',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? 'الرجاء إدخال الاسم' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _academicNumberController,
                  decoration: const InputDecoration(
                    labelText: 'الرقم الأكاديمي',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) =>
                      value!.isEmpty ? 'الرجاء إدخال الرقم الأكاديمي' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _dobController,
                  decoration: const InputDecoration(
                    labelText: 'تاريخ الميلاد',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  readOnly: true,
                  onTap: _selectDate,
                  validator: (value) =>
                      value!.isEmpty ? 'الرجاء اختيار تاريخ الميلاد' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    labelText: 'رقم الهاتف',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) =>
                      value!.isEmpty ? 'الرجاء إدخال رقم الهاتف' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _gradeController,
                  decoration: const InputDecoration(
                    labelText: 'الدرجة/الصف',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? 'الرجاء إدخال الدرجة/الصف' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'البريد الإلكتروني',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء إدخال البريد الإلكتروني';
                    }
                    if (!RegExp(
                      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
                    ).hasMatch(value)) {
                      return 'الرجاء إدخال عنوان بريد إلكتروني صحيح';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'كلمة المرور',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  validator: (value) =>
                      value!.isEmpty ? 'الرجاء إدخال كلمة المرور' : null,
                ),
                const SizedBox(height: 16),
                // Dropdown for Class ID
                Consumer<ClassProvider>(
                  builder: (context, classProvider, child) {
                    return DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'الفصل',
                        border: OutlineInputBorder(),
                      ),
                      value: _selectedClassId,
                      hint: const Text('اختر فصلاً'),
                      items: classProvider.classes.map((SchoolClass classItem) {
                        return DropdownMenuItem<String>(
                          value: classItem.classId,
                          child: Text(classItem.name),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedClassId = newValue;
                        });
                      },
                      validator: (value) => value == null || value.isEmpty
                          ? 'الرجاء اختيار فصل'
                          : null,
                    );
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _sectionController,
                  decoration: const InputDecoration(
                    labelText: 'الشعبة (اختياري)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _parentNameController,
                  decoration: const InputDecoration(
                    labelText: 'اسم ولي الأمر (اختياري)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _parentPhoneController,
                  decoration: const InputDecoration(
                    labelText: 'هاتف ولي الأمر (اختياري)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _addressController,
                  decoration: const InputDecoration(
                    labelText: 'العنوان (اختياري)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('حالة الطالب'),
                  subtitle: Text(_status ? 'نشط' : 'غير نشط'),
                  value: _status,
                  onChanged: (bool value) {
                    setState(() {
                      _status = value;
                    });
                  },
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _saveStudent,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  child: const Text('حفظ الطالب'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
