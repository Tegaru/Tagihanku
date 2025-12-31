import 'package:fpdart/fpdart.dart';

import '../repositories/auth_repository.dart';

class Logout {
  Logout(this._repository);

  final AuthRepository _repository;

  Future<Either<String, bool>> call() {
    return _repository.logout();
  }
}
