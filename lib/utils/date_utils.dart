bool sameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

/// Sunday-based week start (Sunday = 0 … Saturday = 6).
DateTime startOfWeekSunday(DateTime d) {
  final day = dateOnly(d);
  return day.subtract(Duration(days: day.weekday % 7));
}

/// Day index in a Sunday-first week: Sun=0, Mon=1, … Sat=6.
int sundayFirstDayIndex(DateTime d) => dateOnly(d).weekday % 7;
