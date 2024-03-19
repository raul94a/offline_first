// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:floor/floor.dart';

enum TableReference {
  users,
  products;

  const TableReference();
}


@entity
class SyncEntity {
  @PrimaryKey(autoGenerate: true)
  final int? id;
  final String endpoint;
  final String method;
  final String? body;
  final String table;

  final String? headers;

  const SyncEntity({
    this.id,
    required this.endpoint,
    required this.method,
    required this.table,
    this.body,
    this.headers,
  });

  factory SyncEntity.fromMap(
    Map<String, dynamic> map,
  ) {
    return SyncEntity(
      id: map['id']?.toInt() ?? 0,
      endpoint: map['endpoint'] ?? '',
      method: map['method'],
      table: map['table'],
      body: map['body'],
      headers: map['headers'],
    );
  }

  String toJson() => json.encode(toMap());

  factory SyncEntity.fromJson(String source) =>
      SyncEntity.fromMap(json.decode(source));

  @override
  String toString() {
    return 'SyncEntity(id: $id, endpoint: $endpoint, body: $body, headers: $headers, s)';
  }

  SyncEntity copyWith({
    int? id,
    String? endpoint,
    String? body,
    String? method,
    String? headers,
  }) {
    return SyncEntity(
      id: id ?? this.id,
      method: method ?? this.method,
      table: table,
      endpoint: endpoint ?? this.endpoint,
      body: body ?? this.body,
      headers: headers ?? this.headers,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'method': method,
      'table': table,
      'endpoint': endpoint,
      'body': body,
      'headers': jsonEncode(headers),
    };
  }

  Map<String, String>? get headersMap =>
      headers == null ? null : jsonDecode(headers!);
}
