// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// **************************************************************************
// FloorGenerator
// **************************************************************************

// ignore: avoid_classes_with_only_static_members
class $FloorAppDatabase {
  /// Creates a database builder for a persistent database.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static _$AppDatabaseBuilder databaseBuilder(String name) =>
      _$AppDatabaseBuilder(name);

  /// Creates a database builder for an in memory database.
  /// Information stored in an in memory database disappears when the process is killed.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static _$AppDatabaseBuilder inMemoryDatabaseBuilder() =>
      _$AppDatabaseBuilder(null);
}

class _$AppDatabaseBuilder {
  _$AppDatabaseBuilder(this.name);

  final String? name;

  final List<Migration> _migrations = [];

  Callback? _callback;

  /// Adds migrations to the builder.
  _$AppDatabaseBuilder addMigrations(List<Migration> migrations) {
    _migrations.addAll(migrations);
    return this;
  }

  /// Adds a database [Callback] to the builder.
  _$AppDatabaseBuilder addCallback(Callback callback) {
    _callback = callback;
    return this;
  }

  /// Creates the database and initializes it.
  Future<AppDatabase> build() async {
    final path = name != null
        ? await sqfliteDatabaseFactory.getDatabasePath(name!)
        : ':memory:';
    final database = _$AppDatabase();
    database.database = await database.open(
      path,
      _migrations,
      _callback,
    );
    return database;
  }
}

class _$AppDatabase extends AppDatabase {
  _$AppDatabase([StreamController<String>? listener]) {
    changeListener = listener ?? StreamController<String>.broadcast();
  }

  SDao? _sDaoInstance;

  Future<sqflite.Database> open(
    String path,
    List<Migration> migrations, [
    Callback? callback,
  ]) async {
    final databaseOptions = sqflite.OpenDatabaseOptions(
      version: 1,
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
        await callback?.onConfigure?.call(database);
      },
      onOpen: (database) async {
        await callback?.onOpen?.call(database);
      },
      onUpgrade: (database, startVersion, endVersion) async {
        await MigrationAdapter.runMigrations(
            database, startVersion, endVersion, migrations);

        await callback?.onUpgrade?.call(database, startVersion, endVersion);
      },
      onCreate: (database, version) async {
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `SyncEntity` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `endpoint` TEXT NOT NULL, `method` TEXT NOT NULL, `body` TEXT, `table` TEXT NOT NULL, `headers` TEXT)');

        await callback?.onCreate?.call(database, version);
      },
    );
    return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
  }

  @override
  SDao get sDao {
    return _sDaoInstance ??= _$SDao(database, changeListener);
  }
}

class _$SDao extends SDao {
  _$SDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _syncEntityInsertionAdapter = InsertionAdapter(
            database,
            'SyncEntity',
            (SyncEntity item) => <String, Object?>{
                  'id': item.id,
                  'endpoint': item.endpoint,
                  'method': item.method,
                  'body': item.body,
                  'table': item.table,
                  'headers': item.headers
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<SyncEntity> _syncEntityInsertionAdapter;

  @override
  Future<List<SyncEntity>> getAll() async {
    return _queryAdapter.queryList('SELECT * FROM SyncEntity',
        mapper: (Map<String, Object?> row) => SyncEntity(
            id: row['id'] as int?,
            endpoint: row['endpoint'] as String,
            method: row['method'] as String,
            table: row['table'] as String,
            body: row['body'] as String?,
            headers: row['headers'] as String?));
  }

  @override
  Future<void> deleteSyncEntity(int id) async {
    await _queryAdapter
        .queryNoReturn('DELETE FROM SyncEntity where id = ?1', arguments: [id]);
  }

  @override
  Future<void> insertSyncEntity(SyncEntity entity) async {
    await _syncEntityInsertionAdapter.insert(
        entity, OnConflictStrategy.replace);
  }
}
