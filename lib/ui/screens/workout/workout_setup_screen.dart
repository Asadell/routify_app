import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:provider/provider.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../providers/workout_provider.dart';
import '../../../data/models/workout_model.dart';
import '../../../data/models/exercise_model.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../../core/utils/size_config.dart';

@RoutePage()
class WorkoutSetupScreen extends StatefulWidget {
  final WorkoutModel? workout;

  const WorkoutSetupScreen({Key? key, this.workout}) : super(key: key);

  @override
  State<WorkoutSetupScreen> createState() => _WorkoutSetupScreenState();
}

class _WorkoutSetupScreenState extends State<WorkoutSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _durationController;
  late TextEditingController _notesController;

  Set<int> _selectedDays = {};
  bool _enableNotification = false;
  List<ExerciseModel> _exercises = [];

  bool get _isEditing => widget.workout != null;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    if (_isEditing) {
      final workout = widget.workout!;
      _nameController = TextEditingController(text: workout.name);
      _durationController = TextEditingController(
        text: workout.estimatedDuration?.toString() ?? '',
      );
      _notesController = TextEditingController(text: workout.notes ?? '');
      _selectedDays = workout.daysOfWeek.toSet();
      _enableNotification = workout.enableNotification;
      _exercises = List.from(workout.exercises);
    } else {
      _nameController = TextEditingController();
      _durationController = TextEditingController();
      _notesController = TextEditingController();
      _selectedDays = {};
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _durationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _addExercise() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ExerciseFormSheet(
        onSave: (exercise) {
          setState(() {
            _exercises.add(exercise);
          });
        },
      ),
    );
  }

  void _editExercise(int index) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ExerciseFormSheet(
        exercise: _exercises[index],
        onSave: (exercise) {
          setState(() {
            _exercises[index] = exercise;
          });
        },
      ),
    );
  }

  void _deleteExercise(int index) {
    setState(() {
      _exercises.removeAt(index);
    });
  }

  void _saveWorkout() {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one day')),
      );
      return;
    }

    if (_exercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one exercise')),
      );
      return;
    }

    final workout = WorkoutModel(
      id: _isEditing ? widget.workout!.id : null,
      daysOfWeek: _selectedDays.toList()..sort(), // convert ke list dan sort
      name: _nameController.text.trim(),
      estimatedDuration: int.tryParse(_durationController.text),
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      enableNotification: _enableNotification,
      exercises: _exercises,
    );

    final provider = context.read<WorkoutProvider>();
    if (_isEditing) {
      provider.updateWorkout(workout);
    } else {
      provider.addWorkout(workout);
    }

    context.router.pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isEditing ? 'Workout updated' : 'Workout created'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: _isEditing ? 'Edit Workout' : 'New Workout',
        showBackButton: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(AppSizes.paddingMd),
          children: [
            _buildTextField(
              controller: _nameController,
              label: 'Workout Name',
              hint: 'e.g., Upper Body Strength',
              icon: Iconsax.edit,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter workout name';
                }
                return null;
              },
            ),
            SizedBox(height: AppSizes.md),
            _buildDaySelector(),
            SizedBox(height: AppSizes.md),
            _buildTextField(
              controller: _durationController,
              label: 'Estimated Duration (minutes)',
              hint: 'e.g., 60',
              icon: Iconsax.clock,
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: AppSizes.md),
            _buildTextField(
              controller: _notesController,
              label: 'Notes (Optional)',
              hint: 'Add workout notes...',
              icon: Iconsax.note,
              maxLines: 3,
            ),
            SizedBox(height: AppSizes.md),
            _buildSwitchTile(
              icon: Iconsax.notification,
              title: 'Enable Notification',
              subtitle: 'Get reminded on workout day',
              value: _enableNotification,
              onChanged: (value) {
                setState(() => _enableNotification = value);
              },
            ),
            SizedBox(height: AppSizes.lg),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Exercises', style: AppTextStyles.headlineLarge),
                TextButton.icon(
                  onPressed: _addExercise,
                  icon: const Icon(Iconsax.add_circle),
                  label: const Text('Add Exercise'),
                ),
              ],
            ),
            SizedBox(height: AppSizes.sm),
            if (_exercises.isEmpty)
              Container(
                padding: EdgeInsets.all(AppSizes.paddingXl),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  border: Border.all(color: AppColors.border, style: BorderStyle.solid, width: 2),
                ),
                child: Column(
                  children: [
                    Icon(Iconsax.menu, size: AppSizes.iconXl, color: AppColors.iconSecondary),
                    SizedBox(height: AppSizes.sm),
                    Text(
                      'No exercises yet',
                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                    ),
                    Text(
                      'Tap "Add Exercise" to get started',
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.textTertiary),
                    ),
                  ],
                ),
              )
            else
              ReorderableListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _exercises.length,
                onReorder: (oldIndex, newIndex) {
                  setState(() {
                    if (newIndex > oldIndex) {
                      newIndex -= 1;
                    }
                    final item = _exercises.removeAt(oldIndex);
                    _exercises.insert(newIndex, item);
                  });
                },
                itemBuilder: (context, index) {
                  final exercise = _exercises[index];
                  return _ExerciseCard(
                    key: ValueKey(exercise.hashCode),
                    exercise: exercise,
                    index: index,
                    onEdit: () => _editExercise(index),
                    onDelete: () => _deleteExercise(index),
                  );
                },
              ),
            SizedBox(height: AppSizes.xl),
            ElevatedButton(
              onPressed: _saveWorkout,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: AppSizes.paddingMd),
              ),
              child: Text(_isEditing ? 'Update Workout' : 'Create Workout'),
            ),
            SizedBox(height: AppSizes.md),
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
    TextInputType? keyboardType,
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
          keyboardType: keyboardType,
        ),
      ],
    );
  }

  Widget _buildDaySelector() {
    final days = [
      {'label': 'Sun', 'full': 'Sunday', 'value': 0},
      {'label': 'Mon', 'full': 'Monday', 'value': 1},
      {'label': 'Tue', 'full': 'Tuesday', 'value': 2},
      {'label': 'Wed', 'full': 'Wednesday', 'value': 3},
      {'label': 'Thu', 'full': 'Thursday', 'value': 4},
      {'label': 'Fri', 'full': 'Friday', 'value': 5},
      {'label': 'Sat', 'full': 'Saturday', 'value': 6},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Select Days', style: AppTextStyles.labelLarge),
            TextButton(
              onPressed: () {
                setState(() {
                  if (_selectedDays.length == 7) {
                    _selectedDays.clear();
                  } else {
                    _selectedDays = {0, 1, 2, 3, 4, 5, 6};
                  }
                });
              },
              child: Text(_selectedDays.length == 7 ? 'Clear All' : 'Select All'),
            ),
          ],
        ),
        SizedBox(height: AppSizes.sm),
        Wrap(
          spacing: AppSizes.sm,
          runSpacing: AppSizes.sm,
          children: days.map((day) {
            final dayValue = day['value'] as int;
            final isSelected = _selectedDays.contains(dayValue);
            
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _selectedDays.remove(dayValue);
                  } else {
                    _selectedDays.add(dayValue);
                  }
                });
              },
              child: Container(
                width: 48,
                height: 60,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.surface,
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.border,
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (isSelected)
                      Icon(
                        Iconsax.tick_circle,
                        size: 16,
                        color: Colors.white,
                      )
                    else
                      SizedBox(height: 16),
                    SizedBox(height: 4),
                    Text(
                      day['label'] as String,
                      style: AppTextStyles.labelMedium.copyWith(
                        color: isSelected ? Colors.white : AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        SizedBox(height: AppSizes.sm),
        if (_selectedDays.isNotEmpty)
          Container(
            padding: EdgeInsets.all(AppSizes.paddingSm),
            decoration: BoxDecoration(
              color: AppColors.info.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppSizes.radiusSm),
            ),
            child: Row(
              children: [
                Icon(Iconsax.calendar, size: AppSizes.iconXs, color: AppColors.info),
                SizedBox(width: AppSizes.xs),
                Expanded(
                  child: Text(
                    'Selected: ${_selectedDays.length} day${_selectedDays.length > 1 ? 's' : ''}',
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.info),
                  ),
                ),
              ],
            ),
          ),
      ],
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

class _ExerciseCard extends StatelessWidget {
  final ExerciseModel exercise;
  final int index;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ExerciseCard({
    Key? key,
    required this.exercise,
    required this.index,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: AppSizes.sm),
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        child: Dismissible(
          key: ValueKey(exercise.hashCode),
          direction: DismissDirection.endToStart,
          background: Container(
            color: AppColors.error,
            alignment: Alignment.centerRight,
            padding: EdgeInsets.only(right: AppSizes.paddingMd),
            child: Icon(Iconsax.trash, color: Colors.white, size: AppSizes.iconMd),
          ),
          confirmDismiss: (_) async {
            return await showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Delete Exercise'),
                content: Text('Remove "${exercise.name}" from workout?'),
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
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onEdit,
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              child: Padding(
                padding: EdgeInsets.all(AppSizes.paddingMd),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: AppColors.successGradient,
                        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: AppTextStyles.headlineSmall.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: AppSizes.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(exercise.name, style: AppTextStyles.headlineMedium),
                          SizedBox(height: AppSizes.xs),
                          Row(
                            children: [
                              if (exercise.isStrength) ...[
                                Icon(Iconsax.weight_1, size: AppSizes.iconXs, color: AppColors.textSecondary),
                                SizedBox(width: 4),
                                Text(
                                  '${exercise.sets} sets × ${exercise.reps} reps',
                                  style: AppTextStyles.bodySmall,
                                ),
                                if (exercise.weight != null) ...[
                                  SizedBox(width: AppSizes.sm),
                                  Text(
                                    '${exercise.weight} kg',
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ] else if (exercise.isCardio) ...[
                                Icon(Iconsax.timer_1, size: AppSizes.iconXs, color: AppColors.textSecondary),
                                SizedBox(width: 4),
                                Text(
                                  '${exercise.durationMinutes} minutes',
                                  style: AppTextStyles.bodySmall,
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                    Icon(Iconsax.menu, color: AppColors.iconSecondary, size: AppSizes.iconMd),
                    SizedBox(width: AppSizes.xs),
                    Icon(Iconsax.edit_2, color: AppColors.primary, size: AppSizes.iconSm),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ExerciseFormSheet extends StatefulWidget {
  final ExerciseModel? exercise;
  final Function(ExerciseModel) onSave;

  const _ExerciseFormSheet({
    this.exercise,
    required this.onSave,
  });

  @override
  State<_ExerciseFormSheet> createState() => _ExerciseFormSheetState();
}

class _ExerciseFormSheetState extends State<_ExerciseFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _setsController;
  late TextEditingController _repsController;
  late TextEditingController _durationController;
  late TextEditingController _weightController;

  String _exerciseType = 'strength'; // strength or cardio

  bool get _isEditing => widget.exercise != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final exercise = widget.exercise!;
      _nameController = TextEditingController(text: exercise.name);
      _setsController = TextEditingController(text: exercise.sets?.toString() ?? '');
      _repsController = TextEditingController(text: exercise.reps?.toString() ?? '');
      _durationController = TextEditingController(text: exercise.durationMinutes?.toString() ?? '');
      _weightController = TextEditingController(text: exercise.weight?.toString() ?? '');
      _exerciseType = exercise.isStrength ? 'strength' : 'cardio';
    } else {
      _nameController = TextEditingController();
      _setsController = TextEditingController();
      _repsController = TextEditingController();
      _durationController = TextEditingController();
      _weightController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _setsController.dispose();
    _repsController.dispose();
    _durationController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final exercise = ExerciseModel(
      id: _isEditing ? widget.exercise!.id : null,
      workoutId: _isEditing ? widget.exercise!.workoutId : 0,
      name: _nameController.text.trim(),
      sets: _exerciseType == 'strength' ? int.tryParse(_setsController.text) : null,
      reps: _exerciseType == 'strength' ? int.tryParse(_repsController.text) : null,
      durationMinutes: _exerciseType == 'cardio' ? int.tryParse(_durationController.text) : null,
      weight: _exerciseType == 'strength' && _weightController.text.isNotEmpty
          ? double.tryParse(_weightController.text)
          : null,
    );

    widget.onSave(exercise);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSizes.radiusLg)),
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.all(AppSizes.paddingLg),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              SizedBox(height: AppSizes.md),
              Text(
                _isEditing ? 'Edit Exercise' : 'Add Exercise',
                style: AppTextStyles.headlineLarge,
              ),
              SizedBox(height: AppSizes.lg),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Exercise Name',
                  hintText: 'e.g., Push-ups, Running',
                  prefixIcon: Icon(Iconsax.edit, size: AppSizes.iconSm),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter exercise name';
                  }
                  return null;
                },
              ),
              SizedBox(height: AppSizes.md),
              Text('Exercise Type', style: AppTextStyles.labelLarge),
              SizedBox(height: AppSizes.sm),
              Row(
                children: [
                  Expanded(
                    child: _buildTypeOption('strength', 'Strength', Iconsax.weight_1),
                  ),
                  SizedBox(width: AppSizes.sm),
                  Expanded(
                    child: _buildTypeOption('cardio', 'Cardio', Iconsax.activity),
                  ),
                ],
              ),
              SizedBox(height: AppSizes.md),
              if (_exerciseType == 'strength') ...[
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _setsController,
                        decoration: InputDecoration(
                          labelText: 'Sets',
                          hintText: '3',
                          prefixIcon: Icon(Iconsax.layer, size: AppSizes.iconSm),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Required';
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(width: AppSizes.sm),
                    Expanded(
                      child: TextFormField(
                        controller: _repsController,
                        decoration: InputDecoration(
                          labelText: 'Reps',
                          hintText: '12',
                          prefixIcon: Icon(Iconsax.repeat, size: AppSizes.iconSm),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Required';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppSizes.md),
                TextFormField(
                  controller: _weightController,
                  decoration: InputDecoration(
                    labelText: 'Weight (Optional)',
                    hintText: 'kg',
                    prefixIcon: Icon(Iconsax.weight, size: AppSizes.iconSm),
                  ),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                ),
              ] else ...[
                TextFormField(
                  controller: _durationController,
                  decoration: InputDecoration(
                    labelText: 'Duration',
                    hintText: 'minutes',
                    prefixIcon: Icon(Iconsax.timer_1, size: AppSizes.iconSm),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter duration';
                    }
                    return null;
                  },
                ),
              ],
              SizedBox(height: AppSizes.lg),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: AppSizes.paddingMd),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  SizedBox(width: AppSizes.sm),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _save,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: AppSizes.paddingMd),
                      ),
                      child: Text(_isEditing ? 'Update' : 'Add'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeOption(String value, String label, IconData icon) {
    final isSelected = _exerciseType == value;
    return GestureDetector(
      onTap: () {
        setState(() => _exerciseType = value);
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: AppSizes.paddingMd),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.1) : AppColors.surface,
          borderRadius: BorderRadius.circular(AppSizes.radiusSm),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primary : AppColors.iconSecondary,
              size: AppSizes.iconMd,
            ),
            SizedBox(height: AppSizes.xs),
            Text(
              label,
              style: AppTextStyles.labelMedium.copyWith(
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}