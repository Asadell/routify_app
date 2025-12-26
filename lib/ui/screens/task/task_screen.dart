import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:provider/provider.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:intl/intl.dart';
import '../../../providers/task_provider.dart';
import '../../../data/models/task_model.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/empty_state.dart';
import '../../routes/app_router.dart';
import '../../../core/utils/size_config.dart';

@RoutePage()
class TaskScreen extends StatefulWidget {
  const TaskScreen({Key? key}) : super(key: key);

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    await context.read<TaskProvider>().loadAllTaskCategories();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TaskProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: 'Tasks',
        subtitle: 'Manage your to-do list',
        // actions: [
        //   IconButton(
        //     icon: const Icon(Iconsax.sort),
        //     onPressed: () {},
        //   ),
        // ],
      ),
      // floatingActionButton: FloatingActionButton.extended(
      //   onPressed: () {
      //     context.router.push(TaskFormRoute());
      //   },
      //   icon: const Icon(Iconsax.add),
      //   label: const Text('Add Task'),
      // ),
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
                Tab(text: 'Today'),
                Tab(text: 'Upcoming'),
                Tab(text: 'Completed'),
                Tab(text: 'Priority'),
              ],
            ),
          ),
          Expanded(
            child: provider.isLoading
                ? const LoadingIndicator(message: 'Loading tasks...')
                : provider.error != null
                    ? ErrorDisplay(message: provider.error!, onRetry: _loadData)
                    : TabBarView(
                        controller: _tabController,
                        children: [
                          _buildTaskList(provider.todayTasks, 'No tasks for today'),
                          _buildTaskList(provider.upcomingTasks, 'No upcoming tasks'),
                          _buildTaskList(provider.completedTasks, 'No completed tasks'),
                          _buildPriorityTab(provider),
                        ],
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskList(List<TaskModel> tasks, String emptyMessage) {
    if (tasks.isEmpty) {
      return EmptyState(
        icon: Iconsax.task_square,
        title: emptyMessage,
        message: 'Create a new task to get started',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      color: AppColors.primary,
      child: ListView.separated(
        padding: EdgeInsets.all(AppSizes.paddingMd),
        itemCount: tasks.length,
        separatorBuilder: (_, __) => SizedBox(height: AppSizes.sm),
        itemBuilder: (context, index) {
          final task = tasks[index];
          return _TaskCard(
            task: task,
            onTap: () {
              context.router.push(TaskFormRoute(task: task));
            },
            onToggle: () {
              context.read<TaskProvider>().toggleTaskStatus(task.id!);
            },
            onDelete: () {
              _showDeleteDialog(context, task);
            },
          );
        },
      ),
    );
  }

  Widget _buildPriorityTab(TaskProvider provider) {
    final highTasks = provider.tasks.where((t) => t.priority == 'high' && t.isPending).toList();
    final mediumTasks = provider.tasks.where((t) => t.priority == 'medium' && t.isPending).toList();
    final lowTasks = provider.tasks.where((t) => t.priority == 'low' && t.isPending).toList();

    if (highTasks.isEmpty && mediumTasks.isEmpty && lowTasks.isEmpty) {
      return const EmptyState(
        icon: Iconsax.task_square,
        title: 'No pending tasks',
        message: 'All tasks completed!',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      color: AppColors.primary,
      child: ListView(
        padding: EdgeInsets.all(AppSizes.paddingMd),
        children: [
          if (highTasks.isNotEmpty) ...[
            _buildPrioritySection('High Priority', highTasks, AppColors.priorityHigh),
            SizedBox(height: AppSizes.lg),
          ],
          if (mediumTasks.isNotEmpty) ...[
            _buildPrioritySection('Medium Priority', mediumTasks, AppColors.priorityMedium),
            SizedBox(height: AppSizes.lg),
          ],
          if (lowTasks.isNotEmpty) ...[
            _buildPrioritySection('Low Priority', lowTasks, AppColors.priorityLow),
          ],
        ],
      ),
    );
  }

  Widget _buildPrioritySection(String title, List<TaskModel> tasks, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 20,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(width: AppSizes.sm),
            Text(title, style: AppTextStyles.headlineMedium),
            SizedBox(width: AppSizes.sm),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSizes.paddingSm,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppSizes.radiusXs),
              ),
              child: Text(
                '${tasks.length}',
                style: AppTextStyles.labelSmall.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: AppSizes.sm),
        ...tasks.map((task) => Padding(
              padding: EdgeInsets.only(bottom: AppSizes.sm),
              child: _TaskCard(
                task: task,
                onTap: () {
                  context.router.push(TaskFormRoute(task: task));
                },
                onToggle: () {
                  context.read<TaskProvider>().toggleTaskStatus(task.id!);
                },
                onDelete: () {
                  _showDeleteDialog(context, task);
                },
              ),
            )),
      ],
    );
  }

  void _showDeleteDialog(BuildContext context, TaskModel task) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: Text('Are you sure you want to delete "${task.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<TaskProvider>().deleteTask(task.id!);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Task deleted')),
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

class _TaskCard extends StatelessWidget {
  final TaskModel task;
  final VoidCallback onTap;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const _TaskCard({
    required this.task,
    required this.onTap,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    Color priorityColor = AppColors.priorityMedium;
    if (task.priority == 'high') priorityColor = AppColors.priorityHigh;
    if (task.priority == 'low') priorityColor = AppColors.priorityLow;

    return Dismissible(
      key: Key(task.id.toString()),
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
        return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Task'),
            content: Text('Are you sure you want to delete "${task.title}"?'),
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
                        onChanged: (_) => onToggle(),
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
                            if (task.description != null) ...[
                              SizedBox(height: AppSizes.xs),
                              Text(
                                task.description!,
                                style: AppTextStyles.bodySmall,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                            if (task.dueDate != null) ...[
                              SizedBox(height: AppSizes.sm),
                              Row(
                                children: [
                                  Icon(
                                    Iconsax.calendar,
                                    size: AppSizes.iconXs,
                                    color: task.isOverdue ? AppColors.error : AppColors.textSecondary,
                                  ),
                                  SizedBox(width: AppSizes.xs),
                                  Text(
                                    DateFormat('MMM d, yyyy').format(task.dueDate!),
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: task.isOverdue ? AppColors.error : AppColors.textSecondary,
                                      fontWeight: task.isOverdue ? FontWeight.w600 : FontWeight.normal,
                                    ),
                                  ),
                                  if (task.isOverdue) ...[
                                    SizedBox(width: AppSizes.xs),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: AppSizes.paddingSm,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.error.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(AppSizes.radiusXs),
                                      ),
                                      child: Text(
                                        'OVERDUE',
                                        style: AppTextStyles.labelSmall.copyWith(
                                          color: AppColors.error,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                      SizedBox(width: AppSizes.sm),
                      Column(
                        children: [
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
                          if (task.enableNotification) ...[
                            SizedBox(height: AppSizes.xs),
                            Icon(
                              Iconsax.notification,
                              size: AppSizes.iconSm,
                              color: AppColors.warning,
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
