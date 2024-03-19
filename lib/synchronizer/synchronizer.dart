// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart' as cp;
import 'package:http/http.dart';
import 'package:offline_first/database/sync_database.dart';
import 'package:offline_first/database/models/sync_entity.dart';
import 'package:sqflite/sqflite.dart';

extension SyncDao on Database {
  Future<void> insertSyncEntity(SyncEntity entity) async {
    await database.insert(Synchronizer._syncTable, entity.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> deleteSyncEntity(SyncEntity entity) async {
    if (entity.id == null) return;
    await database.delete(Synchronizer._syncTable,
        where: 'id = ?', whereArgs: [entity.id!]);
  }

  Future<List<SyncEntity>> getAll() async {
    final result = await database.query(Synchronizer._syncTable);
    print('RESULST: $result');
    return result.map((e) => SyncEntity.fromMap(e)).toList();
  }
}

abstract interface class ISynchronizer {
  void syncHandler();
  void initDB(SyncDatabase database);

  String? token;
  String? authHeader;
}

class Synchronizer implements ISynchronizer {
  Synchronizer._();

  static Synchronizer? _instance;
  static Synchronizer get instance => _instance ??= Synchronizer._();

  static SyncDatabase? _database;
  static const String _syncTable = 'sync';
  StreamSubscription<cp.ConnectivityResult>? _internetStatusSubscription;
  final StreamController<SyncResponse> _controller =
      StreamController.broadcast(sync: true);
  Timer? timer;
  Stream<SyncResponse> getSyncResponseStream() => _controller.stream;
  bool _syncHandlerStarted = false;
  bool _syncStarted = false;
  bool _internetAvailable = false;
  @override
  String? token;
  @override
  String? authHeader;

  @override
  void syncHandler() {
    _internetStatusSubscription = cp.Connectivity()
        .onConnectivityChanged
        .listen(_onConnectivityResultEvent);
  }

// TODO: Maybe it can receive a Configuration Object for the database
  // This configuration object may be for deletion policy of SyncEntities
  // deleteInFailed
  // allowedStatusCodes
  //

  @override
  void initDB(SyncDatabase db) {
    _database = db;
  }

  Future<void> _onConnectivityResultEvent(cp.ConnectivityResult event) async {
    print('Connectivity event: $event');
    switch (event) {
      case cp.ConnectivityResult.bluetooth:
      case cp.ConnectivityResult.none:
      case cp.ConnectivityResult.other:
        _syncStarted = false;
        _internetAvailable = false;
        timer?.cancel();
        break;
      case cp.ConnectivityResult.vpn:
      case cp.ConnectivityResult.wifi:
      case cp.ConnectivityResult.ethernet:
      case cp.ConnectivityResult.mobile:
        _internetAvailable = true;
        if (_syncStarted) {
          return;
        }

        await _onStartSync();

        _createTimer();
    }
  }

  Future<void> _onStartSync() async {
    try {
      _syncStarted = true;
      await _processSyncEntities();
      print('Finish processing sync entities in main proccess');
    } catch (e) {
      print(e);
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
    final entities = await database.sDao.getAll();
    print(
        'Getting ${entities.length} entities with availability $_internetAvailable');
    for (final entity in entities) {
      if (!_internetAvailable) {
        throw const SocketException('No internet');
      }
      final headers = entity.headersMap;
      if (authHeader != null && token != null) {
        headers?.addAll({
          authHeader!: token!,
        });
      }
      switch (entity.method) {
        case "POST":
          final response = await post(Uri.parse(entity.endpoint),
              body: entity.body, headers: entity.headersMap);
          final statusCode = response.statusCode;
          final syncResponse =
              SyncResponse(syncEntity: entity, serverResponse: response.body);
          if (statusCode >= 200 && statusCode < 300) {
            _handleCorrectSyncResponse(syncResponse);
          } else {
            // Should throw?
            throw Exception;
          }
          break;
        case "PUT":
          final response = await put(Uri.parse(entity.endpoint),
              body: entity.body, headers: entity.headersMap);
          final statusCode = response.statusCode;
          final syncResponse =
              SyncResponse(syncEntity: entity, serverResponse: response.body);
          if (statusCode >= 200 && statusCode < 300) {
            _handleCorrectSyncResponse(syncResponse);
          } else {
            // Should throw?
            throw Exception;
          }
          break;
        case "PATCH":
          final response = await patch(Uri.parse(entity.endpoint),
              body: entity.body, headers: entity.headersMap);
          final statusCode = response.statusCode;
          final syncResponse =
              SyncResponse(syncEntity: entity, serverResponse: response.body);
          if (statusCode >= 200 && statusCode < 300) {
            _handleCorrectSyncResponse(syncResponse);
          } else {
            // Should throw?
            throw Exception;
          }
          break;
        case "DELETE":
          final response = await delete(Uri.parse(entity.endpoint),
              body: entity.body, headers: entity.headersMap);
          final statusCode = response.statusCode;
          final syncResponse =
              SyncResponse(syncEntity: entity, serverResponse: response.body);
          if (statusCode >= 200 && statusCode < 300) {
            _handleCorrectSyncResponse(syncResponse);
          } else {
            // Should throw?
            throw Exception;
          }
          break;
      }
    }
  }

  void _handleCorrectSyncResponse(SyncResponse response) {
    database.sDao.deleteSyncEntity(response.syncEntity.id!);
    // Must create the SyncResponse Object

    // Add event to the Stream
    _controller.add(response);
  }

  void dispose() {
    _internetStatusSubscription?.cancel();
    _controller.close();
    timer?.cancel();
  }

  SyncDatabase get database {
    assert(_database != null, 'You have to wait until database is opened');
    if (!_syncHandlerStarted) {
      syncHandler();
      _syncHandlerStarted = true;
    }
    return _database!;
  }
}

class SyncResponse {
  final SyncEntity syncEntity;
  final String? serverResponse;
  const SyncResponse({
    required this.syncEntity,
    this.serverResponse,
  });

  SyncResponse copyWith({
    SyncEntity? syncEntity,
    String? serverResponse,
  }) {
    return SyncResponse(
      syncEntity: syncEntity ?? this.syncEntity,
      serverResponse: serverResponse ?? this.serverResponse,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'syncEntity': syncEntity.toMap(),
      'serverResponse': serverResponse,
    };
  }

  @override
  String toString() =>
      'SyncResponse(syncEntity: $syncEntity, serverResponse: $serverResponse)';

  @override
  bool operator ==(covariant SyncResponse other) {
    if (identical(this, other)) return true;

    return other.syncEntity == syncEntity &&
        other.serverResponse == serverResponse;
  }

  @override
  int get hashCode => syncEntity.hashCode ^ serverResponse.hashCode;
}
