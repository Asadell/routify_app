import 'package:routify_app/data/models/exercise_model.dart';

class WorkoutModel {
  final int? id;
  final List<int> daysOfWeek;
  final String name;
  final int? estimatedDuration;
  final String? notes;
  final bool enableNotification;
  final List<ExerciseModel> exercises;

  WorkoutModel({
    this.id,
    required this.daysOfWeek,
    required this.name,
    this.estimatedDuration,
    this.notes,
    this.enableNotification = false,
    this.exercises = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'estimated_duration': estimatedDuration,
      'notes': notes,
      'enable_notification': enableNotification ? 1 : 0,
    };
  }

  factory WorkoutModel.fromMap(Map<String, dynamic> map, {List<int>? daysOfWeek}) {
    return WorkoutModel(
      id: map['id'] as int?,
      daysOfWeek: daysOfWeek ?? [], 
      name: map['name'] as String,
      estimatedDuration: map['estimated_duration'] as int?,
      notes: map['notes'] as String?,
      enableNotification: (map['enable_notification'] as int?) == 1,
      exercises: [],
    );
  }

  WorkoutModel copyWith({
    int? id,
    List<int>? daysOfWeek,
    String? name,
    int? estimatedDuration,
    String? notes,
    bool? enableNotification,
    List<ExerciseModel>? exercises,
  }) {
    return WorkoutModel(
      id: id ?? this.id,
      daysOfWeek: daysOfWeek ?? this.daysOfWeek,
      name: name ?? this.name,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      notes: notes ?? this.notes,
      enableNotification: enableNotification ?? this.enableNotification,
      exercises: exercises ?? this.exercises,
    );
  }

  String get daysNames {
    const days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    if (daysOfWeek.isEmpty) return 'No days';
    if (daysOfWeek.length == 7) return 'Every day';
    return daysOfWeek.map((d) => days[d]).join(', ');
  }
}