import 'package:floor/floor.dart';
import 'package:offline_first/database/models/syn_model.dart';

@Entity(tableName: 'users')
class UserEntity extends SyncModel {
  final String name;
  final String email;
  final String dni;
  UserEntity({
    required super.table,
    required this.dni,
    required this.name,
    required this.email,
  });
}
