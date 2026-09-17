import 'package:flutter/material.dart';
import '../models/subject.dart';
import '../utils/grade_utils.dart';

class SubjectGradeCard extends StatelessWidget {
  final Subject subject;
  final VoidCallback onDelete;

  const SubjectGradeCard({
    super.key,
    required this.subject,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        title: Text(
          subject.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '${subject.credits} credits • Grade: ${GradeUtils.letterGrade(subject.gradePoint)}',
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              subject.gradePoint.toStringAsFixed(1),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
