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
        BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
        BottomNavigationBarItem(icon: Icon(Icons.school), label: 'Students'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Teachers'),
        BottomNavigationBarItem(icon: Icon(Icons.class_), label: 'Classes'),
        BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Subjects'),
      ];
    } else if (userRole == 'teacher') {
      // Similar setup for teacher
    } else if (userRole == 'student') {
      // Similar setup for student
    } else if (userRole == 'parent') {
      // Similar setup for parent
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

class DashboardSummary extends StatelessWidget {
  const DashboardSummary({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dashboard Summary',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 20),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: const [
              SummaryCard(title: 'Total Students', value: '1,234', icon: Icons.school, color: Colors.blue),
              SummaryCard(title: 'Total Teachers', value: '56', icon: Icons.person, color: Colors.green),
              SummaryCard(title: 'Total Classes', value: '34', icon: Icons.class_, color: Colors.orange),
              SummaryCard(title: 'Pass Percentage', value: '95%', icon: Icons.trending_up, color: Colors.purple),
            ],
          ),
          const SizedBox(height: 30),
          Text(
            'Student Attendance Overview',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                barGroups: [
                  BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 8, color: Colors.lightBlue)]),
                  BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 10, color: Colors.lightBlue)]),
                  BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 14, color: Colors.lightBlue)]),
                  BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: 15, color: Colors.lightBlue)]),
                  BarChartGroupData(x: 4, barRods: [BarChartRodData(toY: 13, color: Colors.lightBlue)]),
                  BarChartGroupData(x: 5, barRods: [BarChartRodData(toY: 10, color: Colors.lightBlue)]),
                  BarChartGroupData(x: 6, barRods: [BarChartRodData(toY: 11, color: Colors.lightBlue)]),
                ],
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (value, meta) => Text('Day ${value.toInt() + 1}'))),
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
