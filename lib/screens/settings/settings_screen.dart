import 'package:flutter/material.dart';

import 'about_us_screen.dart';
import 'app_overview_screen.dart';
import 'contact_us_screen.dart';

class SettingsScreen extends StatelessWidget {
  final bool dark;
  final ValueChanged<bool> onTheme;

  const SettingsScreen({
    super.key,
    required this.dark,
    required this.onTheme,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Dark mode'),
            value: dark,
            onChanged: onTheme,
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('App overview'),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const AppOverviewScreen()),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.groups_outlined),
            title: const Text('About us'),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const AboutUsScreen()),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.mail_outline),
            title: const Text('Contact us'),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ContactUsScreen()),
            ),
          ),
          const ListTile(
            leading: Icon(Icons.tag),
            title: Text('App version'),
            subtitle: Text('1.0.0'),
          ),
        ],
      ),
    );
  }
}
