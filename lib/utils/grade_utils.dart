class GradeUtils {
  // 10-point scale CGPA calculation:
  // CGPA = sum(credits * gradePoint) / sum(credits)
  static double calculateCGPA(List<dynamic> subjects) {
    if (subjects.isEmpty) return 0.0;

    double totalCredits = 0;
    double totalWeightedPoints = 0;

    for (final s in subjects) {
      totalCredits += s.credits;
      totalWeightedPoints += s.credits * s.gradePoint;
    }

    if (totalCredits == 0) return 0.0;
    return totalWeightedPoints / totalCredits;
  }

  static String letterGrade(double gradePoint) {
    if (gradePoint >= 9) return 'O';
    if (gradePoint >= 8) return 'A+';
    if (gradePoint >= 7) return 'A';
    if (gradePoint >= 6) return 'B+';
    if (gradePoint >= 5) return 'B';
    if (gradePoint >= 4) return 'C';
    return 'F';
  }

  static String cgpaRemark(double cgpa) {
    if (cgpa >= 9) return 'Outstanding';
    if (cgpa >= 8) return 'Excellent';
    if (cgpa >= 7) return 'Very Good';
    if (cgpa >= 6) return 'Good';
    if (cgpa >= 5) return 'Average';
    return 'Needs Improvement';
  }
}
