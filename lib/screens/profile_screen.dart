import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/profile_provider.dart';

const navy = Color(0xFF0A1128);
const accentBlue = Color(0xFF1E40AF);

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
  final _studentIdController = TextEditingController();
  final _departmentController = TextEditingController();
  int? _selectedYear;
  bool _editing = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final userId = context.read<AuthProvider>().user!.id;
      await context.read<ProfileProvider>().loadProfile(userId);
      if (mounted) {
        _populateControllers();
      }
    });
  }

  void _populateControllers() {
    if (!mounted) return;
    final profile = context.read<ProfileProvider>().profile;
    if (profile != null) {
      _nameController.text = profile.fullName;
      _studentIdController.text = profile.studentId ?? '';
      _departmentController.text = profile.department ?? '';
      _selectedYear = profile.yearOfStudy;
      setState(() {});
    }
  }

  Future<void> _save() async {
    await context.read<ProfileProvider>().updateProfile(
      fullName: _nameController.text.trim(),
      studentId: _studentIdController.text.trim(),
      department: _departmentController.text.trim(),
      yearOfStudy: _selectedYear,
    );
    setState(() => _editing = false);
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Profile updated')));
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _studentIdController.dispose();
    _departmentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final profileProvider = context.watch<ProfileProvider>();
    final email = auth.user?.email ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: profileProvider.isLoading
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
                  padding: const EdgeInsets.fromLTRB(20, 50, 20, 32),
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
                              'Profile',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              if (_editing) {
                                _save();
                              } else {
                                setState(() => _editing = true);
                              }
                            },
                            icon: Icon(
                              _editing ? Icons.check : Icons.edit_outlined,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Avatar placeholder
                      Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white24, width: 2),
                        ),
                        child: const Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 48,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _nameController.text.isNotEmpty
                            ? _nameController.text
                            : 'Add your name',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        email,
                        style: TextStyle(color: Colors.grey[400], fontSize: 13),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Details
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Academic Information',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: navy,
                        ),
                      ),
                      const SizedBox(height: 16),

                      _ProfileField(
                        icon: Icons.badge_outlined,
                        label: 'Full Name',
                        controller: _nameController,
                        editing: _editing,
                      ),
                      const SizedBox(height: 12),
                      _ProfileField(
                        icon: Icons.confirmation_number_outlined,
                        label: 'Student ID',
                        controller: _studentIdController,
                        editing: _editing,
                      ),
                      const SizedBox(height: 12),
                      _ProfileField(
                        icon: Icons.school_outlined,
                        label: 'Department',
                        controller: _departmentController,
                        editing: _editing,
                      ),
                      const SizedBox(height: 12),

                      // Year of study - dropdown when editing, text when not
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
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
                            const Icon(
                              Icons.calendar_today_outlined,
                              color: accentBlue,
                              size: 20,
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Year of Study',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                  _editing
                                      ? DropdownButton<int>(
                                          value: _selectedYear,
                                          isExpanded: true,
                                          underline: const SizedBox(),
                                          hint: const Text('Select year'),
                                          items: [1, 2, 3, 4, 5]
                                              .map(
                                                (y) => DropdownMenuItem(
                                                  value: y,
                                                  child: Text('Year $y'),
                                                ),
                                              )
                                              .toList(),
                                          onChanged: (v) =>
                                              setState(() => _selectedYear = v),
                                        )
                                      : Padding(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 10,
                                          ),
                                          child: Text(
                                            _selectedYear != null
                                                ? 'Year $_selectedYear'
                                                : 'Not set',
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w500,
                                              color: navy,
                                            ),
                                          ),
                                        ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Account actions
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Account',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: navy,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: ListTile(
                          leading: const Icon(Icons.logout, color: Colors.red),
                          title: const Text(
                            'Sign Out',
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          onTap: () => context.read<AuthProvider>().signOut(),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),
    );
  }
}

class _ProfileField extends StatelessWidget {
  final IconData icon;
  final String label;
  final TextEditingController controller;
  final bool editing;

  const _ProfileField({
    required this.icon,
    required this.label,
    required this.controller,
    required this.editing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
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
          Icon(icon, color: accentBlue, size: 20),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                ),
                editing
                    ? TextField(
                        controller: controller,
                        decoration: const InputDecoration(
                          isDense: true,
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 8),
                        ),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: navy,
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Text(
                          controller.text.isNotEmpty
                              ? controller.text
                              : 'Not set',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: navy,
                          ),
                        ),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
