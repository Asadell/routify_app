class ScheduleModel {
  final int? id;
  final String title;
  final String? description;
  final String startTime;
  final String endTime;
  final bool repeatMon;
  final bool repeatTue;
  final bool repeatWed;
  final bool repeatThu;
  final bool repeatFri;
  final bool repeatSat;
  final bool repeatSun;
  final bool useAll7Days;
  final bool enableNotification;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ScheduleModel({
    this.id,
    required this.title,
    this.description,
    required this.startTime,
    required this.endTime,
    this.repeatMon = false,
    this.repeatTue = false,
    this.repeatWed = false,
    this.repeatThu = false,
    this.repeatFri = false,
    this.repeatSat = false,
    this.repeatSun = false,
    this.useAll7Days = false,
    this.enableNotification = false,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'start_time': startTime,
      'end_time': endTime,
      'repeat_mon': repeatMon ? 1 : 0,
      'repeat_tue': repeatTue ? 1 : 0,
      'repeat_wed': repeatWed ? 1 : 0,
      'repeat_thu': repeatThu ? 1 : 0,
      'repeat_fri': repeatFri ? 1 : 0,
      'repeat_sat': repeatSat ? 1 : 0,
      'repeat_sun': repeatSun ? 1 : 0,
      'use_all_7_days': useAll7Days ? 1 : 0,
      'enable_notification': enableNotification ? 1 : 0,
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  factory ScheduleModel.fromMap(Map<String, dynamic> map) {
    return ScheduleModel(
      id: map['id'] as int?,
      title: map['title'] as String,
      description: map['description'] as String?,
      startTime: map['start_time'] as String,
      endTime: map['end_time'] as String,
      repeatMon: (map['repeat_mon'] as int) == 1,
      repeatTue: (map['repeat_tue'] as int) == 1,
      repeatWed: (map['repeat_wed'] as int) == 1,
      repeatThu: (map['repeat_thu'] as int) == 1,
      repeatFri: (map['repeat_fri'] as int) == 1,
      repeatSat: (map['repeat_sat'] as int) == 1,
      repeatSun: (map['repeat_sun'] as int) == 1,
      useAll7Days: (map['use_all_7_days'] as int) == 1,
      enableNotification: (map['enable_notification'] as int) == 1,
      isActive: (map['is_active'] as int) == 1,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : null,
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'] as String)
          : null,
    );
  }

  ScheduleModel copyWith({
    int? id,
    String? title,
    String? description,
    String? startTime,
    String? endTime,
    bool? repeatMon,
    bool? repeatTue,
    bool? repeatWed,
    bool? repeatThu,
    bool? repeatFri,
    bool? repeatSat,
    bool? repeatSun,
    bool? useAll7Days,
    bool? enableNotification,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ScheduleModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      repeatMon: repeatMon ?? this.repeatMon,
      repeatTue: repeatTue ?? this.repeatTue,
      repeatWed: repeatWed ?? this.repeatWed,
      repeatThu: repeatThu ?? this.repeatThu,
      repeatFri: repeatFri ?? this.repeatFri,
      repeatSat: repeatSat ?? this.repeatSat,
      repeatSun: repeatSun ?? this.repeatSun,
      useAll7Days: useAll7Days ?? this.useAll7Days,
      enableNotification: enableNotification ?? this.enableNotification,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool isActiveOnDay(int dayOfWeek) {
    if (useAll7Days) return true;
    switch (dayOfWeek) {
      case 0:
        return repeatSun;
      case 1:
        return repeatMon;
      case 2:
        return repeatTue;
      case 3:
        return repeatWed;
      case 4:
        return repeatThu;
      case 5:
        return repeatFri;
      case 6:
        return repeatSat;
      default:
        return false;
    }
  }
}