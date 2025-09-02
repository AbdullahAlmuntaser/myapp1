import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/student_provider.dart';
import '../../providers/teacher_provider.dart';
import '../../providers/class_provider.dart';
import '../../providers/subject_provider.dart';

class ReportsTab extends StatelessWidget {
  const ReportsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('التقارير والإحصائيات'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildReportCard(
              context,
              title: 'إحصائيات الطلاب',
              icon: Icons.school,
              dataBuilder: (context) {
                final studentProvider = Provider.of<StudentProvider>(context);
                return Text(
                  'إجمالي الطلاب: ${studentProvider.students.length}',
                  style: Theme.of(context).textTheme.titleMedium,
                );
              },
            ),
            _buildReportCard(
              context,
              title: 'إحصائيات المعلمين',
              icon: Icons.person,
              dataBuilder: (context) {
                final teacherProvider = Provider.of<TeacherProvider>(context);
                return Text(
                  'إجمالي المعلمين: ${teacherProvider.teachers.length}',
                  style: Theme.of(context).textTheme.titleMedium,
                );
              },
            ),
            _buildReportCard(
              context,
              title: 'إحصائيات الفصول',
              icon: Icons.class_,
              dataBuilder: (context) {
                final classProvider = Provider.of<ClassProvider>(context);
                return Text(
                  'إجمالي الفصول: ${classProvider.classes.length}',
                  style: Theme.of(context).textTheme.titleMedium,
                );
              },
            ),
            _buildReportCard(
              context,
              title: 'إحصائيات المواد',
              icon: Icons.book,
              dataBuilder: (context) {
                final subjectProvider = Provider.of<SubjectProvider>(context);
                return Text(
                  'إجمالي المواد: ${subjectProvider.subjects.length}',
                  style: Theme.of(context).textTheme.titleMedium,
                );
              },
            ),
            // Add more detailed reports or charts here in the future
          ],
        ),
      ),
    );
  }

  Widget _buildReportCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Widget Function(BuildContext) dataBuilder,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 30, color: Theme.of(context).primaryColor),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ],
            ),
            const Divider(height: 20),
            dataBuilder(context),
          ],
        ),
      ),
    );
  }
}
