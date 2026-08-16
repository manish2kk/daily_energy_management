import 'package:flutter/material.dart';

import '../../data/app_db.dart';
import '../../services/important_times_service.dart';
import '../../utils/date_utils.dart';
import 'widgets/energy_graph.dart';
import 'widgets/important_times_card.dart';
import 'widgets/stat_card.dart';

class DashboardScreen extends StatefulWidget {
  final int refreshToken;

  const DashboardScreen({super.key, this.refreshToken = 0});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<Map<String, Object?>> rows = [];
  ImportantTimes? importantTimes;
  bool timesLoading = true;

  @override
  void initState() {
    super.initState();
    load();
  }

  @override
  void didUpdateWidget(covariant DashboardScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.refreshToken != widget.refreshToken) {
      load();
    }
  }

  Future<void> load() async {
    setState(() => timesLoading = importantTimes == null);
    try {
      final completed = await AppDb.allCompleted();
      final times = await ImportantTimesService.load();
      if (!mounted) return;
      setState(() {
        rows = completed;
        importantTimes = times;
        timesLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        timesLoading = false;
      });
    }
  }

  bool dischargeOn(DateTime d) => rows.any(
        (r) =>
            r['category'] == 'discharge' &&
            sameDay(DateTime.parse(r['date'] as String), d),
      );

  int countOn(DateTime d) => rows
      .where(
        (r) =>
            r['category'] != 'discharge' &&
            sameDay(DateTime.parse(r['date'] as String), d),
      )
      .length;

  int streak() {
    // Show streak through yesterday — today's progress is still in progress.
    var d = dateOnly(DateTime.now()).subtract(const Duration(days: 1));
    var n = 0;
    while (countOn(d) > 0 && !dischargeOn(d)) {
      n++;
      d = d.subtract(const Duration(days: 1));
    }
    return n;
  }

  @override
  Widget build(BuildContext context) {
    final monthAgo = DateTime.now().subtract(const Duration(days: 30));
    final goodMonth = rows
        .where(
          (r) =>
              r['category'] != 'discharge' &&
              DateTime.parse(r['date'] as String).isAfter(monthAgo),
        )
        .length;

    return Scaffold(
      appBar: AppBar(title: const Text('Daily Energy Management')),
      body: RefreshIndicator(
        onRefresh: load,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    title: 'Streak',
                    value: '${streak()} days',
                    icon: Icons.local_fire_department_outlined,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatCard(
                    title: 'Good activities',
                    value: '$goodMonth / month',
                    icon: Icons.bolt_outlined,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            Text(
              'Energy Graph',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Your energy graph over the past months.',
            ),
            const SizedBox(height: 14),
            EnergyGraph(rows: rows),
            const SizedBox(height: 28),
            ImportantTimesCard(
              times: importantTimes,
              loading: timesLoading,
            ),
          ],
        ),
      ),
    );
  }
}
