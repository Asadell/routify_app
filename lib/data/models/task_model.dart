class TaskModel {
  final int? id;
  final String title;
  final String? description;
  final DateTime? dueDate;
  final String priority; // 'low', 'medium', 'high'
  final String status; // 'pending', 'completed'
  final bool enableNotification;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  TaskModel({
    this.id,
    required this.title,
    this.description,
    this.dueDate,
    this.priority = 'medium',
    this.status = 'pending',
    this.enableNotification = false,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'due_date': dueDate?.toIso8601String(),
      'priority': priority,
      'status': status,
      'enable_notification': enableNotification ? 1 : 0,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  factory TaskModel.fromMap(Map<String, dynamic> map) {
    return TaskModel(
      id: map['id'] as int?,
      title: map['title'] as String,
      description: map['description'] as String?,
      dueDate: map['due_date'] != null
          ? DateTime.parse(map['due_date'] as String)
          : null,
      priority: map['priority'] as String? ?? 'medium',
      status: map['status'] as String? ?? 'pending',
      enableNotification: (map['enable_notification'] as int) == 1,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : null,
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'] as String)
          : null,
    );
  }

  TaskModel copyWith({
    int? id,
    String? title,
    String? description,
    DateTime? dueDate,
    String? priority,
    String? status,
    bool? enableNotification,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      enableNotification: enableNotification ?? this.enableNotification,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isCompleted => status == 'completed';
  bool get isPending => status == 'pending';
  bool get isOverdue =>
      dueDate != null && dueDate!.isBefore(DateTime.now()) && isPending;
}