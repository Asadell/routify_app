import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:provider/provider.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:intl/intl.dart';
import '../../../providers/workout_provider.dart';
import '../../../data/models/workout_model.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/empty_state.dart';
import '../../routes/app_router.dart';
import '../../../core/utils/size_config.dart';
import '../../../core/utils/date_helper.dart';

@RoutePage()
class WorkoutScreen extends StatefulWidget {
  const WorkoutScreen({Key? key}) : super(key: key);

  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final provider = context.read<WorkoutProvider>();
    await provider.loadWeekWorkouts();
    await provider.loadWeekHistory();
    await provider.loadWeeklyStats();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WorkoutProvider>();
    final stats = provider.weeklyStats;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: 'Workout Plan',
        subtitle: 'Stay consistent, stay strong',
        actions: [
          IconButton(
            tooltip: 'View workout history', 
            icon: const Icon(Iconsax.chart),
            onPressed: () {
              context.router.push(WorkoutHistoryRoute());
            },
          ),
        ],
      ),
      // floatingActionButton: FloatingActionButton.extended(
      //   onPressed: () {
      //     context.router.push(WorkoutSetupRoute());
      //   },
      //   icon: const Icon(Iconsax.add),
      //   label: const Text('Setup Workout'),
      // ),
      body: provider.isLoading
          ? const LoadingIndicator(message: 'Loading workouts...')
          : provider.error != null
              ? ErrorDisplay(message: provider.error!, onRetry: _loadData)
              : RefreshIndicator(
                  onRefresh: _loadData,
                  color: AppColors.primary,
                  child: ListView(
                    padding: EdgeInsets.all(AppSizes.paddingMd),
                    children: [
                      _buildStatsSection(stats),
                      SizedBox(height: AppSizes.lg),
                      _buildWeekSelector(provider),
                      SizedBox(height: AppSizes.md),
                      _buildWeekCalendar(provider),
                      SizedBox(height: AppSizes.lg),
                      _buildWorkoutsList(provider),
                    ],
                  ),
                ),
    );
  }

  Widget _buildStatsSection(Map<String, int> stats) {
    final completed = stats['completed'] ?? 0;
    final planned = stats['planned'] ?? 0;
    final minutes = stats['minutes'] ?? 0;
    final completion = planned > 0 ? (completed / planned * 100).round() : 0;

    return Container(
      padding: EdgeInsets.all(AppSizes.paddingLg),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Iconsax.cup, color: Colors.white, size: AppSizes.iconLg),
              SizedBox(width: AppSizes.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Weekly Progress',
                      style: AppTextStyles.headlineMedium.copyWith(color: Colors.white),
                    ),
                    SizedBox(height: AppSizes.xs),
                    Text(
                      '$completed of $planned workouts completed',
                      style: AppTextStyles.bodySmall.copyWith(color: Colors.white70),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.all(AppSizes.paddingSm),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                ),
                child: Text(
                  '$completion%',
                  style: AppTextStyles.headlineLarge.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppSizes.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSizes.radiusSm),
            child: LinearProgressIndicator(
              value: planned > 0 ? completed / planned : 0,
              backgroundColor: Colors.white.withOpacity(0.2),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 8,
            ),
          ),
          SizedBox(height: AppSizes.md),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  icon: Iconsax.timer_1,
                  label: 'Total Time',
                  value: '$minutes min',
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withOpacity(0.2),
              ),
              Expanded(
                child: _buildStatItem(
                  icon: Iconsax.activity,
                  label: 'Completed',
                  value: '$completed',
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withOpacity(0.2),
              ),
              Expanded(
                child: _buildStatItem(
                  icon: Iconsax.calendar_tick,
                  label: 'Planned',
                  value: '$planned',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: AppSizes.iconMd),
        SizedBox(height: AppSizes.xs),
        Text(
          value,
          style: AppTextStyles.headlineMedium.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(color: Colors.white70),
        ),
      ],
    );
  }

  Widget _buildWeekSelector(WorkoutProvider provider) {
    final startOfWeek = provider.selectedWeek;
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    final weekLabel = '${DateFormat('MMM d').format(startOfWeek)} - ${DateFormat('MMM d').format(endOfWeek)}';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () => provider.previousWeek(),
          icon: const Icon(Iconsax.arrow_left_2),
          style: IconButton.styleFrom(
            backgroundColor: AppColors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusSm),
              side: const BorderSide(color: AppColors.border),
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: AppSizes.paddingLg,
            vertical: AppSizes.paddingSm,
          ),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            border: Border.all(color: AppColors.border),
          ),
          child: Text(weekLabel, style: AppTextStyles.headlineSmall),
        ),
        IconButton(
          onPressed: () => provider.nextWeek(),
          icon: const Icon(Iconsax.arrow_right_3),
          style: IconButton.styleFrom(
            backgroundColor: AppColors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusSm),
              side: const BorderSide(color: AppColors.border),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWeekCalendar(WorkoutProvider provider) {
    final days = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    final startOfWeek = provider.selectedWeek;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(7, (index) {
        final date = startOfWeek.add(Duration(days: index));
        final isToday = DateHelper.isToday(date);
        final status = provider.getWorkoutStatusForDay(index, startOfWeek);
        
        Color statusColor = AppColors.workoutNone;
        IconData? statusIcon;
        
        switch (status) {
          case 'completed':
            statusColor = AppColors.workoutCompleted;
            statusIcon = Iconsax.tick_circle;
            break;
          case 'pending':
          case 'partial':
            statusColor = AppColors.workoutPartial;
            statusIcon = Iconsax.close_circle;
            break;
          case 'scheduled':
            statusColor = AppColors.workoutScheduled;
            statusIcon = Iconsax.clock;
            break;
        }

        return Container(
          width: 45,
          height: 60,
          decoration: BoxDecoration(
            color: isToday ? AppColors.primary : AppColors.surface,
            borderRadius: BorderRadius.circular(AppSizes.radiusSm),
            border: Border.all(
              color: isToday ? AppColors.primary : AppColors.border,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                days[index],
                style: AppTextStyles.labelMedium.copyWith(
                  color: isToday ? Colors.white : AppColors.textSecondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: AppSizes.xs),
              Text(
                '${date.day}',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isToday ? Colors.white : AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (statusIcon != null) ...[
                SizedBox(height: 2),
                Icon(
                  statusIcon,
                  size: 12,
                  color: isToday ? Colors.white : statusColor,
                ),
              ],
            ],
          ),
        );
      }),
    );
  }

  Widget _buildWorkoutsList(WorkoutProvider provider) {
    final workouts = provider.weekWorkouts;
    
    if (workouts.isEmpty || workouts.values.every((list) => list.isEmpty)) {
      return EmptyState(
        icon: Iconsax.weight,
        title: 'No workouts planned',
        message: 'Setup your weekly workout routine',
        actionLabel: 'Setup Workout',
        onAction: () {
          context.router.push(WorkoutSetupRoute());
        },
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Workout Schedule', style: AppTextStyles.headlineLarge),
        SizedBox(height: AppSizes.md),
        ...List.generate(7, (dayIndex) {
          final dayWorkouts = workouts[dayIndex] ?? [];
          if (dayWorkouts.isEmpty) return const SizedBox.shrink();
          
          return Padding(
            padding: EdgeInsets.only(bottom: AppSizes.md),
            child: _buildDayWorkouts(dayIndex, dayWorkouts, provider),
          );
        }),
      ],
    );
  }

  Widget _buildDayWorkouts(int dayIndex, List<WorkoutModel> dayWorkouts, WorkoutProvider provider) {
    final dayName = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'][dayIndex];
    final startOfWeek = provider.selectedWeek;
    final status = provider.getWorkoutStatusForDay(dayIndex, startOfWeek);

    Color statusColor = AppColors.workoutNone;
    switch (status) {
      case 'completed':
        statusColor = AppColors.workoutCompleted;
        break;
      case 'pending':
      case 'partial':
        statusColor = AppColors.workoutPartial;
        break;
      case 'scheduled':
        statusColor = AppColors.workoutScheduled;
        break;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 20,
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(width: AppSizes.sm),
            Text(dayName, style: AppTextStyles.headlineMedium),
            SizedBox(width: AppSizes.sm),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSizes.paddingSm,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppSizes.radiusXs),
              ),
              child: Text(
                '${dayWorkouts.length} workout${dayWorkouts.length > 1 ? 's' : ''}',
                style: AppTextStyles.labelSmall.copyWith(
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: AppSizes.sm),
        ...dayWorkouts.map((workout) => Padding(
          padding: EdgeInsets.only(bottom: AppSizes.sm),
          child: _WorkoutCard(workout: workout, provider: provider),
        )),
      ],
    );
  }
}

class _WorkoutCard extends StatelessWidget {
  final WorkoutModel workout;
  final WorkoutProvider provider;

  const _WorkoutCard({required this.workout, required this.provider});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.router.push(
          WorkoutSessionRoute(
            workout: workout,
            date: DateTime.now(),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.all(AppSizes.paddingMd),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(AppSizes.paddingSm),
                  decoration: BoxDecoration(
                    gradient: AppColors.successGradient,
                    borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                  ),
                  child: Icon(Iconsax.weight, color: Colors.white, size: AppSizes.iconMd),
                ),
                SizedBox(width: AppSizes.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(workout.name, style: AppTextStyles.headlineMedium),
                      SizedBox(height: AppSizes.xs),
                      Row(
                        children: [
                          Icon(Iconsax.calendar_1, size: AppSizes.iconXs, color: AppColors.textSecondary),
                          SizedBox(width: AppSizes.xs),
                          Expanded(
                            child: Text(
                              workout.daysNames,
                              style: AppTextStyles.bodySmall,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(Iconsax.clock, size: AppSizes.iconXs, color: AppColors.textSecondary),
                          SizedBox(width: AppSizes.xs),
                          Text(
                            '${workout.estimatedDuration ?? 0} min',
                            style: AppTextStyles.bodySmall,
                          ),
                          SizedBox(width: AppSizes.sm),
                          Icon(Iconsax.menu, size: AppSizes.iconXs, color: AppColors.textSecondary),
                          SizedBox(width: AppSizes.xs),
                          Text(
                            '${workout.exercises.length} exercises',
                            style: AppTextStyles.bodySmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    context.router.push(WorkoutSetupRoute(workout: workout));
                  },
                  icon: Icon(Iconsax.edit_2, color: AppColors.primary, size: AppSizes.iconSm),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                    ),
                  ),
                ),
              ],
            ),
            if (workout.notes != null && workout.notes!.isNotEmpty) ...[
              SizedBox(height: AppSizes.sm),
              Container(
                padding: EdgeInsets.all(AppSizes.paddingSm),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                ),
                child: Row(
                  children: [
                    Icon(Iconsax.note, size: AppSizes.iconXs, color: AppColors.textSecondary),
                    SizedBox(width: AppSizes.xs),
                    Expanded(
                      child: Text(
                        workout.notes!,
                        style: AppTextStyles.bodySmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
