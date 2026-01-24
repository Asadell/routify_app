import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:provider/provider.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../providers/schedule_provider.dart';
import '../../../data/models/schedule_model.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/empty_state.dart';
import '../../routes/app_router.dart';
import '../../../core/utils/size_config.dart';

@RoutePage()
class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({Key? key}) : super(key: key);

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    await context.read<ScheduleProvider>().loadSchedules();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ScheduleProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: 'My Schedule',
        subtitle: 'Manage your daily schedules',
        actions: [
          IconButton(
            tooltip: 'Activate all schedules',
            icon: const Icon(Iconsax.refresh),
            onPressed: () async {
              final provider = context.read<ScheduleProvider>();

              await provider.activateAllSchedules();

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('All schedules activated'),
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.router.push(ScheduleFormRoute());
        },
        icon: const Icon(Iconsax.add),
        label: const Text('Add Schedule'),
      ),
      body: provider.isLoading
          ? const LoadingIndicator(message: 'Loading schedules...')
          : provider.error != null
              ? ErrorDisplay(message: provider.error!, onRetry: _loadData)
              : provider.schedules.isEmpty
                  ? EmptyState(
                      icon: Iconsax.calendar,
                      title: 'No schedules yet',
                      message: 'Create your first schedule to get started',
                      actionLabel: 'Add Schedule',
                      onAction: () {
                        context.router.push(ScheduleFormRoute());
                      },
                    )
                  : RefreshIndicator(
                      onRefresh: _loadData,
                      color: AppColors.primary,
                      child: ListView.separated(
                        padding: EdgeInsets.all(AppSizes.paddingMd),
                        itemCount: provider.schedules.length,
                        separatorBuilder: (_, __) => SizedBox(height: AppSizes.sm),
                        itemBuilder: (context, index) {
                          final schedule = provider.schedules[index];
                          return _ScheduleCard(
                            schedule: schedule,
                            onTap: () {
                              context.router.push(
                                ScheduleFormRoute(schedule: schedule),
                              );
                            },
                            onToggle: () {
                              provider.toggleScheduleActive(schedule);
                            },
                            onDelete: () async {
                              await provider.deleteSchedule(schedule.id!);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Schedule deleted')),
                                );
                              }
                            },
                          );
                        },
                      ),
                    ),
    );
  }
}

class _ScheduleCard extends StatelessWidget {
  final ScheduleModel schedule;
  final VoidCallback onTap;
  final VoidCallback onToggle;
  final Future<void> Function() onDelete;

  const _ScheduleCard({
    required this.schedule,
    required this.onTap,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final days = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    final activeDays = [
      schedule.repeatSun,
      schedule.repeatMon,
      schedule.repeatTue,
      schedule.repeatWed,
      schedule.repeatThu,
      schedule.repeatFri,
      schedule.repeatSat,
    ];

    return Dismissible(
      key: Key(schedule.id.toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: AppSizes.paddingMd),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        ),
        child: Icon(Iconsax.trash, color: Colors.white, size: AppSizes.iconMd),
      ),
      confirmDismiss: (_) async {
        return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Schedule'),
            content: Text('Are you sure you want to delete "${schedule.title}"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                child: const Text('Delete'),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) => onDelete(),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(AppSizes.paddingMd),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            border: Border.all(
              color: schedule.isActive ? AppColors.border : AppColors.borderLight,
            ),
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
                      color: schedule.isActive
                          ? AppColors.primary.withOpacity(0.1)
                          : AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                    ),
                    child: Icon(
                      Iconsax.calendar_1,
                      color: schedule.isActive ? AppColors.primary : AppColors.iconSecondary,
                      size: AppSizes.iconMd,
                    ),
                  ),
                  SizedBox(width: AppSizes.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          schedule.title,
                          style: AppTextStyles.headlineMedium.copyWith(
                            color: schedule.isActive
                                ? AppColors.textPrimary
                                : AppColors.textSecondary,
                          ),
                        ),
                        if (schedule.description != null) ...[
                          SizedBox(height: AppSizes.xs),
                          Text(
                            schedule.description!,
                            style: AppTextStyles.bodySmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  Switch(
                    value: schedule.isActive,
                    onChanged: (_) => onToggle(),
                    activeColor: AppColors.primary,
                  ),
                ],
              ),
              SizedBox(height: AppSizes.md),
              Row(
                children: [
                  Icon(Iconsax.clock, size: AppSizes.iconSm, color: AppColors.textSecondary),
                  SizedBox(width: AppSizes.xs),
                  Text(
                    '${schedule.startTime} - ${schedule.endTime}',
                    style: AppTextStyles.bodyMedium,
                  ),
                  const Spacer(),
                  if (schedule.enableNotification)
                    Icon(
                      Iconsax.notification,
                      size: AppSizes.iconSm,
                      color: AppColors.warning,
                    ),
                ],
              ),
              SizedBox(height: AppSizes.sm),
              if (schedule.useAll7Days)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSizes.paddingSm,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppSizes.radiusXs),
                  ),
                  child: Text(
                    'Every Day',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              else
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(7, (index) {
                    final isActive = activeDays[index];
                    return Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: isActive
                            ? AppColors.primary
                            : AppColors.surfaceVariant,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          days[index],
                          style: AppTextStyles.labelMedium.copyWith(
                            color: isActive ? Colors.white : AppColors.textSecondary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
            ],
          ),
        ),
      ),
    );
  }
}