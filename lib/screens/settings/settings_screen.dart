import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'about_us_screen.dart';
import 'app_overview_screen.dart';
import 'contact_us_screen.dart';

class SettingsScreen extends StatefulWidget {
  final bool dark;
  final ValueChanged<bool> onTheme;

  const SettingsScreen({
    super.key,
    required this.dark,
    required this.onTheme,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _version = '…';

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    if (!mounted) return;
    setState(() => _version = info.version);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Dark mode'),
            value: widget.dark,
            onChanged: widget.onTheme,
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
          ListTile(
            leading: const Icon(Icons.tag),
            title: const Text('App version'),
            subtitle: Text(_version),
          ),
        ],
      ),
    );
  }
}
