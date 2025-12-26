import '../models/task_model.dart';
import '../services/database_service.dart';
import '../services/notification_service.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/date_helper.dart';

class TaskRepository {
  final DatabaseService _dbService = DatabaseService.instance;
  final NotificationService _notificationService = NotificationService.instance;

  Future<List<TaskModel>> getAllTasks() async {
    final maps = await _dbService.queryAll(AppConstants.tableTasks);
    return maps.map((map) => TaskModel.fromMap(map)).toList();
  }

  Future<List<TaskModel>> getPendingTasks() async {
    final maps = await _dbService.queryWhere(
      AppConstants.tableTasks,
      'status = ?',
      ['pending'],
    );
    return maps.map((map) => TaskModel.fromMap(map)).toList();
  }

  Future<List<TaskModel>> getCompletedTasks() async {
    final maps = await _dbService.queryWhere(
      AppConstants.tableTasks,
      'status = ?',
      ['completed'],
    );
    return maps.map((map) => TaskModel.fromMap(map)).toList();
  }

  Future<List<TaskModel>> getTodayTasks() async {
    final today = DateHelper.formatDate(DateTime.now());
    final maps = await _dbService.queryWhere(
      AppConstants.tableTasks,
      'date(due_date) = ? AND status = ?',
      [today, 'pending'],
    );
    return maps.map((map) => TaskModel.fromMap(map)).toList();
  }

  Future<List<TaskModel>> getUpcomingTasks() async {
    final today = DateTime.now();
    final maps = await _dbService.queryWhere(
      AppConstants.tableTasks,
      'due_date > ? AND status = ?',
      [today.toIso8601String(), 'pending'],
    );
    return maps.map((map) => TaskModel.fromMap(map)).toList();
  }

  Future<List<TaskModel>> getOverdueTasks() async {
    final now = DateTime.now();
    final maps = await _dbService.queryWhere(
      AppConstants.tableTasks,
      'due_date < ? AND status = ?',
      [now.toIso8601String(), 'pending'],
    );
    return maps.map((map) => TaskModel.fromMap(map)).toList();
  }

  Future<List<TaskModel>> getTasksByPriority(String priority) async {
    final maps = await _dbService.queryWhere(
      AppConstants.tableTasks,
      'priority = ? AND status = ?',
      [priority, 'pending'],
    );
    return maps.map((map) => TaskModel.fromMap(map)).toList();
  }

  Future<TaskModel?> getTaskById(int id) async {
    final maps = await _dbService.queryWhere(
      AppConstants.tableTasks,
      'id = ?',
      [id],
    );
    if (maps.isEmpty) return null;
    return TaskModel.fromMap(maps.first);
  }

  Future<int> insertTask(TaskModel task) async {
    final now = DateTime.now();
    final taskWithDates = task.copyWith(
      createdAt: now,
      updatedAt: now,
    );

    final id = await _dbService.insert(
      AppConstants.tableTasks,
      taskWithDates.toMap(),
    );

    // Schedule notification if enabled and has due date
    if (taskWithDates.enableNotification && taskWithDates.dueDate != null) {
      await _scheduleTaskNotification(taskWithDates.copyWith(id: id));
    }

    return id;
  }

  Future<int> updateTask(TaskModel task) async {
    final updatedTask = task.copyWith(updatedAt: DateTime.now());

    // Cancel existing notification
    if (task.id != null) {
      await _notificationService.cancelNotification(task.id! + 10000);
    }

    final result = await _dbService.update(
      AppConstants.tableTasks,
      updatedTask.toMap(),
      'id = ?',
      [task.id],
    );

    // Reschedule notification if enabled
    if (updatedTask.enableNotification && updatedTask.dueDate != null) {
      await _scheduleTaskNotification(updatedTask);
    }

    return result;
  }

  Future<int> deleteTask(int id) async {
    await _notificationService.cancelNotification(id + 10000);
    return await _dbService.delete(
      AppConstants.tableTasks,
      'id = ?',
      [id],
    );
  }

  Future<int> toggleTaskStatus(int id) async {
    final task = await getTaskById(id);
    if (task == null) return 0;

    final newStatus = task.isCompleted ? 'pending' : 'completed';
    return await updateTask(task.copyWith(status: newStatus));
  }

  Future<void> _scheduleTaskNotification(TaskModel task) async {
    if (task.id == null || task.dueDate == null) return;

    // Schedule notification 1 hour before due date
    final notificationTime = task.dueDate!.subtract(const Duration(hours: 1));

    if (notificationTime.isAfter(DateTime.now())) {
      await _notificationService.scheduleNotification(
        id: task.id! + 10000, // Offset to avoid conflict with schedule IDs
        title: 'Task Due Soon',
        body: task.title,
        scheduledTime: notificationTime,
        channelId: AppConstants.taskChannelId,
      );
    }
  }
}