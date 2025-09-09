import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/student_provider.dart';
import '../../student_model.dart';
import '../../providers/class_provider.dart';
import '../../class_model.dart';
import '../../database_helper.dart'; // Import DatabaseHelper
import '../../user_model.dart'; // Import User model

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

  String? _selectedClassId;
  bool _status = true;
  List<User> _parents = []; // List to hold parent users
  int? _selectedParentUserId; // To store the selected parent's user ID

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

    _selectedClassId = widget.student?.classId;
    _status = widget.student?.status ?? true;
    _selectedParentUserId = widget.student?.parentUserId; // Initialize selected parent

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ClassProvider>(context, listen: false).fetchClasses();
      _fetchParents(); // Fetch parents when the screen initializes
    });
  }

  Future<void> _fetchParents() async {
    final dbHelper = DatabaseHelper();
    // Assuming you have a method to get users by role in DatabaseHelper
    // For now, let's fetch all users and filter by role 'parent'
    final allUsers = await dbHelper.database.then((db) async {
      final List<Map<String, dynamic>> maps = await db.query('users');
      return List.generate(maps.length, (i) {
        return User.fromMap(maps[i]);
      });
    });

    if (mounted) {
      setState(() {
        _parents = allUsers.where((user) => user.role == 'parent').toList();
        // If no parent is selected for an existing student, and there are parents, try to default.
        if (widget.student?.parentUserId == null && _parents.isNotEmpty && _selectedParentUserId == null) {
          // Optionally default to the first parent or keep null
          // _selectedParentUserId = _parents.first.id;
        }
      });
    }
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
        classId: _selectedClassId,
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
        parentUserId: _selectedParentUserId, // Save the selected parent's user ID
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
                // Consider removing password field for student if authentication is separate
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'كلمة المرور (يمكن تركها فارغة لتغيير لاحقًا)',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
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
                      initialValue: _selectedClassId, // Changed 'value' to 'initialValue'
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
                  },\n                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _sectionController,
                  decoration: const InputDecoration(
                    labelText: 'الشعبة (اختياري)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                // Dropdown for Parent User
                DropdownButtonFormField<int>(
                  decoration: const InputDecoration(
                    labelText: 'ربط بولي أمر (اختياري)',
                    border: OutlineInputBorder(),
                  ),
                  initialValue: _selectedParentUserId, // Changed 'value' to 'initialValue'
                  hint: const Text('اختر ولي أمر'),
                  items: _parents.map((User parentUser) {
                    return DropdownMenuItem<int>(
                      value: parentUser.id,
                      child: Text('${parentUser.username} (${parentUser.role})'), // Fixed interpolation
                    );
                  }).toList(),
                  onChanged: (int? newValue) {
                    setState(() {
                      _selectedParentUserId = newValue;
                    });
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _parentNameController,
                  decoration: const InputDecoration(
                    labelText: 'اسم ولي الأمر (يملأ تلقائياً عند اختيار ولي أمر)',
                    border: OutlineInputBorder(),
                  ),
                  readOnly: true, // Make it read-only as it will be filled by selected parent
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _parentPhoneController,
                  decoration: const InputDecoration(
                    labelText: 'هاتف ولي الأمر (يملأ تلقائياً عند اختيار ولي أمر)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                  readOnly: true, // Make it read-only
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
