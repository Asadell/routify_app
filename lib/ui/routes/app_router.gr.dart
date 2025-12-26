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
class ScheduleFormRoute extends PageRouteInfo<void> {
  const ScheduleFormRoute({List<PageRouteInfo>? children})
    : super(ScheduleFormRoute.name, initialChildren: children);

  static const String name = 'ScheduleFormRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ScheduleFormScreen();
    },
  );
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
class TaskFormRoute extends PageRouteInfo<void> {
  const TaskFormRoute({List<PageRouteInfo>? children})
    : super(TaskFormRoute.name, initialChildren: children);

  static const String name = 'TaskFormRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const TaskFormScreen();
    },
  );
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
    required int dayOfWeek,
    List<PageRouteInfo>? children,
  }) : super(
         WorkoutSetupRoute.name,
         args: WorkoutSetupRouteArgs(key: key, dayOfWeek: dayOfWeek),
         rawPathParams: {'dayOfWeek': dayOfWeek},
         initialChildren: children,
       );

  static const String name = 'WorkoutSetupRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<WorkoutSetupRouteArgs>(
        orElse: () =>
            WorkoutSetupRouteArgs(dayOfWeek: pathParams.getInt('dayOfWeek')),
      );
      return WorkoutSetupScreen(key: args.key, dayOfWeek: args.dayOfWeek);
    },
  );
}

class WorkoutSetupRouteArgs {
  const WorkoutSetupRouteArgs({this.key, required this.dayOfWeek});

  final Key? key;

  final int dayOfWeek;

  @override
  String toString() {
    return 'WorkoutSetupRouteArgs{key: $key, dayOfWeek: $dayOfWeek}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! WorkoutSetupRouteArgs) return false;
    return key == other.key && dayOfWeek == other.dayOfWeek;
  }

  @override
  int get hashCode => key.hashCode ^ dayOfWeek.hashCode;
}
