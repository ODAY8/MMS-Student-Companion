class Subject {
  final String id;
  final String name;
  final double credits;
  final double gradePoint; // 0 - 10
  final int semester;

  Subject({
    required this.id,
    required this.name,
    required this.credits,
    required this.gradePoint,
    required this.semester,
  });

  factory Subject.fromMap(Map<String, dynamic> map) {
    return Subject(
      id: map['id'],
      name: map['name'],
      credits: (map['credits'] as num).toDouble(),
      gradePoint: (map['grade_point'] as num).toDouble(),
      semester: map['semester'],
    );
  }

  Map<String, dynamic> toInsertMap(String userId) {
    return {
      'user_id': userId,
      'name': name,
      'credits': credits,
      'grade_point': gradePoint,
      'semester': semester,
    };
  }
}
