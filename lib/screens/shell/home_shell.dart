import 'package:flutter/material.dart';

import '../checklist/checklist_screen.dart';
import '../dashboard/dashboard_screen.dart';
import '../settings/settings_screen.dart';

class HomeShell extends StatefulWidget {
  final bool dark;
  final ValueChanged<bool> onTheme;

  const HomeShell({
    super.key,
    required this.dark,
    required this.onTheme,
  });

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int tab = 0;
  int refresh = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      DashboardScreen(refreshToken: refresh),
      ChecklistScreen(onChanged: () => setState(() => refresh++)),
      SettingsScreen(dark: widget.dark, onTheme: widget.onTheme),
    ];

    return Scaffold(
      body: IndexedStack(index: tab, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: tab,
        onDestinationSelected: (v) => setState(() => tab = v),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.checklist_outlined),
            selectedIcon: Icon(Icons.checklist),
            label: 'Checklist',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
