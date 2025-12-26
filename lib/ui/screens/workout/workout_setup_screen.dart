import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

@RoutePage()
class WorkoutSetupScreen extends StatelessWidget {
  final int dayOfWeek;

  const WorkoutSetupScreen({
    Key? key,
    @PathParam('dayOfWeek') required this.dayOfWeek,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final days = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
    
    return Scaffold(
      appBar: AppBar(
        title: Text('${days[dayOfWeek]} Workout'),
      ),
      body: Center(
        child: Text('Workout Setup for Day $dayOfWeek - UI akan dibuat'),
      ),
    );
  }
}