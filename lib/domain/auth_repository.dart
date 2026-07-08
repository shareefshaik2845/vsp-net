import 'entities.dart';

abstract class IAuthRepository {
  Future<bool> isInstallationComplete();
  Future<InstallationRecord> completeInstallation({
    required String name,
    required String email,
    required String passwordHash,
    required String passwordSalt,
    required String setupToken,
    String? recoveryEmail,
    String? recoveryCodeHash,
  });
  Future<UserAccount?> authenticate(String email);
  Future<String> createSession(String userId);
  Future<bool> validateSession(String token);
  Future<void> invalidateSession(String token);
  Future<bool> emailExists(String email);
  Future<bool> hasSuperAdmin();
  Future<String> generateSetupToken();
}
