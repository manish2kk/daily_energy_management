import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class AppDb {
  static late Database db;

  static const _categoryOrder =
      "CASE category "
      "WHEN 'exercise' THEN 0 "
      "WHEN 'create' THEN 1 "
      "WHEN 'communicate' THEN 2 "
      "WHEN 'discharge' THEN 3 "
      "ELSE 4 END ASC, sort_order ASC, id ASC";

  static Future<void> init() async {
    db = await openDatabase(
      join(await getDatabasesPath(), 'energy_management.db'),
      version: 2,
      onCreate: (db, _) async {
        await db.execute(
          'CREATE TABLE activities('
          'id INTEGER PRIMARY KEY AUTOINCREMENT,'
          'title TEXT,'
          'category TEXT,'
          'completed INTEGER,'
          'date TEXT,'
          'sort_order INTEGER NOT NULL DEFAULT 0)',
        );
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute(
            'ALTER TABLE activities ADD COLUMN sort_order INTEGER NOT NULL DEFAULT 0',
          );
          final rows = await db.query('activities', orderBy: 'id');
          for (final row in rows) {
            await db.update(
              'activities',
              {'sort_order': row['id']},
              where: 'id=?',
              whereArgs: [row['id']],
            );
          }
        }
      },
    );
  }

  static (String, String) _dayBounds(DateTime day) {
    final start = DateTime(day.year, day.month, day.day);
    final end = start.add(const Duration(days: 1));
    return (start.toIso8601String(), end.toIso8601String());
  }

  static Future<int> _nextSortOrder(String start, String end) async {
    final result = await db.rawQuery(
      'SELECT MAX(sort_order) as m FROM activities WHERE date>=? AND date<?',
      [start, end],
    );
    final max = result.first['m'] as int?;
    return (max ?? -1) + 1;
  }

  static Future<void> ensureToday(List<(String, String)> defaults) async {
    final today = DateTime.now();
    final (startIso, endIso) = _dayBounds(today);

    final existing = await db.query(
      'activities',
      where: 'date>=? AND date<?',
      whereArgs: [startIso, endIso],
      limit: 1,
    );
    // Today already has a checklist — don't recreate it.
    if (existing.isNotEmpty) return;

    // Copy the most recent previous day's checklist forward.
    final previous = await db.rawQuery(
      'SELECT date FROM activities WHERE date<? ORDER BY date DESC LIMIT 1',
      [startIso],
    );

    if (previous.isEmpty) {
      for (final d in defaults) {
        await add(d.$1, d.$2, day: today);
      }
      return;
    }

    final prevDate = DateTime.parse(previous.first['date'] as String);
    final prevItems = await forDate(prevDate);

    var order = 0;
    for (final item in prevItems) {
      await db.insert('activities', {
        'title': item['title'],
        'category': item['category'],
        'completed': 0,
        'date': DateTime.now().toIso8601String(),
        'sort_order': item['sort_order'] ?? order,
      });
      order++;
    }
  }

  static Future<void> add(
    String title,
    String category, {
    DateTime? day,
  }) async {
    final d = day ?? DateTime.now();
    final (start, end) = _dayBounds(d);
    await db.insert('activities', {
      'title': title,
      'category': category,
      'completed': 0,
      'date': DateTime(d.year, d.month, d.day, DateTime.now().hour,
              DateTime.now().minute, DateTime.now().second)
          .toIso8601String(),
      'sort_order': await _nextSortOrder(start, end),
    });
  }

  static Future<void> updateItem(int id, String title, String category) =>
      db.update(
        'activities',
        {'title': title, 'category': category},
        where: 'id=?',
        whereArgs: [id],
      );

  static Future<void> toggle(int id, bool value) => db.update(
        'activities',
        {'completed': value ? 1 : 0},
        where: 'id=?',
        whereArgs: [id],
      );

  static Future<void> deleteItem(int id) =>
      db.delete('activities', where: 'id=?', whereArgs: [id]);

  static Future<void> reorder(List<int> orderedIds) async {
    final batch = db.batch();
    for (var i = 0; i < orderedIds.length; i++) {
      batch.update(
        'activities',
        {'sort_order': i},
        where: 'id=?',
        whereArgs: [orderedIds[i]],
      );
    }
    await batch.commit(noResult: true);
  }

  static Future<List<Map<String, Object?>>> forDate(DateTime day) async {
    final (start, end) = _dayBounds(day);
    return List<Map<String, Object?>>.from(
      await db.query(
        'activities',
        where: 'date>=? AND date<?',
        whereArgs: [start, end],
        orderBy: 'completed ASC, $_categoryOrder',
      ),
    );
  }

  static Future<DateTime?> earliestActivityDate() async {
    final rows = await db.rawQuery(
      'SELECT date FROM activities ORDER BY date ASC LIMIT 1',
    );
    if (rows.isEmpty) return null;
    return DateTime.parse(rows.first['date'] as String);
  }

  static Future<List<Map<String, Object?>>> allCompleted() async =>
      List<Map<String, Object?>>.from(
        await db.query('activities', where: 'completed=1', orderBy: 'date'),
      );
}
