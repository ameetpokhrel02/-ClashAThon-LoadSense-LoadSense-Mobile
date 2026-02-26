class Deadline {
  final String id;
  final String title;
  final DateTime dueDate;
  final bool isCompleted;
  final String priority;
  final String type;
  final int estimatedHours;
  final String? moduleId;
  final String? moduleName;
  final String? notes;

  Deadline({
    required this.id,
    required this.title,
    required this.dueDate,
    this.isCompleted = false,
    required this.priority,
    required this.type,
    required this.estimatedHours,
    this.moduleId,
    this.moduleName,
    this.notes,
  });

  bool get isOverdue => dueDate.isBefore(DateTime.now()) && !isCompleted;
  bool get isDueToday {
    final now = DateTime.now();
    return dueDate.year == now.year && dueDate.month == now.month && dueDate.day == now.day;
  }

  factory Deadline.fromJson(Map<String, dynamic> json) {
    return Deadline(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      title: json['title'] ?? '',
      dueDate: DateTime.tryParse(json['dueDate'] ?? json['due_date'] ?? '') ?? DateTime.now(),
      isCompleted: json['is_completed'] ?? json['status'] == 'completed' ?? false,
      priority: json['priority'] ?? json['risk'] ?? 'Medium',
      type: json['type'] ?? 'assignment',
      estimatedHours: _toInt(json['estimatedHours'] ?? json['estimated_hours']),
      moduleId: json['moduleId']?.toString() ?? json['module_id']?.toString() ?? json['user_id']?.toString(), 
      moduleName: json['moduleName'] ?? json['course'] ?? json['module']?['name'],
      notes: json['notes'] ?? json['description'],
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'dueDate': dueDate.toIso8601String(),
        'is_completed': isCompleted,
        'type': type.toLowerCase(),
        'estimatedHours': estimatedHours,
        'course': moduleName ?? 'General',
        'notes': notes,
      };

  static int _toInt(dynamic value) {
    if (value == null) return 1;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 1;
    return 1;
  }
}
