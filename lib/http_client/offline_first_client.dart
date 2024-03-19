// ignore_for_file: unused_local_variable

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:offline_first/connectivity/connectivity.dart';
import 'package:offline_first/database/models/sync_entity.dart';
import 'package:offline_first/synchronizer/synchronizer.dart';

abstract class OfflineFirstClient<SyncStrategyT extends Enum> {
  Future<http.Response> get(String endpoint,
      {Map<String, String>? headers, Interceptor? interceptor}) async {
    await interceptor?.run();

    final response = http.get(Uri.parse(endpoint), headers: headers);
    return response;
  }

  Future<http.Response?> post(String endpoint,
      {Map<String, String>? headers,
      String? body,
      Encoding? encoding,
      SyncStrategyT? syncStrategy,
      required String table,
      Interceptor? interceptor}) async {
    if (!await Connectivity.instance.isConnected()) {
      // handle sync
      final syncEntity = SyncEntity(
        endpoint: endpoint,
        table: table,
        body: body,
        method: 'POST',
        headers: jsonEncode(headers),
      );

      final sync = Synchronizer.instance;
      sync.database.sDao.insertSyncEntity(syncEntity);
      return null;
    }
    await interceptor?.run();

    final response = http.post(Uri.parse(endpoint),
        headers: headers, encoding: encoding, body: body);
    return response;
  }

  Future<http.Response?> put(String endpoint,
      {Map<String, String>? headers,
      String? body,
      Encoding? encoding,
      required String table,
      SyncStrategyT? syncStrategy,
      Interceptor? interceptor}) async {
    if (!await Connectivity.instance.isConnected()) {
      // handle sync
      final syncEntity = SyncEntity(
        endpoint: endpoint,
        table: table,
        body: body,
        method: 'PUT',
        headers: jsonEncode(headers),
      );

      final sync = Synchronizer.instance;
      sync.database.sDao.insertSyncEntity(syncEntity);
      return null;
    }
    await interceptor?.run();

    final response = http.put(Uri.parse(endpoint),
        headers: headers, encoding: encoding, body: body);

    return response;
  }

  Future<http.Response?> delete(String endpoint,
      {Map<String, String>? headers,
      String? body,
      SyncStrategyT? syncStrategy,
      Encoding? encoding,
      required String table,
      Interceptor? interceptor}) async {
    if (!await Connectivity.instance.isConnected()) {
      // handle sync
      final syncEntity = SyncEntity(
        endpoint: endpoint,
        body: body,
        headers: jsonEncode(headers),
        method: 'DELETE',
        table: table,
      );

      final sync = Synchronizer.instance;
      // sync.database..insertSyncEntity(syncEntity);
      return null;
    }
    await interceptor?.run();

    final response = http.delete(Uri.parse(endpoint),
        headers: headers, encoding: encoding, body: body);
    return response;
  }

  Future<http.Response?> patch(String endpoint,
      {Map<String, String>? headers,
      String? body,
      Encoding? encoding,
      SyncStrategyT? syncStrategy,
      required String table,
      Interceptor? interceptor}) async {
    if (!await Connectivity.instance.isConnected()) {
      // handle sync
      final syncEntity = SyncEntity(
          endpoint: endpoint,
          body: body,
          method: 'PATCH',
          table: table,
          headers: jsonEncode(headers));

      final sync = Synchronizer.instance;
      sync.database.sDao.insertSyncEntity(syncEntity);
      return null;
    }
    await interceptor?.run();

    final response = http.patch(Uri.parse(endpoint),
        headers: headers, encoding: encoding, body: body);
    return response;
  }
}

abstract class Interceptor {
  List<InterceptorMiddleware> middlewares = [];

  Future<dynamic> run() async {
    final copyFn = [...middlewares].reversed.toList();
    while (copyFn.isNotEmpty) {
      final interceptor = copyFn.removeAt(0);
      try {
        await interceptor.fn();
      } catch (_) {
        if (interceptor.cancelOnError) rethrow;
      }
    }
  }
}

class InterceptorMiddleware {
  final Function fn;
  final bool cancelOnError;

  const InterceptorMiddleware({required this.fn, this.cancelOnError = true});
}
