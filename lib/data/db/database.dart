// lib/data/db/database.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class AppDatabase {
  static final AppDatabase _instance = AppDatabase._internal();
  factory AppDatabase() => _instance;
  AppDatabase._internal();

  static Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'myapp1.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      // لاحقاً يمكن إضافة onUpgrade للـ migrations
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE students (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT,
        class_id INTEGER NOT NULL,
        created_at TEXT
      )
    ''');

    // TODO: إضافة جداول teachers, classes, attendance, grades, subjects, timetable
  }

  Future close() async {
    final database = _db;
    if (database != null) {
      await database.close();
      _db = null;
    }
  }
}
