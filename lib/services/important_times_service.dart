import 'package:geolocator/geolocator.dart';
import 'package:nrel_spa/nrel_spa.dart';

class ImportantTimes {
  final DateTime sunrise;
  final DateTime sunset;
  final DateTime brahmaMuhurtaStart;
  final DateTime brahmaMuhurtaEnd;
  final bool usedFallbackLocation;

  const ImportantTimes({
    required this.sunrise,
    required this.sunset,
    required this.brahmaMuhurtaStart,
    required this.brahmaMuhurtaEnd,
    required this.usedFallbackLocation,
  });
}

class ImportantTimesService {
  /// New Delhi — used when location is unavailable.
  static const fallbackLat = 28.6139;
  static const fallbackLng = 77.2090;

  static Future<ImportantTimes> load({DateTime? day}) async {
    final now = day ?? DateTime.now();
    final localDay = DateTime(now.year, now.month, now.day);
    final timezone = now.timeZoneOffset.inMinutes / 60.0;

    var lat = fallbackLat;
    var lng = fallbackLng;
    var usedFallback = true;

    try {
      final position = await _resolvePosition();
      if (position != null) {
        lat = position.latitude;
        lng = position.longitude;
        usedFallback = false;
      }
    } catch (_) {
      usedFallback = true;
    }

    // SPA expects a UTC timestamp; use noon UTC on the local calendar day.
    final spa = getSpa(
      DateTime.utc(localDay.year, localDay.month, localDay.day, 12),
      lat,
      lng,
      timezone,
    );

    final sunrise = _fromLocalHours(localDay, spa.sunrise);
    final sunset = _fromLocalHours(localDay, spa.sunset);
    // Brahma Muhurta: 1h 36m before sunrise until 48m before sunrise.
    final brahmaStart = sunrise.subtract(const Duration(hours: 1, minutes: 36));
    final brahmaEnd = sunrise.subtract(const Duration(minutes: 48));

    return ImportantTimes(
      sunrise: sunrise,
      sunset: sunset,
      brahmaMuhurtaStart: brahmaStart,
      brahmaMuhurtaEnd: brahmaEnd,
      usedFallbackLocation: usedFallback,
    );
  }

  static DateTime _fromLocalHours(DateTime day, double hours) {
    final totalMinutes = (hours * 60).round();
    final h = totalMinutes ~/ 60;
    final m = totalMinutes % 60;
    return DateTime(day.year, day.month, day.day, h, m);
  }

  static Future<Position?> _resolvePosition() async {
    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) return null;

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return null;
    }

    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.low,
        timeLimit: Duration(seconds: 8),
      ),
    );
  }
}
