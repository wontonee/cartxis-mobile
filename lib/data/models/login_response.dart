import 'user_model.dart';

/// Login Response Data
class LoginData {
  final UserModel user;
  final String token;
  final String tokenType;
  final int expiresIn;

  LoginData({
    required this.user,
    required this.token,
    required this.tokenType,
    required this.expiresIn,
  });

  factory LoginData.fromJson(Map<String, dynamic> json) {
    return LoginData(
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
      token: json['token'] as String,
      tokenType: json['token_type'] as String,
      expiresIn: json['expires_in'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user.toJson(),
      'token': token,
      'token_type': tokenType,
      'expires_in': expiresIn,
    };
  }
}
