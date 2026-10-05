import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'downloaded_file_dao.dart';
import 'transfer_dao.dart';

class AppDatabase {
  AppDatabase._(this._database)
      : transferDao = TransferDaoImpl(_database),
        downloadedFileDao = DownloadedFileDaoImpl(_database);

  final Database _database;
  final TransferDao transferDao;
  final DownloadedFileDao downloadedFileDao;

  static const String databaseName = 'laan_pos_transfers.db';
  static const int databaseVersion = 2;

  static Future<AppDatabase> create({String? customPath}) async {
    final path = customPath ?? join(await getDatabasesPath(), databaseName);

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
            completedAt INTEGER,
            fileId INTEGER
          )
        ''');

        await db.execute('''
          CREATE INDEX idx_transfers_status ON transfers (status)
        ''');

        await db.execute('''
          CREATE INDEX idx_transfers_created_at ON transfers (createdAt DESC)
        ''');

        await db.execute('''
          CREATE TABLE downloaded_files (
            fileId INTEGER PRIMARY KEY,
            fileName TEXT NOT NULL,
            originalName TEXT NOT NULL,
            localPath TEXT NOT NULL,
            fileSize INTEGER NOT NULL,
            fileType TEXT,
            downloadedAt INTEGER NOT NULL
          )
        ''');

        await db.execute('''
          CREATE INDEX idx_downloaded_files_name ON downloaded_files (fileName)
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          try {
            await db.execute('ALTER TABLE transfers ADD COLUMN fileId INTEGER');
          } catch (_) {}

          await db.execute('''
            CREATE TABLE IF NOT EXISTS downloaded_files (
              fileId INTEGER PRIMARY KEY,
              fileName TEXT NOT NULL,
              originalName TEXT NOT NULL,
              localPath TEXT NOT NULL,
              fileSize INTEGER NOT NULL,
              fileType TEXT,
              downloadedAt INTEGER NOT NULL
            )
          ''');

          await db.execute('''
            CREATE INDEX IF NOT EXISTS idx_downloaded_files_name ON downloaded_files (fileName)
          ''');
        }
      },
    );

    return AppDatabase._(db);
  }

  Future<void> close() => _database.close();
}
