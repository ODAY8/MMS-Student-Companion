import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  // ── Init ──────────────────────────────────────────────────────────────

  static Future<void> init() async {
    if (_initialized) return;
    tz.initializeTimeZones();

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: ios),
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    _initialized = true;
  }

  static void _onNotificationTap(NotificationResponse response) {
    // Handle notification tap — extend this to navigate to a specific page
    debugPrint('Notification tapped: ${response.payload}');
  }

  // ── ID helpers ────────────────────────────────────────────────────────
  // Converts a String UUID into a stable unique int for the notification plugin.
  // Uses different base offsets per type so IDs never collide across categories.

  static int _toId(String uuid, {int offset = 0}) =>
      (uuid.hashCode.abs() + offset) & 0x7FFFFFFF;

  // Assignment uses two slots: base (3-day) and base+1 (1-day)
  static int _assignmentId3Day(String id) => _toId(id, offset: 0);
  static int _assignmentId1Day(String id) => _toId(id, offset: 1);

  // Holiday uses a single slot with a high offset to avoid collisions
  static int _holidayId(String id) => _toId(id, offset: 100000);

  // Timetable uses a single slot with an even higher offset
  static int _timetableId(String id) => _toId(id, offset: 200000);

  // ── Assignment notifications ──────────────────────────────────────────

  static Future<void> scheduleAssignment({
    required String id,
    required String title,
    required DateTime deadline,
    String? subject,
  }) async {
    final body = subject != null ? '$subject – $title' : title;

    // 3 days before deadline
    await _schedule(
      id: _assignmentId3Day(id),
      title: '📚 Assignment due in 3 days',
      body: body,
      scheduledDate: deadline.subtract(const Duration(days: 3)),
      channelId: 'assignments',
      channelName: 'Assignment Deadlines',
      payload: 'assignment:$id',
    );

    // 1 day before deadline
    await _schedule(
      id: _assignmentId1Day(id),
      title: '⚠️ Assignment due tomorrow!',
      body: body,
      scheduledDate: deadline.subtract(const Duration(days: 1)),
      channelId: 'assignments',
      channelName: 'Assignment Deadlines',
      payload: 'assignment:$id',
    );
  }

  static Future<void> cancelAssignment(String id) async {
    await _plugin.cancel(_assignmentId3Day(id));
    await _plugin.cancel(_assignmentId1Day(id));
  }

  // ── Holiday notifications ────────────────────────────────────────────

  static Future<void> scheduleHoliday({
    required String id,
    required String name,
    required DateTime date,
  }) async {
    // Notify at 8 AM the day before the holiday
    final notifyAt = DateTime(
      date.year,
      date.month,
      date.day,
      8,
      0,
    ).subtract(const Duration(days: 1));

    await _schedule(
      id: _holidayId(id),
      title: '🎉 Holiday tomorrow!',
      body: name,
      scheduledDate: notifyAt,
      channelId: 'holidays',
      channelName: 'Holidays',
      payload: 'holiday:$id',
    );
  }

  static Future<void> cancelHoliday(String id) async {
    await _plugin.cancel(_holidayId(id));
  }

  // ── Timetable notifications ───────────────────────────────────────────

  /// Pass the next occurrence [classTime] of the class.
  /// Set [repeatWeekly] to true so it fires every week automatically.
  static Future<void> scheduleTimetableReminder({
    required String id,
    required String subject,
    required DateTime classTime,
    int minutesBefore = 30,
  }) async {
    final notifyAt = classTime.subtract(Duration(minutes: minutesBefore));

    await _schedule(
      id: _timetableId(id),
      title: '🔔 Class in $minutesBefore minutes',
      body: subject,
      scheduledDate: notifyAt,
      channelId: 'timetable',
      channelName: 'Timetable Reminders',
      repeatWeekly: true,
      payload: 'timetable:$id',
    );
  }

  static Future<void> cancelTimetableReminder(String id) async {
    await _plugin.cancel(_timetableId(id));
  }

  static Future<void> testNotification() async {
    await _plugin.show(
      999,
      'Test Notification',
      'Flutter notifications are working!',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'test_channel',
          'Test Channel',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
    );
  }

  // ── Cancel all ────────────────────────────────────────────────────────

  static Future<void> cancelAll() => _plugin.cancelAll();

  // ── Core scheduler ────────────────────────────────────────────────────

  static Future<void> _schedule({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    required String channelId,
    required String channelName,
    bool repeatWeekly = false,
    String? payload,
  }) async {
    // Skip if the scheduled time is already in the past
    if (scheduledDate.isBefore(DateTime.now())) {
      debugPrint(
        'Skipping notification "$title" — scheduled date is in the past ($scheduledDate)',
      );
      return;
    }

    try {
      final tzDate = tz.TZDateTime.from(scheduledDate, tz.local);

      await _plugin.zonedSchedule(
        id,
        title,
        body,
        tzDate,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channelId,
            channelName,
            importance: Importance.high,
            priority: Priority.high,
            styleInformation: BigTextStyleInformation(body),
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: repeatWeekly
            ? DateTimeComponents.dayOfWeekAndTime
            : null,
        payload: payload,
      );

      debugPrint('Scheduled: "$title" at $scheduledDate (id: $id)');
    } catch (e) {
      debugPrint('Failed to schedule notification "$title": $e');
    }
  }
}
