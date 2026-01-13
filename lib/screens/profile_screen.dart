import 'package:flutter/material.dart';
import 'package:messaging_app/services/auth_service.dart';
import 'package:messaging_app/services/user_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? userData;
  bool logoutIsLoading = false;
  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  void fetchUserData() async {
    try {
      final userData = await UserService().getUserDetail();
      setState(() {
        this.userData = userData;
        isLoading = false;
      });
      debugPrint("User Data: $userData");
    } catch (e) {
      debugPrint("Error fetching user data: $e");
    }
  }

  void handleLogout() async {
    final success = await LogoutService().logout();
    debugPrint("Logout Success: $success");
    if (success) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove("token");
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/login',
        (Route<dynamic> route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint(userData.toString());
    return Scaffold(
      body: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 50),
          child: isLoading
              ? const CircularProgressIndicator()
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  spacing: 10,
                  children: [
                    FadeInImage.assetNetwork(
                      width: 200,
                      image:
                          userData!['avatar'] ??
                          "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRH87TKQrWcl19xly2VNs0CjBzy8eaKNM-ZpA&s",
                      placeholder: 'lib/assets/loading.png',
                    ),
                    Text(
                      "Name: ${userData!['username']}",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      "Email: ${userData!['email']}",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.red,
                          textStyle: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        onPressed: () {
                          handleLogout();
                        },
                        child: Text("Logout"),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
