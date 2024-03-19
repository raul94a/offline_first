import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart' as cp;
import 'package:flutter/widgets.dart';
import 'package:path/path.dart' as path;
import 'package:flutter_test/flutter_test.dart';

import 'package:http/testing.dart';
import 'package:offline_first/offline_first.dart';
import 'package:offline_first/database/models/sync_entity.dart';
import 'package:offline_first/synchronizer/synchronizer.dart';
import 'package:sqlite3/open.dart';
import 'package:sqlite3/sqlite3.dart';

DynamicLibrary _openOnWindows() {
  final scriptDir = File('sqlite3.dll');
  print(scriptDir.absolute.path);

  return DynamicLibrary.open(scriptDir.path);
}

extension SyncDao on Database {
  Future<List<SyncEntity>> getAll() async {
    final rows = select('SELECT * FROM sync').rows;
    print('ROWS: $rows');
    final data = rows.map((e) => SyncEntity(
        id: e.first as int,
        endpoint: e[1] as String,
        body: e[2] as String,
        method: e[4] as String,
        strategy: SyncStrategy.post));
    return data.toList();
  }

  Future<void> delete(SyncEntity entity) async {
    print('Deleting entity: $entity');
    if (entity.id == null) return;
    execute('delete from sync where id = ${entity.id}');
  }

  Future<void> save(SyncEntity entity) async {
    var SyncEntity(:endpoint, :method, :body, :strategy) = entity;
    execute(
        "INSERT INTO sync(endpoint, method, body) VALUES ('$endpoint', '$method', '$body')");
  }
}

class SynchronizerTest implements ISynchronizer {
  SynchronizerTest._();

  static SynchronizerTest? _instance;
  static SynchronizerTest get instance => _instance ??= SynchronizerTest._();

  static Database? _database;
  static const String _syncTable = 'sync';
  StreamSubscription<cp.ConnectivityResult>? _internetStatusSubscription;
  final StreamController<Object> _controller =
      StreamController.broadcast(sync: true);
  Timer? timer;
  Stream<Object> getSyncResponseStream() => _controller.stream;
  bool _syncHandlerStarted = false;
  bool _syncStarted = false;
  bool _internetAvailable = false;

  @override
  Future<void> initDB() async {
    open.overrideFor(OperatingSystem.windows, () => _openOnWindows());
    try {
      final db = sqlite3.openInMemory();
      db.execute('''CREATE TABLE sync (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    endpoint TEXT,
    body BLOB,
    headers BLOB,
    method varchar(255),
    strategy TEXT
);''');
      await Future.delayed(const Duration(seconds: 3));
      _database = db;
    } catch (e) {
      print(e);
    }
  }

  @override
  void syncHandler() {
    Stream.value(0).listen(_onConnectivityResultEvent);
  }

  Future<void> _onConnectivityResultEvent(dynamic event) async {
    print('Connectivity event: $event');

    _internetAvailable = true;
    if (_syncStarted) {
      return;
    }

    await _onStartSync();

    _createTimer();
  }

  Future<void> _onStartSync() async {
    try {
      _syncStarted = true;
      await _processSyncEntities();
      print('Finish processing sync entities in main proccess');
    } catch (e) {
      if (e is SocketException) {
        _internetAvailable = false;
      }
    } finally {
      _syncStarted = false;
    }
  }

  void _createTimer() {
    timer?.cancel();

    timer = Timer.periodic(const Duration(seconds: 15), (timer) async {
      print('Calling timer periodic callback with syncStarted $_syncStarted');
      if (_syncStarted) return;
      await _onStartSync();
    });
  }

  Future<void> _processSyncEntities() async {
    final entities = await database.getAll();
    print('Number of entities: ${entities.length}');
    for (final entity in entities) {
      if (!_internetAvailable) {
        throw const SocketException('No internet');
      }
      final client = MockClient((req) async {
        final response = Response('', 201);
        return response;
      });

      switch (entity.method) {
        case "POST":
          final response = await client.post(Uri.parse(entity.endpoint),
              body: entity.body, headers: entity.headers);
          final statusCode = response.statusCode;
          print('PROCESSIGN POST $entity');
          if (statusCode >= 200 && statusCode < 300) {
            _handleCorrectSyncResponse(entity);
          } else {
            // Should throw?
            throw Exception;
          }
          break;
        case "PUT":
          final response = await client.put(Uri.parse(entity.endpoint),
              body: entity.body, headers: entity.headers);
          final statusCode = response.statusCode;
          if (statusCode >= 200 && statusCode < 300) {
            _handleCorrectSyncResponse(entity);
          } else {
            // Should throw?
            throw Exception;
          }
          break;
        case "PATCH":
          final response = await client.patch(Uri.parse(entity.endpoint),
              body: entity.body, headers: entity.headers);
          final statusCode = response.statusCode;
          if (statusCode >= 200 && statusCode < 300) {
            _handleCorrectSyncResponse(entity);
          } else {
            // Should throw?
            throw Exception;
          }
          break;
        case "DELETE":
          final response = await client.delete(Uri.parse(entity.endpoint),
              body: entity.body, headers: entity.headers);
          final statusCode = response.statusCode;
          if (statusCode >= 200 && statusCode < 300) {
            _handleCorrectSyncResponse(entity);
          } else {
            // Should throw?
            throw Exception;
          }
          break;
      }
    }
  }

  void _handleCorrectSyncResponse(SyncEntity entity) {
    print('Deleting sync entity: $entity');
    database.delete(entity);
    // Must create the SyncResponse Object

    // Add event to the Stream
    _controller.add(Object());
  }

  void dispose() {
    _internetStatusSubscription?.cancel();
    _controller.close();
    timer?.cancel();
  }

  Database get database {
    assert(_database != null, 'You have to wait until database is opened');
    if (!_syncHandlerStarted) {
      syncHandler();
      _syncHandlerStarted = true;
    }
    return _database!;
  }
}

void main() async {
  final SynchronizerTest synchroTest = SynchronizerTest.instance;

  group('Synchronization test', () {
    test('Database opening', () async {
      var database = SynchronizerTest._database;
      expect(database, null);
      await synchroTest.initDB();
      database = synchroTest.database;
      expect(database, isNot(null));
      expect(database.select('select * from sync').rows.length, equals(0));
      synchroTest._internetStatusSubscription?.onData((data) {
        print('Result: $data');
      });

      final enty = SyncEntity(
          endpoint: 'MYENDPOINTSUPERWAY',
          method: 'POST',
          body: jsonEncode({'name': 'raul'}),
          strategy: SyncStrategy.post);

      await database.save(enty);
      var data = database.select('select * from sync');
      expect(data.rows.length, equals(1));
      await synchroTest._onConnectivityResultEvent(null);
      data = database.select('select * from sync');
      expect(data.rows.length, equals(1));
    });
  });
}
