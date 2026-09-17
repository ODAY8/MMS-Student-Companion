import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/academic_provider.dart';

class HolidaysScreen extends StatelessWidget {
  const HolidaysScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final academicProvider = context.watch<AcademicProvider>();
    final holidays = academicProvider.holidays;

    return Scaffold(
      appBar: AppBar(title: const Text('Holiday List')),
      body: academicProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : holidays.isEmpty
          ? const Center(child: Text('No holidays found'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: holidays.length,
              itemBuilder: (context, index) {
                final h = holidays[index];
                final isPast = h.date.isBefore(DateTime.now());

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isPast
                          ? Colors.grey[300]
                          : Theme.of(
                              context,
                            ).colorScheme.primary.withOpacity(0.1),
                      child: Icon(
                        Icons.celebration_outlined,
                        color: isPast
                            ? Colors.grey
                            : Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    title: Text(
                      h.name,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      DateFormat('EEEE, MMM d, yyyy').format(h.date),
                    ),
                    trailing: isPast
                        ? const Text(
                            'Past',
                            style: TextStyle(color: Colors.grey),
                          )
                        : null,
                  ),
                );
              },
            ),
    );
  }
}
