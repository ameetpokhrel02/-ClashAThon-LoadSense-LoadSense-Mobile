class Reminder {
  final String id;
  final String title;
  final String message;
  final DateTime? reminderTime;
  final bool isRead;

  Reminder({
    required this.id,
    required this.title,
    required this.message,
    this.reminderTime,
    required this.isRead,
  });

  factory Reminder.fromJson(Map<String, dynamic> json) {
    final type = json['type'] ?? 'task';
    final course = json['course'] ?? 'General';
    
    return Reminder(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      title: json['title'] ?? 'Upcoming Deadline',
      message: 'You have a ${type} for ${course} due soon.',
      reminderTime: json['dueDate'] != null
          ? DateTime.tryParse(json['dueDate'].toString())
          : (json['reminderTime'] != null ? DateTime.tryParse(json['reminderTime'].toString()) : null),
      isRead: json['is_read'] ?? json['isRead'] ?? false,
    );
  }
}
