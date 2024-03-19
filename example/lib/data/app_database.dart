
import 'package:offline_first/offline_first.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:floor/floor.dart';
import 'dart:async';
part 'app_database.g.dart';

@Database(version: 1, entities: [SyncEntity])
abstract class AppDatabase extends SyncDatabase {
  @override
  SDao get sDao;
}
