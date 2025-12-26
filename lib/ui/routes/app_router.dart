
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:routify_app/data/models/schedule_model.dart';
import 'package:routify_app/data/models/task_model.dart';
import 'package:routify_app/data/models/workout_model.dart';
import '../screens/home/home_screen.dart';
import '../screens/schedule/schedule_screen.dart';
import '../screens/schedule/schedule_form_screen.dart';
import '../screens/task/task_screen.dart';
import '../screens/task/task_form_screen.dart';
import '../screens/workout/workout_screen.dart';
import '../screens/workout/workout_setup_screen.dart';
import '../screens/workout/workout_history_screen.dart';
import '../screens/add/quick_add_screen.dart';
import '../screens/main/main_screen.dart';

part 'app_router.gr.dart';

@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
        AutoRoute(
          page: MainRoute.page,
          initial: true,
          children: [
            AutoRoute(page: HomeRoute.page, path: 'home'),
            AutoRoute(page: ScheduleRoute.page, path: 'schedule'),
            AutoRoute(page: QuickAddRoute.page, path: 'add'),
            AutoRoute(page: TaskRoute.page, path: 'tasks'),
            AutoRoute(page: WorkoutRoute.page, path: 'workout'),
          ],
        ),
        AutoRoute(page: ScheduleFormRoute.page, path: '/schedule/form'),
        AutoRoute(page: TaskFormRoute.page, path: '/task/form'),
        AutoRoute(page: WorkoutSetupRoute.page, path: '/workout/setup'),
        AutoRoute(page: WorkoutHistoryRoute.page, path: '/workout/history'),
      ];
}