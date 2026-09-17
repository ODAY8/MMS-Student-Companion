import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../screens/cgpa_screen.dart';
import '../screens/timetable_screen.dart';
import '../screens/holidays_screen.dart';
import '../screens/faculty_screen.dart';

class NavDrawer extends StatelessWidget {
  const NavDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final email = context.read<AuthProvider>().user?.email ?? '';

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Icon(Icons.account_circle, size: 48, color: Colors.white),
                const SizedBox(height: 8),
                Text(
                  email,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.calculate_outlined),
            title: const Text('CGPA Calculator'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CGPAScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.schedule_outlined),
            title: const Text('Timetable'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TimetableScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.celebration_outlined),
            title: const Text('Holidays'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HolidaysScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.people_outline),
            title: const Text('Faculty Directory'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FacultyScreen()),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Sign Out', style: TextStyle(color: Colors.red)),
            onTap: () => context.read<AuthProvider>().signOut(),
          ),
        ],
      ),
    );
  }
}
