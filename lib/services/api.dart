import 'package:shared_preferences/shared_preferences.dart';

class Api {
  // static const String baseUrl = 'https://messaging-socket.onrender.com';
  static const String baseUrl = "http://192.168.100.7:3000";

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    return token;
  }
}
