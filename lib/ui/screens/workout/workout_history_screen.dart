import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

@RoutePage()
class WorkoutHistoryScreen extends StatelessWidget {
  const WorkoutHistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout History'),
      ),
      body: const Center(
        child: Text('Workout History - UI akan dibuat'),
      ),
    );
  }
}