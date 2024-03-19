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

  UserDao? _userDaoInstance;

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
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `users` (`name` TEXT NOT NULL, `email` TEXT NOT NULL, `dni` TEXT NOT NULL, `entityId` INTEGER PRIMARY KEY AUTOINCREMENT, `table` TEXT NOT NULL)');

        await callback?.onCreate?.call(database, version);
      },
    );
    return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
  }

  @override
  SDao get sDao {
    return _sDaoInstance ??= _$SDao(database, changeListener);
  }

  @override
  UserDao get userDao {
    return _userDaoInstance ??= _$UserDao(database, changeListener);
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

class _$UserDao extends UserDao {
  _$UserDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database, changeListener),
        _userEntityInsertionAdapter = InsertionAdapter(
            database,
            'users',
            (UserEntity item) => <String, Object?>{
                  'name': item.name,
                  'email': item.email,
                  'dni': item.dni,
                  'entityId': item.entityId,
                  'table': item.table
                },
            changeListener);

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<UserEntity> _userEntityInsertionAdapter;

  @override
  Stream<List<UserEntity>> getAllStream() {
    return _queryAdapter.queryListStream('SELECT * FROM users',
        mapper: (Map<String, Object?> row) => UserEntity(
            table: row['table'] as String,
            dni: row['dni'] as String,
            name: row['name'] as String,
            email: row['email'] as String),
        queryableName: 'users',
        isView: false);
  }

  @override
  Future<void> saveMany(List<UserEntity> users) async {
    await _userEntityInsertionAdapter.insertList(
        users, OnConflictStrategy.abort);
  }

  @override
  Future<void> saveOne(UserEntity user) async {
    await _userEntityInsertionAdapter.insert(user, OnConflictStrategy.abort);
  }
}
