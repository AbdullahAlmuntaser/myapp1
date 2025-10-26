import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../services/local_auth_service.dart';
import 'tabs/students_tab.dart';
import 'tabs/teachers_tab.dart';
import 'tabs/classes_tab.dart';
import 'tabs/subjects_tab.dart';
import 'tabs/settings_tab.dart';
import 'tabs/reports_tab.dart';
import 'grades_screen.dart';
import 'timetable_screen.dart';
import 'attendance_screen.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart'; // Import for date formatting
import '../providers/dashboard_provider.dart'; // Import DashboardProvider

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  DashboardScreenState createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final authService = Provider.of<LocalAuthService>(context);
    final currentUser = authService.currentUser;
    final String? userRole = currentUser?.role;
    final bool isDesktop = MediaQuery.of(context).size.width >= 600;

    List<Widget> widgetOptions = [];
    List<NavigationRailDestination> navigationRailDestinations = [];
    List<BottomNavigationBarItem> bottomNavigationBarItems = [];

    // Correctly define widgets and navigation items for the admin role
    if (userRole == 'admin') {
      widgetOptions = <Widget>[
        const DashboardSummary(),
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
      navigationRailDestinations = const <NavigationRailDestination>[
        NavigationRailDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: Text('Dashboard')),
        NavigationRailDestination(icon: Icon(Icons.school_outlined), selectedIcon: Icon(Icons.school), label: Text('Students')),
        NavigationRailDestination(icon: Icon(Icons.person_outlined), selectedIcon: Icon(Icons.person), label: Text('Teachers')),
        NavigationRailDestination(icon: Icon(Icons.class_outlined), selectedIcon: Icon(Icons.class_), label: Text('Classes')),
        NavigationRailDestination(icon: Icon(Icons.book_outlined), selectedIcon: Icon(Icons.book), label: Text('Subjects')),
        NavigationRailDestination(icon: Icon(Icons.calendar_today_outlined), selectedIcon: Icon(Icons.calendar_today), label: Text('Timetable')),
        NavigationRailDestination(icon: Icon(Icons.grade_outlined), selectedIcon: Icon(Icons.grade), label: Text('Grades')),
        NavigationRailDestination(icon: Icon(Icons.check_circle_outline), selectedIcon: Icon(Icons.check_circle), label: Text('Attendance')),
        NavigationRailDestination(icon: Icon(Icons.bar_chart_outlined), selectedIcon: Icon(Icons.bar_chart), label: Text('Reports')),
        NavigationRailDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings), label: Text('Settings')),
      ];
      bottomNavigationBarItems = const <BottomNavigationBarItem>[
        BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'لوحة التحكم'),
        BottomNavigationBarItem(icon: Icon(Icons.school), label: 'الطلاب'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'المعلمون'),
        BottomNavigationBarItem(icon: Icon(Icons.class_), label: 'الفصول'),
        BottomNavigationBarItem(icon: Icon(Icons.book), label: 'المواد'),
        BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'الجدول'),
        BottomNavigationBarItem(icon: Icon(Icons.grade), label: 'الدرجات'),
        BottomNavigationBarItem(icon: Icon(Icons.check_circle), label: 'الحضور'),
        BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'التقارير'),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'الإعدادات'),
      ];
    } else if (userRole == 'teacher') {
      widgetOptions = <Widget>[
        const DashboardSummary(),
        const StudentsTab(),
        const GradesScreen(),
        const AttendanceScreen(),
        const TimetableScreen(),
        const SettingsTab(),
      ];
      navigationRailDestinations = const <NavigationRailDestination>[
        NavigationRailDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: Text('لوحة التحكم')),
        NavigationRailDestination(icon: Icon(Icons.school_outlined), selectedIcon: Icon(Icons.school), label: Text('الطلاب')),
        NavigationRailDestination(icon: Icon(Icons.grade_outlined), selectedIcon: Icon(Icons.grade), label: Text('الدرجات')),
        NavigationRailDestination(icon: Icon(Icons.check_circle_outline), selectedIcon: Icon(Icons.check_circle), label: Text('الحضور')),
        NavigationRailDestination(icon: Icon(Icons.calendar_today_outlined), selectedIcon: Icon(Icons.calendar_today), label: Text('الجدول')),
        NavigationRailDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings), label: Text('الإعدادات')),
      ];
      bottomNavigationBarItems = const <BottomNavigationBarItem>[
        BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'لوحة التحكم'),
        BottomNavigationBarItem(icon: Icon(Icons.school), label: 'الطلاب'),
        BottomNavigationBarItem(icon: Icon(Icons.grade), label: 'الدرجات'),
        BottomNavigationBarItem(icon: Icon(Icons.check_circle), label: 'الحضور'),
        BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'الجدول'),
      ];
    } else if (userRole == 'student') {
      widgetOptions = <Widget>[
        const DashboardSummary(),
        const GradesScreen(),
        const AttendanceScreen(),
        const TimetableScreen(),
        const SettingsTab(),
      ];
      navigationRailDestinations = const <NavigationRailDestination>[
        NavigationRailDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: Text('لوحة التحكم')),
        NavigationRailDestination(icon: Icon(Icons.grade_outlined), selectedIcon: Icon(Icons.grade), label: Text('الدرجات')),
        NavigationRailDestination(icon: Icon(Icons.check_circle_outline), selectedIcon: Icon(Icons.check_circle), label: Text('الحضور')),
        NavigationRailDestination(icon: Icon(Icons.calendar_today_outlined), selectedIcon: Icon(Icons.calendar_today), label: Text('الجدول')),
        NavigationRailDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings), label: Text('الإعدادات')),
      ];
      bottomNavigationBarItems = const <BottomNavigationBarItem>[
        BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'لوحة التحكم'),
        BottomNavigationBarItem(icon: Icon(Icons.grade), label: 'الدرجات'),
        BottomNavigationBarItem(icon: Icon(Icons.check_circle), label: 'الحضور'),
        BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'الجدول'),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'الإعدادات'),
      ];
    } else if (userRole == 'parent') {
      final int? currentParentUserId = currentUser?.id;
      widgetOptions = <Widget>[
        const DashboardSummary(),
        StudentsTab(parentUserId: currentParentUserId), // Parent can view their children's details
        const SettingsTab(),
      ];
      navigationRailDestinations = const <NavigationRailDestination>[
        NavigationRailDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: Text('لوحة التحكم')),
        NavigationRailDestination(icon: Icon(Icons.school_outlined), selectedIcon: Icon(Icons.school), label: Text('أبنائي')),
        NavigationRailDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings), label: Text('الإعدادات')),
      ];
      bottomNavigationBarItems = const <BottomNavigationBarItem>[
        BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'لوحة التحكم'),
        BottomNavigationBarItem(icon: Icon(Icons.school), label: 'أبنائي'),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'الإعدادات'),
      ];
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome, ${currentUser?.username ?? 'Guest'}'),
        actions: [
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return IconButton(
                icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
                onPressed: () {
                  themeProvider.toggleTheme(!isDarkMode);
                },
                tooltip: 'Toggle Theme',
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              authService.signOut();
            },
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Row(
        children: [
          if (isDesktop)
            NavigationRail(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (int index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              labelType: NavigationRailLabelType.all,
              destinations: navigationRailDestinations,
            ),
          Expanded(
            child: widgetOptions.elementAt(_selectedIndex),
          ),
        ],
      ),
      bottomNavigationBar: isDesktop
          ? null
          : BottomNavigationBar(
              items: bottomNavigationBarItems,
              currentIndex: _selectedIndex,
              onTap: (int index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              selectedItemColor: Theme.of(context).primaryColor,
              unselectedItemColor: Colors.grey,
              type: BottomNavigationBarType.fixed,
            ),
    );
  }
}

class DashboardSummary extends StatefulWidget {
  const DashboardSummary({super.key});

  @override
  State<DashboardSummary> createState() => _DashboardSummaryState();
}

class _DashboardSummaryState extends State<DashboardSummary> {
  @override
  void initState() {
    super.initState();
    // Fetch data when the widget is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DashboardProvider>(context, listen: false).fetchDashboardData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardProvider>(
      builder: (context, dashboardProvider, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ملخص لوحة التحكم',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 20),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  SummaryCard(title: 'إجمالي الطلاب', value: dashboardProvider.totalStudents.toString(), icon: Icons.school, color: Colors.blue),
                  SummaryCard(title: 'إجمالي المعلمين', value: dashboardProvider.totalTeachers.toString(), icon: Icons.person, color: Colors.green),
                  SummaryCard(title: 'إجمالي الفصول', value: dashboardProvider.totalClasses.toString(), icon: Icons.class_, color: Colors.orange),
                  SummaryCard(title: 'نسبة النجاح', value: '${dashboardProvider.passPercentage.toStringAsFixed(0)}%', icon: Icons.trending_up, color: Colors.purple),
                ],
              ),
              const SizedBox(height: 30),
              Text(
                'نظرة عامة على حضور الطلاب',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 200,
                child: BarChart(
                  BarChartData(
                    barGroups: _buildAttendanceBarGroups(dashboardProvider.attendanceSummary),
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            if (value.toInt() < dashboardProvider.attendanceSummary.length) {
                              final date = DateTime.parse(dashboardProvider.attendanceSummary[value.toInt()]['date']);
                              return Text(DateFormat('dd/MM').format(date));
                            }
                            return const Text('');
                          },
                          reservedSize: 30,
                        ),
                      ),
                      leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
                    ),
                    borderData: FlBorderData(show: false),
                    gridData: FlGridData(show: false),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<BarChartGroupData> _buildAttendanceBarGroups(List<Map<String, dynamic>> summary) {
    return List.generate(summary.length, (index) {
      final data = summary[index];
      final presentCount = (data['presentCount'] as int).toDouble();
      final absentCount = (data['absentCount'] as int).toDouble();
      final lateCount = (data['lateCount'] as int).toDouble();

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: presentCount,
            color: Colors.green,
            width: 8,
            borderRadius: BorderRadius.circular(2),
          ),
          BarChartRodData(
            toY: absentCount,
            color: Colors.red,
            width: 8,
            borderRadius: BorderRadius.circular(2),
          ),
          BarChartRodData(
            toY: lateCount,
            color: Colors.orange,
            width: 8,
            borderRadius: BorderRadius.circular(2),
          ),
        ],
        showingTooltipIndicators: [0],
      );
    });
  }
}

class SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const SummaryCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                Icon(icon, color: color, size: 30),
              ],
            ),
            Text(value, style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
