import 'package:routify_app/data/models/exercise_model.dart';

class WorkoutModel {
  final int? id;
  final int dayOfWeek; // 0 = Sunday, 1 = Monday, ..., 6 = Saturday
  final String name;
  final int? estimatedDuration; // in minutes
  final String? notes;
  final bool enableNotification;
  final List<ExerciseModel> exercises;

  WorkoutModel({
    this.id,
    required this.dayOfWeek,
    required this.name,
    this.estimatedDuration,
    this.notes,
    this.enableNotification = false,
    this.exercises = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'day_of_week': dayOfWeek,
      'name': name,
      'estimated_duration': estimatedDuration,
      'notes': notes,
      'enable_notification': enableNotification ? 1 : 0,
    };
  }

  factory WorkoutModel.fromMap(Map<String, dynamic> map) {
    return WorkoutModel(
      id: map['id'] as int?,
      dayOfWeek: map['day_of_week'] as int,
      name: map['name'] as String,
      estimatedDuration: map['estimated_duration'] as int?,
      notes: map['notes'] as String?,
      enableNotification: (map['enable_notification'] as int?) == 1,
      exercises: [],
    );
  }

  WorkoutModel copyWith({
    int? id,
    int? dayOfWeek,
    String? name,
    int? estimatedDuration,
    String? notes,
    bool? enableNotification,
    List<ExerciseModel>? exercises,
  }) {
    return WorkoutModel(
      id: id ?? this.id,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      name: name ?? this.name,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      notes: notes ?? this.notes,
      enableNotification: enableNotification ?? this.enableNotification,
      exercises: exercises ?? this.exercises,
    );
  }

  String get dayName {
    const days = [
      'Sunday',
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday'
    ];
    return days[dayOfWeek];
  }
}