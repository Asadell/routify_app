import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../routes/app_router.dart';
import '../../../core/utils/size_config.dart';

@RoutePage()
class QuickAddScreen extends StatelessWidget {
  const QuickAddScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(AppSizes.paddingLg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Quick Add',
                style: AppTextStyles.displayMedium,
              ),
              SizedBox(height: AppSizes.sm),
              Text(
                'What would you like to add?',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: AppSizes.xxl),
              _QuickAddCard(
                icon: Iconsax.calendar_1,
                title: 'Schedule',
                subtitle: 'Add a new schedule item',
                gradient: const LinearGradient(
                  colors: [Color(0xFF3B82F6), Color(0xFF60A5FA)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                onTap: () {
                  context.router.push(ScheduleFormRoute());
                },
              ),
              SizedBox(height: AppSizes.md),
              _QuickAddCard(
                icon: Iconsax.task_square,
                title: 'Task',
                subtitle: 'Create a new task',
                gradient: const LinearGradient(
                  colors: [Color(0xFFF59E0B), Color(0xFFFBBF24)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                onTap: () {
                  context.router.push(TaskFormRoute());
                },
              ),
              SizedBox(height: AppSizes.md),
              _QuickAddCard(
                icon: Iconsax.weight,
                title: 'Workout',
                subtitle: 'Plan a new workout',
                gradient: AppColors.successGradient,
                onTap: () {
                  context.router.push(WorkoutSetupRoute());
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickAddCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Gradient gradient;
  final VoidCallback onTap;

  const _QuickAddCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        child: Container(
          padding: EdgeInsets.all(AppSizes.paddingLg),
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(AppSizes.radiusLg),
            boxShadow: [
              BoxShadow(
                color: gradient.colors.first.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(AppSizes.paddingMd),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                ),
                child: Icon(icon, color: Colors.white, size: AppSizes.iconLg),
              ),
              SizedBox(width: AppSizes.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.headlineLarge.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: AppSizes.xs),
                    Text(
                      subtitle,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Iconsax.arrow_right_3,
                color: Colors.white,
                size: AppSizes.iconMd,
              ),
            ],
          ),
        ),
      ),
    );
  }
}