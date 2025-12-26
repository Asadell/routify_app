import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:routify_app/data/models/workout_history_model.dart';
import '../../../providers/workout_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/empty_state.dart';
import '../../../core/utils/size_config.dart';
import '../../../core/utils/date_helper.dart';

@RoutePage()
class WorkoutHistoryScreen extends StatefulWidget {
  const WorkoutHistoryScreen({Key? key}) : super(key: key);

  @override
  State<WorkoutHistoryScreen> createState() => _WorkoutHistoryScreenState();
}

class _WorkoutHistoryScreenState extends State<WorkoutHistoryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final provider = context.read<WorkoutProvider>();
    await provider.loadWeekHistory();
    await provider.loadMonthHistory();
    await provider.loadWeeklyStats();
    await provider.loadMonthlyStats();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WorkoutProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: 'Workout History',
        subtitle: 'Track your progress',
        showBackButton: true,
      ),
      body: Column(
        children: [
          Container(
            color: AppColors.surface,
            padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingMd),
            child: TabBar(
              controller: _tabController,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textSecondary,
              indicatorColor: AppColors.primary,
              indicatorWeight: 3,
              labelStyle: AppTextStyles.labelLarge,
              tabs: const [
                Tab(text: 'This Week'),
                Tab(text: 'This Month'),
              ],
            ),
          ),
          Expanded(
            child: provider.isLoading
                ? const LoadingIndicator(message: 'Loading history...')
                : provider.error != null
                    ? ErrorDisplay(message: provider.error!, onRetry: _loadData)
                    : TabBarView(
                        controller: _tabController,
                        children: [
                          _buildWeekTab(provider),
                          _buildMonthTab(provider),
                        ],
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekTab(WorkoutProvider provider) {
    final stats = provider.weeklyStats;
    final history = provider.weekHistory;

    return RefreshIndicator(
      onRefresh: _loadData,
      color: AppColors.primary,
      child: ListView(
        padding: EdgeInsets.all(AppSizes.paddingMd),
        children: [
          _buildWeekStats(stats),
          SizedBox(height: AppSizes.lg),
          _buildHistoryList(history, 'This Week'),
        ],
      ),
    );
  }

  Widget _buildMonthTab(WorkoutProvider provider) {
    final stats = provider.monthlyStats;
    final history = provider.monthHistory;

    return RefreshIndicator(
      onRefresh: _loadData,
      color: AppColors.primary,
      child: ListView(
        padding: EdgeInsets.all(AppSizes.paddingMd),
        children: [
          _buildMonthStats(stats),
          SizedBox(height: AppSizes.lg),
          _buildHistoryList(history, 'This Month'),
        ],
      ),
    );
  }

  Widget _buildWeekStats(Map<String, int> stats) {
    final completed = stats['completed'] ?? 0;
    final planned = stats['planned'] ?? 0;
    final minutes = stats['minutes'] ?? 0;

    return Container(
      padding: EdgeInsets.all(AppSizes.paddingLg),
      decoration: BoxDecoration(
        gradient: AppColors.successGradient,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        boxShadow: [
          BoxShadow(
            color: AppColors.success.withOpacity(0.3),
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
                      'Weekly Summary',
                      style: AppTextStyles.headlineMedium.copyWith(color: Colors.white),
                    ),
                    SizedBox(height: AppSizes.xs),
                    Text(
                      'Keep pushing forward!',
                      style: AppTextStyles.bodySmall.copyWith(color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: AppSizes.lg),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Iconsax.tick_circle,
                  label: 'Completed',
                  value: '$completed',
                  subtitle: 'of $planned planned',
                ),
              ),
              SizedBox(width: AppSizes.sm),
              Expanded(
                child: _buildStatCard(
                  icon: Iconsax.timer_1,
                  label: 'Total Time',
                  value: '$minutes',
                  subtitle: 'minutes',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMonthStats(Map<String, dynamic> stats) {
    final totalWorkouts = stats['total_workouts'] ?? 0;
    final totalMinutes = stats['total_minutes'] ?? 0;
    final totalExercises = stats['total_exercises'] ?? 0;
    final avgDuration = stats['avg_duration'] ?? 0;

    return Container(
      padding: EdgeInsets.all(AppSizes.paddingLg),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF8B5CF6), Color(0xFFA78BFA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8B5CF6).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Iconsax.award, color: Colors.white, size: AppSizes.iconLg),
              SizedBox(width: AppSizes.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Monthly Summary',
                      style: AppTextStyles.headlineMedium.copyWith(color: Colors.white),
                    ),
                    SizedBox(height: AppSizes.xs),
                    Text(
                      'Excellent progress this month!',
                      style: AppTextStyles.bodySmall.copyWith(color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: AppSizes.lg),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Iconsax.activity,
                  label: 'Workouts',
                  value: '$totalWorkouts',
                  subtitle: 'completed',
                ),
              ),
              SizedBox(width: AppSizes.sm),
              Expanded(
                child: _buildStatCard(
                  icon: Iconsax.clock,
                  label: 'Minutes',
                  value: '$totalMinutes',
                  subtitle: 'total time',
                ),
              ),
            ],
          ),
          SizedBox(height: AppSizes.sm),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Iconsax.menu,
                  label: 'Exercises',
                  value: '$totalExercises',
                  subtitle: 'total reps',
                ),
              ),
              SizedBox(width: AppSizes.sm),
              Expanded(
                child: _buildStatCard(
                  icon: Iconsax.timer_1,
                  label: 'Avg Duration',
                  value: '$avgDuration',
                  subtitle: 'minutes',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required String subtitle,
  }) {
    return Container(
      padding: EdgeInsets.all(AppSizes.paddingMd),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: AppSizes.iconMd),
          SizedBox(height: AppSizes.sm),
          Text(
            value,
            style: AppTextStyles.displaySmall.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(color: Colors.white70),
          ),
          Text(
            subtitle,
            style: AppTextStyles.caption.copyWith(color: Colors.white60),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList(List<WorkoutHistoryModel> history, String period) {
    if (history.isEmpty) {
      return EmptyState(
        icon: Iconsax.calendar_remove,
        title: 'No workouts recorded',
        message: 'Complete workouts to see them here',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Completed Workouts', style: AppTextStyles.headlineLarge),
        SizedBox(height: AppSizes.sm),
        ...history.map((workout) => Padding(
              padding: EdgeInsets.only(bottom: AppSizes.sm),
              child: _WorkoutHistoryCard(
                history: workout,
                onDelete: () => _deleteHistory(workout),
              ),
            )),
      ],
    );
  }

  void _deleteHistory(WorkoutHistoryModel history) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Record'),
        content: const Text('Remove this workout from history?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<WorkoutProvider>().deleteHistory(history.id!);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Record deleted')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _WorkoutHistoryCard extends StatelessWidget {
  final WorkoutHistoryModel history;
  final VoidCallback onDelete;

  const _WorkoutHistoryCard({
    required this.history,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('EEEE, MMM d').format(history.date);
    final isToday = DateHelper.isToday(history.date);

    return Container(
      padding: EdgeInsets.all(AppSizes.paddingMd),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(
          color: isToday ? AppColors.primary : AppColors.border,
          width: isToday ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(AppSizes.paddingMd),
            decoration: BoxDecoration(
              gradient: AppColors.successGradient,
              borderRadius: BorderRadius.circular(AppSizes.radiusSm),
            ),
            child: Icon(Iconsax.tick_circle, color: Colors.white, size: AppSizes.iconMd),
          ),
          SizedBox(width: AppSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(history.workoutName, style: AppTextStyles.headlineMedium),
                    ),
                    if (isToday)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSizes.paddingSm,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppSizes.radiusXs),
                        ),
                        child: Text(
                          'TODAY',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: AppSizes.xs),
                Row(
                  children: [
                    Icon(Iconsax.calendar, size: AppSizes.iconXs, color: AppColors.textSecondary),
                    SizedBox(width: 4),
                    Text(dateStr, style: AppTextStyles.bodySmall),
                    if (history.actualDuration != null) ...[
                      SizedBox(width: AppSizes.sm),
                      Icon(Iconsax.clock, size: AppSizes.iconXs, color: AppColors.textSecondary),
                      SizedBox(width: 4),
                      Text(
                        '${history.actualDuration} min',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.success,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
                if (history.notes != null && history.notes!.isNotEmpty) ...[
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
                            history.notes!,
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
          IconButton(
            onPressed: onDelete,
            icon: Icon(Iconsax.trash, color: AppColors.error, size: AppSizes.iconSm),
            style: IconButton.styleFrom(
              backgroundColor: AppColors.error.withOpacity(0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusSm),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
