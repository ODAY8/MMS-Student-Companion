import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/auth_provider.dart';
import '../providers/attendance_provider.dart';
import '../models/attendance.dart';

const navy = Color(0xFF0A1128);
const accentBlue = Color(0xFF1E40AF);

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = context.read<AuthProvider>().user!.id;
      context.read<AttendanceProvider>().loadAll(userId);
    });
  }

  void _showAddSubjectDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Subject'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'e.g. Mathematics'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isEmpty) return;
              final userId = context.read<AuthProvider>().user!.id;
              context.read<AttendanceProvider>().addSubject(userId, name);
              Navigator.pop(ctx);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showMarkDialog(AttendanceSubject subject) {
    final today = DateTime.now();
    final userId = context.read<AuthProvider>().user!.id;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(subject.name),
        content: Text(
          'Mark attendance for ${DateFormat('EEEE, MMM d').format(today)}',
        ),
        actions: [
          TextButton(
            onPressed: () {
              context.read<AttendanceProvider>().markAttendance(
                userId: userId,
                subjectId: subject.id,
                date: today,
                status: 'absent',
              );
              Navigator.pop(ctx);
            },
            child: const Text('Absent', style: TextStyle(color: Colors.red)),
          ),
          FilledButton(
            onPressed: () {
              context.read<AttendanceProvider>().markAttendance(
                userId: userId,
                subjectId: subject.id,
                date: today,
                status: 'present',
              );
              Navigator.pop(ctx);
            },
            child: const Text('Present'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final attendance = context.watch<AttendanceProvider>();
    final today = DateTime.now();

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: attendance.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: EdgeInsets.zero,
              children: [
                // Navy header
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
                    children: [
                      Row(
                        children: [
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                            ),
                          ),
                          const Expanded(
                            child: Text(
                              'Attendance',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 48),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '${attendance.overallPercentage.toStringAsFixed(1)}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Overall Attendance',
                        style: TextStyle(color: Colors.grey[400], fontSize: 13),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Overall / Highest / Lowest cards
                if (attendance.subjects.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            icon: Icons.donut_large,
                            color: accentBlue,
                            label: 'Overall',
                            subject: '${attendance.subjects.length} subjects',
                            percentage: attendance.overallPercentage,
                          ),
                        ),
                        if (attendance.highest != null) ...[
                          const SizedBox(width: 12),
                          Expanded(
                            child: _StatCard(
                              icon: Icons.trending_up,
                              color: const Color(0xFF10B981),
                              label: 'Highest',
                              subject: attendance.highest!.subject.name,
                              percentage: attendance.highest!.percentage,
                            ),
                          ),
                        ],
                        if (attendance.lowest != null) ...[
                          const SizedBox(width: 12),
                          Expanded(
                            child: _StatCard(
                              icon: Icons.trending_down,
                              color: const Color(0xFFEF4444),
                              label: 'Lowest',
                              subject: attendance.lowest!.subject.name,
                              percentage: attendance.lowest!.percentage,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                const SizedBox(height: 24),

                // Subjects list
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Subjects',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: navy,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: _showAddSubjectDialog,
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Add'),
                      ),
                    ],
                  ),
                ),

                if (attendance.subjects.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(40),
                    child: Center(
                      child: Text(
                        'No subjects yet.\nTap "Add" to start tracking attendance.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: attendance.statsPerSubject.map((stats) {
                        final todayStatus = attendance.statusFor(
                          stats.subject.id,
                          today,
                        );
                        return _SubjectCard(
                          stats: stats,
                          todayStatus: todayStatus,
                          onTap: () => _showMarkDialog(stats.subject),
                          onDelete: () {
                            final userId = context
                                .read<AuthProvider>()
                                .user!
                                .id;
                            context.read<AttendanceProvider>().deleteSubject(
                              userId,
                              stats.subject.id,
                            );
                          },
                        );
                      }).toList(),
                    ),
                  ),

                const SizedBox(height: 30),
              ],
            ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String subject;
  final double percentage;

  const _StatCard({
    required this.icon,
    required this.color,
    required this.label,
    required this.subject,
    required this.percentage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${percentage.toStringAsFixed(1)}%',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: percentage >= 75 ? navy : const Color(0xFFEF4444),
            ),
          ),
          Text(
            subject,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _SubjectCard extends StatelessWidget {
  final SubjectAttendanceStats stats;
  final String? todayStatus;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _SubjectCard({
    required this.stats,
    required this.todayStatus,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = stats.percentage;
    final color = percentage >= 75
        ? const Color(0xFF10B981)
        : percentage >= 50
        ? const Color(0xFFF59E0B)
        : const Color(0xFFEF4444);

    return Dismissible(
      key: Key(stats.subject.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (_) async {
        return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Delete subject?'),
            content: Text(
              'Delete "${stats.subject.name}" and all its attendance records?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) => onDelete(),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
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
            SizedBox(
              width: 48,
              height: 48,
              child: Stack(
                children: [
                  CircularProgressIndicator(
                    value: percentage / 100,
                    backgroundColor: Colors.grey[200],
                    color: color,
                    strokeWidth: 4,
                  ),
                  Center(
                    child: Text(
                      '${percentage.toStringAsFixed(0)}%',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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
                    stats.subject.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: navy,
                    ),
                  ),
                  Text(
                    '${stats.present}/${stats.totalClasses} classes attended',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            if (todayStatus != null)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: todayStatus == 'present'
                      ? const Color(0xFF10B981).withOpacity(0.1)
                      : const Color(0xFFEF4444).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  todayStatus == 'present' ? 'Present' : 'Absent',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: todayStatus == 'present'
                        ? const Color(0xFF10B981)
                        : const Color(0xFFEF4444),
                  ),
                ),
              )
            else
              FilledButton(
                onPressed: onTap,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  minimumSize: Size.zero,
                  backgroundColor: accentBlue,
                ),
                child: const Text('Mark', style: TextStyle(fontSize: 12)),
              ),
            IconButton(
              icon: const Icon(
                Icons.delete_outline,
                color: Colors.red,
                size: 20,
              ),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Delete subject?'),
                    content: Text(
                      'Delete "${stats.subject.name}" and all its attendance records?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text(
                          'Delete',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                );
                if (confirm == true) onDelete();
              },
            ),
          ],
        ),
      ),
    );
  }
}
