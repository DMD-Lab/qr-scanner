import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../../../scanner/domain/models/scan_result.dart';
import '../../../scanner/domain/models/qr_type.dart';

// ---------------------------------------------------------------------------
// Database
// ---------------------------------------------------------------------------

final _dbProvider = FutureProvider<Database>((ref) async {
  final dbPath = await getDatabasesPath();
  return openDatabase(
    join(dbPath, 'qrscanner.db'),
    version: 1,
    onCreate: (db, _) => db.execute('''
      CREATE TABLE scans (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        raw TEXT NOT NULL,
        type TEXT NOT NULL,
        scanned_at INTEGER NOT NULL
      )
    '''),
  );
});

// ---------------------------------------------------------------------------
// History notifier
// ---------------------------------------------------------------------------

class HistoryNotifier extends AsyncNotifier<List<ScanResult>> {
  @override
  Future<List<ScanResult>> build() async {
    final db = await ref.watch(_dbProvider.future);
    final rows = await db.query('scans', orderBy: 'scanned_at DESC');
    return rows.map(ScanResult.fromMap).toList();
  }

  Future<void> add(String raw) async {
    final db = await ref.read(_dbProvider.future);
    await db.insert('scans', {
      'raw': raw,
      'type': QrType.detect(raw).name,
      'scanned_at': DateTime.now().millisecondsSinceEpoch,
    });
    ref.invalidateSelf();
  }

  Future<void> delete(int id) async {
    final db = await ref.read(_dbProvider.future);
    await db.delete('scans', where: 'id = ?', whereArgs: [id]);
    ref.invalidateSelf();
  }

  Future<void> clearAll() async {
    final db = await ref.read(_dbProvider.future);
    await db.delete('scans');
    ref.invalidateSelf();
  }
}

final historyProvider = AsyncNotifierProvider<HistoryNotifier, List<ScanResult>>(
  HistoryNotifier.new,
);
