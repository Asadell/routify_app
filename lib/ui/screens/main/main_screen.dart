
import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../theme/app_colors.dart';
import '../../routes/app_router.dart';

@RoutePage()
class MainScreen extends StatelessWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AutoTabsScaffold(
      routes: const [
        HomeRoute(),
        ScheduleRoute(),
        QuickAddRoute(),
        TaskRoute(),
        WorkoutRoute(),
      ],
      bottomNavigationBuilder: (_, tabsRouter) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _NavBarItem(
                    icon: Iconsax.home_2,
                    activeIcon: Iconsax.home_2_copy,
                    label: 'Home',
                    isActive: tabsRouter.activeIndex == 0,
                    onTap: () => tabsRouter.setActiveIndex(0),
                  ),
                  _NavBarItem(
                    icon: Iconsax.calendar_1,
                    activeIcon: Iconsax.calendar_1_copy,
                    label: 'Schedule',
                    isActive: tabsRouter.activeIndex == 1,
                    onTap: () => tabsRouter.setActiveIndex(1),
                  ),
                  _NavBarCenterItem(
                    onTap: () => tabsRouter.setActiveIndex(2),
                    isActive: tabsRouter.activeIndex == 2,
                  ),
                  _NavBarItem(
                    icon: Iconsax.task_square,
                    activeIcon: Iconsax.task_square_copy,
                    label: 'Tasks',
                    isActive: tabsRouter.activeIndex == 3,
                    onTap: () => tabsRouter.setActiveIndex(3),
                  ),
                  _NavBarItem(
                    icon: Iconsax.weight,
                    activeIcon: Iconsax.weight_copy,
                    label: 'Workout',
                    isActive: tabsRouter.activeIndex == 4,
                    onTap: () => tabsRouter.setActiveIndex(4),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              color: isActive ? AppColors.primary : AppColors.iconSecondary,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                color: isActive ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavBarCenterItem extends StatelessWidget {
  final VoidCallback onTap;
  final bool isActive;

  const _NavBarCenterItem({
    required this.onTap,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          gradient: isActive
              ? AppColors.successGradient
              : AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: (isActive ? AppColors.success : AppColors.primary)
                  .withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(
          Iconsax.add,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }
}