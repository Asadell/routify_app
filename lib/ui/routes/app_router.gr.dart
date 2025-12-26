// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

part of 'app_router.dart';

/// generated route for
/// [HomeScreen]
class HomeRoute extends PageRouteInfo<void> {
  const HomeRoute({List<PageRouteInfo>? children})
    : super(HomeRoute.name, initialChildren: children);

  static const String name = 'HomeRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const HomeScreen();
    },
  );
}

/// generated route for
/// [MainScreen]
class MainRoute extends PageRouteInfo<void> {
  const MainRoute({List<PageRouteInfo>? children})
    : super(MainRoute.name, initialChildren: children);

  static const String name = 'MainRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const MainScreen();
    },
  );
}

/// generated route for
/// [QuickAddScreen]
class QuickAddRoute extends PageRouteInfo<void> {
  const QuickAddRoute({List<PageRouteInfo>? children})
    : super(QuickAddRoute.name, initialChildren: children);

  static const String name = 'QuickAddRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const QuickAddScreen();
    },
  );
}

/// generated route for
/// [ScheduleFormScreen]
class ScheduleFormRoute extends PageRouteInfo<ScheduleFormRouteArgs> {
  ScheduleFormRoute({
    Key? key,
    ScheduleModel? schedule,
    List<PageRouteInfo>? children,
  }) : super(
         ScheduleFormRoute.name,
         args: ScheduleFormRouteArgs(key: key, schedule: schedule),
         initialChildren: children,
       );

  static const String name = 'ScheduleFormRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ScheduleFormRouteArgs>(
        orElse: () => const ScheduleFormRouteArgs(),
      );
      return ScheduleFormScreen(key: args.key, schedule: args.schedule);
    },
  );
}

class ScheduleFormRouteArgs {
  const ScheduleFormRouteArgs({this.key, this.schedule});

  final Key? key;

  final ScheduleModel? schedule;

  @override
  String toString() {
    return 'ScheduleFormRouteArgs{key: $key, schedule: $schedule}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ScheduleFormRouteArgs) return false;
    return key == other.key && schedule == other.schedule;
  }

  @override
  int get hashCode => key.hashCode ^ schedule.hashCode;
}

/// generated route for
/// [ScheduleScreen]
class ScheduleRoute extends PageRouteInfo<void> {
  const ScheduleRoute({List<PageRouteInfo>? children})
    : super(ScheduleRoute.name, initialChildren: children);

  static const String name = 'ScheduleRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ScheduleScreen();
    },
  );
}

/// generated route for
/// [TaskFormScreen]
class TaskFormRoute extends PageRouteInfo<TaskFormRouteArgs> {
  TaskFormRoute({Key? key, TaskModel? task, List<PageRouteInfo>? children})
    : super(
        TaskFormRoute.name,
        args: TaskFormRouteArgs(key: key, task: task),
        initialChildren: children,
      );

  static const String name = 'TaskFormRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<TaskFormRouteArgs>(
        orElse: () => const TaskFormRouteArgs(),
      );
      return TaskFormScreen(key: args.key, task: args.task);
    },
  );
}

class TaskFormRouteArgs {
  const TaskFormRouteArgs({this.key, this.task});

  final Key? key;

  final TaskModel? task;

  @override
  String toString() {
    return 'TaskFormRouteArgs{key: $key, task: $task}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! TaskFormRouteArgs) return false;
    return key == other.key && task == other.task;
  }

  @override
  int get hashCode => key.hashCode ^ task.hashCode;
}

/// generated route for
/// [TaskScreen]
class TaskRoute extends PageRouteInfo<void> {
  const TaskRoute({List<PageRouteInfo>? children})
    : super(TaskRoute.name, initialChildren: children);

  static const String name = 'TaskRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const TaskScreen();
    },
  );
}

/// generated route for
/// [WorkoutHistoryScreen]
class WorkoutHistoryRoute extends PageRouteInfo<void> {
  const WorkoutHistoryRoute({List<PageRouteInfo>? children})
    : super(WorkoutHistoryRoute.name, initialChildren: children);

  static const String name = 'WorkoutHistoryRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const WorkoutHistoryScreen();
    },
  );
}

/// generated route for
/// [WorkoutScreen]
class WorkoutRoute extends PageRouteInfo<void> {
  const WorkoutRoute({List<PageRouteInfo>? children})
    : super(WorkoutRoute.name, initialChildren: children);

  static const String name = 'WorkoutRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const WorkoutScreen();
    },
  );
}

/// generated route for
/// [WorkoutSetupScreen]
class WorkoutSetupRoute extends PageRouteInfo<WorkoutSetupRouteArgs> {
  WorkoutSetupRoute({
    Key? key,
    WorkoutModel? workout,
    List<PageRouteInfo>? children,
  }) : super(
         WorkoutSetupRoute.name,
         args: WorkoutSetupRouteArgs(key: key, workout: workout),
         initialChildren: children,
       );

  static const String name = 'WorkoutSetupRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<WorkoutSetupRouteArgs>(
        orElse: () => const WorkoutSetupRouteArgs(),
      );
      return WorkoutSetupScreen(key: args.key, workout: args.workout);
    },
  );
}

class WorkoutSetupRouteArgs {
  const WorkoutSetupRouteArgs({this.key, this.workout});

  final Key? key;

  final WorkoutModel? workout;

  @override
  String toString() {
    return 'WorkoutSetupRouteArgs{key: $key, workout: $workout}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! WorkoutSetupRouteArgs) return false;
    return key == other.key && workout == other.workout;
  }

  @override
  int get hashCode => key.hashCode ^ workout.hashCode;
}
