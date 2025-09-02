import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/student_provider.dart';
import '../../providers/teacher_provider.dart';
import '../../providers/class_provider.dart';
import '../../providers/subject_provider.dart';
import '../providers/theme_provider.dart'; // Import ThemeProvider
import 'tabs/students_tab.dart';
import 'tabs/teachers_tab.dart';
import 'tabs/classes_tab.dart';
import 'tabs/subjects_tab.dart';
import 'tabs/settings_tab.dart';
import 'tabs/reports_tab.dart';
import 'grades_screen.dart'; // Import GradesScreen

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
    GradesScreen(), // Add GradesScreen
    SettingsTab(),
    ReportsTab(),
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
    // Determine if current theme is dark mode for the icon
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'لوحة التحكم الرئيسية',
        ), // Centralized title for the dashboard
        actions: [
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return IconButton(
                icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
                onPressed: () {
                  themeProvider.toggleTheme(!isDarkMode);
                },
                tooltip: 'تبديل الوضع', // Tooltip for accessibility
              );
            },
          ),
        ],
      ),
      body: Center(child: _widgetOptions.elementAt(_selectedIndex)),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.school), label: 'الطلاب'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'المعلمون'),
          BottomNavigationBarItem(icon: Icon(Icons.class_), label: 'الفصول'),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'المواد'),
          BottomNavigationBarItem(icon: Icon(Icons.grade), label: 'الدرجات'), // Add Grades item
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'الإعدادات'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'التقارير'),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
      ),
    );
  }
}
