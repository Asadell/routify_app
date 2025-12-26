import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

@RoutePage()
class QuickAddScreen extends StatelessWidget {
  const QuickAddScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quick Add'),
      ),
      body: const Center(
        child: Text('Quick Add Screen - UI akan dibuat'),
      ),
    );
  }
}