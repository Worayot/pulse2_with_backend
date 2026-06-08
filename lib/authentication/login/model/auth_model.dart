class AuthModel {
  final String? username;
  final String? password;
  final bool rememberMe;
  const AuthModel({this.username, this.password, required this.rememberMe});
}
