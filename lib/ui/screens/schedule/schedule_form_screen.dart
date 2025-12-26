import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
// import '../../../data/models/schedule_model.dart';

@RoutePage()
class ScheduleFormScreen extends StatelessWidget {
  // final ScheduleModel? schedule;

  const ScheduleFormScreen({
    Key? key,
    // @QueryParam('id') this.schedule,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // title: Text(schedule == null ? 'Add Schedule' : 'Edit Schedule'),
        title: Text('Edit Schedule'),
      ),
      body: const Center(
        child: Text('Schedule Form - UI akan dibuat'),
      ),
    );
  }
}