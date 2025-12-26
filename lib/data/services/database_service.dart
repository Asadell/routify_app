import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../core/constants/app_constants.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB(AppConstants.dbName);
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: AppConstants.dbVersion,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // Schedules table
    await db.execute('''
      CREATE TABLE ${AppConstants.tableSchedules} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT,
        start_time TEXT NOT NULL,
        end_time TEXT NOT NULL,
        repeat_mon INTEGER DEFAULT 0,
        repeat_tue INTEGER DEFAULT 0,
        repeat_wed INTEGER DEFAULT 0,
        repeat_thu INTEGER DEFAULT 0,
        repeat_fri INTEGER DEFAULT 0,
        repeat_sat INTEGER DEFAULT 0,
        repeat_sun INTEGER DEFAULT 0,
        use_all_7_days INTEGER DEFAULT 0,
        enable_notification INTEGER DEFAULT 0,
        is_active INTEGER DEFAULT 1,
        created_at TEXT,
        updated_at TEXT
      )
    ''');

    // Tasks table
    await db.execute('''
      CREATE TABLE ${AppConstants.tableTasks} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT,
        due_date TEXT,
        priority TEXT,
        status TEXT DEFAULT 'pending',
        enable_notification INTEGER DEFAULT 0,
        created_at TEXT,
        updated_at TEXT
      )
    ''');

    // Workouts table
    await db.execute('''
      CREATE TABLE ${AppConstants.tableWorkouts} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        day_of_week INTEGER NOT NULL,
        name TEXT NOT NULL,
        estimated_duration INTEGER,
        notes TEXT,
        enable_notification INTEGER DEFAULT 0
      )
    ''');

    // Exercises table
    await db.execute('''
      CREATE TABLE ${AppConstants.tableExercises} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        workout_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        sets INTEGER,
        reps INTEGER,
        duration_minutes INTEGER,
        weight REAL,
        FOREIGN KEY(workout_id) REFERENCES ${AppConstants.tableWorkouts}(id) ON DELETE CASCADE
      )
    ''');

    // Workout history table
    await db.execute('''
      CREATE TABLE ${AppConstants.tableWorkoutHistory} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        workout_name TEXT NOT NULL,
        date TEXT NOT NULL,
        actual_duration INTEGER,
        notes TEXT
      )
    ''');
  }

  Future<void> close() async {
    final db = await instance.database;
    await db.close();
  }

  // Generic CRUD operations
  Future<int> insert(String table, Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert(table, row);
  }

  Future<List<Map<String, dynamic>>> queryAll(String table) async {
    final db = await instance.database;
    return await db.query(table);
  }

  Future<List<Map<String, dynamic>>> queryWhere(
    String table,
    String where,
    List<dynamic> whereArgs,
  ) async {
    final db = await instance.database;
    return await db.query(table, where: where, whereArgs: whereArgs);
  }

  Future<int> update(
    String table,
    Map<String, dynamic> row,
    String where,
    List<dynamic> whereArgs,
  ) async {
    final db = await instance.database;
    return await db.update(table, row, where: where, whereArgs: whereArgs);
  }

  Future<int> delete(
    String table,
    String where,
    List<dynamic> whereArgs,
  ) async {
    final db = await instance.database;
    return await db.delete(table, where: where, whereArgs: whereArgs);
  }
}