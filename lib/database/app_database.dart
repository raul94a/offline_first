import 'package:floor/floor.dart';
import 'package:offline_first/database/models/sync_entity.dart';
import 'package:offline_first/database/sync_database.dart';

import 'package:sqflite/sqflite.dart' as sqflite;
import 'dart:async';
part 'app_database.g.dart';

@Database(version: 1, entities: [SyncEntity])
abstract class AppDatabase extends SyncDatabase {
  @override
  SDao get sDao;
}
