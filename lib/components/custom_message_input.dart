import 'package:flutter/material.dart';

class CustomMessageInput extends StatelessWidget {
  final TextEditingController controller;
  final bool isRecording;
  final VoidCallback onSend;
  final VoidCallback onOpenFilePicker;
  final VoidCallback onStartRecording;
  final VoidCallback onStopRecording;
  final ValueChanged<String> onTyping;
  const CustomMessageInput({
    super.key,
    required this.controller,
    required this.isRecording,
    required this.onSend,
    required this.onOpenFilePicker,
    required this.onStartRecording,
    required this.onStopRecording,
    required this.onTyping,
  });

  @override
  Widget build(BuildContext context) {
    final outline = const OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(20)),
      borderSide: BorderSide(width: 1, color: Color.fromARGB(255, 6, 120, 214)),
    );
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            IconButton(
              icon: const Icon(Icons.camera_alt),
              color: const Color.fromARGB(255, 6, 120, 214),
              onPressed: onOpenFilePicker,
            ),

            IconButton(
              icon: Icon(isRecording ? Icons.stop : Icons.mic),
              color: isRecording
                  ? Colors.red
                  : Color.fromARGB(255, 6, 120, 214),
              onPressed: () {
                if (isRecording) {
                  onStopRecording();
                } else {
                  onStartRecording();
                }
              },
            ),

            Expanded(
              child: TextField(
                controller: controller,
                onChanged: onTyping,
                minLines: 1,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: "Type a message...",
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  enabledBorder: outline,
                  focusedBorder: outline,
                ),
              ),
            ),

            IconButton(
              icon: const Icon(Icons.send),
              color: const Color.fromARGB(255, 6, 120, 214),
              onPressed: onSend,
            ),
          ],
        ),
      ),
    );
  }
}
