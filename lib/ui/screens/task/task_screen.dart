import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:routify_app/ui/routes/app_router.dart';

@RoutePage()
class TaskScreen extends StatelessWidget {
  const TaskScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
      ),
      body: Column(
        children: [
          Center(
            child: Text('Task Screen'),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => context.router.push(TaskFormRoute()),
            child: Text('Add Task'),
          ),
        ],
      ),
    );
  }
}