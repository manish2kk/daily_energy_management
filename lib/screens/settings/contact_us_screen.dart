import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ContactUsScreen extends StatelessWidget {
  const ContactUsScreen({super.key});

  static const _email = 'support@dailyenergymanagement.com';

  Future<void> _copyEmail(BuildContext context) async {
    await Clipboard.setData(const ClipboardData(text: _email));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Email copied')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Contact us')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            'We’d love to hear from you',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Questions, feedback, or ideas for Daily Energy Management? '
            'Reach out and we’ll get back to you.',
          ),
          const SizedBox(height: 24),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.mail_outline),
            title: const Text('Email'),
            subtitle: const Text(_email),
            trailing: IconButton(
              tooltip: 'Copy email',
              onPressed: () => _copyEmail(context),
              icon: const Icon(Icons.copy),
            ),
          ),
        ],
      ),
    );
  }
}
