import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:routify_app/ui/routes/app_router.dart';

@RoutePage()
class WorkoutScreen extends StatelessWidget {
  const WorkoutScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout'),
      ),
      body: Column(
        children: [
          Center(
            child: Text('Workout Screen - UI akan dibuat'),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => context.router.push(WorkoutSetupRoute(dayOfWeek: 1)),
            child: Text('Add Workout'),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => context.router.push(WorkoutHistoryRoute()),
            child: Text('View Workouts'),
          ),
        ],
      ),
    );
  }
}