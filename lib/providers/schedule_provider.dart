import 'package:flutter/foundation.dart';
import '../data/models/schedule_model.dart';
import '../data/repositories/schedule_repository.dart';

class ScheduleProvider with ChangeNotifier {
  final ScheduleRepository _repository = ScheduleRepository();

  List<ScheduleModel> _schedules = [];
  List<ScheduleModel> _todaySchedules = [];
  Map<int, bool> _checkedSchedules = {};
  bool _isLoading = false;
  String? _error;

  List<ScheduleModel> get schedules => _schedules;
  List<ScheduleModel> get todaySchedules => _todaySchedules;
  Map<int, bool> get checkedSchedules => _checkedSchedules;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadSchedules() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _schedules = await _repository.getAllSchedules();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadTodaySchedules() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _todaySchedules = await _repository.getTodaySchedules();
      
      final today = DateTime.now();
      for (final schedule in _todaySchedules) {
        if (schedule.id != null) {
          _checkedSchedules[schedule.id!] = 
              await _repository.isCheckedToday(schedule.id!, today);
        }
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<ScheduleModel>> getSchedulesForDay(DateTime date) async {
    try {
      return await _repository.getSchedulesForDay(date);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return [];
    }
  }

  Future<int> addSchedule(ScheduleModel schedule) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final id = await _repository.insertSchedule(schedule);
      await loadSchedules();
      return id;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateSchedule(ScheduleModel schedule) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.updateSchedule(schedule);
      
      if (schedule.id != null && schedule.timeSlots != null && schedule.timeSlots!.isNotEmpty) {
        await _repository.saveTimeSlots(schedule.id!, schedule.timeSlots!);
      } else if (schedule.id != null && schedule.timeSlots?.isEmpty == true) {
        await _repository.saveTimeSlots(schedule.id!, {});
      }
      
      await loadSchedules();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteSchedule(int id) async {
    try {
      await _repository.deleteSchedule(id);
      await loadSchedules();
      await loadTodaySchedules();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> toggleScheduleActive(ScheduleModel schedule) async {
    try {
      final updated = schedule.copyWith(isActive: !schedule.isActive);
      await _repository.updateSchedule(updated);
      await loadSchedules();
      await loadTodaySchedules();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> activateAllSchedules() async {
    try {
      await _repository.activateAllSchedules();
      await loadSchedules();
      await loadTodaySchedules();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> toggleScheduleCheckin(int scheduleId) async {
    try {
      final today = DateTime.now();
      await _repository.toggleCheckin(scheduleId, today);
      
      // Update local state
      _checkedSchedules[scheduleId] = 
          await _repository.isCheckedToday(scheduleId, today);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}