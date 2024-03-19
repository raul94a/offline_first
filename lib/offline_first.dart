library offline_first;


export 'package:floor/src/adapter/deletion_adapter.dart';
export 'package:floor/src/adapter/insertion_adapter.dart';
export 'package:floor/src/adapter/migration_adapter.dart';
export 'package:floor/src/adapter/query_adapter.dart';
export 'package:floor/src/adapter/update_adapter.dart';
export 'package:floor/src/callback.dart';
export 'package:floor/src/database.dart';
export 'package:floor/src/migration.dart';
export 'package:floor/src/sqflite_database_factory.dart';
export 'package:floor_annotation/floor_annotation.dart';
export './connectivity/connectivity.dart';
export './database/sync_database.dart';
export './database/models/syn_model.dart';
export './database/models/sync_entity.dart';
export './http_client/offline_first_client.dart';
export './synchronizer/sync_strategy.dart';
export './synchronizer/synchronizer.dart';

/// A Calculator.
class Calculator {
  /// Returns [value] plus 1.
  int addOne(int value) => value + 1;
}
