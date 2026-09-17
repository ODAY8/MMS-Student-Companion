class Assignment {
  final String id;
  final String title;
  final String? subject;
  final DateTime dueDate;
  final String priority; // 'low', 'medium', 'high'
  final bool isCompleted;

  Assignment({
    required this.id,
    required this.title,
    this.subject,
    required this.dueDate,
    required this.priority,
    required this.isCompleted,
  });

  factory Assignment.fromMap(Map<String, dynamic> map) {
    return Assignment(
      id: map['id'],
      title: map['title'],
      subject: map['subject'],
      dueDate: DateTime.parse(map['due_date']),
      priority: map['priority'] ?? 'medium',
      isCompleted: map['is_completed'] ?? false,
    );
  }

  bool get isOverdue =>
      !isCompleted &&
      dueDate.isBefore(DateTime.now().subtract(const Duration(days: 1)));

  bool get isDueToday {
    final now = DateTime.now();
    return dueDate.year == now.year &&
        dueDate.month == now.month &&
        dueDate.day == now.day;
  }

  int get daysUntilDue {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return dueDate.difference(today).inDays;
  }
}
