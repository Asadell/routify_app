import 'package:flutter/foundation.dart';
import '../data/models/schedule_model.dart';
import '../data/repositories/schedule_repository.dart';

class ScheduleProvider with ChangeNotifier {
  final ScheduleRepository _repository = ScheduleRepository();

  List<ScheduleModel> _schedules = [];
  List<ScheduleModel> _todaySchedules = [];
  bool _isLoading = false;
  String? _error;

  List<ScheduleModel> get schedules => _schedules;
  List<ScheduleModel> get todaySchedules => _todaySchedules;
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
    try {
      _todaySchedules = await _repository.getTodaySchedules();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
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

  Future<void> addSchedule(ScheduleModel schedule) async {
    try {
      await _repository.insertSchedule(schedule);
      await loadSchedules();
      await loadTodaySchedules();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateSchedule(ScheduleModel schedule) async {
    try {
      await _repository.updateSchedule(schedule);
      await loadSchedules();
      await loadTodaySchedules();
    } catch (e) {
      _error = e.toString();
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
}