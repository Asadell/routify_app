import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:routify_app/ui/routes/app_router.dart';

@RoutePage()
class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedule'),
      ),
      body: Column(
        children: [
          Center(
            child: Text('Schedule Screen - UI akan dibuat'),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => context.router.push(ScheduleFormRoute()),
            child: Text('Add Schedule'),
          ),
        ],
      ),
    );
  }
}