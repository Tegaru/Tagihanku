import 'package:fpdart/fpdart.dart';

class AuthSession {
  const AuthSession({
    required this.email,
    required this.isLoggedIn,
    required this.isPro,
    required this.profileName,
  });

  final String email;
  final bool isLoggedIn;
  final bool isPro;
  final String profileName;
}

abstract class AuthRepository {
  Future<Either<String, AuthSession?>> getSession();
  Future<Either<String, AuthSession>> login({
    required String email,
    required String password,
  });
  Future<Either<String, AuthSession>> register({
    required String email,
    required String password,
    required String name,
  });
  Future<Either<String, AuthSession>> upgradeToPro();
  Future<Either<String, AuthSession>> updateProfileName(String name);
  Future<Either<String, bool>> logout();
}
