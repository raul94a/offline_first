import 'package:example/data/models/entities/user_entity.dart';
import 'package:floor/floor.dart';


@dao
abstract class UserDao {
  @Insert()
  Future<void> saveMany(List<UserEntity> users);

  @Insert()
  Future<void> saveOne(UserEntity user);

  @Query('SELECT * FROM users')
  Stream<List<UserEntity>> getAllStream();
}
