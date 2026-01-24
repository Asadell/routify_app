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
    // =========================
    // SCHEDULES
    // =========================
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
        start_date TEXT,
        end_date TEXT,
        created_at TEXT,
        updated_at TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE ${AppConstants.tableScheduleTimeSlots} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        schedule_id INTEGER NOT NULL,
        day_of_week INTEGER NOT NULL,
        start_time TEXT NOT NULL,
        end_time TEXT NOT NULL,
        FOREIGN KEY(schedule_id) REFERENCES ${AppConstants.tableSchedules}(id) ON DELETE CASCADE,
        UNIQUE(schedule_id, day_of_week)
      )
    ''');

    await db.execute('''
      CREATE TABLE ${AppConstants.tableScheduleCheckins} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        schedule_id INTEGER NOT NULL,
        check_date TEXT NOT NULL,
        checked_at TEXT NOT NULL,
        FOREIGN KEY(schedule_id) REFERENCES ${AppConstants.tableSchedules}(id) ON DELETE CASCADE,
        UNIQUE(schedule_id, check_date)
      )
    ''');

    // =========================
    // TASKS
    // =========================
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

    // =========================
    // WORKOUTS
    // =========================
    await db.execute('''
      CREATE TABLE ${AppConstants.tableWorkouts} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        estimated_duration INTEGER,
        notes TEXT,
        enable_notification INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE ${AppConstants.tableWorkoutDays} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        workout_id INTEGER NOT NULL,
        day_of_week INTEGER NOT NULL,
        FOREIGN KEY(workout_id) REFERENCES ${AppConstants.tableWorkouts}(id) ON DELETE CASCADE,
        UNIQUE(workout_id, day_of_week)
      )
    ''');

    // =========================
    // EXERCISES
    // =========================
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

    // =========================
    // WORKOUT HISTORY
    // =========================
    await db.execute('''
      CREATE TABLE ${AppConstants.tableWorkoutHistory} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        workout_name TEXT NOT NULL,
        date TEXT NOT NULL,
        actual_duration INTEGER,
        notes TEXT
      )
    ''');

    await _insertDummyData(db);
  }

  // =========================
  // DUMMY DATA
  // =========================
  Future<void> _insertDummyData(Database db) async {
    final now = DateTime.now();
    final nowStr = now.toIso8601String();
    final today = now.toIso8601String().substring(0, 10);
    final yesterday = now.subtract(const Duration(days: 1)).toIso8601String().substring(0, 10);
    final tomorrow = now.add(const Duration(days: 1)).toIso8601String().substring(0, 10);

    // =========================
    // SCHEDULES DUMMY
    // =========================
    
    // 1️⃣ Simple daily schedule (use_all_7_days)
    final dailyStandupId = await db.insert(AppConstants.tableSchedules, {
      'title': 'Daily Standup',
      'description': 'Daily team sync meeting',
      'start_time': '09:00',
      'end_time': '09:30',
      'use_all_7_days': 1,
      'enable_notification': 1,
      'created_at': nowStr,
      'updated_at': nowStr,
    });

    // 2️⃣ Weekday schedule (Mon–Fri only)
    final officeWorkId = await db.insert(AppConstants.tableSchedules, {
      'title': 'Office Work',
      'description': 'Regular work hours',
      'start_time': '09:00',
      'end_time': '17:00',
      'repeat_mon': 1,
      'repeat_tue': 1,
      'repeat_wed': 1,
      'repeat_thu': 1,
      'repeat_fri': 1,
      'enable_notification': 1,
      'created_at': nowStr,
      'updated_at': nowStr,
    });

    // 3️⃣ Weekend schedule (Sat–Sun only)
    final gymId = await db.insert(AppConstants.tableSchedules, {
      'title': 'Weekend Gym Session',
      'description': 'Morning workout at the gym',
      'start_time': '07:00',
      'end_time': '08:30',
      'repeat_sat': 1,
      'repeat_sun': 1,
      'enable_notification': 1,
      'created_at': nowStr,
      'updated_at': nowStr,
    });

    // 4️⃣ Schedule with date range (30 days bootcamp)
    final bootcamp30Id = await db.insert(AppConstants.tableSchedules, {
      'title': '30 Days Challenge',
      'description': 'Intensive fitness program',
      'start_time': '19:00',
      'end_time': '21:00',
      'use_all_7_days': 1,
      'start_date': now.toIso8601String(),
      'end_date': now.add(const Duration(days: 30)).toIso8601String(),
      'enable_notification': 1,
      'created_at': nowStr,
      'updated_at': nowStr,
    });

    // 5️⃣ Bootcamp schedule (custom time per day) - MODE BOOTCAMP
    final flutterBootcampId = await db.insert(AppConstants.tableSchedules, {
      'title': 'Flutter Bootcamp',
      'description': 'Different time each day',
      'start_time': '00:00', // Default, akan override by time slots
      'end_time': '00:00',
      'enable_notification': 1,
      'created_at': nowStr,
      'updated_at': nowStr,
    });

    // Time slots untuk Flutter Bootcamp (bootcamp mode)
    final bootcampTimeSlots = [
      {'day': 1, 'start': '08:00', 'end': '10:00'}, // Monday
      {'day': 2, 'start': '09:00', 'end': '11:00'}, // Tuesday
      {'day': 3, 'start': '14:00', 'end': '16:00'}, // Wednesday
      {'day': 4, 'start': '13:00', 'end': '15:00'}, // Thursday
      {'day': 5, 'start': '08:30', 'end': '10:30'}, // Friday
    ];

    for (final slot in bootcampTimeSlots) {
      await db.insert(AppConstants.tableScheduleTimeSlots, {
        'schedule_id': flutterBootcampId,
        'day_of_week': slot['day'],
        'start_time': slot['start'],
        'end_time': slot['end'],
      });
    }

    // 6️⃣ Another bootcamp with all 7 days custom time
    final yogaBootcampId = await db.insert(AppConstants.tableSchedules, {
      'title': 'Yoga Bootcamp',
      'description': 'Morning yoga every day with different duration',
      'start_time': '00:00',
      'end_time': '00:00',
      'enable_notification': 1,
      'created_at': nowStr,
      'updated_at': nowStr,
    });

    final yogaTimeSlots = [
      {'day': 1, 'start': '06:00', 'end': '07:00'}, // Monday
      {'day': 2, 'start': '06:00', 'end': '07:30'}, // Tuesday
      {'day': 3, 'start': '06:00', 'end': '07:00'}, // Wednesday
      {'day': 4, 'start': '06:00', 'end': '08:00'}, // Thursday
      {'day': 5, 'start': '06:00', 'end': '07:00'}, // Friday
      {'day': 6, 'start': '07:00', 'end': '09:00'}, // Saturday
      {'day': 0, 'start': '07:00', 'end': '09:00'}, // Sunday
    ];

    for (final slot in yogaTimeSlots) {
      await db.insert(AppConstants.tableScheduleTimeSlots, {
        'schedule_id': yogaBootcampId,
        'day_of_week': slot['day'],
        'start_time': slot['start'],
        'end_time': slot['end'],
      });
    }

    // 7️⃣ Specific days only (Mon, Wed, Fri)
    await db.insert(AppConstants.tableSchedules, {
      'title': 'Cardio Training',
      'description': 'Alternate day cardio',
      'start_time': '06:00',
      'end_time': '07:00',
      'repeat_mon': 1,
      'repeat_wed': 1,
      'repeat_fri': 1,
      'enable_notification': 1,
      'created_at': nowStr,
      'updated_at': nowStr,
    });

    // 8️⃣ Inactive schedule
    await db.insert(AppConstants.tableSchedules, {
      'title': 'Old Schedule',
      'description': 'No longer active',
      'start_time': '10:00',
      'end_time': '11:00',
      'use_all_7_days': 1,
      'is_active': 0,
      'created_at': nowStr,
      'updated_at': nowStr,
    });

    // 9️⃣ Schedule with past date range (expired)
    await db.insert(AppConstants.tableSchedules, {
      'title': 'Past Bootcamp',
      'description': 'Already finished',
      'start_time': '18:00',
      'end_time': '20:00',
      'use_all_7_days': 1,
      'start_date': now.subtract(const Duration(days: 30)).toIso8601String(),
      'end_date': now.subtract(const Duration(days: 1)).toIso8601String(),
      'created_at': nowStr,
      'updated_at': nowStr,
    });

    // =========================
    // SCHEDULE CHECK-INS DUMMY
    // =========================
    
    // Check-ins for Daily Standup
    await db.insert(AppConstants.tableScheduleCheckins, {
      'schedule_id': dailyStandupId,
      'check_date': today,
      'checked_at': nowStr,
    });

    await db.insert(AppConstants.tableScheduleCheckins, {
      'schedule_id': dailyStandupId,
      'check_date': yesterday,
      'checked_at': now.subtract(const Duration(days: 1)).toIso8601String(),
    });

    // Check-ins for Office Work
    await db.insert(AppConstants.tableScheduleCheckins, {
      'schedule_id': officeWorkId,
      'check_date': today,
      'checked_at': nowStr,
    });

    // Check-ins for Bootcamp
    await db.insert(AppConstants.tableScheduleCheckins, {
      'schedule_id': flutterBootcampId,
      'check_date': today,
      'checked_at': nowStr,
    });

    // =========================
    // TASKS DUMMY
    // =========================
    
    // Today tasks
    await db.insert(AppConstants.tableTasks, {
      'title': 'Review pull requests',
      'description': 'Check and review team PRs on GitHub',
      'due_date': today,
      'priority': 'high',
      'status': 'pending',
      'enable_notification': 1,
      'created_at': nowStr,
      'updated_at': nowStr,
    });

    await db.insert(AppConstants.tableTasks, {
      'title': 'Update documentation',
      'description': 'Add API documentation for new endpoints',
      'due_date': today,
      'priority': 'medium',
      'status': 'pending',
      'enable_notification': 1,
      'created_at': nowStr,
      'updated_at': nowStr,
    });

    await db.insert(AppConstants.tableTasks, {
      'title': 'Buy groceries',
      'description': 'Milk, eggs, bread, vegetables',
      'due_date': today,
      'priority': 'low',
      'status': 'pending',
      'enable_notification': 0,
      'created_at': nowStr,
      'updated_at': nowStr,
    });

    // Tomorrow tasks
    await db.insert(AppConstants.tableTasks, {
      'title': 'Client meeting presentation',
      'description': 'Prepare slides for Q1 review',
      'due_date': tomorrow,
      'priority': 'high',
      'status': 'pending',
      'enable_notification': 1,
      'created_at': nowStr,
      'updated_at': nowStr,
    });

    await db.insert(AppConstants.tableTasks, {
      'title': 'Fix login bug',
      'description': 'Users reporting issue with OAuth flow',
      'due_date': tomorrow,
      'priority': 'high',
      'status': 'pending',
      'enable_notification': 1,
      'created_at': nowStr,
      'updated_at': nowStr,
    });

    // Upcoming tasks
    final nextWeek = now.add(const Duration(days: 7)).toIso8601String().substring(0, 10);
    await db.insert(AppConstants.tableTasks, {
      'title': 'Deploy to production',
      'description': 'Release version 2.0',
      'due_date': nextWeek,
      'priority': 'high',
      'status': 'pending',
      'enable_notification': 1,
      'created_at': nowStr,
      'updated_at': nowStr,
    });

    await db.insert(AppConstants.tableTasks, {
      'title': 'Code refactoring',
      'description': 'Clean up legacy code in authentication module',
      'due_date': nextWeek,
      'priority': 'medium',
      'status': 'pending',
      'enable_notification': 0,
      'created_at': nowStr,
      'updated_at': nowStr,
    });

    // Completed tasks
    await db.insert(AppConstants.tableTasks, {
      'title': 'Setup CI/CD pipeline',
      'description': 'Configure GitHub Actions',
      'due_date': yesterday,
      'priority': 'high',
      'status': 'completed',
      'enable_notification': 0,
      'created_at': nowStr,
      'updated_at': nowStr,
    });

    await db.insert(AppConstants.tableTasks, {
      'title': 'Write unit tests',
      'description': 'Add tests for user service',
      'due_date': yesterday,
      'priority': 'medium',
      'status': 'completed',
      'enable_notification': 0,
      'created_at': nowStr,
      'updated_at': nowStr,
    });

    // Overdue task
    final lastWeek = now.subtract(const Duration(days: 7)).toIso8601String().substring(0, 10);
    await db.insert(AppConstants.tableTasks, {
      'title': 'Performance optimization',
      'description': 'Improve app loading time',
      'due_date': lastWeek,
      'priority': 'low',
      'status': 'pending',
      'enable_notification': 0,
      'created_at': nowStr,
      'updated_at': nowStr,
    });

    // Tasks without due date
    await db.insert(AppConstants.tableTasks, {
      'title': 'Research new framework',
      'description': 'Evaluate Flutter alternatives',
      'due_date': null,
      'priority': 'low',
      'status': 'pending',
      'enable_notification': 0,
      'created_at': nowStr,
      'updated_at': nowStr,
    });

    // =========================
    // WORKOUTS DUMMY
    // =========================
    
    // Workout 1: Full Body (Mon, Wed, Fri)
    final fullBodyId = await db.insert(AppConstants.tableWorkouts, {
      'name': 'Full Body Workout',
      'estimated_duration': 60,
      'notes': 'Complete body workout with compound exercises',
      'enable_notification': 1,
    });

    await db.insert(AppConstants.tableWorkoutDays, {
      'workout_id': fullBodyId,
      'day_of_week': 1, // Monday
    });
    await db.insert(AppConstants.tableWorkoutDays, {
      'workout_id': fullBodyId,
      'day_of_week': 3, // Wednesday
    });
    await db.insert(AppConstants.tableWorkoutDays, {
      'workout_id': fullBodyId,
      'day_of_week': 5, // Friday
    });

    // Exercises for Full Body
    await db.insert(AppConstants.tableExercises, {
      'workout_id': fullBodyId,
      'name': 'Squats',
      'sets': 4,
      'reps': 12,
      'weight': 80.0,
    });
    await db.insert(AppConstants.tableExercises, {
      'workout_id': fullBodyId,
      'name': 'Bench Press',
      'sets': 4,
      'reps': 10,
      'weight': 60.0,
    });
    await db.insert(AppConstants.tableExercises, {
      'workout_id': fullBodyId,
      'name': 'Deadlift',
      'sets': 3,
      'reps': 8,
      'weight': 100.0,
    });
    await db.insert(AppConstants.tableExercises, {
      'workout_id': fullBodyId,
      'name': 'Pull-ups',
      'sets': 3,
      'reps': 10,
      'weight': null,
    });

    // Workout 2: Cardio (Tue, Thu)
    final cardioId = await db.insert(AppConstants.tableWorkouts, {
      'name': 'Cardio Session',
      'estimated_duration': 45,
      'notes': 'High intensity interval training',
      'enable_notification': 1,
    });

    await db.insert(AppConstants.tableWorkoutDays, {
      'workout_id': cardioId,
      'day_of_week': 2, // Tuesday
    });
    await db.insert(AppConstants.tableWorkoutDays, {
      'workout_id': cardioId,
      'day_of_week': 4, // Thursday
    });

    // Exercises for Cardio
    await db.insert(AppConstants.tableExercises, {
      'workout_id': cardioId,
      'name': 'Running',
      'sets': null,
      'reps': null,
      'duration_minutes': 20,
      'weight': null,
    });
    await db.insert(AppConstants.tableExercises, {
      'workout_id': cardioId,
      'name': 'Jump Rope',
      'sets': 5,
      'reps': null,
      'duration_minutes': 3,
      'weight': null,
    });
    await db.insert(AppConstants.tableExercises, {
      'workout_id': cardioId,
      'name': 'Burpees',
      'sets': 3,
      'reps': 15,
      'weight': null,
    });

    // Workout 3: Upper Body (Sat)
    final upperBodyId = await db.insert(AppConstants.tableWorkouts, {
      'name': 'Upper Body Focus',
      'estimated_duration': 50,
      'notes': 'Chest, back, shoulders, and arms',
      'enable_notification': 1,
    });

    await db.insert(AppConstants.tableWorkoutDays, {
      'workout_id': upperBodyId,
      'day_of_week': 6, // Saturday
    });

    // Exercises for Upper Body
    await db.insert(AppConstants.tableExercises, {
      'workout_id': upperBodyId,
      'name': 'Shoulder Press',
      'sets': 4,
      'reps': 12,
      'weight': 40.0,
    });
    await db.insert(AppConstants.tableExercises, {
      'workout_id': upperBodyId,
      'name': 'Bicep Curls',
      'sets': 3,
      'reps': 15,
      'weight': 15.0,
    });
    await db.insert(AppConstants.tableExercises, {
      'workout_id': upperBodyId,
      'name': 'Tricep Dips',
      'sets': 3,
      'reps': 12,
      'weight': null,
    });
    await db.insert(AppConstants.tableExercises, {
      'workout_id': upperBodyId,
      'name': 'Lat Pulldown',
      'sets': 4,
      'reps': 10,
      'weight': 50.0,
    });

    // Workout 4: Yoga (Sun)
    final yogaId = await db.insert(AppConstants.tableWorkouts, {
      'name': 'Sunday Yoga',
      'estimated_duration': 60,
      'notes': 'Relaxing yoga session for recovery',
      'enable_notification': 1,
    });

    await db.insert(AppConstants.tableWorkoutDays, {
      'workout_id': yogaId,
      'day_of_week': 0, // Sunday
    });

    // Exercises for Yoga
    await db.insert(AppConstants.tableExercises, {
      'workout_id': yogaId,
      'name': 'Sun Salutation',
      'sets': null,
      'reps': null,
      'duration_minutes': 10,
      'weight': null,
    });
    await db.insert(AppConstants.tableExercises, {
      'workout_id': yogaId,
      'name': 'Downward Dog',
      'sets': null,
      'reps': null,
      'duration_minutes': 5,
      'weight': null,
    });
    await db.insert(AppConstants.tableExercises, {
      'workout_id': yogaId,
      'name': 'Meditation',
      'sets': null,
      'reps': null,
      'duration_minutes': 15,
      'weight': null,
    });

    // Workout 5: No scheduled days (flexibility)
    final flexWorkoutId = await db.insert(AppConstants.tableWorkouts, {
      'name': 'Flexibility Training',
      'estimated_duration': 30,
      'notes': 'Can be done any day',
      'enable_notification': 0,
    });

    await db.insert(AppConstants.tableExercises, {
      'workout_id': flexWorkoutId,
      'name': 'Stretching',
      'sets': null,
      'reps': null,
      'duration_minutes': 15,
      'weight': null,
    });
    await db.insert(AppConstants.tableExercises, {
      'workout_id': flexWorkoutId,
      'name': 'Foam Rolling',
      'sets': null,
      'reps': null,
      'duration_minutes': 15,
      'weight': null,
    });

    // =========================
    // WORKOUT HISTORY DUMMY
    // =========================
    
    // Today's workout
    await db.insert(AppConstants.tableWorkoutHistory, {
      'workout_name': 'Full Body Workout',
      'date': today,
      'actual_duration': 65,
      'notes': 'Great session! Increased weight on squats',
    });

    // Yesterday's workout
    await db.insert(AppConstants.tableWorkoutHistory, {
      'workout_name': 'Cardio Session',
      'date': yesterday,
      'actual_duration': 42,
      'notes': 'Felt tired but completed all sets',
    });

    // Last week workouts
    final threeDaysAgo = now.subtract(const Duration(days: 3)).toIso8601String().substring(0, 10);
    await db.insert(AppConstants.tableWorkoutHistory, {
      'workout_name': 'Full Body Workout',
      'date': threeDaysAgo,
      'actual_duration': 58,
      'notes': 'Good form on deadlifts',
    });

    final fiveDaysAgo = now.subtract(const Duration(days: 5)).toIso8601String().substring(0, 10);
    await db.insert(AppConstants.tableWorkoutHistory, {
      'workout_name': 'Cardio Session',
      'date': fiveDaysAgo,
      'actual_duration': 50,
      'notes': 'Personal best on running distance',
    });

    final sixDaysAgo = now.subtract(const Duration(days: 6)).toIso8601String().substring(0, 10);
    await db.insert(AppConstants.tableWorkoutHistory, {
      'workout_name': 'Upper Body Focus',
      'date': sixDaysAgo,
      'actual_duration': 48,
      'notes': 'Shoulder press felt heavy',
    });

    final tenDaysAgo = now.subtract(const Duration(days: 10)).toIso8601String().substring(0, 10);
    await db.insert(AppConstants.tableWorkoutHistory, {
      'workout_name': 'Sunday Yoga',
      'date': tenDaysAgo,
      'actual_duration': 62,
      'notes': 'Very relaxing session',
    });

    // Older workout
    final twoWeeksAgo = now.subtract(const Duration(days: 14)).toIso8601String().substring(0, 10);
    await db.insert(AppConstants.tableWorkoutHistory, {
      'workout_name': 'Full Body Workout',
      'date': twoWeeksAgo,
      'actual_duration': 55,
      'notes': 'Started new program',
    });
  }

  // =========================
  // GENERIC CRUD
  // =========================
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

  Future<void> close() async {
    final db = await instance.database;
    await db.close();
  }
}