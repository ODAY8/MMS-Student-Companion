import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/cgpa_provider.dart';
import '../widgets/subject_grade_card.dart';
import '../utils/grade_utils.dart';

class CGPAScreen extends StatelessWidget {
  const CGPAScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cgpaProvider = context.watch<CGPAProvider>();
    final semesters = cgpaProvider.bySemester.keys.toList()..sort();

    return Scaffold(
      appBar: AppBar(title: const Text('CGPA Calculator')),
      body: cgpaProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  color: Theme.of(context).colorScheme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        const Text(
                          'Overall CGPA',
                          style: TextStyle(color: Colors.white70),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          cgpaProvider.cgpa.toStringAsFixed(2),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${GradeUtils.cgpaRemark(cgpaProvider.cgpa)} • out of 10',
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (semesters.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Center(
                      child: Text(
                        'No subjects added yet.\nTap + to add your first grade.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ...semesters.map((sem) {
                  final subjects = cgpaProvider.bySemester[sem]!;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Semester $sem',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            Text(
                              'SGPA: ${cgpaProvider.sgpaForSemester(sem).toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ...subjects.map(
                        (s) => SubjectGradeCard(
                          subject: s,
                          onDelete: () {
                            final userId = context
                                .read<AuthProvider>()
                                .user!
                                .id;
                            context.read<CGPAProvider>().deleteSubject(
                              s.id,
                              userId,
                            );
                          },
                        ),
                      ),
                    ],
                  );
                }),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    final nameController = TextEditingController();
    final creditsController = TextEditingController();
    final gradeController = TextEditingController();
    final semesterController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Subject'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Subject name'),
              ),
              TextField(
                controller: creditsController,
                decoration: const InputDecoration(
                  labelText: 'Credits (e.g. 4)',
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
              ),
              TextField(
                controller: gradeController,
                decoration: const InputDecoration(
                  labelText: 'Grade point (0-10)',
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
              ),
              TextField(
                controller: semesterController,
                decoration: const InputDecoration(
                  labelText: 'Semester (e.g. 1)',
                ),
                keyboardType: TextInputType.number,
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
              final name = nameController.text.trim();
              final credits = double.tryParse(creditsController.text);
              final grade = double.tryParse(gradeController.text);
              final semester = int.tryParse(semesterController.text);

              if (name.isEmpty ||
                  credits == null ||
                  grade == null ||
                  semester == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please fill all fields correctly'),
                  ),
                );
                return;
              }
              if (grade < 0 || grade > 10) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Grade point must be between 0 and 10'),
                  ),
                );
                return;
              }

              final userId = context.read<AuthProvider>().user!.id;
              context.read<CGPAProvider>().addSubject(
                userId: userId,
                name: name,
                credits: credits,
                gradePoint: grade,
                semester: semester,
              );
              Navigator.pop(ctx);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
