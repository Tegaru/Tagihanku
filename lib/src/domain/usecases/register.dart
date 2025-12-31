import 'package:fpdart/fpdart.dart';

import '../repositories/auth_repository.dart';

class Register {
  Register(this._repository);

  final AuthRepository _repository;

  Future<Either<String, AuthSession>> call({
    required String email,
    required String password,
    required String name,
  }) {
    return _repository.register(
      email: email,
      password: password,
      name: name,
    );
  }
}
