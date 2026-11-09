import 'package:openhiit/core/logs/logs.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

Future<void> migration5(Database db) async {} // no-op
Future<void> migration6(Database db) async {} // no-op
Future<void> migration7(Database db) async {} // no-op
Future<void> migration8(Database db) async {
  Log.debug(
    "Running migration 8: Adding breakSound column to SoundSettingsTable",
  );
  await addColumnIfMissing(db, "SoundSettingsTable", "breakSound", "TEXT");
}

Future<void> migration9(Database db) async {
  Log.debug(
    "Running migration 9: Adding skipWarmupRest column to TimeSettingsTable",
  );
  await addColumnIfMissing(
    db,
    "TimeSettingsTable",
    "skipWarmupRest",
    "INTEGER DEFAULT 0",
  );
}

Future<void> migration10(Database db) async {
  Log.debug(
    "Running migration 10: Adding workTimes column to TimerTable",
  );
  await addColumnIfMissing(db, "TimerTable", "workTimes", "TEXT");
}

/// Adds [column] to [table] unless the table doesn't exist yet (it is then
/// created with the column by the runner) or already has the column. Keeps
/// upgrades from any older database version from failing.
Future<void> addColumnIfMissing(
  Database db,
  String table,
  String column,
  String type,
) async {
  final columns = await db.rawQuery("PRAGMA table_info($table);");
  if (columns.isEmpty) return;
  if (columns.any((c) => c['name'] == column)) return;
  await db.execute("ALTER TABLE $table ADD COLUMN $column $type;");
}
