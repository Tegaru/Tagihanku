import 'package:fpdart/fpdart.dart';

import '../../domain/repositories/auth_repository.dart';
import '../datasources/local_storage.dart';
import '../models/auth_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({LocalStorage? storage})
      : _storage = storage ?? LocalStorage();

  final LocalStorage _storage;
  static const _defaultEmail = 'user@tagihanku.app';
  static const _defaultPassword = 'merdeka123';
  static const _defaultName = 'Tagihanku Pro';

  Future<void> _ensureSeeded() async {
    final list = await _storage.loadAuthList();
    if (list.isEmpty) {
      final legacy = await _storage.loadAuth();
      if (legacy != null) {
        list.add(legacy);
        await _storage.saveAuthList(list);
      }
    }
    final existing = list.any((item) => item['email'] == _defaultEmail);
    if (!existing) {
      final model = AuthModel(
        email: _defaultEmail,
        password: _defaultPassword,
        isLoggedIn: false,
        isPro: true,
        profileName: _defaultName,
      );
      list.add(model.toMap());
      await _storage.saveAuthList(list);
    }
  }

  @override
  Future<Either<String, AuthSession?>> getSession() async {
    try {
      await _ensureSeeded();
      final list = await _storage.loadAuthList();
      if (list.isEmpty) return const Right(null);
      final activeEmail = await _storage.loadActiveEmail();
      final current = activeEmail == null
          ? null
          : list.firstWhere(
              (item) => item['email'] == activeEmail,
              orElse: () => <String, dynamic>{},
            );
      if (current == null || current.isEmpty) return const Right(null);
      final model = AuthModel.fromMap(current);
      return Right(
        AuthSession(
          email: model.email,
          isLoggedIn: model.isLoggedIn,
          isPro: model.isPro,
          profileName: model.profileName,
        ),
      );
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, AuthSession>> login({
    required String email,
    required String password,
  }) async {
    try {
      await _ensureSeeded();
      final list = await _storage.loadAuthList();
      if (list.isEmpty) {
        return const Left('Akun belum terdaftar');
      }

      final match = list.firstWhere(
        (item) => item['email'] == email,
        orElse: () => <String, dynamic>{},
      );
      if (match.isEmpty) {
        return const Left('Akun belum terdaftar');
      }
      final model = AuthModel.fromMap(match);
      if (model.password != password) {
        return const Left('Email atau password salah');
      }
      final updated = AuthModel(
        email: model.email,
        password: model.password,
        isLoggedIn: true,
        isPro: model.isPro,
        profileName: model.profileName,
      );
      final index = list.indexWhere((item) => item['email'] == email);
      list[index] = updated.toMap();
      await _storage.saveAuthList(list);
      await _storage.saveActiveEmail(email);
      return Right(
        AuthSession(
          email: updated.email,
          isLoggedIn: true,
          isPro: updated.isPro,
          profileName: updated.profileName,
        ),
      );
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, AuthSession>> register({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      await _ensureSeeded();
      final list = await _storage.loadAuthList();
      final exists = list.any((item) => item['email'] == email);
      if (exists) {
        return const Left('Email sudah terdaftar');
      }
      final model = AuthModel(
        email: email,
        password: password,
        isLoggedIn: true,
        isPro: false,
        profileName: name,
      );
      list.add(model.toMap());
      await _storage.saveAuthList(list);
      await _storage.saveActiveEmail(email);
      return Right(
        AuthSession(
          email: model.email,
          isLoggedIn: true,
          isPro: model.isPro,
          profileName: model.profileName,
        ),
      );
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, AuthSession>> upgradeToPro() async {
    try {
      await _ensureSeeded();
      final list = await _storage.loadAuthList();
      final activeEmail = await _storage.loadActiveEmail();
      if (activeEmail == null) {
        return const Left('Akun belum tersedia');
      }
      final index = list.indexWhere((item) => item['email'] == activeEmail);
      if (index == -1) {
        return const Left('Akun belum tersedia');
      }
      final model = AuthModel.fromMap(list[index]);
      final updated = AuthModel(
        email: model.email,
        password: model.password,
        isLoggedIn: model.isLoggedIn,
        isPro: true,
        profileName: model.profileName,
      );
      list[index] = updated.toMap();
      await _storage.saveAuthList(list);
      return Right(
        AuthSession(
          email: updated.email,
          isLoggedIn: updated.isLoggedIn,
          isPro: true,
          profileName: updated.profileName,
        ),
      );
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, bool>> logout() async {
    try {
      await _ensureSeeded();
      final list = await _storage.loadAuthList();
      final activeEmail = await _storage.loadActiveEmail();
      if (activeEmail == null) {
        return const Right(true);
      }
      final index = list.indexWhere((item) => item['email'] == activeEmail);
      if (index == -1) {
        return const Right(true);
      }
      final model = AuthModel.fromMap(list[index]);
      final updated = AuthModel(
        email: model.email,
        password: model.password,
        isLoggedIn: false,
        isPro: model.isPro,
        profileName: model.profileName,
      );
      list[index] = updated.toMap();
      await _storage.saveAuthList(list);
      await _storage.saveActiveEmail(null);
      return const Right(true);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, AuthSession>> updateProfileName(String name) async {
    try {
      await _ensureSeeded();
      final list = await _storage.loadAuthList();
      final activeEmail = await _storage.loadActiveEmail();
      if (activeEmail == null) {
        return const Left('Akun belum tersedia');
      }
      final index = list.indexWhere((item) => item['email'] == activeEmail);
      if (index == -1) {
        return const Left('Akun belum tersedia');
      }
      final model = AuthModel.fromMap(list[index]);
      final updated = AuthModel(
        email: model.email,
        password: model.password,
        isLoggedIn: model.isLoggedIn,
        isPro: model.isPro,
        profileName: name,
      );
      list[index] = updated.toMap();
      await _storage.saveAuthList(list);
      return Right(
        AuthSession(
          email: updated.email,
          isLoggedIn: updated.isLoggedIn,
          isPro: updated.isPro,
          profileName: updated.profileName,
        ),
      );
    } catch (e) {
      return Left(e.toString());
    }
  }
}
