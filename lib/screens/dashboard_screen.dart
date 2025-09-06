import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../services/local_auth_service.dart'; // Import LocalAuthService
import 'tabs/students_tab.dart';
import 'tabs/teachers_tab.dart';
import 'tabs/classes_tab.dart';
import 'tabs/subjects_tab.dart';
import 'tabs/settings_tab.dart';
import 'tabs/reports_tab.dart';
import 'grades_screen.dart';
import 'timetable_screen.dart';
import 'attendance_screen.dart';
import 'parent_portal_screen.dart'; // Import ParentPortalScreen

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  DashboardScreenState createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    // Removed data fetching from initState here, as it's handled by AppInitializer based on auth state.
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final authService = Provider.of<LocalAuthService>(context); // Listen to auth changes
    final currentUser = authService.currentUser;
    final String? userRole = currentUser?.role;

    List<Widget> widgetOptions = [];
    List<BottomNavigationBarItem> bottomNavigationBarItems = [];

    // Define content and navigation based on user role
    if (userRole == 'admin') {
      widgetOptions = <Widget>[
        const StudentsTab(),
        const TeachersTab(),
        const ClassesTab(),
        const SubjectsTab(),
        const TimetableScreen(),
        const GradesScreen(),
        const AttendanceScreen(),
        const ReportsTab(),
        const SettingsTab(),
      ];
      bottomNavigationBarItems = const <BottomNavigationBarItem>[
        BottomNavigationBarItem(icon: Icon(Icons.school), label: 'الطلاب'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'المعلمون'),
        BottomNavigationBarItem(icon: Icon(Icons.class_), label: 'الصفوف'),
        BottomNavigationBarItem(icon: Icon(Icons.book), label: 'المواد'),
        BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'الجداول'),
        BottomNavigationBarItem(icon: Icon(Icons.grade), label: 'الدرجات'),
        BottomNavigationBarItem(icon: Icon(Icons.check_circle), label: 'الحضور'),
        BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'التقارير'),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'الإعدادات'),
      ];
    } else if (userRole == 'teacher') {
      widgetOptions = <Widget>[
        const TeachersTab(), // Teachers can view their own profile
        const TimetableScreen(), // Teachers can view their timetable
        const GradesScreen(), // Teachers can manage grades
        const AttendanceScreen(), // Teachers can manage attendance
        const SettingsTab(),
      ];
      bottomNavigationBarItems = const <BottomNavigationBarItem>[
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'ملفي'),
        BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'جدولي'),
        BottomNavigationBarItem(icon: Icon(Icons.grade), label: 'الدرجات'),
        BottomNavigationBarItem(icon: Icon(Icons.check_circle), label: 'الحضور'),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'الإعدادات'),
      ];
    } else if (userRole == 'student') {
      widgetOptions = <Widget>[
        const StudentsTab(), // Students can view their own profile
        const TimetableScreen(), // Students can view their timetable
        const GradesScreen(), // Students can view their grades
        const AttendanceScreen(), // Students can view their attendance
        const SettingsTab(),
      ];
      bottomNavigationBarItems = const <BottomNavigationBarItem>[
        BottomNavigationBarItem(icon: Icon(Icons.school), label: 'ملفي'),
        BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'جدولي'),
        BottomNavigationBarItem(icon: Icon(Icons.grade), label: 'درجاتي'),
        BottomNavigationBarItem(icon: Icon(Icons.check_circle), label: 'حضوري'),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'الإعدادات'),
      ];
    } else if (userRole == 'parent') {
      widgetOptions = <Widget>[
        const ParentPortalScreen(), // Dedicated screen for parents
        const SettingsTab(),
      ];
      bottomNavigationBarItems = const <BottomNavigationBarItem>[
        BottomNavigationBarItem(icon: Icon(Icons.family_restroom), label: 'البوابة'),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'الإعدادات'),
      ];
    } else {
      // Fallback for unknown role or not logged in (though AppInitializer handles this)
      widgetOptions = [const Text('Unauthorized Access')];
      bottomNavigationBarItems = [];
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'مرحباً يا ${currentUser?.username ?? 'زائر'}',
        ),
        actions: [
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return IconButton(
                icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
                onPressed: () {
                  themeProvider.toggleTheme(!isDarkMode);
                },
                tooltip: 'تبديل الوضع',
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout), // Logout button
            onPressed: () { // Removed await
              authService.signOut();
              // No need to navigate, Consumer in main.dart will rebuild to LoginScreen
            },
            tooltip: 'تسجيل الخروج',
          ),
        ],
      ),
      body: Center(child: widgetOptions.elementAt(_selectedIndex)),
      bottomNavigationBar: (bottomNavigationBarItems.isNotEmpty)
          ? BottomNavigationBar(
              items: bottomNavigationBarItems,
              currentIndex: _selectedIndex,
              onTap: _onItemTapped,
              selectedItemColor: Theme.of(context).primaryColor,
              unselectedItemColor: Colors.grey,
              type: BottomNavigationBarType.fixed,
            )
          : null, // Hide BottomNavigationBar if no items
    );
  }
}
