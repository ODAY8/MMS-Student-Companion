import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/auth_provider.dart';
import '../providers/cgpa_provider.dart';
import '../providers/timetable_provider.dart';
import '../providers/academic_provider.dart';
import '../utils/grade_utils.dart';
import 'cgpa_screen.dart';
import 'timetable_screen.dart';
import 'holidays_screen.dart';
import 'faculty_screen.dart';
import 'onboarding_screen.dart';
import 'profile_screen.dart';
import '../providers/attendance_provider.dart';
import 'attendance_screen.dart';
import 'assignments_screen.dart';
import '../providers/assignment_provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:sms_app/providers/assignment_provider.dart';
import '../services/notification_service.dart';

const navy = Color(0xFF0A1128);
const accentBlue = Color(0xFF1E40AF);

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _requestNotificationPermission();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = context.read<AuthProvider>().user!.id;
      context.read<CGPAProvider>().loadSubjects(userId);
      context.read<TimetableProvider>().loadTimetable();
      context.read<AcademicProvider>().loadAll();
      context.read<AssignmentProvider>().loadAll(userId);
    });
  }

  Future<void> _requestNotificationPermission() async {
    final plugin = FlutterLocalNotificationsPlugin();
    await plugin.resolvePlatformSpecificImplementation;
    AndroidFlutterLocalNotificationsPlugin()?.requestNotificationsPermission();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final cgpaProvider = context.watch<CGPAProvider>();
    final timetableProvider = context.watch<TimetableProvider>();
    final academicProvider = context.watch<AcademicProvider>();

    final now = DateTime.now();
    final dayName = DateFormat('EEEE').format(now);
    final monthDay = DateFormat('MMM d').format(now);

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: RefreshIndicator(
        onRefresh: () async {
          final userId = auth.user!.id;
          await Future.wait([
            cgpaProvider.loadSubjects(userId),
            timetableProvider.loadTimetable(),
            academicProvider.loadAll(),
          ]);
        },
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // Top navy header
            Container(
              decoration: const BoxDecoration(
                color: navy,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(28),
                  bottomRight: Radius.circular(28),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(20, 50, 20, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 88,
                            height: 88,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFF1E40AF,
                                  ).withOpacity(0.4),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Image.asset(
                                'assets/images/logo.png',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                        ],
                      ),
                      Row(
                        children: [
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(
                              Icons.notifications_none,
                              color: Colors.white,
                            ),
                          ),
                          // Avatar placeholder - person icon, ready for future image upload
                          // Avatar placeholder - person icon, tap to open menu
                          PopupMenuButton<String>(
                            offset: const Offset(0, 45),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            onSelected: (value) async {
                              if (value == 'signout') {
                                await context.read<AuthProvider>().signOut();
                              } else if (value == 'profile') {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const ProfileScreen(),
                                  ),
                                );
                              }
                            },
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                value: 'profile',
                                child: Row(
                                  children: const [
                                    Icon(
                                      Icons.person_outline,
                                      size: 18,
                                      color: navy,
                                    ),
                                    SizedBox(width: 10),
                                    Text('Profile'),
                                  ],
                                ),
                              ),
                              PopupMenuItem(
                                value: 'signout',
                                child: Row(
                                  children: const [
                                    Icon(
                                      Icons.logout,
                                      size: 18,
                                      color: Colors.red,
                                    ),
                                    SizedBox(width: 10),
                                    Text(
                                      'Sign Out',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            child: Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white24),
                              ),
                              child: const Icon(
                                Icons.person,
                                color: Colors.white,
                                size: 22,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    dayName,
                    style: TextStyle(color: Colors.grey[400], fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    monthDay,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    auth.user?.email ?? '',
                    style: TextStyle(color: Colors.grey[400], fontSize: 12),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Feature Grid
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 1.1,
                children: [
                  _FeatureCard(
                    icon: Icons.calculate_outlined,
                    label: 'CGPA',
                    value: cgpaProvider.cgpa.toStringAsFixed(2),
                    sublabel: GradeUtils.cgpaRemark(cgpaProvider.cgpa),
                    color: const Color(0xFF1E40AF),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CGPAScreen()),
                    ),
                  ),
                  _FeatureCard(
                    icon: Icons.schedule_outlined,
                    label: 'Timetable',
                    value: '${timetableProvider.today.length}',
                    sublabel: 'classes today',
                    color: const Color(0xFF0EA5E9),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const TimetableScreen(),
                      ),
                    ),
                  ),
                  _FeatureCard(
                    icon: Icons.celebration_outlined,
                    label: 'Holidays',
                    value: '${academicProvider.upcomingHolidays.length}',
                    sublabel: 'upcoming',
                    color: const Color(0xFFF59E0B),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const HolidaysScreen()),
                    ),
                  ),
                  _FeatureCard(
                    icon: Icons.people_outline,
                    label: 'Faculty',
                    value: '${academicProvider.faculty.length}',
                    sublabel: 'members',
                    color: const Color(0xFF10B981),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const FacultyScreen()),
                    ),
                  ),
                  _FeatureCard(
                    icon: Icons.fact_check_outlined,
                    label: 'Attendance',
                    value:
                        '${context.watch<AttendanceProvider>().overallPercentage.toStringAsFixed(0)}%',
                    sublabel: 'overall',
                    color: const Color(0xFFEF4444),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AttendanceScreen(),
                      ),
                    ),
                  ),
                  _FeatureCard(
                    icon: Icons.assignment_outlined,
                    label: 'Assignments',
                    value:
                        '${context.watch<AssignmentProvider>().pendingCount}',
                    sublabel: 'pending',
                    color: const Color(0xFFF59E0B),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AssignmentsScreen(),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Today's Classes
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Today's Classes",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: navy,
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const TimetableScreen(),
                      ),
                    ),
                    child: const Text(
                      'View all',
                      style: TextStyle(color: accentBlue),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: timetableProvider.isLoading
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : timetableProvider.today.isEmpty
                  ? const _EmptyCard(text: 'No classes scheduled today 🎉')
                  : Column(
                      children: timetableProvider.today
                          .map((entry) => _ClassCard(entry: entry))
                          .toList(),
                    ),
            ),

            const SizedBox(height: 24),

            // Upcoming Holidays
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Upcoming Holidays',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: navy,
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const HolidaysScreen()),
                    ),
                    child: const Text(
                      'View all',
                      style: TextStyle(color: accentBlue),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: academicProvider.isLoading
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : academicProvider.upcomingHolidays.isEmpty
                  ? const _EmptyCard(text: 'No upcoming holidays')
                  : Column(
                      children: academicProvider.upcomingHolidays
                          .take(3)
                          .map((h) => _HolidayCard(holiday: h))
                          .toList(),
                    ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

// ---------------- Reusable widgets ----------------

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String sublabel;
  final Color color;
  final VoidCallback onTap;

  const _FeatureCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.sublabel,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const Spacer(),
            Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: navy,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: navy,
              ),
            ),
            Text(
              sublabel,
              style: TextStyle(fontSize: 11, color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }
}

class _ClassCard extends StatelessWidget {
  final dynamic entry; // TimetableEntry

  const _ClassCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: accentBlue.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                Text(
                  entry.startTime,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: accentBlue,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  entry.endTime,
                  style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.subjectName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: navy,
                  ),
                ),
                if (entry.facultyName != null)
                  Text(
                    entry.facultyName!,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                if (entry.room != null)
                  Text(
                    'Room ${entry.room}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HolidayCard extends StatelessWidget {
  final dynamic holiday; // Holiday

  const _HolidayCard({required this.holiday});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFF59E0B).withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.celebration_outlined,
              color: Color(0xFFF59E0B),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  holiday.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: navy,
                  ),
                ),
                Text(
                  DateFormat('EEEE, MMM d, yyyy').format(holiday.date),
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  final String text;
  const _EmptyCard({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Text(text, style: TextStyle(color: Colors.grey[600])),
      ),
    );
  }
}
