import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:myapp/providers/student_provider.dart';
import 'package:myapp/providers/theme_provider.dart';
import 'package:myapp/screens/dashboard_screen.dart';
import 'package:myapp/student_model.dart';
import 'package:provider/provider.dart';

import 'mock_generator_test.mocks.dart';

void main() {
  late StudentProvider studentProvider;
  late MockDatabaseHelper mockDatabaseHelper;

  setUp(() {
    mockDatabaseHelper = MockDatabaseHelper();
    studentProvider = StudentProvider(databaseHelper: mockDatabaseHelper);
  });

  Widget createHomeScreen() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeProvider>(create: (_) => ThemeProvider()),
        ChangeNotifierProvider<StudentProvider>.value(value: studentProvider),
      ],
      child: const MaterialApp(home: DashboardScreen()),
    );
  }

  testWidgets('Shows "No students found" message when list is empty', (WidgetTester tester) async {
    // Arrange
    when(mockDatabaseHelper.getStudents()).thenAnswer((_) async => []);

    // Act
    await tester.pumpWidget(createHomeScreen());
    await tester.pumpAndSettle(); // Wait for async operations and animations

    // Assert
    expect(find.text('No students found.'), findsOneWidget);
    // The student list is inside a tab, so we need to find the specific tab content
    expect(find.byKey(const Key('students_tab_view')), findsOneWidget);
  });

  testWidgets('Shows a list of students when data is available', (WidgetTester tester) async {
    // Arrange
    final studentList = [Student(id: 1, name: 'First Student', dob: '2001-01-01', phone: '111', grade: 'B')];
    when(mockDatabaseHelper.getStudents()).thenAnswer((_) async => studentList);

    // Act
    await tester.pumpWidget(createHomeScreen());
    await tester.pumpAndSettle();

    // Assert
    expect(find.text('No students found.'), findsNothing);
    expect(find.text('First Student'), findsOneWidget);
    expect(find.text('Grade: B | DOB: 2001-01-01'), findsOneWidget);
  });

   testWidgets('Tapping FAB navigates to AddEditStudentScreen', (WidgetTester tester) async {
    // Arrange
    when(mockDatabaseHelper.getStudents()).thenAnswer((_) async => []);
    await tester.pumpWidget(createHomeScreen());
    await tester.pumpAndSettle();

    // Act
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    // Assert
    expect(find.text('Add Student'), findsOneWidget);
  });
}