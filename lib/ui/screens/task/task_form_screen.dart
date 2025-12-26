import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
// import '../../../data/models/task_model.dart';

@RoutePage()
class TaskFormScreen extends StatelessWidget {
  // final TaskModel? task;

  const TaskFormScreen({
    Key? key,
    // @QueryParam('id') this.task,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // title: Text(task == null ? 'Add Task' : 'Edit Task'),
        title: Text('Edit Task'),
      ),
      body: const Center(
        child: Text('Task Form - UI akan dibuat'),
      ),
    );
  }
}