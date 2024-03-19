import 'package:example/data/app_database.dart';
import 'package:example/data/models/entities/user_entity.dart';
import 'package:flutter/material.dart';

late AppDatabase database;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final db = await $FloorAppDatabase.databaseBuilder('db.db').build();
  database = db;
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Stream<List<UserEntity>> strm;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    strm = database.userDao.getAllStream();
  }

  final cName = TextEditingController();
  final cDni = TextEditingController();
  final cEmail = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Offline first test'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: cName,
            ),
            TextField(
              controller: cDni,
            ),
            TextField(
              controller: cEmail,
            ),
            ElevatedButton(
                onPressed: () {
                  final name = cName.text;
                  final email = cEmail.text;
                  final dni = cDni.text;

                  final user = UserEntity(dni: dni, name: name, email: email);
                  database.userDao.saveOne(user);
                  cName.clear();
                  cDni.clear();
                  cEmail.clear();
                },
                child: Text('save')),
            StreamBuilder<List<UserEntity>>(
                stream: strm,
                builder: (ctx, snapshot) {
                  print(snapshot);
                  switch (snapshot.connectionState) {
                    case ConnectionState.none:
                    case ConnectionState.waiting:
                    case ConnectionState.done:
                      return const SizedBox();
                    case ConnectionState.active:
                      print(snapshot);
                      final data = snapshot.data ?? [];
                      return ListView.builder(
                          itemCount: data.length,
                          shrinkWrap: true,
                          primary: false,
                          itemBuilder: (ctx, i) {
                            final user = data[i];
                            return ListTile(
                              isThreeLine: true,
                              title: Text(user.name),
                              subtitle: Column(
                                children: [Text(user.dni), Text(user.email)],
                              ),
                            );
                          });
                  }
                })
          ],
        ),
      ),
    );
  }
}
