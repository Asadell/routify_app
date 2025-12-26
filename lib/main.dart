import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:routify_app/ui/routes/app_router.dart';
import 'package:routify_app/ui/theme/app_theme.dart';
import 'package:sizer/sizer.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'data/services/database_service.dart';
import 'data/services/notification_service.dart';
import 'providers/schedule_provider.dart';
import 'providers/task_provider.dart';
import 'providers/workout_provider.dart';
import 'providers/filter_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  tz.initializeTimeZones();

  await DatabaseService.instance.database;

  await NotificationService.instance.initialize();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  final _appRouter = AppRouter();

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        return MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => ScheduleProvider()),
            ChangeNotifierProvider(create: (_) => TaskProvider()),
            ChangeNotifierProvider(create: (_) => WorkoutProvider()),
            ChangeNotifierProvider(create: (_) => FilterProvider()),
          ],
          child: MaterialApp.router(
            title: 'Daily Planner',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            routerConfig: _appRouter.config(),
          ),
        );
      },
    );
  }
}