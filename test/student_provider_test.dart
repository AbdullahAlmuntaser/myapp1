
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:myapp/database_helper.dart';
import 'package:myapp/providers/student_provider.dart';
import 'package:myapp/student_model.dart';

import 'student_provider_test.mocks.dart';

// Generate a MockClient using the Mockito package.
@GenerateMocks([DatabaseHelper])
void main() {
  late StudentProvider studentProvider;
  late MockDatabaseHelper mockDatabaseHelper;

  setUp(() {
    mockDatabaseHelper = MockDatabaseHelper();
    // It's not ideal to instantiate the real provider directly with a mock,
    // but for this architecture, it's the most straightforward way.
    // A better approach would be to inject the dependency.
    studentProvider = StudentProvider(); 
  });

  final tStudent = Student(id: 1, name: 'Test Student', dob: '2000-01-01', phone: '12345', grade: 'A');
  final tStudentList = [tStudent];

  test('initial students list should be empty', () {
    expect(studentProvider.students, []);
  });

  group('fetchStudents', () {
    test('should get students from the database', () async {
      // arrange
      when(mockDatabaseHelper.getStudents()).thenAnswer((_) async => tStudentList);
      
      // Create a new provider that will use the mock via a factory or DI approach
      final provider = StudentProvider();
      // For this test, we will manually simulate the dependency
      final originalHelper = provider.getDbHelper(); // Need to expose the helper for this
      provider.setDbHelper(mockDatabaseHelper); // Need a setter

      // act
      await provider.fetchStudents();

      // assert
      expect(provider.students, tStudentList);
      verify(mockDatabaseHelper.getStudents());
      verifyNoMoreInteractions(mockDatabaseHelper);

      // cleanup
      provider.setDbHelper(originalHelper); // Restore original helper
    });
  });

  group('addStudent', () {
    test('should call createStudent and then fetch students', () async {
      // arrange
      when(mockDatabaseHelper.createStudent(any)).thenAnswer((_) async => 1);
      when(mockDatabaseHelper.getStudents()).thenAnswer((_) async => tStudentList);
      final provider = StudentProvider();
      final originalHelper = provider.getDbHelper();
      provider.setDbHelper(mockDatabaseHelper);

      // act
      await provider.addStudent(tStudent);

      // assert
      verify(mockDatabaseHelper.createStudent(tStudent));
      verify(mockDatabaseHelper.getStudents());
      expect(provider.students, tStudentList);
    });
  });

  // Similar tests can be written for update, delete, and search
}

// NOTE: To make this test fully work, you would need to modify StudentProvider
// to allow injecting the DatabaseHelper dependency, for example:
/*
class StudentProvider with ChangeNotifier {
  List<Student> _students = [];
  DatabaseHelper _dbHelper;

  StudentProvider({DatabaseHelper? dbHelper}) : _dbHelper = dbHelper ?? DatabaseHelper();

  //...
}
*/
// The test above is written with assumptions on how to inject the mock.
// The code generation will fail because the test file is not self-contained.
// I will now write the correct test files.
