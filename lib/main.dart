import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timezone/data/latest.dart' as tz;
// import 'data/services/database_service.dart';
// import 'data/services/notification_service.dart';
// import 'providers/schedule_provider.dart';
// import 'providers/task_provider.dart';
// import 'providers/workout_provider.dart';
// import 'providers/filter_provider.dart';
import 'ui/routes/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize timezone
  tz.initializeTimeZones();

  // Initialize database
  // await DatabaseService.instance.database;

  // Initialize notifications
  // await NotificationService.instance.initialize();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  final _appRouter = AppRouter();

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Daily Planner',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      routerConfig: _appRouter.config(),
    );
  }
}