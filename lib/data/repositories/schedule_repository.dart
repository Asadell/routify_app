import '../models/schedule_model.dart';
import '../services/database_service.dart';
import '../services/notification_service.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/date_helper.dart';

class ScheduleRepository {
  final DatabaseService _dbService = DatabaseService.instance;
  final NotificationService _notificationService = NotificationService.instance;

  Future<List<ScheduleModel>> getAllSchedules() async {
    final maps = await _dbService.queryAll(AppConstants.tableSchedules);
    return maps.map((map) => ScheduleModel.fromMap(map)).toList();
  }

  Future<List<ScheduleModel>> getActiveSchedules() async {
    final maps = await _dbService.queryWhere(
      AppConstants.tableSchedules,
      'is_active = ?',
      [1],
    );
    return maps.map((map) => ScheduleModel.fromMap(map)).toList();
  }

  Future<List<ScheduleModel>> getSchedulesForDay(DateTime date) async {
    final allSchedules = await getActiveSchedules();
    final dayOfWeek = DateHelper.getDayOfWeek(date);

    return allSchedules.where((schedule) {
      return schedule.isActiveOnDay(dayOfWeek);
    }).toList();
  }

  Future<List<ScheduleModel>> getTodaySchedules() async {
    return getSchedulesForDay(DateTime.now());
  }

  Future<ScheduleModel?> getScheduleById(int id) async {
    final maps = await _dbService.queryWhere(
      AppConstants.tableSchedules,
      'id = ?',
      [id],
    );
    if (maps.isEmpty) return null;
    return ScheduleModel.fromMap(maps.first);
  }

  Future<int> insertSchedule(ScheduleModel schedule) async {
    final now = DateTime.now();
    final scheduleWithDates = schedule.copyWith(
      createdAt: now,
      updatedAt: now,
    );

    final id = await _dbService.insert(
      AppConstants.tableSchedules,
      scheduleWithDates.toMap(),
    );

    // Schedule notifications if enabled
    if (scheduleWithDates.enableNotification) {
      await _scheduleNotifications(scheduleWithDates.copyWith(id: id));
    }

    return id;
  }

  Future<int> updateSchedule(ScheduleModel schedule) async {
    final updatedSchedule = schedule.copyWith(updatedAt: DateTime.now());

    // Cancel existing notifications
    if (schedule.id != null) {
      await _notificationService.cancelNotification(schedule.id!);
    }

    final result = await _dbService.update(
      AppConstants.tableSchedules,
      updatedSchedule.toMap(),
      'id = ?',
      [schedule.id],
    );

    // Reschedule notifications if enabled
    if (updatedSchedule.enableNotification && updatedSchedule.isActive) {
      await _scheduleNotifications(updatedSchedule);
    }

    return result;
  }

  Future<int> deleteSchedule(int id) async {
    await _notificationService.cancelNotification(id);
    return await _dbService.delete(
      AppConstants.tableSchedules,
      'id = ?',
      [id],
    );
  }

  Future<void> _scheduleNotifications(ScheduleModel schedule) async {
    if (schedule.id == null) return;

    // Parse start time
    final startTime = DateHelper.parseTime(schedule.startTime);
    if (startTime == null) return;

    final now = DateTime.now();
    final scheduledTime = DateTime(
      now.year,
      now.month,
      now.day,
      startTime.hour,
      startTime.minute,
    );

    // Only schedule if time is in the future today
    if (scheduledTime.isAfter(now)) {
      final dayOfWeek = DateHelper.getDayOfWeek(scheduledTime);
      if (schedule.isActiveOnDay(dayOfWeek)) {
        await _notificationService.scheduleNotification(
          id: schedule.id!,
          title: schedule.title,
          body: 'Scheduled at ${schedule.startTime}',
          scheduledTime: scheduledTime,
          channelId: AppConstants.scheduleChannelId,
        );
      }
    }
  }

  Future<void> activateAllSchedules() async {
    final db = await DatabaseService.instance.database;

    await db.update(
      AppConstants.tableSchedules,
      {'is_active': 1},
    );
  }
}