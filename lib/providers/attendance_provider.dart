import 'package:flutter/material.dart';
import '../models/attendance.dart';
import '../services/supabase_service.dart';

class AttendanceProvider extends ChangeNotifier {
  final SupabaseService _service = SupabaseService();

  List<AttendanceSubject> _subjects = [];
  List<AttendanceRecord> _records = [];
  bool _isLoading = false;

  bool get isLoading => _isLoading;
  List<AttendanceSubject> get subjects => _subjects;

  Future<void> loadAll(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _subjects = await _service.getAttendanceSubjects(userId);
      _records = await _service.getAttendanceRecords(userId);
    } catch (e) {
      print('ATTENDANCE LOAD ERROR: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addSubject(String userId, String name) async {
    await _service.addAttendanceSubject(userId, name);
    await loadAll(userId);
  }

  Future<void> deleteSubject(String userId, String subjectId) async {
    await _service.deleteAttendanceSubject(subjectId);
    await loadAll(userId);
  }

  Future<void> markAttendance({
    required String userId,
    required String subjectId,
    required DateTime date,
    required String status,
  }) async {
    await _service.markAttendance(
      userId: userId,
      subjectId: subjectId,
      date: date,
      status: status,
    );
    await loadAll(userId);
  }

  // Get the status for a subject on a specific date, if recorded
  String? statusFor(String subjectId, DateTime date) {
    final dateStr =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    final record = _records
        .where(
          (r) =>
              r.subjectId == subjectId &&
              '${r.date.year}-${r.date.month.toString().padLeft(2, '0')}-${r.date.day.toString().padLeft(2, '0')}' ==
                  dateStr,
        )
        .toList();
    return record.isEmpty ? null : record.first.status;
  }

  // Stats per subject
  List<SubjectAttendanceStats> get statsPerSubject {
    return _subjects.map((subject) {
      final subjectRecords = _records
          .where((r) => r.subjectId == subject.id)
          .toList();
      final total = subjectRecords.length;
      final present = subjectRecords.where((r) => r.status == 'present').length;
      return SubjectAttendanceStats(
        subject: subject,
        totalClasses: total,
        present: present,
      );
    }).toList();
  }

  // Overall percentage across all subjects
  double get overallPercentage {
    final stats = statsPerSubject;
    final totalClasses = stats.fold<int>(0, (sum, s) => sum + s.totalClasses);
    final totalPresent = stats.fold<int>(0, (sum, s) => sum + s.present);
    if (totalClasses == 0) return 0;
    return (totalPresent / totalClasses) * 100;
  }

  SubjectAttendanceStats? get highest {
    final stats = statsPerSubject.where((s) => s.totalClasses > 0).toList();
    if (stats.isEmpty) return null;
    stats.sort((a, b) => b.percentage.compareTo(a.percentage));
    return stats.first;
  }

  SubjectAttendanceStats? get lowest {
    final stats = statsPerSubject.where((s) => s.totalClasses > 0).toList();
    if (stats.isEmpty) return null;
    stats.sort((a, b) => a.percentage.compareTo(b.percentage));
    return stats.first;
  }
}
