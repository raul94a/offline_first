import 'dart:convert';

import 'package:floor/floor.dart';

// ignore_for_file: public_member_api_docs, sort_constructors_first

abstract class SyncModel {
  @PrimaryKey(autoGenerate: true)
  final int? entityId;
  final String table;
  const SyncModel({this.entityId, required this.table});
}

class UserModel extends SyncModel {
  final String? id;
  final int age;
  final String name;
  final String email;

  const UserModel({
    required super.entityId,
    this.id,
    super.table = 'users',
    required this.age,
    required this.name,
    required this.email,
  });

  UserModel copyWith({
    int? entityId,
    String? id,
    int? age,
    String? name,
    String? email,
  }) {
    return UserModel(
      entityId: entityId ?? this.entityId,
      id: id ?? this.id,
      age: age ?? this.age,
      name: name ?? this.name,
      email: email ?? this.email,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'age': age,
      'name': name,
      'email': email,
      'entityId': entityId
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
        id: (map["id"] ?? '') as String,
        age: (map["age"] ?? 0) as int,
        name: (map["name"] ?? '') as String,
        email: (map["email"] ?? '') as String,
        entityId: map['entityId']);
  }

  String toJson() => json.encode(toMap());

  factory UserModel.fromJson(String source) =>
      UserModel.fromMap(json.decode(source) as Map<String, dynamic>);
}

const usersTable = '''
CREATE TABLE users(entityId INTEGER primary key autoincrement,
                   id INTEGER,
                   age INTEGER,
                   name VARCHAR(255),
                   email VARCHAR(255)
);
''';

class SQLiteManager {
  SQLiteManager._();
  static SQLiteManager? _instance;
  static SQLiteManager get instance => _instance ??= SQLiteManager._();
}
