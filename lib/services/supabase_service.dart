import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/subject.dart';
import '../models/timetable_entry.dart';
import '../models/holiday.dart';
import '../models/faculty.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sms_app/models/profile.dart';
import '../models/attendance.dart';
import '../models/assignments.dart';

class SupabaseService {
  final SupabaseClient _client = Supabase.instance.client;

  // ---------- AUTH ----------
  User? get currentUser => _client.auth.currentUser;

  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  Future<AuthResponse> signIn(String email, String password) {
    return _client.auth.signInWithPassword(email: email, password: password);
  }

  // ---------- ASSIGNMENTS ----------
  Future<List<Assignment>> getAssignments(String userId) async {
    final data = await _client
        .from('assignments')
        .select()
        .eq('user_id', userId)
        .order('due_date');

    return (data as List).map((e) => Assignment.fromMap(e)).toList();
  }

  Future<void> addAssignment({
    required String userId,
    required String title,
    String? subject,
    required DateTime dueDate,
    required String priority,
  }) async {
    final dateStr =
        '${dueDate.year}-${dueDate.month.toString().padLeft(2, '0')}-${dueDate.day.toString().padLeft(2, '0')}';

    await _client.from('assignments').insert({
      'user_id': userId,
      'title': title,
      'subject': subject,
      'due_date': dateStr,
      'priority': priority,
    });
  }

  Future<void> toggleAssignmentComplete(String id, bool isCompleted) async {
    await _client
        .from('assignments')
        .update({'is_completed': isCompleted})
        .eq('id', id);
  }

  Future<void> deleteAssignment(String id) async {
    await _client.from('assignments').delete().eq('id', id);
  }

  //attendence
  Future<List<AttendanceSubject>> getAttendanceSubjects(String userId) async {
    final data = await _client
        .from('attendance_subjects')
        .select()
        .eq('user_id', userId)
        .order('created_at');

    return (data as List).map((e) => AttendanceSubject.fromMap(e)).toList();
  }

  Future<void> addAttendanceSubject(String userId, String name) async {
    await _client.from('attendance_subjects').insert({
      'user_id': userId,
      'name': name,
    });
  }

  Future<void> deleteAttendanceSubject(String id) async {
    await _client.from('attendance_subjects').delete().eq('id', id);
  }

  Future<List<AttendanceRecord>> getAttendanceRecords(String userId) async {
    final data = await _client
        .from('attendance_records')
        .select()
        .eq('user_id', userId);

    return (data as List).map((e) => AttendanceRecord.fromMap(e)).toList();
  }

  // Marks attendance for a subject on a specific date (upsert)
  Future<void> markAttendance({
    required String userId,
    required String subjectId,
    required DateTime date,
    required String status,
  }) async {
    final dateStr =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

    await _client.from('attendance_records').upsert({
      'user_id': userId,
      'subject_id': subjectId,
      'date': dateStr,
      'status': status,
    }, onConflict: 'subject_id,date');
  }

  Future<AuthResponse> register(String email, String password) {
    return _client.auth.signUp(email: email, password: password);
  }

  Future<void> signOut() => _client.auth.signOut();

  // ---------- SUBJECTS (CGPA) ----------
  Future<List<Subject>> getSubjects(String userId) async {
    final data = await _client
        .from('subjects')
        .select()
        .eq('user_id', userId)
        .order('semester');

    return (data as List).map((e) => Subject.fromMap(e)).toList();
  }

  Future<void> addSubject(Subject subject, String userId) async {
    await _client.from('subjects').insert(subject.toInsertMap(userId));
  }

  Future<void> deleteSubject(String id) async {
    await _client.from('subjects').delete().eq('id', id);
  }

  // ---------- PROFILE ----------
  Future<Profile> getProfile(String userId) async {
    final data = await _client
        .from('profiles')
        .select()
        .eq('id', userId)
        .single();

    return Profile.fromMap(data);
  }

  Future<void> updateProfile(Profile profile) async {
    await _client
        .from('profiles')
        .update(profile.toUpdateMap())
        .eq('id', profile.id);
  }

  // ---------- TIMETABLE ----------
  // In future: replace this with a call to the university timetable API
  // ---------- TIMETABLE (live API demo) ----------
  // Replaces the Supabase 'timetable' table with mock data from JSONPlaceholder.
  // In future: replace this with a call to the university timetable API.
  Future<List<TimetableEntry>> getTimetable() async {
    final url = Uri.parse('https://jsonplaceholder.typicode.com/todos');

    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception('Failed to load timetable: ${response.statusCode}');
    }

    final List<dynamic> data = jsonDecode(response.body);

    // Take first 21 items (3 per day x 7 days) to keep it realistic
    final limited = data.take(21).toList();

    return limited.map((e) => TimetableEntry.fromJsonPlaceholder(e)).toList();
  }

  // ---------- HOLIDAYS ----------
  // In future: replace this with a call to the university academic calendar API
  Future<List<Holiday>> getHolidays() async {
    final year = DateTime.now().year;
    final url = Uri.parse(
      'https://date.nager.at/api/v3/PublicHolidays/$year/US',
    );

    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception('Failed to load holidays: ${response.statusCode}');
    }

    final List<dynamic> data = jsonDecode(response.body);
    return data.map((e) => Holiday.fromNagerApi(e)).toList();
  }

  // ... keep getTimetable(), getFaculty(), etc. unchanged

  // ---------- FACULTY ----------
  // In future: replace this with a call to the university directory API
  // ---------- FACULTY (live API demo) ----------
  // Replaces the Supabase 'faculty' table with mock data from randomuser.me.
  // In future: replace this with a call to the university directory API.
  Future<List<Faculty>> getFaculty() async {
    final url = Uri.parse('https://randomuser.me/api/?results=10&seed=mmsapp');

    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception('Failed to load faculty: ${response.statusCode}');
    }

    final Map<String, dynamic> data = jsonDecode(response.body);
    final List<dynamic> results = data['results'];

    return results
        .asMap()
        .entries
        .map((entry) => Faculty.fromRandomUserApi(entry.value, entry.key))
        .toList();
  }
}
