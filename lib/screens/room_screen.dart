import 'package:flutter/material.dart';
import 'package:messaging_app/services/socket_service.dart';

class RoomScreen extends StatefulWidget {
  final String friendId;
  final String friendUsername;

  const RoomScreen({
    super.key,
    required this.friendId,
    required this.friendUsername,
  });

  @override
  State<RoomScreen> createState() => _RoomScreenState();
}

class _RoomScreenState extends State<RoomScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> messages = [];

  @override
  void initState() {
    super.initState();
    SocketService().socket.on("receiveDirectMessage", (data) {
      setState(() {
        messages.add({"message": data["message"], "isMe": false});
      });
    });
  }

  void sendMessage() {
    if (_controller.text.trim().isEmpty) return;

    final text = _controller.text;
    debugPrint(widget.friendId);
    debugPrint("Testing");
    SocketService().sendMessage(recipientId: widget.friendId, message: text);

    setState(() {
      messages.add({"message": text, "isMe": true});
    });

    _controller.clear();
  }

  @override
  void dispose() {
    SocketService().socket.off("receiveDirectMessage");
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.friendUsername)),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                return Align(
                  alignment: msg["isMe"]
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: msg["isMe"] ? Colors.blue : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      msg["message"],
                      style: TextStyle(
                        color: msg["isMe"] ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    hintText: "Type a message...",
                    contentPadding: EdgeInsets.all(12),
                  ),
                ),
              ),
              IconButton(icon: const Icon(Icons.send), onPressed: sendMessage),
            ],
          ),
          SizedBox(height: 10),
        ],
      ),
    );
  }
}
