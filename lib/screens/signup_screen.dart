import 'package:flutter/material.dart';
import 'package:messaging_app/components/login_input.dart';
import 'package:messaging_app/services/auth_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
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
                  LoginInput(
                    label: "User Name",
                    controller: usernameController,
                  ),
                  const SizedBox(height: 30),
                  LoginInput(label: "Email", controller: emailController),
                  const SizedBox(height: 30),
                  LoginInput(label: "Password", controller: passwordController),
                  Row(
                    spacing: 0.0,
                    children: [
                      Text("Already have an account?"),
                      TextButton(
                        style: TextButton.styleFrom(padding: EdgeInsets.all(5)),
                        onPressed: () {
                          Navigator.pushNamed(context, '/login');
                        },
                        child: Text(
                          "Login",
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
                        final response = await SignupService().signup(
                          usernameController.text,
                          emailController.text,
                          passwordController.text,
                        );
                        if (response["success"] == true) {
                          Navigator.pushNamed(context, "/login");
                        } else {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: Text("Signup Failed"),
                                content: Text(response['error']),
                              );
                            },
                          );
                        }
                      },
                      child: Text("Sign Up"),
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
