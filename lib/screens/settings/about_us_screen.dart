import 'package:flutter/material.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About us')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            'Daily Energy Management',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Daily Energy Management helps you notice how daily choices charge or '
            'drain your energy. Mark charging activities (exercise, create, '
            'communicate) and discharging ones, then watch your streak and '
            'energy graph grow.',
          ),
          const SizedBox(height: 20),
          Text(
            'Our goal',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Give you a clear sense of achievement and fulfillment by making '
            'good days visible — and honest about the hard ones.',
          ),
        ],
      ),
    );
  }
}
