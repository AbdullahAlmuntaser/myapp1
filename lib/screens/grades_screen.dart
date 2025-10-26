import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/grade_provider.dart';
import '../providers/student_provider.dart';
import '../providers/subject_provider.dart';
import '../providers/class_provider.dart';
import 'tabs/grades_overview_tab.dart';
import 'tabs/grades_bulk_entry_tab.dart';
import 'tabs/assessment_management_tab.dart';

class GradesScreen extends StatefulWidget {
  static const routeName = '/grades';

  const GradesScreen({super.key});

  @override
  State<GradesScreen> createState() => _GradesScreenState();
}

class _GradesScreenState extends State<GradesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoadingInitialData = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fetchInitialData();
  }

  Future<void> _fetchInitialData() async {
    if (!mounted) return;
    setState(() {
      _isLoadingInitialData = true;
    });
    try {
      await Future.wait([
        Provider.of<GradeProvider>(context, listen: false).fetchGrades(),
        Provider.of<StudentProvider>(context, listen: false).fetchStudents(),
        Provider.of<SubjectProvider>(context, listen: false).fetchSubjects(),
        Provider.of<ClassProvider>(context, listen: false).fetchClasses(),
      ]);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل تحميل البيانات الأولية للدرجات: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingInitialData = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'إدارة الدرجات',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.onPrimary,
              ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        centerTitle: true,
        elevation: 4,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Theme.of(context).colorScheme.onPrimary,
          labelColor: Theme.of(context).colorScheme.onPrimary,
          unselectedLabelColor: Theme.of(context).colorScheme.onPrimary.withAlpha((0.7 * 255).round()),
          labelStyle: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
          unselectedLabelStyle: Theme.of(context).textTheme.titleSmall,
          indicatorSize: TabBarIndicatorSize.tab,
          overlayColor: WidgetStateProperty.resolveWith<Color?>(
            (Set<WidgetState> states) {
              if (states.contains(WidgetState.hovered)) {
                return Theme.of(context).colorScheme.onPrimary.withAlpha((0.1 * 255).round());
              }
              return null;
            },
          ),
          tabs: const [
            Tab(text: 'نظرة عامة'),
            Tab(text: 'إدخال جماعي'),
            Tab(text: 'إدارة التقييمات'),
          ],
        ),
      ),
      body: _isLoadingInitialData
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: const [
                GradesOverviewTab(),
                GradesBulkEntryTab(),
                AssessmentManagementTab(),
              ],
            ),
    );
  }
}
