import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/di.dart';
import '../../../../domain/repositories/auth_repository.dart';
import '../../../../domain/usecases/get_session.dart';
import '../../../../domain/usecases/login.dart';
import '../../../../domain/usecases/logout.dart';
import '../../../../domain/usecases/register.dart';
import '../../../../domain/usecases/upgrade_to_pro.dart';
import '../../../../domain/usecases/update_profile_name.dart';

class AuthState {
  const AuthState({
    required this.isLoading,
    required this.isLoggedIn,
    required this.isPro,
    this.profileName,
    this.email,
    this.error,
  });

  final bool isLoading;
  final bool isLoggedIn;
  final bool isPro;
  final String? profileName;
  final String? email;
  final String? error;

  AuthState copyWith({
    bool? isLoading,
    bool? isLoggedIn,
    bool? isPro,
    String? profileName,
    String? email,
    String? error,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      isPro: isPro ?? this.isPro,
      profileName: profileName ?? this.profileName,
      email: email ?? this.email,
      error: error,
    );
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final getSession = ref.watch(getSessionProvider);
  final login = ref.watch(loginProvider);
  final register = ref.watch(registerProvider);
  final logout = ref.watch(logoutProvider);
  final upgrade = ref.watch(upgradeToProProvider);
  final updateProfile = ref.watch(updateProfileNameProvider);
  return AuthNotifier(
    getSession,
    login,
    register,
    logout,
    upgrade,
    updateProfile,
  )..load();
});

final getSessionProvider = Provider<GetSession>((ref) {
  return GetSession(ref.watch(authRepositoryProvider));
});

final loginProvider = Provider<Login>((ref) {
  return Login(ref.watch(authRepositoryProvider));
});

final registerProvider = Provider<Register>((ref) {
  return Register(ref.watch(authRepositoryProvider));
});

final logoutProvider = Provider<Logout>((ref) {
  return Logout(ref.watch(authRepositoryProvider));
});

final upgradeToProProvider = Provider<UpgradeToPro>((ref) {
  return UpgradeToPro(ref.watch(authRepositoryProvider));
});

final updateProfileNameProvider = Provider<UpdateProfileName>((ref) {
  return UpdateProfileName(ref.watch(authRepositoryProvider));
});

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(
    this._getSession,
    this._login,
    this._register,
    this._logout,
    this._upgradeToPro,
    this._updateProfileName,
  )
      : super(const AuthState(isLoading: true, isLoggedIn: false, isPro: false));

  final GetSession _getSession;
  final Login _login;
  final Register _register;
  final Logout _logout;
  final UpgradeToPro _upgradeToPro;
  final UpdateProfileName _updateProfileName;

  Future<void> load() async {
    state = state.copyWith(isLoading: true);
    final result = await _getSession();
    state = result.match(
      (error) => AuthState(
        isLoading: false,
        isLoggedIn: false,
        isPro: false,
        error: error,
      ),
      (session) => AuthState(
        isLoading: false,
        isLoggedIn: session?.isLoggedIn ?? false,
        isPro: session?.isPro ?? false,
        email: session?.email,
        profileName: session?.profileName,
      ),
    );
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await _login(email: email, password: password);
    state = result.match(
      (error) => AuthState(
        isLoading: false,
        isLoggedIn: false,
        isPro: false,
        error: error,
      ),
      (session) => AuthState(
        isLoading: false,
        isLoggedIn: session.isLoggedIn,
        isPro: session.isPro,
        email: session.email,
        profileName: session.profileName,
      ),
    );
    return state.isLoggedIn;
  }

  Future<bool> register({
    required String email,
    required String password,
    required String name,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    final result =
        await _register(email: email, password: password, name: name);
    state = result.match(
      (error) => AuthState(
        isLoading: false,
        isLoggedIn: false,
        isPro: false,
        error: error,
      ),
      (session) => AuthState(
        isLoading: false,
        isLoggedIn: session.isLoggedIn,
        isPro: session.isPro,
        email: session.email,
        profileName: session.profileName,
      ),
    );
    return state.isLoggedIn;
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true, error: null);
    await _logout();
    state = AuthState(
      isLoading: false,
      isLoggedIn: false,
      isPro: state.isPro,
      email: state.email,
      profileName: state.profileName,
    );
  }

  Future<void> upgradeToPro() async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await _upgradeToPro();
    state = result.match(
      (error) => state.copyWith(isLoading: false, error: error),
      (session) => AuthState(
        isLoading: false,
        isLoggedIn: session.isLoggedIn,
        isPro: session.isPro,
        email: session.email,
        profileName: session.profileName,
      ),
    );
  }

  Future<void> updateProfileName(String name) async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await _updateProfileName(name);
    state = result.match(
      (error) => state.copyWith(isLoading: false, error: error),
      (session) => AuthState(
        isLoading: false,
        isLoggedIn: session.isLoggedIn,
        isPro: session.isPro,
        email: session.email,
        profileName: session.profileName,
      ),
    );
  }
}
