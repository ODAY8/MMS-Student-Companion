import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/timetable_provider.dart';
import '../widgets/timetable_tile.dart';

class TimetableScreen extends StatefulWidget {
  const TimetableScreen({super.key});

  @override
  State<TimetableScreen> createState() => _TimetableScreenState();
}

class _TimetableScreenState extends State<TimetableScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  void initState() {
    super.initState();
    final todayIndex = DateTime.now().weekday - 1; // 0-6
    _tabController = TabController(
      length: 7,
      vsync: this,
      initialIndex: todayIndex,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final timetableProvider = context.watch<TimetableProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Timetable'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: _days.map((d) => Tab(text: d)).toList(),
        ),
      ),
      body: timetableProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: List.generate(7, (index) {
                final dayOfWeek = index + 1; // 1=Monday
                final classes = timetableProvider.forDay(dayOfWeek);

                if (classes.isEmpty) {
                  return const Center(child: Text('No classes scheduled'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: classes.length,
                  itemBuilder: (context, i) => TimetableTile(entry: classes[i]),
                );
              }),
            ),
    );
  }
}
