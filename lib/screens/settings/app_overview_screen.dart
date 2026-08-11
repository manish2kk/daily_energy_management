import 'package:flutter/material.dart';

class AppOverviewScreen extends StatelessWidget {
  final bool fromFirstLaunch;
  final VoidCallback? onContinue;

  const AppOverviewScreen({
    super.key,
    this.fromFirstLaunch = false,
    this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    final body = ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Icon(
          Icons.bolt_outlined,
          size: 64,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(height: 16),
        Text(
          'Daily Energy Management',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Track charging and discharging activities each day. '
          'Build streaks, see your energy graph, and stay accountable.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 28),
        _OverviewTile(
          icon: Icons.home_outlined,
          title: 'Home',
          body:
              'See your charging streak, monthly good activities, and a '
              'year-long energy graph — green for charging, red for discharge.',
        ),
        _OverviewTile(
          icon: Icons.checklist_outlined,
          title: 'Checklist',
          body:
              'Check off daily items by category: Exercise, Create / Build, '
              'Communicate, and Discharge. Add your own anytime.',
        ),
        _OverviewTile(
          icon: Icons.settings_outlined,
          title: 'Settings',
          body: 'Switch dark or light theme, and open About or Contact.',
        ),
        if (fromFirstLaunch) ...[
          const SizedBox(height: 24),
          FilledButton(
            onPressed: onContinue,
            child: const Text('Get started'),
          ),
        ],
      ],
    );

    if (fromFirstLaunch) {
      return Scaffold(body: SafeArea(child: body));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('App overview')),
      body: body,
    );
  }
}

class _OverviewTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;

  const _OverviewTile({
    required this.icon,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 4),
                Text(body),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
