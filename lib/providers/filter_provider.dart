import 'package:flutter/foundation.dart';

class FilterProvider with ChangeNotifier {
  String _homeFilter = 'all'; // all, schedule, task, workout

  String get homeFilter => _homeFilter;

  void setHomeFilter(String filter) {
    _homeFilter = filter;
    notifyListeners();
  }

  bool shouldShowSchedules() {
    return _homeFilter == 'all' || _homeFilter == 'schedule';
  }

  bool shouldShowTasks() {
    return _homeFilter == 'all' || _homeFilter == 'task';
  }

  bool shouldShowWorkouts() {
    return _homeFilter == 'all' || _homeFilter == 'workout';
  }
}