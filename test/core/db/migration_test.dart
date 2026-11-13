import 'package:flutter_test/flutter_test.dart';
import 'package:openhiit/core/db/migrations/migration_runner.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

Future<List<String>> _columns(Database db, String table) async {
  final rows = await db.rawQuery("PRAGMA table_info($table);");
  return rows.map((r) => r['name'] as String).toList();
}

void main() {
  sqfliteFfiInit();

  late Database db;

  setUp(() async {
    db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
  });

  tearDown(() async {
    await db.close();
  });

  test('upgrade 9 -> 10 adds workTimes and keeps existing timers', () async {
    // TimerTable as it existed at database version 9.
    await db.execute('''
      CREATE TABLE TimerTable(
        id TEXT PRIMARY KEY, name TEXT, timerIndex INTEGER,
        totalTime INTEGER, intervals INTEGER, activeIntervals INTEGER,
        activities TEXT, showMinutes INTEGER, color INTEGER
      )
    ''');
    await db.insert('TimerTable', {'id': 't1', 'name': 'Old timer'});

    await runMigrations(db, 9, 10);

    expect(await _columns(db, 'TimerTable'), contains('workTimes'));
    final rows = await db.query('TimerTable');
    expect(rows.single['name'], 'Old timer');
    expect(rows.single['workTimes'], isNull);
  });

  test('upgrade from a version without the new tables does not fail',
      () async {
    await runMigrations(db, 4, 10);

    expect(await _columns(db, 'TimerTable'), contains('workTimes'));
    expect(await _columns(db, 'TimeSettingsTable'), contains('skipWarmupRest'));
    expect(await _columns(db, 'SoundSettingsTable'), contains('breakSound'));
  });

  test('running a migration twice is harmless', () async {
    await runMigrations(db, 4, 10);
    await runMigrations(db, 9, 10);

    expect(
      (await _columns(db, 'TimerTable')).where((c) => c == 'workTimes'),
      hasLength(1),
    );
  });
}
