import 'package:flutter/foundation.dart';
import '../data/models/task_model.dart';
import '../data/repositories/task_repository.dart';

class TaskProvider with ChangeNotifier {
  final TaskRepository _repository = TaskRepository();

  List<TaskModel> _tasks = [];
  List<TaskModel> _todayTasks = [];
  List<TaskModel> _upcomingTasks = [];
  List<TaskModel> _completedTasks = [];
  List<TaskModel> _overdueTasks = [];

  bool _isLoading = false;
  String? _error;
  String _currentFilter = 'all'; // all, today, upcoming, completed, priority

  List<TaskModel> get tasks => _tasks;
  List<TaskModel> get todayTasks => _todayTasks;
  List<TaskModel> get upcomingTasks => _upcomingTasks;
  List<TaskModel> get completedTasks => _completedTasks;
  List<TaskModel> get overdueTasks => _overdueTasks;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get currentFilter => _currentFilter;

  List<TaskModel> get filteredTasks {
    switch (_currentFilter) {
      case 'today':
        return _todayTasks;
      case 'upcoming':
        return _upcomingTasks;
      case 'completed':
        return _completedTasks;
      case 'high':
        return _tasks.where((t) => t.priority == 'high' && t.isPending).toList();
      case 'medium':
        return _tasks.where((t) => t.priority == 'medium' && t.isPending).toList();
      case 'low':
        return _tasks.where((t) => t.priority == 'low' && t.isPending).toList();
      default:
        return _tasks;
    }
  }

  void setFilter(String filter) {
    _currentFilter = filter;
    notifyListeners();
  }

  Future<void> loadTasks() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _tasks = await _repository.getAllTasks();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadTodayTasks() async {
    try {
      _todayTasks = await _repository.getTodayTasks();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> loadUpcomingTasks() async {
    try {
      _upcomingTasks = await _repository.getUpcomingTasks();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> loadCompletedTasks() async {
    try {
      _completedTasks = await _repository.getCompletedTasks();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> loadOverdueTasks() async {
    try {
      _overdueTasks = await _repository.getOverdueTasks();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> loadAllTaskCategories() async {
    await loadTasks();
    await loadTodayTasks();
    await loadUpcomingTasks();
    await loadCompletedTasks();
    await loadOverdueTasks();
  }

  Future<void> addTask(TaskModel task) async {
    try {
      await _repository.insertTask(task);
      await loadAllTaskCategories();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateTask(TaskModel task) async {
    try {
      await _repository.updateTask(task);
      await loadAllTaskCategories();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteTask(int id) async {
    try {
      await _repository.deleteTask(id);
      await loadAllTaskCategories();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> toggleTaskStatus(int id) async {
    try {
      await _repository.toggleTaskStatus(id);
      await loadAllTaskCategories();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}