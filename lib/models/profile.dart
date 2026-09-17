class Profile {
  final String id;
  final String fullName;
  final String? studentId;
  final String? department;
  final int? yearOfStudy;

  Profile({
    required this.id,
    required this.fullName,
    this.studentId,
    this.department,
    this.yearOfStudy,
  });

  factory Profile.fromMap(Map<String, dynamic> map) {
    return Profile(
      id: map['id'],
      fullName: map['full_name'] ?? '',
      studentId: map['student_id'],
      department: map['department'],
      yearOfStudy: map['year_of_study'],
    );
  }

  Map<String, dynamic> toUpdateMap() {
    return {
      'full_name': fullName,
      'student_id': studentId,
      'department': department,
      'year_of_study': yearOfStudy,
    };
  }
}
