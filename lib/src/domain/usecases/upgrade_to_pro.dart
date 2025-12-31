import 'package:fpdart/fpdart.dart';

import '../repositories/auth_repository.dart';

class UpgradeToPro {
  UpgradeToPro(this._repository);

  final AuthRepository _repository;

  Future<Either<String, AuthSession>> call() {
    return _repository.upgradeToPro();
  }
}
