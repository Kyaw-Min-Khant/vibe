import 'package:flutter/material.dart';
import 'package:messaging_app/components/login_input.dart';
import 'package:messaging_app/services/auth_service.dart';
import 'package:messaging_app/services/firebase_messaging_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> saveToken(String token, String userId, String userName) async {
  final pref = await SharedPreferences.getInstance();
  await pref.setString("token", token);
  await pref.setString('user_id', userId);
  await pref.setString('user_name', userName);
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue, Colors.purple],
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Color.fromARGB(162, 255, 255, 255),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Messaging App",
                    style: TextStyle(
                      color: const Color.fromARGB(255, 0, 140, 255),
                      fontSize: 26,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 30),
                  LoginInput(label: "User Name", controller: emailController),
                  const SizedBox(height: 30),
                  LoginInput(label: "Password", controller: passwordController),
                  Row(
                    spacing: 0.0,
                    children: [
                      Text("Don't have an account?"),
                      TextButton(
                        style: TextButton.styleFrom(padding: EdgeInsets.all(5)),
                        onPressed: () {
                          Navigator.pushNamed(context, '/signup');
                        },
                        child: Text(
                          "Sign up",
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 50.0,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: const Color.fromARGB(255, 0, 140, 255),
                        textStyle: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadiusGeometry.all(
                            Radius.circular(5),
                          ),
                        ),
                      ),
                      onPressed: () async {
                        final fcmToken = await FirebaseMessagingService.instance
                            .getFcmToken();
                        debugPrint("FCM Token:");
                        debugPrint(fcmToken);
                        if (fcmToken == null) {
                          debugPrint("FCM Token is null");
                          return;
                        }
                        final response = await LoginService().login(
                          emailController.text,
                          passwordController.text,
                          fcmToken,
                        );

                        if (response.success) {
                          debugPrint(response.data!.user.id);
                          saveToken(
                            response.data!.token,
                            response.data!.user.id,
                            response.data!.user.username,
                          );
                          Navigator.pushReplacementNamed(context, '/home');
                        } else {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text("Login Failed"),
                                content: Text(
                                  response.message ?? "Something went wrong",
                                ),
                                actions: [
                                  TextButton(
                                    child: const Text("OK"),
                                    onPressed: () => Navigator.pop(context),
                                  ),
                                ],
                              );
                            },
                          );
                        }
                      },

                      child: Text("Login"),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
