import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class AppDb {
  static late Database db;

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

  static Future<int> _nextSortOrder(String start, String end) async {
    final result = await db.rawQuery(
      'SELECT MAX(sort_order) as m FROM activities WHERE date>=? AND date<?',
      [start, end],
    );
    final max = result.first['m'] as int?;
    return (max ?? -1) + 1;
  }

  static Future<void> seedDefaults(List<(String, String)> defaults) async {
    final today = DateTime.now();
    final start = DateTime(today.year, today.month, today.day).toIso8601String();
    final end = DateTime(today.year, today.month, today.day + 1).toIso8601String();
    final existing = await db.query(
      'activities',
      where: 'date>=? AND date<?',
      whereArgs: [start, end],
      limit: 1,
    );
    // Only seed when today is empty — never re-add after rename/delete.
    if (existing.isNotEmpty) return;
    for (final d in defaults) {
      await add(d.$1, d.$2);
    }
  }

  static Future<void> add(String title, String category) async {
    final n = DateTime.now();
    final start = DateTime(n.year, n.month, n.day).toIso8601String();
    final end = DateTime(n.year, n.month, n.day + 1).toIso8601String();
    await db.insert('activities', {
      'title': title,
      'category': category,
      'completed': 0,
      'date': DateTime.now().toIso8601String(),
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

  static Future<List<Map<String, Object?>>> today() async {
    final n = DateTime.now();
    // Copy into a growable list — sqflite returns a read-only QueryResultSet.
    return List<Map<String, Object?>>.from(
      await db.query(
        'activities',
        where: 'date>=? AND date<?',
        whereArgs: [
          DateTime(n.year, n.month, n.day).toIso8601String(),
          DateTime(n.year, n.month, n.day + 1).toIso8601String(),
        ],
        orderBy: 'completed ASC, sort_order ASC, id ASC',
      ),
    );
  }

  static Future<List<Map<String, Object?>>> allCompleted() async =>
      List<Map<String, Object?>>.from(
        await db.query('activities', where: 'completed=1', orderBy: 'date'),
      );
}
