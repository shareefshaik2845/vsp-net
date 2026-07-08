import 'entities.dart';

abstract class IUserRepository {
  Future<List<UserAccount>> getUsers({UserRole? roleFilter, String? search});
  Future<UserAccount?> getUserById(String id);
  Future<UserAccount> createUser(UserAccount user);
  Future<UserAccount> updateUser(UserAccount user);
  Future<void> deleteUser(String id);
  Future<bool> emailExists(String email);
}
