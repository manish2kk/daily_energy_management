import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'screens/settings/app_overview_screen.dart';
import 'screens/shell/home_shell.dart';
import 'theme/app_theme.dart';

class EnergyApp extends StatefulWidget {
  const EnergyApp({super.key});

  @override
  State<EnergyApp> createState() => _EnergyAppState();
}

class _EnergyAppState extends State<EnergyApp> {
  static const _themeKey = 'dark_mode';
  static const _overviewSeenKey = 'overview_seen';

  bool _ready = false;
  bool _dark = false;
  bool _showOverview = false;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _dark = prefs.getBool(_themeKey) ?? false;
      _showOverview = !(prefs.getBool(_overviewSeenKey) ?? false);
      _ready = true;
    });
  }

  Future<void> _setDark(bool value) async {
    setState(() => _dark = value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, value);
  }

  Future<void> _finishOverview() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_overviewSeenKey, true);
    setState(() => _showOverview = false);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Daily Energy Management',
      themeMode: _dark ? ThemeMode.dark : ThemeMode.light,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      home: !_ready
          ? const Scaffold(body: Center(child: CircularProgressIndicator()))
          : _showOverview
              ? AppOverviewScreen(
                  fromFirstLaunch: true,
                  onContinue: _finishOverview,
                )
              : HomeShell(dark: _dark, onTheme: _setDark),
    );
  }
}
