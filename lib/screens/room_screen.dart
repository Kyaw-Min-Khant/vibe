import 'dart:io' as io;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:messaging_app/components/custom_audio_player.dart';
import 'package:messaging_app/services/appwrite_service.dart';
import 'package:messaging_app/services/audiorecorder_service.dart';
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
  final AudioRecorderService _recorder = AudioRecorderService();
  bool _isRecording = false;

  final ScrollController _scrollController = ScrollController();
  final TextEditingController _textController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  final List<Map<String, dynamic>> _messages = [];
  String messageType = 'text';
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

  Future<void> _startRecording() async {
    try {
      await _recorder.startRecording();
      setState(() => _isRecording = true);
    } catch (e) {
      debugPrint('Start recording failed: $e');
    }
  }

  Future<void> _stopRecording() async {
    try {
      final file = await _recorder.stopRecording();
      setState(() => _isRecording = false);

      if (file == null) return;

      final url = await AppWriteService.uploadImage(file);

      if (url != null) {
        SocketService().sendMessage(
          recipientId: widget.friendId,
          message: url,
          messageType: 'audio',
        );
        setState(() {
          _messages.insert(0, {
            "message": url,
            'fileUrl': url,
            "messageType": 'audio',
            "isMe": true,
            "createdAt": DateTime.now().toIso8601String(),
          });
        });
      }
    } catch (e) {
      debugPrint('Stop recording failed: $e');
    }
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
        'messageType': msg["messageType"],
        'fileUrl': msg["fileUrl"],
        'status': msg['status'],
        'deliveredAt': msg['deliveredAt'],
        'seenAt': msg['seenAt'],
      };
    }).toList();

    setState(() {
      _messages.addAll(messages);
      _page++;
      _isLoading = false;
    });
  }

  void _openfilePickerAndUpload() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 50,
      );
      if (photo == null) return;
      final io.File file = io.File(photo.path);
      final url = await AppWriteService.uploadImage(file);
      debugPrint(url);
      if (url != null) {
        SocketService().sendMessage(
          recipientId: widget.friendId,
          message: url,
          messageType: 'image',
        );
        setState(() {
          _messages.insert(0, {
            "message": url,
            'fileUrl': url,
            "messageType": 'image',
            "isMe": true,
            "createdAt": DateTime.now().toIso8601String(),
            "status": 'sent',
          });
        });
      }
    } catch (e) {
      debugPrint(e.toString());
    }
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
    debugPrint('📩 New message data: $data');
    if (!mounted) return;
    setState(() {
      _messages.insert(0, {
        "id": data["_id"] ?? '',
        "message": data["message"] ?? '',
        "isMe": false,
        "createdAt": data["createdAt"] ?? DateTime.now().toIso8601String(),
        'messageType': data["messageType"] ?? 'text',
        'fileUrl': data["message"] ?? '',
        'status': data['status'] ?? 'sent',
        'deliveredAt': data['deliveredAt'],
        'seenAt': data['seenAt'],
      });
    });
  }

  void _sendMessage() {
    final text = _textController.text;
    if (text.isEmpty) return;
    debugPrint("Sending text to: ${widget.friendId}");
    SocketService().socket.emit("typing", {
      "recipientId": widget.friendId.toString(),
      "isTyping": false,
    });

    SocketService().sendMessage(
      recipientId: widget.friendId,
      message: text,
      messageType: 'text',
    );

    setState(() {
      _messages.insert(0, {
        "message": text,
        "isMe": true,
        "createdAt": DateTime.now().toIso8601String(),
        "messageType": "text",
        "status": "sent",
        "seenAt": null,
        "deliveredAt": null,
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

  IconData _getStatusIcon(String status, dynamic seenAt) {
    switch (status) {
      case 'sent':
        return Icons.check;
      case 'delivered':
        return Icons.done_all;
      default:
        return Icons.check;
    }
  }

  Color _getStatusColor(String status, dynamic seenAt) {
    if (seenAt != null) return Colors.blue; // seen = blue double tick
    if (status == 'delivered') return Colors.white70; // delivered gray
    return Colors.white; // sent
  }

  String _formatTime(dynamic dateTime) {
    if (dateTime == null) return '';
    final dt = DateTime.parse(dateTime).toLocal();
    String period = dt.hour >= 12 ? "PM" : "AM";

    // Convert 0-23 hour to 1-12 hour
    final hour = dt.hour % 12;
    final formattedHour = hour == 0 ? 12 : hour;
    final formattedHourStr = formattedHour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    return '$formattedHourStr:$min $period';
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
                final messageType = msg['messageType'] ?? 'text';
                Widget bubble;

                switch (messageType) {
                  case 'image':
                    bubble = Stack(
                      children: [
                        if (msg['messageType'] == 'image' &&
                            (msg['fileUrl'] ?? '').isNotEmpty)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: FadeInImage.assetNetwork(
                              placeholder: 'lib/assets/loading.png',
                              image: msg['fileUrl']!,
                              width: 200,
                              height: 200,
                              fit: BoxFit.cover,
                            ),
                          ),

                        if (isMe)
                          Positioned(
                            bottom: 4,
                            right: 4,
                            child: Row(
                              children: [
                                Icon(
                                  _getStatusIcon(
                                    msg['status'] ?? 'sent',
                                    msg['seenAt'],
                                  ),
                                  size: 16,
                                  color: _getStatusColor(
                                    msg['status'],
                                    msg['seenAt'],
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _formatTime(msg['createdAt']),
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    );
                    break;

                  case 'audio':
                    bubble = Column(
                      crossAxisAlignment: isMe
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      children: [
                        if (msg['messageType'] == 'audio' &&
                            (msg['fileUrl'] ?? '').isNotEmpty)
                          CustomAudioPlayer(url: msg['fileUrl']!, isMe: isMe),
                        const SizedBox(height: 4),
                        if (isMe)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Icon(
                                _getStatusIcon(
                                  msg['status'] ?? 'sent',
                                  msg['seenAt'],
                                ),
                                size: 16,
                                color: _getStatusColor(
                                  msg['status'] ?? 'sent',
                                  msg['seenAt'],
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _formatTime(msg['createdAt']),
                                style: TextStyle(
                                  fontSize: 10,
                                  color: isMe ? Colors.white70 : Colors.black54,
                                ),
                              ),
                            ],
                          ),
                      ],
                    );
                    break;

                  default:
                    bubble = Column(
                      crossAxisAlignment: isMe
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: isMe ? Colors.blue : Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            msg["message"] ?? '',
                            style: TextStyle(
                              color: isMe ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (isMe)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Icon(
                                _getStatusIcon(
                                  msg['status'] ?? 'sent',
                                  msg['seenAt'],
                                ),
                                size: 16,
                                color: _getStatusColor(
                                  msg['status'] ?? 'sent',
                                  msg['seenAt'],
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _formatTime(msg['createdAt']),
                                style: TextStyle(
                                  fontSize: 10,
                                  color: isMe ? Colors.white70 : Colors.black54,
                                ),
                              ),
                            ],
                          ),
                      ],
                    );
                }

                return Align(
                  alignment: isMe
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: bubble,
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
      child: Container(
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                IconButton(
                  style: IconButton.styleFrom(
                    foregroundColor: const Color.fromARGB(255, 6, 120, 214),
                  ),
                  icon: const Icon(Icons.camera_alt),
                  onPressed: _openfilePickerAndUpload,
                ),
                IconButton(
                  icon: Icon(_isRecording ? Icons.stop : Icons.mic),
                  color: _isRecording
                      ? Colors.red
                      : const Color.fromARGB(255, 6, 120, 214),
                  onPressed: () {
                    if (_isRecording) {
                      _stopRecording();
                    } else {
                      _startRecording();
                    }
                  },
                ),
                // if (selectedFile != null)
                //   Expanded(
                //     child: Padding(
                //       padding: const EdgeInsets.only(bottom: 10),
                //       child: Image.file(
                //         selectedFile!,
                //         width: 150,
                //         height: 150,
                //         fit: BoxFit.contain,
                //       ),
                //     ),
                //   )
                // else
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
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                  style: IconButton.styleFrom(
                    foregroundColor: const Color.fromARGB(255, 6, 120, 214),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
