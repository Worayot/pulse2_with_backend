class User {
  final String nurseId;
  final String password;
  final String role;
  final String fullname;

  User({
    required this.fullname,
    required this.nurseId,
    required this.password,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      nurseId: json['nurse_id'],
      password: json['password'],
      role: json['role'],
      fullname: json['fullname'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fullname': fullname,
      'nurseId': nurseId,
      'password': password,
      'role': role,
    };
  }
}
