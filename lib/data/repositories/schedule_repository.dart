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

    final validSchedules = <ScheduleModel>[];
    
    for (final schedule in allSchedules) {
      if (!schedule.isActiveOnDate(date)) continue;
      
      if (!schedule.isActiveOnDay(dayOfWeek)) continue;
      
      final scheduleWithSlots = await _loadTimeSlots(schedule);
      validSchedules.add(scheduleWithSlots);
    }

    return validSchedules;
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

    if (scheduleWithDates.enableNotification) {
      await _scheduleNotifications(scheduleWithDates.copyWith(id: id));
    }

    return id;
  }

  Future<int> updateSchedule(ScheduleModel schedule) async {
    final updatedSchedule = schedule.copyWith(updatedAt: DateTime.now());

    if (schedule.id != null) {
      await _notificationService.cancelNotification(schedule.id!);
    }

    final result = await _dbService.update(
      AppConstants.tableSchedules,
      updatedSchedule.toMap(),
      'id = ?',
      [schedule.id],
    );

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

  Future<ScheduleModel> _loadTimeSlots(ScheduleModel schedule) async {
    if (schedule.id == null) return schedule;
    
    final db = await _dbService.database;
    final maps = await db.query(
      AppConstants.tableScheduleTimeSlots,
      where: 'schedule_id = ?',
      whereArgs: [schedule.id],
    );
    
    if (maps.isEmpty) return schedule;
    
    final timeSlots = <int, TimeSlot>{};
    for (final map in maps) {
      final dayOfWeek = map['day_of_week'] as int;
      timeSlots[dayOfWeek] = TimeSlot.fromMap(map);
    }
    
    return schedule.copyWith(timeSlots: timeSlots);
  }

  Future<void> saveTimeSlots(int scheduleId, Map<int, TimeSlot> timeSlots) async {
    final db = await _dbService.database;
    
    await db.delete(
      AppConstants.tableScheduleTimeSlots,
      where: 'schedule_id = ?',
      whereArgs: [scheduleId],
    );
    
    for (final entry in timeSlots.entries) {
      await db.insert(
        AppConstants.tableScheduleTimeSlots,
        entry.value.toMap(scheduleId, entry.key),
      );
    }
  }

  Future<bool> isCheckedToday(int scheduleId, DateTime date) async {
    final dateStr = DateHelper.formatDate(date);
    final db = await _dbService.database;
    
    final maps = await db.query(
      AppConstants.tableScheduleCheckins,
      where: 'schedule_id = ? AND check_date = ?',
      whereArgs: [scheduleId, dateStr],
    );
    
    return maps.isNotEmpty;
  }

  Future<void> toggleCheckin(int scheduleId, DateTime date) async {
    final dateStr = DateHelper.formatDate(date);
    final db = await _dbService.database;
    
    final existing = await db.query(
      AppConstants.tableScheduleCheckins,
      where: 'schedule_id = ? AND check_date = ?',
      whereArgs: [scheduleId, dateStr],
    );
    
    if (existing.isNotEmpty) {
      await db.delete(
        AppConstants.tableScheduleCheckins,
        where: 'schedule_id = ? AND check_date = ?',
        whereArgs: [scheduleId, dateStr],
      );
    } else {
      await db.insert(
        AppConstants.tableScheduleCheckins,
        {
          'schedule_id': scheduleId,
          'check_date': dateStr,
          'checked_at': DateTime.now().toIso8601String(),
        },
      );
    }
  }
}