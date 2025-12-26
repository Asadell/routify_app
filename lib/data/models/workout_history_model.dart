class WorkoutHistoryModel {
  final int? id;
  final String workoutName;
  final DateTime date;
  final int? actualDuration; // in minutes
  final String? notes;

  WorkoutHistoryModel({
    this.id,
    required this.workoutName,
    required this.date,
    this.actualDuration,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'workout_name': workoutName,
      'date': date.toIso8601String(),
      'actual_duration': actualDuration,
      'notes': notes,
    };
  }

  factory WorkoutHistoryModel.fromMap(Map<String, dynamic> map) {
    return WorkoutHistoryModel(
      id: map['id'] as int?,
      workoutName: map['workout_name'] as String,
      date: DateTime.parse(map['date'] as String),
      actualDuration: map['actual_duration'] as int?,
      notes: map['notes'] as String?,
    );
  }

  WorkoutHistoryModel copyWith({
    int? id,
    String? workoutName,
    DateTime? date,
    int? actualDuration,
    String? notes,
  }) {
    return WorkoutHistoryModel(
      id: id ?? this.id,
      workoutName: workoutName ?? this.workoutName,
      date: date ?? this.date,
      actualDuration: actualDuration ?? this.actualDuration,
      notes: notes ?? this.notes,
    );
  }
}