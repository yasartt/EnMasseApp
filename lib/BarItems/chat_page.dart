import 'package:flutter/material.dart';

class ChatPage extends StatelessWidget {
  final String contactName;

  const ChatPage({Key? key, required this.contactName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat with $contactName'),
      ),
      body: Center(
        child: Text('This is the chat with $contactName'),
      ),
    );
  }
}
