class TimetableEntry {
  final String id;
  final int dayOfWeek;
  final String subjectName;
  final String startTime;
  final String endTime;
  final String? room;
  final String? facultyName;

  TimetableEntry({
    required this.id,
    required this.dayOfWeek,
    required this.subjectName,
    required this.startTime,
    required this.endTime,
    this.room,
    this.facultyName,
  });

  factory TimetableEntry.fromMap(Map<String, dynamic> map) {
    return TimetableEntry(
      id: map['id'],
      dayOfWeek: map['day_of_week'],
      subjectName: map['subject_name'],
      startTime: map['start_time'],
      endTime: map['end_time'],
      room: map['room'],
      facultyName: map['faculty']?['name'],
    );
  }

  // For JSONPlaceholder /todos response
  factory TimetableEntry.fromJsonPlaceholder(Map<String, dynamic> json) {
    final id = json['id'] as int;
    final userId = json['userId'] as int; // 1-10

    // Map userId (1-7) to day of week, wrap others into 1-7
    final dayOfWeek = ((id - 1) % 7) + 1;

    // Generate a fake time slot based on id (cycles through periods)
    final periodIndex = (id - 1) % 6; // 6 periods per day
    final startHour = 8 + periodIndex; // 8 AM to 1 PM
    final startTime = '${startHour.toString().padLeft(2, '0')}:00';
    final endTime = '${(startHour + 1).toString().padLeft(2, '0')}:00';

    return TimetableEntry(
      id: id.toString(),
      dayOfWeek: dayOfWeek,
      subjectName: json['title'] ?? 'Untitled Subject',
      startTime: startTime,
      endTime: endTime,
      room: 'Room ${100 + (id % 10)}',
      facultyName: 'Faculty ${userId}',
    );
  }
}
