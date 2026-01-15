import 'package:flutter/material.dart';
import 'package:messaging_app/services/api.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  String? userId;
  String? userName;
  late SharedPreferences prefs;

  Future<void> init() async {
    prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('user_id');
    userName = prefs.getString('user_name');
  }

  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  late IO.Socket socket;
  SocketService._internal();
  void connect() {
    debugPrint(userId);
    debugPrint("user id");
    socket = IO.io(
      Api.baseUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .setQuery({'userId': userId})
          .enableAutoConnect()
          .build(),
    );

    socket.onConnect((_) {
      debugPrint('✅ Socket connected');
      socket.emit('authenticate', {"username": userName, "userId": userId});
    });

    socket.on('authenticate', (data) {
      return data;
    });

    socket.onDisconnect((_) {
      debugPrint('❌ Socket disconnected');
    });

    socket.onConnectError((err) {
      debugPrint('⚠️ Connect error: $err');
    });
  }

  void sendMessage({required String recipientId, required String message}) {
    socket.emit("sendDirectMessage", {
      "recipientId": recipientId,
      "message": message,
      "userId": userId,
    });
  }

  void disconnect() {
    socket.disconnect();
  }
}
