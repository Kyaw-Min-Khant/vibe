import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:messaging_app/models/loginresponse.dart';
import 'package:messaging_app/services/api.dart';

class LoginService {
  Future<LoginResponse> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('${Api.baseUrl}/v1/api/auth/login'),
      body: {"email": email, "password": password},
    );
    final loginResponseJson = jsonDecode(response.body) as Map<String, dynamic>;
    return LoginResponse.fromJson(loginResponseJson);
  }
}

class SignupService {
  Future<dynamic> signup(String username, String email, String password) async {
    debugPrint(
      (jsonEncode({
        "username": username,
        "email": email,
        "password": password,
      })),
    );
    final response = await http.post(
      Uri.parse('${Api.baseUrl}/v1/api/auth/register'),
      body: {"username": username, "email": email, "password": password},
    );
    final signupResponseJson = jsonDecode(response.body);
    debugPrint(jsonEncode(signupResponseJson));
    return signupResponseJson;
  }
}

class LogoutService {
  Future<dynamic> logout() async {
    final token = await Api().getToken();
    final response = await http.post(
      Uri.parse('${Api.baseUrl}/v1/api/auth/logout'),
      headers: {'Authorization': 'Bearer $token'},
    );
    final logoutResponseJson = jsonDecode(response.body);
    return logoutResponseJson['success'];
  }
}
