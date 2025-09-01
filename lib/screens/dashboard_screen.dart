
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/student_provider.dart';
import '../providers/teacher_provider.dart';
import '../providers/class_provider.dart';
import '../providers/subject_provider.dart';
import 'tabs/students_tab.dart';
import 'tabs/teachers_tab.dart';
import 'tabs/classes_tab.dart';
import 'tabs/subjects_tab.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  DashboardScreenState createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    StudentsTab(),
    TeachersTab(),
    ClassesTab(),
    SubjectsTab(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Provider.of<StudentProvider>(context, listen: false).fetchStudents();
        Provider.of<TeacherProvider>(context, listen: false).fetchTeachers();
        Provider.of<ClassProvider>(context, listen: false).fetchClasses();
        Provider.of<SubjectProvider>(context, listen: false).fetchSubjects();
      }
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.school),
            label: 'الطلاب',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'المعلمون',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.class_),
            label: 'الفصول',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'المواد',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
      ),
    );
  }
}
