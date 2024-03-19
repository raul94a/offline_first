import 'dart:convert';

import 'package:floor/floor.dart';
import 'package:offline_first/database/models/syn_model.dart';
import 'package:offline_first/database/models/sync_entity.dart';

abstract class SyncDatabase extends FloorDatabase {
  SDao get sDao;
}

@dao
abstract class SDao {
  @Query('SELECT * FROM SyncEntity')
  Future<List<SyncEntity>> getAll();
  @Query('DELETE FROM SyncEntity where id = :id')
  Future<void> deleteSyncEntity(int id);
  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insertSyncEntity(SyncEntity entity);
}

