import 'package:flutter/material.dart';

class LoginInput extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  const LoginInput({super.key, required this.label, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        labelText: label,
      ),
    );
  }
}
