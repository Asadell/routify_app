import '../models/workout_model.dart';
import '../models/exercise_model.dart';
import '../models/workout_history_model.dart';
import '../services/database_service.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/date_helper.dart';

class WorkoutRepository {
  final DatabaseService _dbService = DatabaseService.instance;

  Future<List<int>> _getWorkoutDays(int workoutId) async {
    final maps = await _dbService.queryWhere(
      AppConstants.tableWorkoutDays,
      'workout_id = ?',
      [workoutId],
    );
    return maps.map((m) => m['day_of_week'] as int).toList();
  }

  Future<void> _saveWorkoutDays(int workoutId, List<int> days) async {
    await _dbService.delete(
      AppConstants.tableWorkoutDays,
      'workout_id = ?',
      [workoutId],
    );

    for (final day in days) {
      await _dbService.insert(
        AppConstants.tableWorkoutDays,
        {
          'workout_id': workoutId,
          'day_of_week': day,
        },
      );
    }
  }

  Future<List<WorkoutModel>> getAllWorkouts() async {
    final maps = await _dbService.queryAll(AppConstants.tableWorkouts);
    final workouts = <WorkoutModel>[];

    for (final map in maps) {
      final workoutId = map['id'] as int;
      final days = await _getWorkoutDays(workoutId);
      final workout = WorkoutModel.fromMap(map, daysOfWeek: days);
      final exercises = await getExercisesForWorkout(workoutId);
      workouts.add(workout.copyWith(exercises: exercises));
    }

    return workouts;
  }

  Future<List<WorkoutModel>> getWorkoutsForDay(int dayOfWeek) async {
    final db = await _dbService.database;
    final maps = await db.rawQuery('''
      SELECT DISTINCT w.* FROM ${AppConstants.tableWorkouts} w
      INNER JOIN ${AppConstants.tableWorkoutDays} wd ON w.id = wd.workout_id
      WHERE wd.day_of_week = ?
    ''', [dayOfWeek]);

    final workouts = <WorkoutModel>[];
    for (final map in maps) {
      final workoutId = map['id'] as int;
      final days = await _getWorkoutDays(workoutId);
      final workout = WorkoutModel.fromMap(map, daysOfWeek: days);
      final exercises = await getExercisesForWorkout(workoutId);
      workouts.add(workout.copyWith(exercises: exercises));
    }

    return workouts;
  }

  Future<WorkoutModel?> getWorkoutById(int id) async {
    final maps = await _dbService.queryWhere(
      AppConstants.tableWorkouts,
      'id = ?',
      [id],
    );
    if (maps.isEmpty) return null;

    final days = await _getWorkoutDays(id);
    final workout = WorkoutModel.fromMap(maps.first, daysOfWeek: days);
    final exercises = await getExercisesForWorkout(id);
    return workout.copyWith(exercises: exercises);
  }

  Future<int> insertWorkout(WorkoutModel workout) async {
    final id = await _dbService.insert(
      AppConstants.tableWorkouts,
      workout.toMap(),
    );

    // Save days
    await _saveWorkoutDays(id, workout.daysOfWeek);

    // Insert exercises
    for (final exercise in workout.exercises) {
      await insertExercise(exercise.copyWith(workoutId: id));
    }

    return id;
  }

  Future<int> updateWorkout(WorkoutModel workout) async {
    final result = await _dbService.update(
      AppConstants.tableWorkouts,
      workout.toMap(),
      'id = ?',
      [workout.id],
    );

    // Update days
    await _saveWorkoutDays(workout.id!, workout.daysOfWeek);

    // Delete old exercises and insert new ones
    await _dbService.delete(
      AppConstants.tableExercises,
      'workout_id = ?',
      [workout.id],
    );

    for (final exercise in workout.exercises) {
      await insertExercise(exercise.copyWith(workoutId: workout.id!));
    }

    return result;
  }

  Future<List<WorkoutModel>> getTodayWorkouts() async {
    final today = DateTime.now();
    final dayOfWeek = DateHelper.getDayOfWeek(today);
    return getWorkoutsForDay(dayOfWeek);
  }

  Future<Map<int, List<WorkoutModel>>> getWorkoutsForWeek(DateTime date) async {
    // final startOfWeek = DateHelper.getStartOfWeek(date);
    final weekWorkouts = <int, List<WorkoutModel>>{};

    for (int i = 0; i < 7; i++) {
      final dayWorkouts = await getWorkoutsForDay(i);
      weekWorkouts[i] = dayWorkouts;
    }

    return weekWorkouts;
  }

  Future<int> deleteWorkout(int id) async {
    await _dbService.delete(
      AppConstants.tableExercises,
      'workout_id = ?',
      [id],
    );

    return await _dbService.delete(
      AppConstants.tableWorkouts,
      'id = ?',
      [id],
    );
  }

  // ===== Exercise CRUD =====

  Future<List<ExerciseModel>> getExercisesForWorkout(int workoutId) async {
    final maps = await _dbService.queryWhere(
      AppConstants.tableExercises,
      'workout_id = ?',
      [workoutId],
    );
    return maps.map((map) => ExerciseModel.fromMap(map)).toList();
  }

  Future<int> insertExercise(ExerciseModel exercise) async {
    return await _dbService.insert(
      AppConstants.tableExercises,
      exercise.toMap(),
    );
  }

  Future<int> updateExercise(ExerciseModel exercise) async {
    return await _dbService.update(
      AppConstants.tableExercises,
      exercise.toMap(),
      'id = ?',
      [exercise.id],
    );
  }

  Future<int> deleteExercise(int id) async {
    return await _dbService.delete(
      AppConstants.tableExercises,
      'id = ?',
      [id],
    );
  }

  // ===== Workout History CRUD =====

  Future<List<WorkoutHistoryModel>> getAllHistory() async {
    final maps = await _dbService.queryAll(AppConstants.tableWorkoutHistory);
    return maps.map((map) => WorkoutHistoryModel.fromMap(map)).toList();
  }

  Future<List<WorkoutHistoryModel>> getHistoryForDate(DateTime date) async {
    final dateStr = DateHelper.formatDate(date);
    final maps = await _dbService.queryWhere(
      AppConstants.tableWorkoutHistory,
      'date(date) = ?',
      [dateStr],
    );
    return maps.map((map) => WorkoutHistoryModel.fromMap(map)).toList();
  }

  Future<List<WorkoutHistoryModel>> getHistoryForWeek(DateTime date) async {
    final startOfWeek = DateHelper.getStartOfWeek(date);
    final endOfWeek = DateHelper.getEndOfWeek(date);

    final maps = await _dbService.queryWhere(
      AppConstants.tableWorkoutHistory,
      'date >= ? AND date <= ?',
      [startOfWeek.toIso8601String(), endOfWeek.toIso8601String()],
    );
    return maps.map((map) => WorkoutHistoryModel.fromMap(map)).toList();
  }

  Future<List<WorkoutHistoryModel>> getHistoryForMonth(DateTime date) async {
    final startOfMonth = DateTime(date.year, date.month, 1);
    final endOfMonth = DateTime(date.year, date.month + 1, 0);

    final maps = await _dbService.queryWhere(
      AppConstants.tableWorkoutHistory,
      'date >= ? AND date <= ?',
      [startOfMonth.toIso8601String(), endOfMonth.toIso8601String()],
    );
    return maps.map((map) => WorkoutHistoryModel.fromMap(map)).toList();
  }

  Future<int> insertHistory(WorkoutHistoryModel history) async {
    return await _dbService.insert(
      AppConstants.tableWorkoutHistory,
      history.toMap(),
    );
  }

  Future<int> updateHistory(WorkoutHistoryModel history) async {
    return await _dbService.update(
      AppConstants.tableWorkoutHistory,
      history.toMap(),
      'id = ?',
      [history.id],
    );
  }

  Future<int> deleteHistory(int id) async {
    return await _dbService.delete(
      AppConstants.tableWorkoutHistory,
      'id = ?',
      [id],
    );
  }

  // ===== Statistics =====

  Future<Map<String, int>> getWeeklyStats(DateTime date) async {
    final history = await getHistoryForWeek(date);
    final workouts = await getWorkoutsForWeek(date);

    int completed = history.length;
    int planned = 0;
    int totalMinutes = 0;

    // Count planned workouts
    workouts.forEach((day, dayWorkouts) {
      planned += dayWorkouts.length;
    });

    // Sum actual duration
    for (final h in history) {
      totalMinutes += h.actualDuration ?? 0;
    }

    return {
      'completed': completed,
      'planned': planned,
      'minutes': totalMinutes,
    };
  }

  Future<Map<String, dynamic>> getMonthlyStats(DateTime date) async {
    final history = await getHistoryForMonth(date);

    int totalWorkouts = history.length;
    int totalMinutes = 0;
    int totalExercises = 0;

    for (final h in history) {
      totalMinutes += h.actualDuration ?? 0;
    }

    // Count exercises would require more complex query
    // For now, we'll estimate based on average
    totalExercises = totalWorkouts * 5; // Estimate

    double avgDuration = totalWorkouts > 0 ? totalMinutes / totalWorkouts : 0;

    return {
      'total_workouts': totalWorkouts,
      'total_minutes': totalMinutes,
      'total_exercises': totalExercises,
      'avg_duration': avgDuration.round(),
    };
  }
}