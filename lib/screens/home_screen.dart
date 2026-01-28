import 'package:flutter/material.dart';
import 'package:messaging_app/services/user_service.dart';
// import 'package:fluttertoast/fluttertoast.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>>? usersList;
  List<Map<String, dynamic>>? friendRequestList;
  bool isLoading = true;
  bool addFriendLoading = false;
  @override
  void initState() {
    super.initState();
    // _fetchFriendRequestList();
    _fetchUserListData();
  }

  // void _fetchFriendRequestList() async {
  //   try {
  //     final friendRequestResponse = await UserService().getFriendRequestList();
  //     setState(() {
  //       friendRequestList = List<Map<String, dynamic>>.from(
  //         friendRequestResponse,
  //       );
  //     });
  //     debugPrint("Friend Requests: $friendRequestResponse");
  //   } catch (e) {
  //     debugPrint("Error fetching friend request data: $e");
  //   }
  // }

  void _fetchUserListData() async {
    try {
      final usersListData = await UserService().getAllUsers();
      setState(() {
        usersList = List<Map<String, dynamic>>.from(usersListData);
        isLoading = false;
      });
      debugPrint("All Users: $usersList");
    } catch (e) {
      isLoading = false;
      debugPrint("Error fetching user data: $e");
    }
  }

  // void confirmFriendRequest(String requestId) async {
  //   try {
  //     final response = await UserService().acceptFriendRequest(requestId);
  //   } catch (e) {
  //     debugPrint("Error confirming friend request: $e");
  //   }
  // }

  void handleAddFriend(String friendId) async {
    try {
      addFriendLoading = true;
      final response = await UserService().addFriend(friendId);
      final usersListData = await UserService().getAllUsers();
      debugPrint("Add Friend Response: $response");
      setState(() {
        usersList = List<Map<String, dynamic>>.from(usersListData);
        addFriendLoading = false;
      });
    } catch (e) {
      debugPrint("Error adding friend: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          "Friend Suggestions",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: isLoading
            ? const CircularProgressIndicator()
            : Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemBuilder: (context, index) {
                        final user = usersList![index];
                        return Container(
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

                              Spacer(),
                              GestureDetector(
                                onTap: addFriendLoading
                                    ? null
                                    : () {
                                        handleAddFriend(user['_id']);
                                      },
                                child: Container(
                                  margin: EdgeInsets.only(left: 20),
                                  padding: EdgeInsets.symmetric(
                                    vertical: 4,
                                    horizontal: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.blue,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    spacing: 5,
                                    children: [
                                      Text(
                                        "Add",
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Icon(
                                        size: 18,
                                        Icons.person_add_alt,
                                        color: Colors.white,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      itemCount: usersList?.length ?? 0,
                    ),
                  ),
                  // if (friendRequestList!.isNotEmpty)
                  //   Align(
                  //     alignment: Alignment.centerLeft,
                  //     child: Padding(
                  //       padding: const EdgeInsets.symmetric(
                  //         vertical: 10,
                  //         horizontal: 20,
                  //       ),
                  //       child: Text(
                  //         "Friend Requests",
                  //         style: TextStyle(
                  //           fontSize: 18,
                  //           fontWeight: FontWeight.w600,
                  //         ),
                  //       ),
                  //     ),
                  //   ),

                  // Expanded(
                  //   child: ListView.builder(
                  //     itemCount: friendRequestList?.length ?? 0,
                  //     itemBuilder: (context, index) {
                  //       final request = friendRequestList![index];
                  //       return ListTile(
                  //         leading: CircleAvatar(
                  //           backgroundImage: NetworkImage(
                  //             request['requester']['avatar'] ??
                  //                 "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRH87TKQrWcl19xly2VNs0CjBzy8eaKNM-ZpA&s",
                  //           ),
                  //         ),
                  //         title: Text(
                  //           request['requester']['username'] ?? "...",
                  //           style: TextStyle(fontWeight: FontWeight.w600),
                  //         ),
                  //         subtitle: Text("wants to be your friend"),
                  //         trailing: ElevatedButton(
                  //           style: ElevatedButton.styleFrom(
                  //             foregroundColor: Colors.white,
                  //             backgroundColor: Colors.blue,
                  //           ),
                  //           onPressed: () {
                  //             // Handle accept friend request
                  //           },
                  //           child: const Text("Accept"),
                  //         ),
                  //       );
                  //     },
                  //   ),
                  // ),
                ],
              ),
      ),
    );
  }
}
