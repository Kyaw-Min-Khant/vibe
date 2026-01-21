import 'dart:convert';
import 'package:messaging_app/services/api.dart';
import 'package:http/http.dart' as http;

class MessageService {
  Future<dynamic> getMessageListById(String friendId, int page) async {
    final token = await Api().getToken();
    final response = await http.get(
      Uri.parse(
        '${Api.baseUrl}/v1/api/conversations/$friendId/messages?page=$page',
      ),
      headers: {'Authorization': 'Bearer $token'},
    );
    final messageJsonData = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return messageJsonData['data'];
    } else {
      throw Exception('Failed to load messages data');
    }
  }
}
