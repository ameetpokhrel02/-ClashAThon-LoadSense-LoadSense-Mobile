class Module {
  final String id;
  final String title;
  final String moduleCode;
  final double creditHours;
  final double weeklyHours;
  final String difficulty;
  final String? description;
  final String? userId;
  final int semester;
  final int year;
  final String department;

  Module({
    required this.id,
    required this.title,
    required this.moduleCode,
    required this.creditHours,
    required this.weeklyHours,
    required this.difficulty,
    this.description,
    this.userId,
    this.semester = 1,
    this.year = 1,
    this.department = 'General',
  });

  factory Module.fromJson(Map<String, dynamic> json) {
    return Module(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      title: json['title'] ?? json['name'] ?? '',
      moduleCode: json['moduleCode'] ?? json['module_code'] ?? '',
      creditHours: _toDouble(json['creditHours'] ?? json['credit_hours'] ?? json['credits']),
      weeklyHours: _toDouble(json['weeklyHours'] ?? json['weekly_hours']),
      difficulty: json['difficulty'] ?? 'Medium',
      description: json['description'],
      userId: json['userId']?.toString() ?? json['user_id']?.toString(),
      semester: _toInt(json['semester']),
      year: _toInt(json['year']),
      department: json['department'] ?? 'General',
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'moduleCode': moduleCode,
        'creditHours': creditHours,
        'credits': creditHours.round(),
        'weeklyHours': weeklyHours,
        'difficulty': difficulty,
        'description': description,
        'semester': semester,
        'year': year,
        'department': department,
      };

  static double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  static int _toInt(dynamic value) {
    if (value == null) return 1;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 1;
    return 1;
  }
}
