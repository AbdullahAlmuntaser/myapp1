import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/assessment_type_provider.dart';
import '../../assessment_type_model.dart';

class AssessmentManagementTab extends StatefulWidget {
  const AssessmentManagementTab({super.key});

  @override
  State<AssessmentManagementTab> createState() => _AssessmentManagementTabState();
}

class _AssessmentManagementTabState extends State<AssessmentManagementTab> {
  @override
  void initState() {
    super.initState();
    // Fetch assessment types when the widget is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AssessmentTypeProvider>(context, listen: false).fetchAssessmentTypes();
    });
  }

  void _showAssessmentTypeDialog({AssessmentType? assessmentType}) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: assessmentType?.name ?? '');
    final weightController = TextEditingController(text: assessmentType?.weight.toString() ?? '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(assessmentType == null ? 'إضافة نوع تقييم جديد' : 'تعديل نوع التقييم'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'اسم التقييم (مثال: واجب، اختبار)'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء إدخال اسم التقييم';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: weightController,
                  decoration: const InputDecoration(labelText: 'الوزن النسبي (مثال: 0.2 لـ 20%)'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء إدخال الوزن النسبي';
                    }
                    final weight = double.tryParse(value);
                    if (weight == null || weight < 0 || weight > 1) {
                      return 'الرجاء إدخال قيمة بين 0 و 1';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('إلغاء'),
            ),
            FilledButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  final newAssessmentType = AssessmentType(
                    id: assessmentType?.id,
                    name: nameController.text,
                    weight: double.parse(weightController.text),
                  );
                  if (assessmentType == null) {
                    Provider.of<AssessmentTypeProvider>(context, listen: false).addAssessmentType(newAssessmentType);
                  } else {
                    Provider.of<AssessmentTypeProvider>(context, listen: false).updateAssessmentType(newAssessmentType);
                  }
                  Navigator.of(context).pop();
                }
              },
              child: const Text('حفظ'),
            ),
          ],
        );
      },
    );
  }

  void _deleteAssessmentType(int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text('هل أنت متأكد أنك تريد حذف نوع التقييم هذا؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () {
              Provider.of<AssessmentTypeProvider>(context, listen: false).deleteAssessmentType(id);
              Navigator.of(context).pop();
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final assessmentTypeProvider = Provider.of<AssessmentTypeProvider>(context);
    final assessmentTypes = assessmentTypeProvider.assessmentTypes;

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'إدارة أنواع التقييمات وأوزانها',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          Expanded(
            child: assessmentTypes.isEmpty
                ? const Center(child: Text('لا توجد أنواع تقييمات. قم بإضافة واحدة!'))
                : ListView.builder(
                    itemCount: assessmentTypes.length,
                    itemBuilder: (context, index) {
                      final assessmentType = assessmentTypes[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: ListTile(
                          title: Text(assessmentType.name, style: Theme.of(context).textTheme.titleMedium),
                          subtitle: Text('الوزن: ${(assessmentType.weight * 100).toStringAsFixed(0)}%'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () => _showAssessmentTypeDialog(assessmentType: assessmentType),
                                tooltip: 'تعديل',
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteAssessmentType(assessmentType.id!),
                                tooltip: 'حذف',
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAssessmentTypeDialog(),
        tooltip: 'إضافة نوع تقييم جديد',
        child: const Icon(Icons.add),
      ),
    );
  }
}