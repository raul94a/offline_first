import 'package:flutter/material.dart';
import 'package:offline_first/database/sync_database.dart';


@Database
class AppDatabase extends SyncDatabase {
  @override
  SDao get  sDao;
}
