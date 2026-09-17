import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/auth_provider.dart';
import '../providers/assignment_provider.dart';
import '../models/assignments.dart';

const navy = Color(0xFF0A1128);
const accentBlue = Color(0xFF1E40AF);

class AssignmentsScreen extends StatefulWidget {
  const AssignmentsScreen({super.key});

  @override
  State<AssignmentsScreen> createState() => _AssignmentsScreenState();
}

class _AssignmentsScreenState extends State<AssignmentsScreen> {
  bool _showCompleted = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = context.read<AuthProvider>().user!.id;
      context.read<AssignmentProvider>().loadAll(userId);
    });
  }

  void _showAddDialog() {
    final titleController = TextEditingController();
    final subjectController = TextEditingController();
    DateTime selectedDate = DateTime.now().add(const Duration(days: 1));
    String selectedPriority = 'medium';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setStateDialog) => AlertDialog(
          title: const Text('Add Assignment'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    hintText: 'e.g. Physics Lab Report',
                  ),
                  autofocus: true,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: subjectController,
                  decoration: const InputDecoration(
                    labelText: 'Subject (optional)',
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Text('Due date: '),
                    TextButton(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: ctx,
                          initialDate: selectedDate,
                          firstDate: DateTime.now().subtract(
                            const Duration(days: 365),
                          ),
                          lastDate: DateTime.now().add(
                            const Duration(days: 365 * 2),
                          ),
                        );
                        if (picked != null) {
                          setStateDialog(() => selectedDate = picked);
                        }
                      },
                      child: Text(
                        DateFormat('MMM d, yyyy').format(selectedDate),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text('Priority:'),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 8,
                  children: ['low', 'medium', 'high'].map((p) {
                    final selected = p == selectedPriority;
                    return ChoiceChip(
                      label: Text(p[0].toUpperCase() + p.substring(1)),
                      selected: selected,
                      onSelected: (_) =>
                          setStateDialog(() => selectedPriority = p),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final title = titleController.text.trim();
                if (title.isEmpty) return;

                final userId = context.read<AuthProvider>().user!.id;
                context.read<AssignmentProvider>().addAssignment(
                  userId: userId,
                  title: title,
                  subject: subjectController.text.trim().isEmpty
                      ? null
                      : subjectController.text.trim(),
                  dueDate: selectedDate,
                  priority: selectedPriority,
                );
                Navigator.pop(ctx);
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AssignmentProvider>();
    final list = _showCompleted ? provider.all : provider.pending;

    // Sort: overdue first, then by due date
    final sorted = [...list]
      ..sort((a, b) {
        if (a.isOverdue != b.isOverdue) return a.isOverdue ? -1 : 1;
        return a.dueDate.compareTo(b.dueDate);
      });

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: provider.isLoading
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
                              'Assignments',
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _HeaderStat(
                            value: '${provider.pendingCount}',
                            label: 'Pending',
                          ),
                          const SizedBox(width: 24),
                          _HeaderStat(
                            value: '${provider.dueToday.length}',
                            label: 'Due Today',
                          ),
                          const SizedBox(width: 24),
                          _HeaderStat(
                            value: '${provider.overdue.length}',
                            label: 'Overdue',
                            isWarning: true,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Toggle show completed
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _showCompleted
                            ? 'All Assignments'
                            : 'Pending Assignments',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: navy,
                        ),
                      ),
                      TextButton(
                        onPressed: () =>
                            setState(() => _showCompleted = !_showCompleted),
                        child: Text(
                          _showCompleted ? 'Hide completed' : 'Show completed',
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                if (sorted.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(40),
                    child: Center(
                      child: Text(
                        _showCompleted
                            ? 'No assignments yet.'
                            : 'No pending assignments. 🎉',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: sorted
                          .map((a) => _AssignmentCard(assignment: a))
                          .toList(),
                    ),
                  ),

                const SizedBox(height: 30),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        backgroundColor: accentBlue,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _HeaderStat extends StatelessWidget {
  final String value;
  final String label;
  final bool isWarning;

  const _HeaderStat({
    required this.value,
    required this.label,
    this.isWarning = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: isWarning && value != '0'
                ? const Color(0xFFEF4444)
                : Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(label, style: TextStyle(color: Colors.grey[400], fontSize: 12)),
      ],
    );
  }
}

class _AssignmentCard extends StatelessWidget {
  final Assignment assignment;

  const _AssignmentCard({required this.assignment});

  Color get _priorityColor {
    switch (assignment.priority) {
      case 'high':
        return const Color(0xFFEF4444);
      case 'medium':
        return const Color(0xFFF59E0B);
      default:
        return const Color(0xFF10B981);
    }
  }

  String get _dueLabel {
    if (assignment.isCompleted) return 'Completed';
    final days = assignment.daysUntilDue;
    if (days < 0) return 'Overdue by ${-days} day${-days == 1 ? '' : 's'}';
    if (days == 0) return 'Due today';
    if (days == 1) return 'Due tomorrow';
    return 'Due in $days days';
  }

  @override
  Widget build(BuildContext context) {
    final userId = context.read<AuthProvider>().user!.id;

    return Dismissible(
      key: Key(assignment.id),
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
            title: const Text('Delete assignment?'),
            content: Text('Delete "${assignment.title}"?'),
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
      onDismissed: (_) => context.read<AssignmentProvider>().deleteAssignment(
        userId,
        assignment.id,
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: assignment.isOverdue
              ? Border.all(color: const Color(0xFFEF4444).withOpacity(0.4))
              : null,
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
            GestureDetector(
              onTap: () => context.read<AssignmentProvider>().toggleComplete(
                userId,
                assignment,
              ),
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: assignment.isCompleted
                      ? const Color(0xFF10B981)
                      : Colors.transparent,
                  border: Border.all(
                    color: assignment.isCompleted
                        ? const Color(0xFF10B981)
                        : Colors.grey[400]!,
                    width: 2,
                  ),
                ),
                child: assignment.isCompleted
                    ? const Icon(Icons.check, color: Colors.white, size: 16)
                    : null,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    assignment.title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: navy,
                      decoration: assignment.isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (assignment.subject != null) ...[
                        Text(
                          assignment.subject!,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          '  •  ',
                          style: TextStyle(color: Colors.grey[400]),
                        ),
                      ],
                      Text(
                        _dueLabel,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: assignment.isOverdue
                              ? const Color(0xFFEF4444)
                              : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.only(left: 8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _priorityColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
