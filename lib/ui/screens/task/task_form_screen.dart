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
import '../../../core/utils/size_config.dart';

@RoutePage()
class TaskFormScreen extends StatefulWidget {
  final TaskModel? task;

  const TaskFormScreen({Key? key, this.task}) : super(key: key);

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _dueDateController;

  DateTime? _dueDate;
  String _priority = 'medium';
  bool _enableNotification = false;

  bool get _isEditing => widget.task != null;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    if (_isEditing) {
      final task = widget.task!;
      _titleController = TextEditingController(text: task.title);
      _descriptionController = TextEditingController(text: task.description ?? '');
      _dueDate = task.dueDate;
      if (_dueDate != null) {
        _dueDateController = TextEditingController(
          text: DateFormat('MMM d, yyyy').format(_dueDate!),
        );
      } else {
        _dueDateController = TextEditingController();
      }
      _priority = task.priority;
      _enableNotification = task.enableNotification;
    } else {
      _titleController = TextEditingController();
      _descriptionController = TextEditingController();
      _dueDateController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _dueDateController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (date != null) {
      setState(() {
        _dueDate = date;
        _dueDateController.text = DateFormat('MMM d, yyyy').format(date);
      });
    }
  }

  void _saveTask() {
    if (!_formKey.currentState!.validate()) return;

    final task = TaskModel(
      id: _isEditing ? widget.task!.id : null,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      dueDate: _dueDate,
      priority: _priority,
      status: _isEditing ? widget.task!.status : 'pending',
      enableNotification: _enableNotification,
    );

    final provider = context.read<TaskProvider>();
    if (_isEditing) {
      provider.updateTask(task);
    } else {
      provider.addTask(task);
    }

    context.router.pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isEditing ? 'Task updated' : 'Task created'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: _isEditing ? 'Edit Task' : 'New Task',
        showBackButton: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(AppSizes.paddingMd),
          children: [
            _buildTextField(
              controller: _titleController,
              label: 'Title',
              hint: 'e.g., Buy groceries',
              icon: Iconsax.edit,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),
            SizedBox(height: AppSizes.md),
            _buildTextField(
              controller: _descriptionController,
              label: 'Description (Optional)',
              hint: 'Add details...',
              icon: Iconsax.document_text,
              maxLines: 4,
            ),
            SizedBox(height: AppSizes.md),
            _buildDateField(),
            SizedBox(height: AppSizes.lg),
            _buildPrioritySelector(),
            SizedBox(height: AppSizes.md),
            _buildSwitchTile(
              icon: Iconsax.notification,
              title: 'Enable Notification',
              subtitle: 'Get reminded 1 hour before due date',
              value: _enableNotification,
              onChanged: (value) {
                setState(() => _enableNotification = value);
              },
            ),
            SizedBox(height: AppSizes.xl),
            ElevatedButton(
              onPressed: _saveTask,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: AppSizes.paddingMd),
              ),
              child: Text(_isEditing ? 'Update Task' : 'Create Task'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.labelLarge),
        SizedBox(height: AppSizes.xs),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, size: AppSizes.iconSm),
          ),
          validator: validator,
          maxLines: maxLines,
        ),
      ],
    );
  }

  Widget _buildDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Due Date (Optional)', style: AppTextStyles.labelLarge),
        SizedBox(height: AppSizes.xs),
        TextFormField(
          controller: _dueDateController,
          decoration: InputDecoration(
            hintText: 'Select date',
            prefixIcon: Icon(Iconsax.calendar, size: AppSizes.iconSm),
            suffixIcon: _dueDate != null
                ? IconButton(
                    icon: const Icon(Iconsax.close_circle),
                    onPressed: () {
                      setState(() {
                        _dueDate = null;
                        _dueDateController.clear();
                      });
                    },
                  )
                : null,
          ),
          readOnly: true,
          onTap: _pickDate,
        ),
      ],
    );
  }

  Widget _buildPrioritySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Priority', style: AppTextStyles.labelLarge),
        SizedBox(height: AppSizes.sm),
        Row(
          children: [
            Expanded(
              child: _buildPriorityOption('low', 'Low', AppColors.priorityLow, Iconsax.arrow_down),
            ),
            SizedBox(width: AppSizes.sm),
            Expanded(
              child: _buildPriorityOption('medium', 'Medium', AppColors.priorityMedium, Iconsax.minus),
            ),
            SizedBox(width: AppSizes.sm),
            Expanded(
              child: _buildPriorityOption('high', 'High', AppColors.priorityHigh, Iconsax.arrow_up),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPriorityOption(String value, String label, Color color, IconData icon) {
    final isSelected = _priority == value;
    return GestureDetector(
      onTap: () {
        setState(() => _priority = value);
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: AppSizes.paddingMd),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : AppColors.surface,
          borderRadius: BorderRadius.circular(AppSizes.radiusSm),
          border: Border.all(
            color: isSelected ? color : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? color : AppColors.iconSecondary,
              size: AppSizes.iconMd,
            ),
            SizedBox(height: AppSizes.xs),
            Text(
              label,
              style: AppTextStyles.labelMedium.copyWith(
                color: isSelected ? color : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
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
            padding: EdgeInsets.all(AppSizes.paddingSm),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppSizes.radiusSm),
            ),
            child: Icon(icon, color: AppColors.primary, size: AppSizes.iconMd),
          ),
          SizedBox(width: AppSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.headlineSmall),
                Text(subtitle, style: AppTextStyles.bodySmall),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}