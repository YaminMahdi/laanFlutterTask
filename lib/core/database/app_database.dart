import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'transfer_dao.dart';

class AppDatabase {
  AppDatabase._(this._database) : transferDao = TransferDaoImpl(_database);

  final Database _database;
  final TransferDao transferDao;

  static const String databaseName = 'laan_pos_transfers.db';
  static const int databaseVersion = 1;

  static Future<AppDatabase> create() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, databaseName);

    final db = await openDatabase(
      path,
      version: databaseVersion,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE transfers (
            id TEXT PRIMARY KEY,
            fileName TEXT NOT NULL,
            originalName TEXT NOT NULL,
            fileUrl TEXT,
            localPath TEXT,
            transferType TEXT NOT NULL,
            status TEXT NOT NULL,
            bytesTransferred INTEGER NOT NULL DEFAULT 0,
            totalBytes INTEGER NOT NULL DEFAULT 0,
            speedBytesPerSecond INTEGER NOT NULL DEFAULT 0,
            errorMessage TEXT,
            createdAt INTEGER NOT NULL,
            completedAt INTEGER
          )
        ''');

        await db.execute('''
          CREATE INDEX idx_transfers_status ON transfers (status)
        ''');

        await db.execute('''
          CREATE INDEX idx_transfers_created_at ON transfers (createdAt DESC)
        ''');
      },
    );

    return AppDatabase._(db);
  }

  Future<void> close() => _database.close();
}
