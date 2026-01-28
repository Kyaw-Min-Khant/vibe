import 'package:flutter/material.dart';
import 'package:messaging_app/providers/user_provider.dart';
import 'package:messaging_app/services/auth_service.dart';
import 'package:messaging_app/services/user_service.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool logoutIsLoading = false;
  @override
  void initState() {
    super.initState();
  }

  void _handleLogout() async {
    final success = await LogoutService().logout();
    debugPrint("Logout Success: $success");
    if (success) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/login',
        (Route<dynamic> route) => false,
      );
    }
  }

  void _handleAddFriend(String friendId) async {
    try {
      await UserService().addFriend(friendId);
      UserProvider().removeFirRequest(friendId);
    } catch (e) {
      debugPrint("Error adding friend: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    Map<String, dynamic>? user = userProvider.userData;
    List<Map<String, dynamic>>? friRequestList = userProvider.friRequestList;
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(""),
            IconButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Logout'),
                    content: Text('Are you sure to logout ?'),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text("Cancel"),
                      ),
                      TextButton(
                        onPressed: _handleLogout,
                        child: Text("Ok", style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
              },
              icon: Icon(Icons.logout, size: 30, color: Colors.red),
            ),
          ],
        ),
      ),
      body: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          spacing: 10,
          children: [
            ClipOval(
              child: FadeInImage.assetNetwork(
                width: 200,
                image:
                    user['avatar'] ??
                    "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRH87TKQrWcl19xly2VNs0CjBzy8eaKNM-ZpA&s",
                placeholder: 'lib/assets/loading.png',
              ),
            ),
            Text(
              "Name: ${user['username']}",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            Text(
              "Email: ${user['email']}",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),

            if (friRequestList.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 50),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 20,
                    ),
                    child: Text(
                      "Friend Requests",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            Expanded(
              child: ListView.builder(
                itemCount: friRequestList.length,
                itemBuilder: (context, index) {
                  final request = friRequestList[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(
                        request['requester']['avatar'] ??
                            "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRH87TKQrWcl19xly2VNs0CjBzy8eaKNM-ZpA&s",
                      ),
                    ),
                    title: Text(
                      request['requester']['username'] ?? "...",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text("wants to be your friend"),
                    trailing: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.blue,
                      ),
                      onPressed: () {
                        _handleAddFriend(request['_id']);
                      },
                      child: const Text("Accept"),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
