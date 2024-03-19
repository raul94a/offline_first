import 'package:flutter/material.dart';
import 'package:offline_first/database/app_database.dart';
import 'package:offline_first/database/sync_database.dart';
import 'package:offline_first/synchronizer/synchronizer.dart';

Future<void> main(List<String> args) async {
  final database = await $FloorAppDatabase.databaseBuilder('sync.db').build();
  runApp(TestWidget(database: database));
}

class SyncInitializer extends StatefulWidget {
  const SyncInitializer(
      {super.key, required this.database, required this.child});
  final SyncDatabase database;
  final Widget child;

  @override
  State<SyncInitializer> createState() => _SyncInitializerState();
}

class _SyncInitializerState extends State<SyncInitializer> {
  late Future<void> future;
  late Synchronizer sync;

  @override
  void initState() {
    super.initState();
    sync = Synchronizer.instance;
    sync.initDB(widget.database);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: future,
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SizedBox.shrink();
          }
          return widget.child;
        });
  }
}

class TestWidget extends StatefulWidget {
  const TestWidget({super.key, required this.database});
  final SyncDatabase database;
  @override
  State<TestWidget> createState() => _TestWidgetState();
}

class _TestWidgetState extends State<TestWidget> {
  @override
  Widget build(BuildContext context) {
    return SyncInitializer(
      database: widget.database,
      child: MaterialApp(
          home: Scaffold(
        appBar: AppBar(
          title: Text('Offline First example'),
        ),
        body: Column(
          children: [],
        ),
      )),
    );
  }
}
