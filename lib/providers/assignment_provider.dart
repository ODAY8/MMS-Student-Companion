import 'package:flutter/material.dart';
import '../models/assignments.dart';
import '../services/supabase_service.dart';
import '../services/notification_service.dart';

class AssignmentProvider extends ChangeNotifier {
  final SupabaseService _service = SupabaseService();

  List<Assignment> _assignments = [];
  bool _isLoading = false;

  bool get isLoading => _isLoading;
  List<Assignment> get all => _assignments;

  List<Assignment> get pending =>
      _assignments.where((a) => !a.isCompleted).toList();
  List<Assignment> get completed =>
      _assignments.where((a) => a.isCompleted).toList();
  List<Assignment> get overdue =>
      _assignments.where((a) => a.isOverdue).toList();
  List<Assignment> get dueToday =>
      _assignments.where((a) => !a.isCompleted && a.isDueToday).toList();

  int get pendingCount => pending.length;

  // ── Load ──────────────────────────────────────────────────────────────

  Future<void> loadAll(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _assignments = await _service.getAssignments(userId);
      await _rescheduleAll();
    } catch (e) {
      debugPrint('ASSIGNMENT LOAD ERROR: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── Add ───────────────────────────────────────────────────────────────

  Future<void> addAssignment({
    required String userId,
    required String title,
    String? subject,
    required DateTime dueDate,
    required String priority,
  }) async {
    await _service.addAssignment(
      userId: userId,
      title: title,
      subject: subject,
      dueDate: dueDate,
      priority: priority,
    );
    // loadAll will reschedule notifications for all assignments including new one
    await loadAll(userId);
  }

  // ── Toggle complete ───────────────────────────────────────────────────

  Future<void> toggleComplete(String userId, Assignment assignment) async {
    await _service.toggleAssignmentComplete(
      assignment.id,
      !assignment.isCompleted,
    );

    if (!assignment.isCompleted) {
      // Was pending → now completed: cancel its notifications
      await NotificationService.cancelAssignment(assignment.id);
    }
    // else: was completed → now pending again: loadAll will reschedule
    await loadAll(userId);
  }

  // ── Delete ────────────────────────────────────────────────────────────

  Future<void> deleteAssignment(String userId, String id) async {
    await NotificationService.cancelAssignment(id);
    await _service.deleteAssignment(id);
    await loadAll(userId);
  }

  // ── Notifications helper ──────────────────────────────────────────────

  /// Cancels all assignment notifications then reschedules only pending ones.
  Future<void> _rescheduleAll() async {
    for (final assignment in _assignments) {
      // Always cancel first to avoid duplicates on reload
      await NotificationService.cancelAssignment(assignment.id);

      // Only schedule notifications for pending (not completed) assignments
      if (!assignment.isCompleted) {
        await NotificationService.scheduleAssignment(
          id: assignment.id,
          title: _buildNotificationTitle(assignment),
          deadline: assignment.dueDate,
        );
      }
    }
  }

  /// Builds a richer notification body, e.g. "Math – Calculus Problem Set"
  String _buildNotificationTitle(Assignment assignment) {
    if (assignment.subject != null && assignment.subject!.isNotEmpty) {
      return '${assignment.subject} – ${assignment.title}';
    }
    return assignment.title;
  }
}
