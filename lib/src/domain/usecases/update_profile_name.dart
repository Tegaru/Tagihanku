import 'package:fpdart/fpdart.dart';

import '../repositories/auth_repository.dart';

class UpdateProfileName {
  UpdateProfileName(this._repository);

  final AuthRepository _repository;

  Future<Either<String, AuthSession>> call(String name) {
    return _repository.updateProfileName(name);
  }
}
