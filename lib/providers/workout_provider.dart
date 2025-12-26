import 'package:flutter/foundation.dart';
import '../data/models/workout_model.dart';
import '../data/models/workout_history_model.dart';
import '../data/repositories/workout_repository.dart';
import '../core/utils/date_helper.dart';

class WorkoutProvider with ChangeNotifier {
  final WorkoutRepository _repository = WorkoutRepository();

  Map<int, List<WorkoutModel>> _weekWorkouts = {};
  List<WorkoutModel> _todayWorkouts = [];
  List<WorkoutHistoryModel> _weekHistory = [];
  List<WorkoutHistoryModel> _monthHistory = [];

  DateTime _selectedWeek = DateTime.now();
  bool _isLoading = false;
  String? _error;

  Map<int, List<WorkoutModel>> get weekWorkouts => _weekWorkouts;
  List<WorkoutModel> get todayWorkouts => _todayWorkouts;
  List<WorkoutHistoryModel> get weekHistory => _weekHistory;
  List<WorkoutHistoryModel> get monthHistory => _monthHistory;
  DateTime get selectedWeek => _selectedWeek;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Map<String, int> _weeklyStats = {
    'completed': 0,
    'planned': 0,
    'minutes': 0,
  };

  Map<String, dynamic> _monthlyStats = {
    'total_workouts': 0,
    'total_minutes': 0,
    'total_exercises': 0,
    'avg_duration': 0,
  };

  Map<String, int> get weeklyStats => _weeklyStats;
  Map<String, dynamic> get monthlyStats => _monthlyStats;

  void setSelectedWeek(DateTime week) {
    _selectedWeek = DateHelper.getStartOfWeek(week);
    notifyListeners();
    loadWeekWorkouts();
    loadWeekHistory();
    loadWeeklyStats();
  }

  void nextWeek() {
    _selectedWeek = _selectedWeek.add(const Duration(days: 7));
    notifyListeners();
    loadWeekWorkouts();
    loadWeekHistory();
    loadWeeklyStats();
  }

  void previousWeek() {
    _selectedWeek = _selectedWeek.subtract(const Duration(days: 7));
    notifyListeners();
    loadWeekWorkouts();
    loadWeekHistory();
    loadWeeklyStats();
  }

  Future<void> loadWeekWorkouts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _weekWorkouts = await _repository.getWorkoutsForWeek(_selectedWeek);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadTodayWorkouts() async {
    try {
      _todayWorkouts = await _repository.getTodayWorkouts();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> loadWeekHistory() async {
    try {
      _weekHistory = await _repository.getHistoryForWeek(_selectedWeek);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> loadMonthHistory() async {
    try {
      _monthHistory = await _repository.getHistoryForMonth(DateTime.now());
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> loadWeeklyStats() async {
    try {
      _weeklyStats = await _repository.getWeeklyStats(_selectedWeek);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> loadMonthlyStats() async {
    try {
      _monthlyStats = await _repository.getMonthlyStats(DateTime.now());
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> addWorkout(WorkoutModel workout) async {
    try {
      await _repository.insertWorkout(workout);
      await loadWeekWorkouts();
      await loadTodayWorkouts();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateWorkout(WorkoutModel workout) async {
    try {
      await _repository.updateWorkout(workout);
      await loadWeekWorkouts();
      await loadTodayWorkouts();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteWorkout(int id) async {
    try {
      await _repository.deleteWorkout(id);
      await loadWeekWorkouts();
      await loadTodayWorkouts();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> completeWorkout(WorkoutHistoryModel history) async {
    try {
      await _repository.insertHistory(history);
      await loadWeekHistory();
      await loadMonthHistory();
      await loadWeeklyStats();
      await loadMonthlyStats();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Check workout status for a specific day
  String getWorkoutStatusForDay(int dayOfWeek, DateTime weekStart) {
    final dayWorkouts = _weekWorkouts[dayOfWeek] ?? [];
    if (dayWorkouts.isEmpty) return 'none';

    final dayDate = weekStart.add(Duration(days: dayOfWeek));
    final dayHistory = _weekHistory.where((h) {
      return DateHelper.isSameDay(h.date, dayDate);
    }).toList();

    if (dayHistory.length >= dayWorkouts.length) {
      return 'completed'; // ✓ Green
    } else if (dayHistory.isNotEmpty) {
      return 'partial'; // ✗ Red
    } else if (DateHelper.isToday(dayDate) || dayDate.isBefore(DateTime.now())) {
      return 'pending'; // ✗ Red
    } else {
      return 'scheduled'; // ⏰ Blue
    }
  }

  Future<void> deleteHistory(int id) async {
    try {
      await _repository.deleteHistory(id);
      await loadWeekHistory();
      await loadMonthHistory();
      await loadWeeklyStats();
      await loadMonthlyStats();
    } catch (e) {
      _error = e.toString();
    }
  }
}