import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/class_provider.dart';
import '../../class_model.dart';
import '../add_edit_class_screen.dart';

class ClassesTab extends StatefulWidget {
  const ClassesTab({super.key});

  @override
  ClassesTabState createState() => ClassesTabState();
}

class ClassesTabState extends State<ClassesTab> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Provider.of<ClassProvider>(context, listen: false).fetchClasses();
      }
    });
    _searchController.addListener(_filterClasses);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterClasses() {
    Provider.of<ClassProvider>(context, listen: false)
        .searchClasses(_searchController.text);
  }

  void _navigateToAddEditScreen([SchoolClass? schoolClass]) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddEditClassScreen(schoolClass: schoolClass),
      ),
    );
  }

  Future<void> _deleteClass(int id) async {
    final bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: const Text('Are you sure you want to delete this class?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (!mounted) return;

    if (confirm == true) {
      await Provider.of<ClassProvider>(context, listen: false).deleteClass(id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Class deleted successfully')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Class Dashboard'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Search by Class Name or ID',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12.0)),
                ),
              ),
            ),
          ),
          Expanded(
            child: Consumer<ClassProvider>(
              builder: (context, classProvider, child) {
                if (classProvider.classes.isEmpty) {
                  return const Center(child: Text('No classes found.'));
                }
                return ListView.builder(
                  itemCount: classProvider.classes.length,
                  itemBuilder: (context, index) {
                    final schoolClass = classProvider.classes[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                      child: ListTile(
                        title: Text(schoolClass.name),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Class ID: ${schoolClass.classId}'),
                            if (schoolClass.teacherId != null && schoolClass.teacherId!.isNotEmpty)
                              Text('Responsible Teacher ID: ${schoolClass.teacherId}'),
                            if (schoolClass.capacity != null)
                              Text('Capacity: ${schoolClass.capacity}'),
                            if (schoolClass.yearTerm != null && schoolClass.yearTerm!.isNotEmpty)
                              Text('Year/Term: ${schoolClass.yearTerm}'),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _navigateToAddEditScreen(schoolClass),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => _deleteClass(schoolClass.id!),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddEditScreen(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
