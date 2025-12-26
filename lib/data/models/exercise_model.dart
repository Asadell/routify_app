class ExerciseModel {
  final int? id;
  final int workoutId;
  final String name;
  final int? sets;
  final int? reps;
  final int? durationMinutes;
  final double? weight;

  ExerciseModel({
    this.id,
    required this.workoutId,
    required this.name,
    this.sets,
    this.reps,
    this.durationMinutes,
    this.weight,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'workout_id': workoutId,
      'name': name,
      'sets': sets,
      'reps': reps,
      'duration_minutes': durationMinutes,
      'weight': weight,
    };
  }

  factory ExerciseModel.fromMap(Map<String, dynamic> map) {
    return ExerciseModel(
      id: map['id'] as int?,
      workoutId: map['workout_id'] as int,
      name: map['name'] as String,
      sets: map['sets'] as int?,
      reps: map['reps'] as int?,
      durationMinutes: map['duration_minutes'] as int?,
      weight: map['weight'] as double?,
    );
  }

  ExerciseModel copyWith({
    int? id,
    int? workoutId,
    String? name,
    int? sets,
    int? reps,
    int? durationMinutes,
    double? weight,
  }) {
    return ExerciseModel(
      id: id ?? this.id,
      workoutId: workoutId ?? this.workoutId,
      name: name ?? this.name,
      sets: sets ?? this.sets,
      reps: reps ?? this.reps,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      weight: weight ?? this.weight,
    );
  }

  bool get isStrength => sets != null && reps != null;
  bool get isCardio => durationMinutes != null;
}