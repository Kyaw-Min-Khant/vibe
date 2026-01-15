import 'package:flutter/material.dart';
import 'package:messaging_app/services/socket_service.dart';
import 'package:messaging_app/services/user_service.dart';

class MessageListScreen extends StatefulWidget {
  const MessageListScreen({super.key});

  @override
  State<MessageListScreen> createState() => _MessageListScreenState();
}

class _MessageListScreenState extends State<MessageListScreen> {
  List<Map<String, dynamic>> friendsList = [];
  Map<String, dynamic>? authResponse;

  bool isLoading = true;
  void fetchFriendList() async {
    try {
      final friendList = await UserService().getFriends();
      setState(() {
        friendsList = List<Map<String, dynamic>>.from(friendList);
        isLoading = false;
      });
    } catch (e) {
      isLoading = false;
      debugPrint("Error fetching friends data: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    SocketService().connect();
    SocketService().socket.on('authenticated', (data) {
      debugPrint("Authenticated event received: $data");
      setState(() {
        authResponse = Map<String, dynamic>.from(data);
      });
    });
    fetchFriendList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          "Chats",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: Container(
        child: Center(
          child: isLoading
              ? const CircularProgressIndicator()
              : ListView.builder(
                  itemBuilder: (context, index) {
                    final user = friendsList![index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/room',
                          arguments: {
                            "friendId": user['_id'],
                            "friendUsername": user['username'],
                          },
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 15,
                          horizontal: 10,
                        ),
                        decoration: BoxDecoration(
                          border: Border.symmetric(
                            horizontal: BorderSide(
                              color: Colors.grey.shade300,
                              width: 1,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.all(
                                Radius.circular(100),
                              ),
                              child: FadeInImage.assetNetwork(
                                width: 70,
                                height: 70,
                                placeholder: "lib/assets/loading.png",
                                image:
                                    user['avatar'] ??
                                    "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRH87TKQrWcl19xly2VNs0CjBzy8eaKNM-ZpA&s",
                              ),
                            ),

                            Padding(
                              padding: const EdgeInsets.only(left: 30),
                              child: Text(
                                user['username'].toUpperCase() ?? "...",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  itemCount: friendsList?.length ?? 0,
                ),
        ),
      ),
    );
  }
}
