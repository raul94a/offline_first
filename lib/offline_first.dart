library offline_first;


export 'package:floor/floor.dart';
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
