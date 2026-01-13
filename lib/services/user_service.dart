import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:messaging_app/services/api.dart';
import 'package:http/http.dart' as http;

class UserService {
  Future<dynamic> getUserDetail() async {
    final token = await Api().getToken();
    final response = await http.get(
      Uri.parse('${Api.baseUrl}/v1/api/auth/user'),
      headers: {'Authorization': 'Bearer $token'},
    );
    final userDataJson = jsonDecode(response.body);
    debugPrint(jsonEncode(userDataJson));
    if (userDataJson['success'] == true) {
      return userDataJson['data']['user'];
    } else {
      throw Exception('Failed to load user data');
    }
  }

  Future<dynamic> getAllUsers() async {
    final token = await Api().getToken();
    final response = await http.get(
      Uri.parse('${Api.baseUrl}/v1/api/users'),
      headers: {'Authorization': 'Bearer $token'},
    );
    final usersDataJson = jsonDecode(response.body);
    // debugPrint(jsonEncode(usersDataJson));
    if (response.statusCode == 200) {
      return usersDataJson['data'];
    } else {
      throw Exception('Failed to load users data');
    }
  }

  Future<dynamic> addFriend(String friendId) async {
    final token = await Api().getToken();
    final response = await http.post(
      Uri.parse('${Api.baseUrl}/v1/api/users/addfriend'),
      headers: {'Authorization': 'Bearer $token'},
      body: {'friend_id': friendId},
    );
    if (response.statusCode == 201) {
      final responseJson = jsonDecode(response.body);
      return responseJson;
    } else {
      throw Exception('Failed to add friend');
    }
  }

  Future<dynamic> getFriends() async {
    final token = await Api().getToken();
    final response = await http.get(
      Uri.parse('${Api.baseUrl}/v1/api/users/friends'),
      headers: {'Authorization': 'Bearer $token'},
    );
    debugPrint("Friends Response: ${response.body}");
    if (response.statusCode == 200) {
      final friendsList = jsonDecode(response.body);
      return friendsList['data'];
    } else {
      throw Exception('Failed to load friends list');
    }
  }
}
