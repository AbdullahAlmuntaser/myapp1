import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:crypto/crypto.dart'; // Import for password hashing
import 'dart:convert'; // For utf8 encoding

import 'student_model.dart';
import 'teacher_model.dart';
import 'class_model.dart';
import 'subject_model.dart';
import 'grade_model.dart';
import 'attendance_model.dart';
import 'timetable_model.dart';
import 'user_model.dart'; // Import the new User model

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getApplicationDocumentsDirectory();
    final path = join(dbPath.path, 'school_management.db');
    return await openDatabase(
      path,
      version: 14, // Increased version for parentUserId in students table
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL UNIQUE,
        passwordHash TEXT NOT NULL,
        role TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE students(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        dob TEXT NOT NULL,
        phone TEXT NOT NULL,
        grade TEXT NOT NULL,
        email TEXT UNIQUE,
        password TEXT,
        classId INTEGER,
        academicNumber TEXT,
        section TEXT,
        parentName TEXT,
        parentPhone TEXT,
        address TEXT,
        status INTEGER NOT NULL DEFAULT 1,
        parentUserId INTEGER -- New field to link to the parent's User ID
      )
    ''');
    await db.execute('''
      CREATE TABLE teachers(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        subject TEXT NOT NULL,
        phone TEXT NOT NULL,
        email TEXT UNIQUE,
        password TEXT,
        qualificationType TEXT,
        responsibleClassId INTEGER
      )
    ''');
    await db.execute('''
      CREATE TABLE classes(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        classId TEXT NOT NULL UNIQUE,
        teacherId INTEGER,
        capacity INTEGER,
        yearTerm TEXT,
        subjectIds TEXT -- Stored as comma-separated string or JSON string
      )
    ''');
    await db.execute('''
      CREATE TABLE subjects(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE,
        subjectId TEXT NOT NULL UNIQUE,
        description TEXT,
        teacherId INTEGER
      )
    ''');
    await db.execute('''
      CREATE TABLE grades(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        studentId INTEGER NOT NULL,
        subjectId INTEGER NOT NULL,
        classId INTEGER NOT NULL,
        assessmentType TEXT NOT NULL,
        gradeValue REAL NOT NULL,
        weight REAL NOT NULL,
        FOREIGN KEY (studentId) REFERENCES students (id) ON DELETE CASCADE,
        FOREIGN KEY (subjectId) REFERENCES subjects (id) ON DELETE CASCADE,
        FOREIGN KEY (classId) REFERENCES classes (id) ON DELETE CASCADE
      )
    ''');
    await db.execute('''
      CREATE TABLE attendance(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        studentId INTEGER NOT NULL,
        classId INTEGER NOT NULL,
        subjectId INTEGER NOT NULL,
        teacherId INTEGER NOT NULL,
        date TEXT NOT NULL,
        lessonNumber INTEGER NOT NULL,
        status TEXT NOT NULL, -- 'present', 'absent', 'late', 'excused'
        FOREIGN KEY (studentId) REFERENCES students (id) ON DELETE CASCADE,
        FOREIGN KEY (classId) REFERENCES classes (id) ON DELETE CASCADE,
        FOREIGN KEY (subjectId) REFERENCES subjects (id) ON DELETE CASCADE,
        FOREIGN KEY (teacherId) REFERENCES teachers (id) ON DELETE CASCADE
      )
    ''');
    await db.execute('''
      CREATE TABLE timetable(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        classId INTEGER NOT NULL,
        subjectId INTEGER NOT NULL,
        teacherId INTEGER NOT NULL,
        dayOfWeek TEXT NOT NULL, -- 'Sunday', 'Monday', etc.
        lessonNumber INTEGER NOT NULL,
        startTime TEXT NOT NULL, -- 'HH:MM'
        endTime TEXT NOT NULL, -- 'HH:MM'
        FOREIGN KEY (classId) REFERENCES classes (id) ON DELETE CASCADE,
        FOREIGN KEY (subjectId) REFERENCES subjects (id) ON DELETE CASCADE,
        FOREIGN KEY (teacherId) REFERENCES teachers (id) ON DELETE CASCADE
      )
    ''');

    // Insert an initial admin user if the table is empty
    await _insertInitialAdmin(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // For development, dropping and recreating tables is acceptable.
    // For production, consider more robust migration strategies.
    if (oldVersion < newVersion) {
      await db.execute('DROP TABLE IF EXISTS users'); 
      await db.execute('DROP TABLE IF EXISTS students');
      await db.execute('DROP TABLE IF EXISTS teachers');
      await db.execute('DROP TABLE IF EXISTS classes');
      await db.execute('DROP TABLE IF EXISTS subjects');
      await db.execute('DROP TABLE IF EXISTS grades');
      await db.execute('DROP TABLE IF EXISTS attendance');
      await db.execute('DROP TABLE IF EXISTS timetable');
      await _onCreate(db, newVersion);
    }
  }

  // Helper to hash passwords
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Insert initial admin user if no users exist
  Future<void> _insertInitialAdmin(Database db) async {
    final count = Sqflite.firstIntValue(await db.rawQuery("SELECT COUNT(*) FROM users"));
    if (count == 0) {
      final adminUser = User(
        username: 'admin',
        passwordHash: _hashPassword('admin123'), // Default admin password
        role: 'admin',
      );
      await db.insert('users', adminUser.toMap());
    }
  }

  // --- User Methods ---

  Future<int> createUser(User user) async {
    final db = await database;
    return await db.insert(
      'users',
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<User?> getUserByUsername(String username) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
    );
    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    } else {
      return null;
    }
  }

  // New method to get a user by ID
  Future<User?> getUserById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<int> updateUser(User user) async {
    final db = await database;
    return await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  Future<int> deleteUser(int id) async {
    final db = await database;
    return await db.delete('users', where: 'id = ?', whereArgs: [id]);
  }

  // --- Student Methods ---

  Future<int> createStudent(Student student) async {
    final db = await database;
    return await db.insert(
      'students',
      student.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Student>> getStudents() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('students');
    return List.generate(maps.length, (i) {
      return Student.fromMap(maps[i]);
    });
  }

  Future<List<Student>> getStudentsByParentUserId(int parentUserId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'students',
      where: 'parentUserId = ?',
      whereArgs: [parentUserId],
    );
    return List.generate(maps.length, (i) {
      return Student.fromMap(maps[i]);
    });
  }

  Future<int> updateStudent(Student student) async {
    final db = await database;
    return await db.update(
      'students',
      student.toMap(),
      where: 'id = ?',
      whereArgs: [student.id],
    );
  }

  Future<int> deleteStudent(int id) async {
    final db = await database;
    return await db.delete('students', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Student>> searchStudents(
    String nameQuery, {
    String? classId,
  }) async {
    final db = await database;
    List<String> whereClauses = [];
    List<dynamic> whereArgs = [];

    if (nameQuery.isNotEmpty) {
      whereClauses.add('name LIKE ? OR academicNumber LIKE ?');
      whereArgs.add('%$nameQuery%');
      whereArgs.add('%$nameQuery%');
    }

    if (classId != null && classId.isNotEmpty) {
      whereClauses.add('classId = ?');
      whereArgs.add(classId);
    }

    String whereString = whereClauses.isEmpty
        ? ''
        : whereClauses.join(' AND ');

    final List<Map<String, dynamic>> maps = await db.query(
      'students',
      where: whereString.isEmpty
          ? null
          : whereString,
      whereArgs: whereArgs.isEmpty ? null : whereArgs,
    );
    return List.generate(maps.length, (i) {
      return Student.fromMap(maps[i]);
    });
  }

  Future<Student?> getStudentByEmail(String email) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'students',
      where: 'email = ?',
      whereArgs: [email],
    );
    if (maps.isNotEmpty) {
      return Student.fromMap(maps.first);
    } else {
      return null;
    }
  }

  // --- Teacher Methods ---

  Future<int> createTeacher(Teacher teacher) async {
    final db = await database;
    return await db.insert('teachers', teacher.toMap());
  }

  Future<List<Teacher>> getTeachers() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('teachers');
    return List.generate(maps.length, (i) {
      return Teacher.fromMap(maps[i]);
    });
  }

  Future<int> updateTeacher(Teacher teacher) async {
    final db = await database;
    return await db.update(
      'teachers',
      teacher.toMap(),
      where: 'id = ?',
      whereArgs: [teacher.id],
    );
  }

  Future<int> deleteTeacher(int id) async {
    final db = await database;
    return await db.delete('teachers', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Teacher>> searchTeachers(String name, {String? subject}) async {
    final db = await database;
    List<String> whereClauses = [];
    List<dynamic> whereArgs = [];

    if (name.isNotEmpty) {
      whereClauses.add('name LIKE ?');
      whereArgs.add('%$name%');
    }

    if (subject != null && subject.isNotEmpty) {
      whereClauses.add('subject LIKE ?');
      whereArgs.add('%$subject%');
    }

    String whereString = whereClauses.isEmpty ? '' : whereClauses.join(' AND ');

    final List<Map<String, dynamic>> maps = await db.query(
      'teachers',
      where: whereString.isEmpty ? null : whereString,
      whereArgs: whereArgs.isEmpty ? null : whereArgs,
    );
    return List.generate(maps.length, (i) {
      return Teacher.fromMap(maps[i]);
    });
  }

  // --- Class Methods ---

  Future<int> createClass(SchoolClass schoolClass) async {
    final db = await database;
    return await db.insert(
      'classes',
      schoolClass.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<SchoolClass>> getClasses() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('classes');
    return List.generate(maps.length, (i) {
      return SchoolClass.fromMap(maps[i]);
    });
  }

  Future<SchoolClass?> getClassById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'classes',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return SchoolClass.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<SchoolClass?> getClassByClassIdString(String classId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'classes',
      where: 'classId = ?',
      whereArgs: [classId],
    );
    if (maps.isNotEmpty) {
      return SchoolClass.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<int> updateClass(SchoolClass schoolClass) async {
    final db = await database;
    return await db.update(
      'classes',
      schoolClass.toMap(),
      where: 'id = ?',
      whereArgs: [schoolClass.id],
    );
  }

  Future<int> deleteClass(int id) async {
    final db = await database;
    return await db.delete('classes', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<SchoolClass>> searchClasses(String query) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'classes',
      where: 'name LIKE ? OR classId LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
    );
    return List.generate(maps.length, (i) {
      return SchoolClass.fromMap(maps[i]);
    });
  }

  // --- Subject Methods ---

  Future<int> createSubject(Subject subject) async {
    final db = await database;
    return await db.insert(
      'subjects',
      subject.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Subject>> getSubjects() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('subjects');
    return List.generate(maps.length, (i) {
      return Subject.fromMap(maps[i]);
    });
  }

  Future<Subject?> getSubjectById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'subjects',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Subject.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<int> updateSubject(Subject subject) async {
    final db = await database;
    return await db.update(
      'subjects',
      subject.toMap(),
      where: 'id = ?',
      whereArgs: [subject.id],
    );
  }

  Future<int> deleteSubject(int id) async {
    final db = await database;
    return await db.delete('subjects', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Subject>> searchSubjects(String query) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'subjects',
      where: 'name LIKE ? OR subjectId LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
    );
    return List.generate(maps.length, (i) {
      return Subject.fromMap(maps[i]);
    });
  }

  Future<Subject?> getSubjectByName(String name) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'subjects',
      where: 'name = ?',
      whereArgs: [name],
    );
    if (maps.isNotEmpty) {
      return Subject.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<Subject?> getSubjectBySubjectId(String subjectId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'subjects',
      where: 'subjectId = ?',
      whereArgs: [subjectId],
    );
    if (maps.isNotEmpty) {
      return Subject.fromMap(maps.first);
    } else {
      return null;
    }
  }

  // --- Grade Methods ---

  Future<int> createGrade(Grade grade) async {
    final db = await database;
    return await db.insert(
      'grades',
      grade.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Grade>> getGrades() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('grades');
    return List.generate(maps.length, (i) {
      return Grade.fromMap(maps[i]);
    });
  }

  Future<int> updateGrade(Grade grade) async {
    final db = await database;
    return await db.update(
      'grades',
      grade.toMap(),
      where: 'id = ?',
      whereArgs: [grade.id],
    );
  }

  Future<int> deleteGrade(int id) async {
    final db = await database;
    return await db.delete('grades', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Grade>> getGradesByStudent(int studentId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'grades',
      where: 'studentId = ?',
      whereArgs: [studentId],
    );
    return List.generate(maps.length, (i) {
      return Grade.fromMap(maps[i]);
    });
  }

  Future<List<Grade>> getGradesByClass(int classId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'grades',
      where: 'classId = ?',
      whereArgs: [classId],
    );
    return List.generate(maps.length, (i) {
      return Grade.fromMap(maps[i]);
    });
  }

  Future<List<Grade>> getGradesBySubject(int subjectId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'grades',
      where: 'subjectId = ?',
      whereArgs: [subjectId],
    );
    return List.generate(maps.length, (i) {
      return Grade.fromMap(maps[i]);
    });
  }

  Future<List<Map<String, dynamic>>> getAverageGradesBySubject() async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT
        s.name AS subjectName,
        AVG(g.gradeValue * g.weight) / AVG(g.weight) AS averageGrade
      FROM grades g
      JOIN subjects s ON g.subjectId = s.id
      GROUP BY s.name
    ''');
    return result;
  }

  // --- Attendance Methods ---

  Future<int> createAttendance(Attendance attendance) async {
    final db = await database;
    return await db.insert(
      'attendance',
      attendance.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Attendance>> getAttendances() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('attendance');
    return List.generate(maps.length, (i) {
      return Attendance.fromMap(maps[i]);
    });
  }

  Future<int> updateAttendance(Attendance attendance) async {
    final db = await database;
    return await db.update(
      'attendance',
      attendance.toMap(),
      where: 'id = ?',
      whereArgs: [attendance.id],
    );
  }

  Future<int> deleteAttendance(int id) async {
    final db = await database;
    return await db.delete('attendance', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Attendance>> getAttendancesByFilters({
    String? date,
    int? classId,
    int? subjectId,
    int? teacherId,
    int? studentId,
    int? lessonNumber,
  }) async {
    final db = await database;
    List<String> whereClauses = [];
    List<dynamic> whereArgs = [];

    if (date != null && date.isNotEmpty) {
      whereClauses.add('date = ?');
      whereArgs.add(date);
    }
    if (classId != null) {
      whereClauses.add('classId = ?');
      whereArgs.add(classId);
    }
    if (subjectId != null) {
      whereClauses.add('subjectId = ?');
      whereArgs.add(subjectId);
    }
    if (teacherId != null) {
      whereClauses.add('teacherId = ?');
      whereArgs.add(teacherId);
    }
    if (studentId != null) {
      whereClauses.add('studentId = ?');
      whereArgs.add(studentId);
    }
    if (lessonNumber != null) {
      whereClauses.add('lessonNumber = ?');
      whereArgs.add(lessonNumber);
    }

    String whereString = whereClauses.isEmpty ? '' : whereClauses.join(' AND ');

    final List<Map<String, dynamic>> maps = await db.query(
      'attendance',
      where: whereString.isEmpty ? null : whereString,
      whereArgs: whereArgs.isEmpty ? null : whereArgs,
    );
    return List.generate(maps.length, (i) {
      return Attendance.fromMap(maps[i]);
    });
  }

  // --- Timetable Methods ---

  Future<int> insertTimetableEntry(Map<String, dynamic> entry) async {
    final db = await database;
    return await db.insert(
      'timetable',
      entry,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getTimetableEntries() async {
    final db = await database;
    return await db.query('timetable');
  }

  Future<List<Map<String, dynamic>>> getTimetableEntriesByClass(int classId) async {
    final db = await database;
    return await db.query(
      'timetable',
      where: 'classId = ?',
      whereArgs: [classId],
      orderBy: 'dayOfWeek ASC, lessonNumber ASC',
    );
  }

  Future<List<Map<String, dynamic>>> getTimetableEntriesByTeacher(int teacherId) async {
    final db = await database;
    return await db.query(
      'timetable',
      where: 'teacherId = ?',
      whereArgs: [teacherId],
      orderBy: 'dayOfWeek ASC, lessonNumber ASC',
    );
  }

  Future<int> updateTimetableEntry(Map<String, dynamic> entry) async {
    final db = await database;
    return await db.update(
      'timetable',
      entry,
      where: 'id = ?',
      whereArgs: [entry['id']],
    );
  }

  Future<int> deleteTimetableEntry(int id) async {
    final db = await database;
    return await db.delete('timetable', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<TimetableEntry>> getTimetableEntriesByFilters({
    int? classId,
    String? dayOfWeek,
    int? teacherId,
  }) async {
    final db = await database;
    List<String> whereClauses = [];
    List<dynamic> whereArgs = [];

    if (classId != null) {
      whereClauses.add('classId = ?');
      whereArgs.add(classId);
    }
    if (dayOfWeek != null && dayOfWeek.isNotEmpty) {
      whereClauses.add('dayOfWeek = ?');
      whereArgs.add(dayOfWeek);
    }
    if (teacherId != null) {
      whereClauses.add('teacherId = ?');
      whereArgs.add(teacherId);
    }

    String whereString = whereClauses.isEmpty ? '' : whereClauses.join(' AND ');

    final List<Map<String, dynamic>> maps = await db.query(
      'timetable',
      where: whereString.isEmpty ? null : whereString,
      whereArgs: whereArgs.isEmpty ? null : whereArgs,
      orderBy: 'lessonNumber ASC', // Order by lesson number for correct display
    );
    return List.generate(maps.length, (i) {
      return TimetableEntry.fromMap(maps[i]);
    });
  }

  Future<void> clearAllData() async {
    final db = await database;
    await db.delete('users'); 
    await db.delete('students');
    await db.delete('teachers');
    await db.delete('classes');
    await db.delete('subjects');
    await db.delete('grades');
    await db.delete('attendance');
    await db.delete('timetable');
  }
}
