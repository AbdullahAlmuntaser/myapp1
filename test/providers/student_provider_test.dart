
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:myapp/providers/student_provider.dart';
import 'package:myapp/student_model.dart';

import '../mock_generator_test.mocks.dart';

// This is a clean, test-specific version of the provider.
// It inherits from the real provider but allows us to inject a mock database helper.
class TestableStudentProvider extends StudentProvider {
  TestableStudentProvider(MockDatabaseHelper dbHelper) {
    super.dbHelper = dbHelper;
  }
}

void main() {
  late TestableStudentProvider studentProvider;
  late MockDatabaseHelper mockDatabaseHelper;

  // This function runs before each test, ensuring a clean state.
  setUp(() {
    mockDatabaseHelper = MockDatabaseHelper();
    studentProvider = TestableStudentProvider(mockDatabaseHelper);
  });

  final tStudent = Student(id: 1, name: 'Test Student', dob: '2000-01-01', phone: '12345', grade: 'A');
  final tStudentList = [tStudent];

  test('Initial state of students list should be empty', () {
    expect(studentProvider.students, []);
  });

  group('Database Operations', () {
    test('fetchStudents should get students from the database', () async {
      // Arrange: When getStudents is called on the mock helper, return a predefined list.
      when(mockDatabaseHelper.getStudents()).thenAnswer((_) async => tStudentList);
      
      // Act: Call the function we want to test.
      await studentProvider.fetchStudents();

      // Assert: Check if the provider's list now contains the students from the mock.
      expect(studentProvider.students, tStudentList);
      verify(mockDatabaseHelper.getStudents()); // Verify that the method was called.
      verifyNoMoreInteractions(mockDatabaseHelper); // Ensure no other methods were called.
    });

    test('addStudent should call the database and refresh the list', () async {
      // Arrange
      when(mockDatabaseHelper.createStudent(any)).thenAnswer((_) async => 1);
      when(mockDatabaseHelper.getStudents()).thenAnswer((_) async => tStudentList);

      // Act
      await studentProvider.addStudent(tStudent);

      // Assert
      verify(mockDatabaseHelper.createStudent(tStudent));
      verify(mockDatabaseHelper.getStudents()); // It should refresh the list after adding.
      expect(studentProvider.students, tStudentList);
    });

    test('deleteStudent should call the database and refresh the list', () async {
      // Arrange
      when(mockDatabaseHelper.deleteStudent(any)).thenAnswer((_) async => 1);
      when(mockDatabaseHelper.getStudents()).thenAnswer((_) async => []); // Return empty list after delete

      // Act
      await studentProvider.deleteStudent(1);

      // Assert
      verify(mockDatabaseHelper.deleteStudent(1));
      verify(mockDatabaseHelper.getStudents());
      expect(studentProvider.students, []);
    });

    test('searchStudents should call the database with the correct query', () async {
      // Arrange
      when(mockDatabaseHelper.searchStudents(any)).thenAnswer((_) async => tStudentList);
      
      // Act
      await studentProvider.searchStudents('Test');

      // Assert
      expect(studentProvider.students, tStudentList);
      verify(mockDatabaseHelper.searchStudents('Test'));
    });
  });
}
