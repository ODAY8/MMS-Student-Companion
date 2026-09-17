import 'package:flutter/material.dart';
import '../models/timetable_entry.dart';
import '../services/supabase_service.dart';
import '../services/notification_service.dart';

class TimetableProvider extends ChangeNotifier {
  final SupabaseService _service = SupabaseService();

  List<TimetableEntry> _entries = [];
  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  List<TimetableEntry> get all => _entries;

  // Returns classes for a specific weekday (1 = Monday ... 7 = Sunday)
  List<TimetableEntry> forDay(int dayOfWeek) {
    final list = _entries.where((e) => e.dayOfWeek == dayOfWeek).toList();
    list.sort((a, b) => a.startTime.compareTo(b.startTime));
    return list;
  }

  // Today's classes, based on device date
  List<TimetableEntry> get today => forDay(DateTime.now().weekday);

  Future<void> loadTimetable() async {
    _isLoading = true;
    notifyListeners();

    try {
      _entries = await _service.getTimetable();
      debugPrint('TIMETABLE LOADED: ${_entries.length} entries');
      debugPrint(
        'TODAY (weekday ${DateTime.now().weekday}): ${today.length} classes',
      );
      _error = null;

      // Schedule notifications for all timetable entries
      await _rescheduleTimetableNotifications();
    } catch (e) {
      debugPrint('TIMETABLE ERROR: $e');
      _error = 'Failed to load timetable';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── Notification helpers ──────────────────────────────────────────────

  Future<void> _rescheduleTimetableNotifications() async {
    for (final entry in _entries) {
      // Cancel first to avoid duplicates on reload
      await NotificationService.cancelTimetableReminder(entry.id);

      final classTime = _nextOccurrence(entry.dayOfWeek, entry.startTime);
      if (classTime == null) continue;

      await NotificationService.scheduleTimetableReminder(
        id: entry.id,
        subject: _buildNotificationBody(entry),
        classTime: classTime,
      );
    }
  }

  /// Parses "HH:mm" string and finds the next DateTime for the given weekday.
  DateTime? _nextOccurrence(int weekday, String startTime) {
    try {
      final parts = startTime.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);

      var date = DateTime.now();

      // Advance day-by-day until we land on the right weekday
      // and the time is still in the future
      for (int i = 0; i < 8; i++) {
        final candidate = DateTime(
          date.year,
          date.month,
          date.day,
          hour,
          minute,
        );
        if (date.weekday == weekday && candidate.isAfter(DateTime.now())) {
          return candidate;
        }
        date = date.add(const Duration(days: 1));
      }
      return null; // shouldn't happen
    } catch (e) {
      debugPrint('Failed to parse startTime "$startTime": $e');
      return null;
    }
  }

  /// Builds a descriptive notification body, e.g. "Math • Room 101"
  String _buildNotificationBody(TimetableEntry entry) {
    final parts = [entry.subjectName];
    if (entry.room != null && entry.room!.isNotEmpty) {
      parts.add(entry.room!);
    }
    if (entry.facultyName != null && entry.facultyName!.isNotEmpty) {
      parts.add(entry.facultyName!);
    }
    return parts.join(' • ');
  }
}
