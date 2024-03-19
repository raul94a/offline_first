import 'package:example/data/models/entities/user_entity.dart';
import 'package:example/data/source/local/user_dao.dart';
import 'package:offline_first/offline_first.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
// ignore: depend_on_referenced_packages
import 'package:floor/floor.dart';
import 'dart:async';
part 'app_database.g.dart';

@Database(version: 1, entities: [SyncEntity, UserEntity])
abstract class AppDatabase extends SyncDatabase {
  @override
  SDao get sDao;
  UserDao get userDao;
}
