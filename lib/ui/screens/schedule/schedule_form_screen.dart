import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:provider/provider.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:routify_app/data/repositories/schedule_repository.dart';
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
  DateTime? _startDate;
  DateTime? _endDate;  
  bool _isBootcampMode = false;
  Map<int, TimeSlot> _timeSlots = {};
  late TextEditingController _startDateController;
  late TextEditingController _endDateController;  

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
      
      final startDateTime = DateHelper.parseTime(schedule.startTime);
      final endDateTime = DateHelper.parseTime(schedule.endTime);
      
      if (startDateTime != null) {
        _startTime = TimeOfDay.fromDateTime(startDateTime);
        _startTimeController = TextEditingController(text: schedule.startTime);
      } else {
        _startTimeController = TextEditingController();
      }
      
      if (endDateTime != null) {
        _endTime = TimeOfDay.fromDateTime(endDateTime);
        _endTimeController = TextEditingController(text: schedule.endTime);
      } else {
        _endTimeController = TextEditingController();
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

      _startDate = schedule.startDate;
      _endDate = schedule.endDate;
      _isBootcampMode = schedule.hasCustomTimeSlots();
      if (schedule.timeSlots != null) {
        _timeSlots = Map.from(schedule.timeSlots!);
      }
      
      _startDateController = TextEditingController(
        text: _startDate != null ? DateHelper.formatDate(_startDate!) : '',
      );
      _endDateController = TextEditingController(
        text: _endDate != null ? DateHelper.formatDate(_endDate!) : '',
      );
    } else {
      _titleController = TextEditingController();
      _descriptionController = TextEditingController();
      _startTimeController = TextEditingController();
      _endTimeController = TextEditingController();
      _startDateController = TextEditingController();
      _endDateController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();  
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
          
          final now = DateTime.now();
          final startDateTime = DateTime(
            now.year,
            now.month,
            now.day,
            time.hour,
            time.minute,
          );
          
          var endDateTime = startDateTime.add(const Duration(minutes: 30));
          
          final maxTime = DateTime(now.year, now.month, now.day, 23, 59);
          if (endDateTime.isAfter(maxTime)) {
            endDateTime = maxTime;
          }
          
          _endTime = TimeOfDay.fromDateTime(endDateTime);
          _endTimeController.text = _endTime!.format(context);
        } else {
          _endTime = time;
          _endTimeController.text = time.format(context);
        }
      });
    }
  }

  Future<void> _pickDate(bool isStartDate) async {
    final date = await showDatePicker(
      context: context,
      initialDate: isStartDate
          ? (_startDate ?? DateTime.now())
          : (_endDate ?? DateTime.now()),
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
        if (isStartDate) {
          _startDate = date;
          _startDateController.text = DateHelper.formatDate(date);
        } else {
          _endDate = date;
          _endDateController.text = DateHelper.formatDate(date);
        }
      });
    }
  }

  void _saveSchedule() async {
    if (!_formKey.currentState!.validate()) return;

    if (_startTime == null || _endTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select start and end time')),
      );
      return;
    }
    
    if (_startDate != null && _endDate != null) {
      if (_endDate!.isBefore(_startDate!)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('End date must be after start date')),
        );
        return;
      }
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
      startDate: _startDate,
      endDate: _endDate,
      timeSlots: _isBootcampMode ? _timeSlots : null,
    );

    final provider = context.read<ScheduleProvider>();
    
    try {
      if (_isEditing) {
        await provider.updateSchedule(schedule);
      } else {
        final newId = await provider.addSchedule(schedule);
        
        if (_isBootcampMode && _timeSlots.isNotEmpty) {
          await ScheduleRepository().saveTimeSlots(newId, _timeSlots);
        }
      }

      if (mounted) {
        context.router.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditing ? 'Schedule updated' : 'Schedule created'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Widget _buildDateField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required VoidCallback onTap,
    required VoidCallback onClear,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.labelLarge),
        SizedBox(height: AppSizes.xs),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'Select date',
            prefixIcon: Icon(icon, size: AppSizes.iconSm),
            suffixIcon: controller.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Iconsax.close_circle),
                    onPressed: onClear,
                  )
                : null,
          ),
          readOnly: true,
          onTap: onTap,
        ),
      ],
    );
  }

  Widget _buildBootcampTimeEditor() {
    final dayNames = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    
    return Container(
      padding: EdgeInsets.all(AppSizes.paddingMd),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Set Time for Each Day', style: AppTextStyles.headlineSmall),
          SizedBox(height: AppSizes.sm),
          ...List.generate(7, (index) {
            final dayOfWeek = (index + 1) % 7; // Convert to 0=Sun format
            final hasSlot = _timeSlots.containsKey(dayOfWeek);
            
            return Padding(
              padding: EdgeInsets.only(bottom: AppSizes.sm),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(dayNames[index], style: AppTextStyles.bodyMedium),
                  ),
                  Expanded(
                    flex: 3,
                    child: hasSlot
                        ? Text(
                            '${_timeSlots[dayOfWeek]!.startTime} - ${_timeSlots[dayOfWeek]!.endTime}',
                            style: AppTextStyles.bodySmall,
                          )
                        : const Text('Not set', style: TextStyle(color: Colors.grey)),
                  ),
                  IconButton(
                    icon: Icon(hasSlot ? Iconsax.edit : Iconsax.add_circle),
                    onPressed: () => _editDayTimeSlot(dayOfWeek, dayNames[index]),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Future<void> _editDayTimeSlot(int dayOfWeek, String dayName) async {
    TimeOfDay? startTime;
    TimeOfDay? endTime;
    
    if (_timeSlots.containsKey(dayOfWeek)) {
      final slot = _timeSlots[dayOfWeek]!;
      final startDT = DateHelper.parseTime(slot.startTime);
      final endDT = DateHelper.parseTime(slot.endTime);
      if (startDT != null) startTime = TimeOfDay.fromDateTime(startDT);
      if (endDT != null) endTime = TimeOfDay.fromDateTime(endDT);
    }
    
    // Show dialog untuk pick time
    final result = await showDialog<Map<String, TimeOfDay>>(
      context: context,
      builder: (context) => _TimeSlotDialog(
        dayName: dayName,
        initialStart: startTime,
        initialEnd: endTime,
      ),
    );
    
    if (result != null) {
      setState(() {
        _timeSlots[dayOfWeek] = TimeSlot(
          startTime: result['start']!.format(context),
          endTime: result['end']!.format(context),
        );
      });
    }
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
            _buildSectionTitle('Active Period (Optional)'),
            SizedBox(height: AppSizes.sm),
            Row(
              children: [
                Expanded(
                  child: _buildDateField(
                    controller: _startDateController,
                    label: 'Start Date',
                    icon: Iconsax.calendar_1,
                    onTap: () => _pickDate(true),
                    onClear: () {
                      setState(() {
                        _startDate = null;
                        _startDateController.clear();
                      });
                    },
                  ),
                ),
                SizedBox(width: AppSizes.md),
                Expanded(
                  child: _buildDateField(
                    controller: _endDateController,
                    label: 'End Date',
                    icon: Iconsax.calendar_2,
                    onTap: () => _pickDate(false),
                    onClear: () {
                      setState(() {
                        _endDate = null;
                        _endDateController.clear();
                      });
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSizes.md),
            _buildSwitchTile(
              icon: Iconsax.clock_1,
              title: 'Bootcamp Mode',
              subtitle: 'Different time for each day',
              value: _isBootcampMode,
              onChanged: (value) {
                setState(() => _isBootcampMode = value);
              },
            ),
            if (_isBootcampMode) ...[
              SizedBox(height: AppSizes.md),
              _buildBootcampTimeEditor(),
            ],
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

class _TimeSlotDialog extends StatefulWidget {
  final String dayName;
  final TimeOfDay? initialStart;
  final TimeOfDay? initialEnd;

  const _TimeSlotDialog({
    required this.dayName,
    this.initialStart,
    this.initialEnd,
  });

  @override
  State<_TimeSlotDialog> createState() => _TimeSlotDialogState();
}

class _TimeSlotDialogState extends State<_TimeSlotDialog> {
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;

  @override
  void initState() {
    super.initState();
    _startTime = widget.initialStart ?? TimeOfDay.now();
    _endTime = widget.initialEnd ?? TimeOfDay.now();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Set Time for ${widget.dayName}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: const Text('Start Time'),
            subtitle: Text(_startTime.format(context)),
            trailing: const Icon(Iconsax.clock),
            onTap: () async {
              final time = await showTimePicker(context: context, initialTime: _startTime);
              if (time != null) setState(() => _startTime = time);
            },
          ),
          ListTile(
            title: const Text('End Time'),
            subtitle: Text(_endTime.format(context)),
            trailing: const Icon(Iconsax.clock),
            onTap: () async {
              final time = await showTimePicker(context: context, initialTime: _endTime);
              if (time != null) setState(() => _endTime = time);
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context, {
              'start': _startTime,
              'end': _endTime,
            });
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}