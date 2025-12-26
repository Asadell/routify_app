import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:provider/provider.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:sizer/sizer.dart';
import 'package:intl/intl.dart';
import '../../../providers/schedule_provider.dart';
import '../../../providers/task_provider.dart';
import '../../../providers/workout_provider.dart';
import '../../../providers/filter_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/empty_state.dart';
import '../../../core/utils/size_config.dart';

@RoutePage()
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final scheduleProvider = context.read<ScheduleProvider>();
    final taskProvider = context.read<TaskProvider>();
    final workoutProvider = context.read<WorkoutProvider>();

    await Future.wait([
      scheduleProvider.loadTodaySchedules(),
      taskProvider.loadTodayTasks(),
      workoutProvider.loadTodayWorkouts(),
      workoutProvider.loadWeeklyStats(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final filterProvider = context.watch<FilterProvider>();
    final now = DateTime.now();
    final dateStr = DateFormat('EEEE, d MMMM yyyy').format(now);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: 'Daily Planner',
        subtitle: dateStr,
        // actions: [
        //   IconButton(
        //     icon: const Icon(Iconsax.notification),
        //     onPressed: () {},
        //   ),
        // ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        color: AppColors.primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(AppSizes.paddingMd),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFilterChips(filterProvider),
              SizedBox(height: AppSizes.md),
              _buildStatisticsCards(),
              SizedBox(height: AppSizes.lg),
              if (filterProvider.shouldShowSchedules()) ...[
                _buildScheduleSection(),
                SizedBox(height: AppSizes.lg),
              ],
              if (filterProvider.shouldShowTasks()) ...[
                _buildTaskSection(),
                SizedBox(height: AppSizes.lg),
              ],
              if (filterProvider.shouldShowWorkouts()) ...[
                _buildWorkoutSection(),
                SizedBox(height: AppSizes.lg),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips(FilterProvider filterProvider) {
    final filters = [
      {'label': 'All', 'value': 'all', 'icon': Iconsax.category},
      {'label': 'Schedule', 'value': 'schedule', 'icon': Iconsax.calendar},
      {'label': 'Task', 'value': 'task', 'icon': Iconsax.task_square},
      {'label': 'Workout', 'value': 'workout', 'icon': Iconsax.weight},
    ];

    return SizedBox(
      height: 5.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (_, __) => SizedBox(width: AppSizes.sm),
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = filterProvider.homeFilter == filter['value'];

          return FilterChip(
            selected: isSelected,
            label: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  filter['icon'] as IconData,
                  size: AppSizes.iconSm,
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                ),
                SizedBox(width: AppSizes.xs),
                Text(
                  filter['label'] as String,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            onSelected: (_) {
              filterProvider.setHomeFilter(filter['value'] as String);
            },
            backgroundColor: AppColors.surfaceVariant,
            selectedColor: AppColors.primary,
            checkmarkColor: Colors.white,
            showCheckmark: false,
            padding: EdgeInsets.symmetric(
              horizontal: AppSizes.paddingMd,
              vertical: AppSizes.paddingSm,
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatisticsCards() {
    final scheduleProvider = context.watch<ScheduleProvider>();
    final taskProvider = context.watch<TaskProvider>();
    final workoutProvider = context.watch<WorkoutProvider>();

    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Iconsax.calendar_tick,
            label: 'Schedules',
            value: '${scheduleProvider.todaySchedules.length}',
            color: AppColors.info,
            gradient: const LinearGradient(
              colors: [Color(0xFF3B82F6), Color(0xFF60A5FA)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        SizedBox(width: AppSizes.sm),
        Expanded(
          child: _StatCard(
            icon: Iconsax.task_square,
            label: 'Tasks',
            value: '${taskProvider.todayTasks.length}',
            color: AppColors.warning,
            gradient: const LinearGradient(
              colors: [Color(0xFFF59E0B), Color(0xFFFBBF24)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        SizedBox(width: AppSizes.sm),
        Expanded(
          child: _StatCard(
            icon: Iconsax.cup,
            label: 'Workouts',
            value: '${workoutProvider.weeklyStats['completed'] ?? 0}',
            color: AppColors.success,
            gradient: AppColors.successGradient,
          ),
        ),
      ],
    );
  }

  Widget _buildScheduleSection() {
    final provider = context.watch<ScheduleProvider>();

    if (provider.isLoading) {
      return const LoadingIndicator();
    }

    if (provider.error != null) {
      return ErrorDisplay(
        message: provider.error!,
        onRetry: _loadData,
      );
    }

    if (provider.todaySchedules.isEmpty) {
      return EmptyState(
        icon: Iconsax.calendar,
        title: 'No schedules today',
        message: 'Add a schedule to get started',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Today\'s Schedule', style: AppTextStyles.headlineLarge),
            TextButton(
              onPressed: () {},
              child: const Text('See All'),
            ),
          ],
        ),
        SizedBox(height: AppSizes.sm),
        ...provider.todaySchedules.map((schedule) => Padding(
              padding: EdgeInsets.only(bottom: AppSizes.sm),
              child: _ScheduleCard(schedule: schedule),
            )),
      ],
    );
  }

  Widget _buildTaskSection() {
    final provider = context.watch<TaskProvider>();

    if (provider.todayTasks.isEmpty) {
      return EmptyState(
        icon: Iconsax.task_square,
        title: 'No tasks today',
        message: 'You\'re all caught up!',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Today\'s Tasks', style: AppTextStyles.headlineLarge),
            TextButton(
              onPressed: () {},
              child: const Text('See All'),
            ),
          ],
        ),
        SizedBox(height: AppSizes.sm),
        ...provider.todayTasks.map((task) => Padding(
              padding: EdgeInsets.only(bottom: AppSizes.sm),
              child: _TaskCard(task: task),
            )),
      ],
    );
  }

  Widget _buildWorkoutSection() {
    final provider = context.watch<WorkoutProvider>();

    if (provider.todayWorkouts.isEmpty) {
      return EmptyState(
        icon: Iconsax.weight,
        title: 'No workouts today',
        message: 'Rest day or time to plan!',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Today\'s Workout', style: AppTextStyles.headlineLarge),
            TextButton(
              onPressed: () {},
              child: const Text('See All'),
            ),
          ],
        ),
        SizedBox(height: AppSizes.sm),
        ...provider.todayWorkouts.map((workout) => Padding(
              padding: EdgeInsets.only(bottom: AppSizes.sm),
              child: _WorkoutCard(workout: workout),
            )),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final Gradient gradient;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSizes.paddingMd),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white, size: AppSizes.iconMd),
          SizedBox(height: AppSizes.sm),
          Text(
            value,
            style: AppTextStyles.displayMedium.copyWith(color: Colors.white),
          ),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScheduleCard extends StatelessWidget {
  final dynamic schedule;

  const _ScheduleCard({required this.schedule});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSizes.paddingMd),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(width: AppSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(schedule.title, style: AppTextStyles.headlineMedium),
                SizedBox(height: AppSizes.xs),
                Row(
                  children: [
                    Icon(Iconsax.clock, size: AppSizes.iconXs, color: AppColors.textSecondary),
                    SizedBox(width: AppSizes.xs),
                    Text(
                      '${schedule.startTime} - ${schedule.endTime}',
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Icon(Iconsax.arrow_right_3, color: AppColors.iconSecondary),
        ],
      ),
    );
  }
}

class _TaskCard extends StatelessWidget {
  final dynamic task;

  const _TaskCard({required this.task});

  @override
  Widget build(BuildContext context) {
    Color priorityColor = AppColors.priorityMedium;
    if (task.priority == 'high') priorityColor = AppColors.priorityHigh;
    if (task.priority == 'low') priorityColor = AppColors.priorityLow;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          // Left colored indicator bar
          Container(
            width: 4,
            decoration: BoxDecoration(
              color: priorityColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(AppSizes.radiusMd),
                bottomLeft: Radius.circular(AppSizes.radiusMd),
              ),
            ),
          ),
          // Main content
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(AppSizes.paddingMd),
              child: Row(
                children: [
                  Checkbox(
                    value: task.isCompleted,
                    onChanged: (_) {
                      context.read<TaskProvider>().toggleTaskStatus(task.id!);
                    },
                    activeColor: AppColors.success,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  SizedBox(width: AppSizes.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.title,
                          style: AppTextStyles.headlineMedium.copyWith(
                            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                            color: task.isCompleted ? AppColors.textSecondary : AppColors.textPrimary,
                          ),
                        ),
                        if (task.dueDate != null) ...[
                          SizedBox(height: AppSizes.xs),
                          Row(
                            children: [
                              Icon(Iconsax.calendar, size: AppSizes.iconXs, color: AppColors.textSecondary),
                              SizedBox(width: AppSizes.xs),
                              Text(
                                DateFormat('MMM d, yyyy').format(task.dueDate),
                                style: AppTextStyles.bodySmall,
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  SizedBox(width: AppSizes.sm),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSizes.paddingSm,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: priorityColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppSizes.radiusXs),
                    ),
                    child: Text(
                      task.priority.toUpperCase(),
                      style: AppTextStyles.labelSmall.copyWith(
                        color: priorityColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WorkoutCard extends StatelessWidget {
  final dynamic workout;

  const _WorkoutCard({required this.workout});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSizes.paddingMd),
      decoration: BoxDecoration(
        gradient: AppColors.successGradient,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        boxShadow: [
          BoxShadow(
            color: AppColors.success.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(AppSizes.paddingSm),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(AppSizes.radiusSm),
            ),
            child: Icon(Iconsax.weight, color: Colors.white, size: AppSizes.iconMd),
          ),
          SizedBox(width: AppSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  workout.name,
                  style: AppTextStyles.headlineMedium.copyWith(color: Colors.white),
                ),
                SizedBox(height: AppSizes.xs),
                Row(
                  children: [
                    Icon(Iconsax.clock, size: AppSizes.iconXs, color: Colors.white70),
                    SizedBox(width: AppSizes.xs),
                    Text(
                      '${workout.estimatedDuration ?? 0} min',
                      style: AppTextStyles.bodySmall.copyWith(color: Colors.white70),
                    ),
                    SizedBox(width: AppSizes.sm),
                    Icon(Iconsax.menu, size: AppSizes.iconXs, color: Colors.white70),
                    SizedBox(width: AppSizes.xs),
                    Text(
                      '${workout.exercises.length} exercises',
                      style: AppTextStyles.bodySmall.copyWith(color: Colors.white70),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Icon(Iconsax.arrow_right_3, color: Colors.white),
        ],
      ),
    );
  }
}