import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:provider/provider.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import '../../../providers/workout_provider.dart';
import '../../../data/models/workout_model.dart';
import '../../../data/models/workout_history_model.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../../core/utils/size_config.dart';

@RoutePage()
class WorkoutSessionScreen extends StatefulWidget {
  final WorkoutModel workout;
  final DateTime date;

  const WorkoutSessionScreen({
    Key? key,
    required this.workout,
    required this.date,
  }) : super(key: key);

  @override
  State<WorkoutSessionScreen> createState() => _WorkoutSessionScreenState();
}

class _WorkoutSessionScreenState extends State<WorkoutSessionScreen> {
  bool _isSessionStarted = false;
  bool _isSessionCompleted = false;
  int _elapsedSeconds = 0;
  Timer? _timer;
  
  final Map<int, bool> _completedExercises = {};
  final Map<int, TextEditingController> _actualSetsControllers = {};
  final Map<int, TextEditingController> _actualRepsControllers = {};
  final Map<int, TextEditingController> _actualDurationControllers = {};
  final Map<int, TextEditingController> _actualWeightControllers = {};

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    for (int i = 0; i < widget.workout.exercises.length; i++) {
      _completedExercises[i] = false;
      _actualSetsControllers[i] = TextEditingController();
      _actualRepsControllers[i] = TextEditingController();
      _actualDurationControllers[i] = TextEditingController();
      _actualWeightControllers[i] = TextEditingController();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _actualSetsControllers.values.forEach((c) => c.dispose());
    _actualRepsControllers.values.forEach((c) => c.dispose());
    _actualDurationControllers.values.forEach((c) => c.dispose());
    _actualWeightControllers.values.forEach((c) => c.dispose());
    super.dispose();
  }

  void _startSession() {
    setState(() {
      _isSessionStarted = true;
      _elapsedSeconds = 0;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _elapsedSeconds++;
      });
    });
  }

  void _completeSession() {
    _timer?.cancel();

    // Hitung exercise yang selesai
    final completedCount = _completedExercises.values.where((v) => v).length;
    
    if (completedCount == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please complete at least one exercise'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isSessionCompleted = true;
    });
  }

  String _formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m ${secs}s';
    } else if (minutes > 0) {
      return '${minutes}m ${secs}s';
    } else {
      return '${secs}s';
    }
  }

  int get _completedExercisesCount {
    return _completedExercises.values.where((v) => v).length;
  }

  double get _progressPercentage {
    if (widget.workout.exercises.isEmpty) return 0;
    return _completedExercisesCount / widget.workout.exercises.length;
  }

  Future<void> _saveAndFinish() async {
    final history = WorkoutHistoryModel(
      workoutName: widget.workout.name,
      date: widget.date,
      actualDuration: _elapsedSeconds ~/ 60, // Convert to minutes
      notes: 'Completed ${_completedExercisesCount}/${widget.workout.exercises.length} exercises',
    );

    await context.read<WorkoutProvider>().completeWorkout(history);

    if (mounted) {
      context.router.pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Workout completed! Great job!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isSessionCompleted) {
      return _buildCompletionScreen();
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: widget.workout.name,
        subtitle: DateFormat('EEEE, MMM d').format(widget.date),
        showBackButton: true,
      ),
      body: Column(
        children: [
          _buildStatusHeader(),
          _buildProgressSection(),
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(AppSizes.paddingMd),
              children: [
                if (widget.workout.notes != null && widget.workout.notes!.isNotEmpty)
                  _buildNotesSection(),
                SizedBox(height: AppSizes.md),
                Text('Exercises', style: AppTextStyles.headlineLarge),
                SizedBox(height: AppSizes.sm),
                ...List.generate(
                  widget.workout.exercises.length,
                  (index) => _buildExerciseCard(index),
                ),
                SizedBox(height: AppSizes.xl),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildStatusHeader() {
    return Container(
      padding: EdgeInsets.all(AppSizes.paddingMd),
      decoration: BoxDecoration(
        color: _isSessionStarted ? AppColors.success : AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: _isSessionStarted ? Colors.white : AppColors.textSecondary,
              shape: BoxShape.circle,
              boxShadow: _isSessionStarted
                  ? [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.5),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ]
                  : null,
            ),
          ),
          SizedBox(width: AppSizes.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isSessionStarted ? 'Session Active' : 'Ready to Start',
                  style: AppTextStyles.labelLarge.copyWith(
                    color: _isSessionStarted ? Colors.white : AppColors.textPrimary,
                  ),
                ),
                Text(
                  _isSessionStarted
                      ? 'Duration: ${_formatDuration(_elapsedSeconds)}'
                      : 'Target: ${widget.workout.estimatedDuration ?? 0} min',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: _isSessionStarted ? Colors.white70 : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (_isSessionStarted)
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSizes.paddingMd,
                vertical: AppSizes.paddingSm,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(AppSizes.radiusSm),
              ),
              child: Text(
                _formatDuration(_elapsedSeconds),
                style: AppTextStyles.headlineMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProgressSection() {
    return Container(
      padding: EdgeInsets.all(AppSizes.paddingMd),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(color: AppColors.border),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Progress', style: AppTextStyles.labelLarge),
              Text(
                '$_completedExercisesCount/${widget.workout.exercises.length} completed',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSizes.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSizes.radiusSm),
            child: LinearProgressIndicator(
              value: _progressPercentage,
              backgroundColor: AppColors.surfaceVariant,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.success),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesSection() {
    return Container(
      padding: EdgeInsets.all(AppSizes.paddingMd),
      decoration: BoxDecoration(
        color: AppColors.info.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: AppColors.info.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Iconsax.note, size: AppSizes.iconSm, color: AppColors.info),
          SizedBox(width: AppSizes.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Workout Notes',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.info,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: AppSizes.xs),
                Text(
                  widget.workout.notes!,
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.textPrimary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseCard(int index) {
    final exercise = widget.workout.exercises[index];
    final isCompleted = _completedExercises[index] ?? false;

    return Container(
      margin: EdgeInsets.only(bottom: AppSizes.sm),
      decoration: BoxDecoration(
        color: isCompleted ? AppColors.success.withOpacity(0.1) : AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(
          color: isCompleted ? AppColors.success : AppColors.border,
          width: isCompleted ? 2 : 1,
        ),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: EdgeInsets.all(AppSizes.paddingMd),
            child: Row(
              children: [
                Checkbox(
                  value: isCompleted,
                  onChanged: _isSessionStarted
                      ? (value) {
                          setState(() {
                            _completedExercises[index] = value ?? false;
                          });
                        }
                      : null,
                  activeColor: AppColors.success,
                ),
                SizedBox(width: AppSizes.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exercise.name,
                        style: AppTextStyles.headlineMedium.copyWith(
                          decoration: isCompleted ? TextDecoration.lineThrough : null,
                          color: isCompleted ? AppColors.textSecondary : AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: AppSizes.xs),
                      Row(
                        children: [
                          Icon(
                            exercise.isStrength ? Iconsax.weight_1 : Iconsax.timer_1,
                            size: AppSizes.iconXs,
                            color: AppColors.textSecondary,
                          ),
                          SizedBox(width: 4),
                          Text(
                            exercise.isStrength
                                ? '${exercise.sets} × ${exercise.reps} reps'
                                : '${exercise.durationMinutes} min',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
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
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    gradient: isCompleted ? AppColors.successGradient : AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: AppTextStyles.labelLarge.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Input fields (only visible when session started)
          if (_isSessionStarted) ...[
            Container(
              padding: EdgeInsets.all(AppSizes.paddingMd),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant.withOpacity(0.5),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(AppSizes.radiusMd),
                  bottomRight: Radius.circular(AppSizes.radiusMd),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Actual Performance',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: AppSizes.sm),
                  if (exercise.isStrength) ...[
                    Row(
                      children: [
                        Expanded(
                          child: _buildInputField(
                            controller: _actualSetsControllers[index]!,
                            label: 'Sets',
                            hint: '${exercise.sets}',
                          ),
                        ),
                        SizedBox(width: AppSizes.sm),
                        Expanded(
                          child: _buildInputField(
                            controller: _actualRepsControllers[index]!,
                            label: 'Reps',
                            hint: '${exercise.reps}',
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: AppSizes.sm),
                    _buildInputField(
                      controller: _actualWeightControllers[index]!,
                      label: 'Weight (kg)',
                      hint: exercise.weight?.toString() ?? '0',
                    ),
                  ] else ...[
                    _buildInputField(
                      controller: _actualDurationControllers[index]!,
                      label: 'Duration (min)',
                      hint: '${exercise.durationMinutes}',
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        SizedBox(height: 4),
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            hintText: hint,
            isDense: true,
            contentPadding: EdgeInsets.symmetric(
              horizontal: AppSizes.paddingSm,
              vertical: AppSizes.paddingSm,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: EdgeInsets.all(AppSizes.paddingMd),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: _isSessionStarted
            ? ElevatedButton(
                onPressed: _completeSession,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: AppSizes.paddingMd),
                  backgroundColor: AppColors.success,
                ),
                child: const Text('Finish Workout'),
              )
            : ElevatedButton(
                onPressed: _startSession,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: AppSizes.paddingMd),
                ),
                child: const Text('Start Workout'),
              ),
      ),
    );
  }

  Widget _buildCompletionScreen() {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(AppSizes.paddingLg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(AppSizes.paddingXl),
                decoration: BoxDecoration(
                  gradient: AppColors.successGradient,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Iconsax.tick_circle,
                  size: 80,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: AppSizes.xl),
              Text(
                '🎉 Workout Complete!',
                style: AppTextStyles.displaySmall,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppSizes.md),
              Text(
                'Great job! You finished your workout session.',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppSizes.xl),
              Container(
                padding: EdgeInsets.all(AppSizes.paddingLg),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    _buildSummaryRow(
                      icon: Iconsax.timer_1,
                      label: 'Total Duration',
                      value: _formatDuration(_elapsedSeconds),
                    ),
                    Divider(height: AppSizes.lg),
                    _buildSummaryRow(
                      icon: Iconsax.tick_circle,
                      label: 'Exercises Completed',
                      value: '$_completedExercisesCount/${widget.workout.exercises.length}',
                    ),
                    Divider(height: AppSizes.lg),
                    _buildSummaryRow(
                      icon: Iconsax.calendar,
                      label: 'Date',
                      value: DateFormat('MMM d, yyyy').format(widget.date),
                    ),
                  ],
                ),
              ),
              SizedBox(height: AppSizes.xl),
              ElevatedButton(
                onPressed: _saveAndFinish,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSizes.paddingXl,
                    vertical: AppSizes.paddingMd,
                  ),
                  backgroundColor: AppColors.success,
                ),
                child: const Text('Save & Return to Dashboard'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
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
          child: Text(label, style: AppTextStyles.bodyMedium),
        ),
        Text(
          value,
          style: AppTextStyles.headlineSmall.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}