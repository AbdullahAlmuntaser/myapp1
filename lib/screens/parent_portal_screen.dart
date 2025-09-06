import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/local_auth_service.dart';
import '../database_helper.dart';
import '../student_model.dart';
import 'student_detail_for_parent_screen.dart'; // Import the student detail screen

class ParentPortalScreen extends StatefulWidget {
  const ParentPortalScreen({super.key});

  @override
  State<ParentPortalScreen> createState() => _ParentPortalScreenState();
}

class _ParentPortalScreenState extends State<ParentPortalScreen> {
  List<Student> _children = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchChildren();
  }

  Future<void> _fetchChildren() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final authService = Provider.of<LocalAuthService>(context, listen: false);
      final currentUser = authService.currentUser;

      if (currentUser != null && currentUser.role == 'parent' && currentUser.id != null) {
        final students = await DatabaseHelper().getStudentsByParentUserId(currentUser.id!);
        if (mounted) {
          setState(() {
            _children = students;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _errorMessage = 'ليس لديك صلاحية لعرض هذه الصفحة أو لم يتم تسجيل الدخول كولي أمر.';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'حدث خطأ أثناء جلب بيانات أبنائك: $e';
        });
      }
    }
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('بوابة ولي الأمر'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchChildren,
            tooltip: 'تحديث',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : _children.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.sentiment_dissatisfied, size: 80, color: Colors.grey),
                          SizedBox(height: 20),
                          Text(
                            'لا يوجد أبناء مرتبطون بهذا الحساب.',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 10),
                          Text(
                            'يرجى التواصل مع إدارة المدرسة لربط أبنائك بحسابك.',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(8.0),
                      itemCount: _children.length,
                      itemBuilder: (context, index) {
                        final student = _children[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          elevation: 3,
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => StudentDetailForParentScreen(
                                    student: student,
                                  ),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    student.name,
                                    style: Theme.of(context).textTheme.titleLarge,
                                  ),
                                  const SizedBox(height: 5),
                                  Text('الصف: ${student.grade} - الرقم الأكاديمي: ${student.academicNumber ?? 'N/A'}',
                                      style: Theme.of(context).textTheme.bodyMedium),
                                  // You can add more summary details here if needed
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}
