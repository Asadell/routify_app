import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:provider/provider.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../providers/schedule_provider.dart';
import '../../../data/models/schedule_model.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../../core/utils/size_config.dart';
import '../../../core/utils/date_helper.dart';

@RoutePage()
class ScheduleFormScreen extends StatefulWidget {
  final ScheduleModel? schedule;

  const ScheduleFormScreen({Key? key, this.schedule}) : super(key: key);

  @override
  State<ScheduleFormScreen> createState() => _ScheduleFormScreenState();
}

class _ScheduleFormScreenState extends State<ScheduleFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _startTimeController;
  late TextEditingController _endTimeController;

  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  bool _repeatMon = false;
  bool _repeatTue = false;
  bool _repeatWed = false;
  bool _repeatThu = false;
  bool _repeatFri = false;
  bool _repeatSat = false;
  bool _repeatSun = false;
  bool _useAll7Days = false;
  bool _enableNotification = false;

  bool get _isEditing => widget.schedule != null;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    if (_isEditing) {
      final schedule = widget.schedule!;
      _titleController = TextEditingController(text: schedule.title);
      _descriptionController = TextEditingController(text: schedule.description ?? '');
      _startTimeController = TextEditingController(text: schedule.startTime);
      _endTimeController = TextEditingController(text: schedule.endTime);

      final startDateTime = DateHelper.parseTime(schedule.startTime);
      final endDateTime = DateHelper.parseTime(schedule.endTime);
      if (startDateTime != null) {
        _startTime = TimeOfDay.fromDateTime(startDateTime);
      }
      if (endDateTime != null) {
        _endTime = TimeOfDay.fromDateTime(endDateTime);
      }

      _repeatMon = schedule.repeatMon;
      _repeatTue = schedule.repeatTue;
      _repeatWed = schedule.repeatWed;
      _repeatThu = schedule.repeatThu;
      _repeatFri = schedule.repeatFri;
      _repeatSat = schedule.repeatSat;
      _repeatSun = schedule.repeatSun;
      _useAll7Days = schedule.useAll7Days;
      _enableNotification = schedule.enableNotification;
    } else {
      _titleController = TextEditingController();
      _descriptionController = TextEditingController();
      _startTimeController = TextEditingController();
      _endTimeController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    super.dispose();
  }

  Future<void> _pickTime(bool isStartTime) async {
    final time = await showTimePicker(
      context: context,
      initialTime: isStartTime
          ? (_startTime ?? TimeOfDay.now())
          : (_endTime ?? TimeOfDay.now()),
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

    if (time != null) {
      setState(() {
        if (isStartTime) {
          _startTime = time;
          _startTimeController.text = time.format(context);
        } else {
          _endTime = time;
          _endTimeController.text = time.format(context);
        }
      });
    }
  }

  void _saveSchedule() {
    if (!_formKey.currentState!.validate()) return;

    if (_startTime == null || _endTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select start and end time')),
      );
      return;
    }

    final schedule = ScheduleModel(
      id: _isEditing ? widget.schedule!.id : null,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      startTime: _startTimeController.text,
      endTime: _endTimeController.text,
      repeatMon: _repeatMon,
      repeatTue: _repeatTue,
      repeatWed: _repeatWed,
      repeatThu: _repeatThu,
      repeatFri: _repeatFri,
      repeatSat: _repeatSat,
      repeatSun: _repeatSun,
      useAll7Days: _useAll7Days,
      enableNotification: _enableNotification,
    );

    final provider = context.read<ScheduleProvider>();
    if (_isEditing) {
      provider.updateSchedule(schedule);
    } else {
      provider.addSchedule(schedule);
    }

    context.router.pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isEditing ? 'Schedule updated' : 'Schedule created'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: _isEditing ? 'Edit Schedule' : 'New Schedule',
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
              hint: 'e.g., Morning Workout',
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
              hint: 'Add a description...',
              icon: Iconsax.document_text,
              maxLines: 3,
            ),
            SizedBox(height: AppSizes.md),
            Row(
              children: [
                Expanded(
                  child: _buildTimeField(
                    controller: _startTimeController,
                    label: 'Start Time',
                    icon: Iconsax.clock,
                    onTap: () => _pickTime(true),
                  ),
                ),
                SizedBox(width: AppSizes.md),
                Expanded(
                  child: _buildTimeField(
                    controller: _endTimeController,
                    label: 'End Time',
                    icon: Iconsax.clock,
                    onTap: () => _pickTime(false),
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSizes.lg),
            _buildSectionTitle('Repeat Days'),
            SizedBox(height: AppSizes.sm),
            _buildDaySelector(),
            SizedBox(height: AppSizes.md),
            _buildSwitchTile(
              icon: Iconsax.calendar_2,
              title: 'Use All 7 Days',
              subtitle: 'Schedule will repeat every day',
              value: _useAll7Days,
              onChanged: (value) {
                setState(() {
                  _useAll7Days = value;
                  if (value) {
                    _repeatMon = _repeatTue = _repeatWed = true;
                    _repeatThu = _repeatFri = _repeatSat = _repeatSun = true;
                  }
                });
              },
            ),
            SizedBox(height: AppSizes.sm),
            _buildSwitchTile(
              icon: Iconsax.notification,
              title: 'Enable Notification',
              subtitle: 'Get reminded at start time',
              value: _enableNotification,
              onChanged: (value) {
                setState(() => _enableNotification = value);
              },
            ),
            SizedBox(height: AppSizes.xl),
            ElevatedButton(
              onPressed: _saveSchedule,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: AppSizes.paddingMd),
              ),
              child: Text(_isEditing ? 'Update Schedule' : 'Create Schedule'),
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

  Widget _buildTimeField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.labelLarge),
        SizedBox(height: AppSizes.xs),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'Select time',
            prefixIcon: Icon(icon, size: AppSizes.iconSm),
          ),
          readOnly: true,
          onTap: onTap,
        ),
      ],
    );
  }

  Widget _buildDaySelector() {
    final days = [
      {'label': 'M', 'value': _repeatMon, 'key': 'mon'},
      {'label': 'T', 'value': _repeatTue, 'key': 'tue'},
      {'label': 'W', 'value': _repeatWed, 'key': 'wed'},
      {'label': 'T', 'value': _repeatThu, 'key': 'thu'},
      {'label': 'F', 'value': _repeatFri, 'key': 'fri'},
      {'label': 'S', 'value': _repeatSat, 'key': 'sat'},
      {'label': 'S', 'value': _repeatSun, 'key': 'sun'},
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: days.map((day) {
        final isActive = day['value'] as bool;
        return GestureDetector(
          onTap: _useAll7Days
              ? null
              : () {
                  setState(() {
                    switch (day['key']) {
                      case 'mon':
                        _repeatMon = !_repeatMon;
                        break;
                      case 'tue':
                        _repeatTue = !_repeatTue;
                        break;
                      case 'wed':
                        _repeatWed = !_repeatWed;
                        break;
                      case 'thu':
                        _repeatThu = !_repeatThu;
                        break;
                      case 'fri':
                        _repeatFri = !_repeatFri;
                        break;
                      case 'sat':
                        _repeatSat = !_repeatSat;
                        break;
                      case 'sun':
                        _repeatSun = !_repeatSun;
                        break;
                    }
                  });
                },
          child: Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: isActive ? AppColors.primary : AppColors.surfaceVariant,
              shape: BoxShape.circle,
              border: Border.all(
                color: isActive ? AppColors.primary : AppColors.border,
                width: 2,
              ),
            ),
            child: Center(
              child: Text(
                day['label'] as String,
                style: AppTextStyles.headlineSmall.copyWith(
                  color: isActive ? Colors.white : AppColors.textSecondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      }).toList(),
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

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyles.headlineMedium,
    );
  }
}