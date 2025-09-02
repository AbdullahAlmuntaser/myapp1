import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'student_model.dart';
import 'teacher_model.dart';
import 'class_model.dart';
import 'subject_model.dart';

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
    final path = join(dbPath.path, 'students.db');
    return await openDatabase(
      path,
      version:
          8, // Increased version to trigger onUpgrade for new student fields
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE students(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        dob TEXT NOT NULL,
        phone TEXT NOT NULL,
        grade TEXT NOT NULL,
        email TEXT UNIQUE,
        password TEXT,
        classId TEXT,
        academicNumber TEXT,
        section TEXT,
        parentName TEXT,
        parentPhone TEXT,
        address TEXT,
        status INTEGER NOT NULL DEFAULT 1
      )
    ''');
    await db.execute('''
      CREATE TABLE teachers(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        subject TEXT NOT NULL,
        phone TEXT NOT NULL,
        email TEXT,
        password TEXT,
        qualificationType TEXT,
        responsibleClassId TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE classes(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        classId TEXT NOT NULL UNIQUE,
        teacherId TEXT,
        capacity INTEGER,
        yearTerm TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE subjects(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        subjectId TEXT NOT NULL UNIQUE,
        description TEXT,
        teacherId TEXT
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < newVersion) {
      // Drop all tables and recreate them to apply new schema
      await db.execute('DROP TABLE IF EXISTS students');
      await db.execute('DROP TABLE IF EXISTS teachers');
      await db.execute('DROP TABLE IF EXISTS classes');
      await db.execute('DROP TABLE IF EXISTS subjects');
      await _onCreate(db, newVersion);
    }
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
        : 'WHERE ${whereClauses.join(' AND ')}';

    final List<Map<String, dynamic>> maps = await db.query(
      'students',
      where: whereString.isEmpty
          ? null
          : whereString.substring(6), // Remove "WHERE " prefix if exists
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
}
