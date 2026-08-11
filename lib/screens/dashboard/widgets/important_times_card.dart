import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../services/important_times_service.dart';
import '../../../theme/app_colors.dart';

class ImportantTimesCard extends StatelessWidget {
  final ImportantTimes? times;
  final bool loading;

  const ImportantTimesCard({
    super.key,
    required this.times,
    required this.loading,
  });

  String _range(DateTime start, DateTime end) {
    final fmt = DateFormat.jm();
    return '${fmt.format(start)} – ${fmt.format(end)}';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Important times',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 6),
        const Text("Today's sunrise–sunset and Brahma Muhurta."),
        const SizedBox(height: 14),
        Card(
          color: AppColors.brand,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: loading
                ? const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  )
                : times == null
                    ? const ListTile(
                        leading: Icon(Icons.error_outline, color: Colors.white),
                        title: Text(
                          'Could not load times',
                          style: TextStyle(color: Colors.white),
                        ),
                      )
                    : Column(
                        children: [
                          ListTile(
                            leading: const Icon(
                              Icons.wb_sunny_outlined,
                              color: Colors.white,
                            ),
                            title: const Text(
                              'Sunrise – Sunset',
                              style: TextStyle(color: Colors.white),
                            ),
                            subtitle: Text(
                              _range(times!.sunrise, times!.sunset),
                              style: const TextStyle(color: Colors.white70),
                            ),
                          ),
                          const Divider(height: 1, color: Colors.white24),
                          ListTile(
                            leading: const Icon(
                              Icons.brightness_2_outlined,
                              color: Colors.white,
                            ),
                            title: const Text(
                              'Brahma Muhurta',
                              style: TextStyle(color: Colors.white),
                            ),
                            subtitle: Text(
                              _range(
                                times!.brahmaMuhurtaStart,
                                times!.brahmaMuhurtaEnd,
                              ),
                              style: const TextStyle(color: Colors.white70),
                            ),
                          ),
                          if (times!.usedFallbackLocation)
                            const Padding(
                              padding: EdgeInsets.fromLTRB(16, 0, 16, 12),
                              child: Text(
                                'Using New Delhi location. Enable location for local times.',
                                style: TextStyle(
                                  color: Colors.white60,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                        ],
                      ),
          ),
        ),
      ],
    );
  }
}
