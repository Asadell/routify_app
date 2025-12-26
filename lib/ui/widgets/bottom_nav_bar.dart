import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:routify_app/ui/routes/app_router.dart';

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AutoTabsRouter(
      routes: const [
        HomeRoute(),
        ScheduleRoute(),
        QuickAddRoute(),
        TaskRoute(),
        WorkoutRoute(),
      ],
      builder: (context, child) {
        final tabsRouter = AutoTabsRouter.of(context);
        
        return Scaffold(
          body: child,
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: tabsRouter.activeIndex,
            onTap: (index) {
              // Handle center FAB differently
              if (index == 2) {
                // Navigate to Quick Add screen
                tabsRouter.setActiveIndex(index);
              } else {
                tabsRouter.setActiveIndex(index);
              }
            },
            type: BottomNavigationBarType.fixed,
            selectedItemColor: Theme.of(context).primaryColor,
            unselectedItemColor: Colors.grey,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.calendar_today),
                label: 'Schedule',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.add_circle, size: 40),
                label: 'Add',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.check_box),
                label: 'Tasks',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.fitness_center),
                label: 'Workout',
              ),
            ],
          ),
        );
      },
    );
  }
}