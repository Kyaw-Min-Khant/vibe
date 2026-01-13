class LoginResponse {
  final bool success;
  final String? message; // success message or error message
  final LoginData? data; // null when failed

  LoginResponse({required this.success, this.message, this.data});

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      success: json['success'] == true,
      message: json['message'] ?? json['error'],
      data: json['data'] != null ? LoginData.fromJson(json['data']) : null,
    );
  }
}

class LoginData {
  final User user;
  final String token;

  LoginData({required this.user, required this.token});

  factory LoginData.fromJson(Map<String, dynamic> json) {
    return LoginData(
      user: User.fromJson(json['user']),
      token: json['token'] as String,
    );
  }
}

class User {
  final String id;
  final String username;
  final String email;
  final bool isOnline;
  final String? avatar;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.isOnline,
    this.avatar,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      isOnline: json['isOnline'] == true,
      avatar: json['avatar'] as String?,
    );
  }
}
