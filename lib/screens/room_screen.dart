import 'package:flutter/material.dart';
import 'package:messaging_app/services/message_service.dart';
import 'package:messaging_app/services/socket_service.dart';
import 'package:jiffy/jiffy.dart';

class RoomScreen extends StatefulWidget {
  final String friendId;
  final String friendUsername;
  final String? friendAvatar;
  final bool activeStatus;
  final String lastSeen;

  const RoomScreen({
    super.key,
    required this.friendId,
    required this.friendUsername,
    required this.friendAvatar,
    required this.activeStatus,
    required this.lastSeen,
  });

  @override
  State<RoomScreen> createState() => _RoomScreenState();
}

class _RoomScreenState extends State<RoomScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _textController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  bool _isLoading = false;
  bool _isLastPage = false;
  int _page = 1;
  bool isTyping = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _fetchMessages();
    SocketService().socket.on("newDirectMessage", _onNewMessage);
    SocketService().socket.on('userTyping', _checkUserTyping);
  }

  Future<void> _fetchMessages() async {
    if (_isLoading || _isLastPage) return;

    setState(() => _isLoading = true);

    final response = await MessageService().getMessageListById(
      widget.friendId,
      _page,
    );

    if (!mounted) return;

    if (response == null || response.isEmpty) {
      setState(() {
        _isLastPage = true;
        _isLoading = false;
      });
      return;
    }

    final messages = response.map<Map<String, dynamic>>((msg) {
      debugPrint("Fetched message: $msg");
      return {
        "id": msg["_id"],
        "message": msg["content"],
        "isMe": msg["sender"] == SocketService().userId,
        "createdAt": msg["createdAt"],
      };
    }).toList();

    setState(() {
      _messages.addAll(messages);
      _page++;
      _isLoading = false;
    });
  }

  void _checkUserTyping(dynamic data) {
    if (!mounted) return;

    if (data['senderId'] != widget.friendId) return;
    debugPrint('👀 User typing data: $data');
    setState(() {
      isTyping = data['isTyping'] as bool;
    });
  }

  void _onNewMessage(dynamic data) {
    if (!mounted) return;
    setState(() {
      _messages.insert(0, {
        "id": data["_id"],
        "message": data["message"],
        "isMe": false,
        "createdAt": data["createdAt"],
      });
    });
  }

  void _sendMessage() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;
    SocketService().socket.emit("typing", {
      "receiverId": widget.friendId,
      "isTyping": false,
    });
    SocketService().sendMessage(recipientId: widget.friendId, message: text);

    setState(() {
      _messages.insert(0, {
        "message": text,
        "isMe": true,
        "createdAt": DateTime.now().toIso8601String(),
      });
    });

    _textController.clear();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _fetchMessages();
    }
  }

  @override
  void dispose() {
    SocketService().socket.off("newDirectMessage", _onNewMessage);
    SocketService().socket.off("typing", _checkUserTyping);
    _scrollController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dateTime = DateTime.parse(widget.lastSeen).toLocal();
    final formattedTime = Jiffy.parseFromDateTime(dateTime).fromNow();
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: widget.activeStatus ? Colors.blue : Colors.grey,
                  width: 2,
                ),
              ),
              child: ClipOval(
                child: Image.network(
                  widget.friendAvatar ??
                      'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRH87TKQrWcl19xly2VNs0CjBzy8eaKNM-ZpA&s',
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.friendUsername,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                widget.activeStatus
                    ? Text(
                        'Online',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.green,
                        ),
                      )
                    : Text(
                        'Last seen : ${formattedTime}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black,
                        ),
                      ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          if (_isLoading)
            SizedBox(
              width: 30,
              height: 30,
              child: const Padding(
                padding: EdgeInsets.all(8),
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),

          Expanded(
            child: ListView.builder(
              reverse: true,
              controller: _scrollController,
              padding: const EdgeInsets.all(12),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isMe = msg["isMe"] as bool;
                return Align(
                  alignment: isMe
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isMe ? Colors.blue : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      msg["message"],
                      style: TextStyle(
                        color: isMe ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (isTyping)
            Padding(
              padding: const EdgeInsets.only(left: 12, bottom: 4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      '${widget.friendUsername} is typing...',
                      style: const TextStyle(
                        fontStyle: FontStyle.italic,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          _buildInput(),
        ],
      ),
    );
  }

  Widget _buildInput() {
    return SafeArea(
      child: Row(
        children: [
          Expanded(
            child: TextField(
              onChanged: (text) {
                SocketService().isUserTyping(
                  recipientId: widget.friendId,
                  isTyping: text.isNotEmpty,
                );
              },
              controller: _textController,
              decoration: const InputDecoration(
                hintText: "Type a message...",
                contentPadding: EdgeInsets.all(12),
              ),
            ),
          ),
          IconButton(icon: const Icon(Icons.send), onPressed: _sendMessage),
        ],
      ),
    );
  }
}
