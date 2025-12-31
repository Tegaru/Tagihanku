class AuthModel {
  AuthModel({
    required this.email,
    required this.password,
    required this.isLoggedIn,
    required this.isPro,
    required this.profileName,
  });

  final String email;
  final String password;
  final bool isLoggedIn;
  final bool isPro;
  final String profileName;

  Map<String, dynamic> toMap() => {
        'email': email,
        'password': password,
        'isLoggedIn': isLoggedIn,
        'isPro': isPro,
        'profileName': profileName,
      };

  static AuthModel fromMap(Map<String, dynamic> map) {
    return AuthModel(
      email: map['email'] as String,
      password: map['password'] as String,
      isLoggedIn: map['isLoggedIn'] as bool? ?? false,
      isPro: map['isPro'] as bool? ?? false,
      profileName: map['profileName'] as String? ?? '',
    );
  }
}
