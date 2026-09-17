import 'package:flutter/material.dart';
import '../models/holiday.dart';
import '../models/faculty.dart';
import '../services/supabase_service.dart';
import '../services/notification_service.dart';

class AcademicProvider extends ChangeNotifier {
  final SupabaseService _service = SupabaseService();

  List<Holiday> _holidays = [];
  List<Faculty> _faculty = [];
  bool _isLoading = false;

  bool get isLoading => _isLoading;
  List<Holiday> get holidays => _holidays;
  List<Faculty> get faculty => _faculty;

  List<Holiday> get upcomingHolidays =>
      _holidays.where((h) => h.isUpcoming).toList();

  Holiday? get nextHoliday =>
      upcomingHolidays.isNotEmpty ? upcomingHolidays.first : null;

  Future<void> loadAll() async {
    _isLoading = true;
    notifyListeners();

    try {
      _holidays = await _service.getHolidays();
      debugPrint('HOLIDAYS LOADED: ${_holidays.length}');
      _faculty = await _service.getFaculty();

      // Schedule notifications for all upcoming holidays
      await _rescheduleHolidayNotifications();
    } catch (e) {
      debugPrint('ACADEMIC LOAD ERROR: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── Notification helper ───────────────────────────────────────────────

  Future<void> _rescheduleHolidayNotifications() async {
    for (final holiday in _holidays) {
      // Cancel first to avoid duplicates on reload
      await NotificationService.cancelHoliday(holiday.id);

      // Only schedule for upcoming holidays (past ones are skipped inside the service)
      if (holiday.isUpcoming) {
        await NotificationService.scheduleHoliday(
          id: holiday.id,
          name: holiday.name,
          date: holiday.date,
        );
      }
    }
  }

  // ── Faculty helper ────────────────────────────────────────────────────

  List<Faculty> facultyForSubject(String subjectName) {
    return _faculty
        .where((f) => f.subject.toLowerCase() == subjectName.toLowerCase())
        .toList();
  }
}
