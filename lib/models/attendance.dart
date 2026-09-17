class AttendanceSubject {
  final String id;
  final String name;

  AttendanceSubject({required this.id, required this.name});

  factory AttendanceSubject.fromMap(Map<String, dynamic> map) {
    return AttendanceSubject(id: map['id'], name: map['name']);
  }
}

class AttendanceRecord {
  final String id;
  final String subjectId;
  final DateTime date;
  final String status; // 'present' or 'absent'

  AttendanceRecord({
    required this.id,
    required this.subjectId,
    required this.date,
    required this.status,
  });

  factory AttendanceRecord.fromMap(Map<String, dynamic> map) {
    return AttendanceRecord(
      id: map['id'],
      subjectId: map['subject_id'],
      date: DateTime.parse(map['date']),
      status: map['status'],
    );
  }
}

// Computed stats for one subject
class SubjectAttendanceStats {
  final AttendanceSubject subject;
  final int totalClasses;
  final int present;

  SubjectAttendanceStats({
    required this.subject,
    required this.totalClasses,
    required this.present,
  });

  double get percentage =>
      totalClasses == 0 ? 0 : (present / totalClasses) * 100;
}
