class AppConstants {
  // Database
  static const String dbName = 'daily_plannerv1.db';
  static const int dbVersion = 1;

  // Tables
  static const String tableSchedules = 'schedules';
  static const String tableTasks = 'tasks';
  static const String tableWorkouts = 'workouts';
  static const String tableExercises = 'exercises';
  static const String tableWorkoutHistory = 'workout_history';

  // Notification channels
  static const String scheduleChannelId = 'schedule_channel';
  static const String taskChannelId = 'task_channel';
  static const String workoutChannelId = 'workout_channel';
}