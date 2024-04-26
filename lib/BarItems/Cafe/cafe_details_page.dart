import 'dart:async';
import 'package:en_masse_app/BarItems/Cafe/session_message.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
import 'package:en_masse_app/config.dart';
import 'package:flutter/material.dart';
import 'package:en_masse_app/signalr_service.dart';
import '../../Authentication/authentication.dart';

class MessageBubble extends StatelessWidget {
  final String senderUsername;
  final String message;
  final String time; // Added time property

  MessageBubble({
    required this.senderUsername,
    required this.message,
    required this.time, // Added time property
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 2.0),
          child: Text(
            senderUsername,
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 12.0,
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.only(left: 12.0, right: 12.0, bottom: 2.0),
          padding: EdgeInsets.all(10.0),
          decoration: BoxDecoration(
            color: Colors.transparent,
            border: Border.all(
              color: Colors.blue,
              width: 1.0,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                message,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 12.0,
                ),
              ),
            ],
          ),
        ),
        Align(
          alignment: Alignment.bottomRight,
          child: Padding(
            padding: const EdgeInsets.only(right: 12.0, bottom: 0.5),
            child: Text(
              time,
              style: TextStyle(
                color: Colors.black,
                fontSize: 10.0, // Smaller font size for time
              ),
            ),
          ),
        ),
        Divider(
          thickness: 1.0,
          color: Colors.grey,
          indent: 12.0,
          endIndent: 12.0,
        ),
      ],
    );
  }
}

class CafeDetailsPage extends StatefulWidget {
  final String cafeId;
  final String cafeName;

  CafeDetailsPage({Key? key, required this.cafeId, required this.cafeName}) : super(key: key);

  @override
  _CafeDetailsPageState createState() => _CafeDetailsPageState();
}

class _CafeDetailsPageState extends State<CafeDetailsPage> {
  late SignalRService _signalRService;
  final TextEditingController _messageController = TextEditingController();
  Box<SessionMessage>? messagesBox;

  @override
  void initState() {
    super.initState();
    _signalRService = SignalRService();
    messagesBox = Hive.box<SessionMessage>('sessionMessages');

    _signalRService.onMessageReceived = (userName, messageJson) {
      final messageMap = jsonDecode(messageJson) as Map<String, dynamic>;
      final message = SessionMessage.fromJson(messageMap);
      messagesBox?.add(message);
      // Trigger UI update
      if (mounted) setState(() {});
    };

    _signalRService.startConnection().then((_) {
      AuthService.getUserId().then((userId) {
        if (userId != null) {
          _signalRService.joinCafeGroup(widget.cafeId, userId);
        } else {
          print('User ID is null');
        }
      }).catchError((error) {
        print('Error getting user ID: $error');
      });
    });
  }

  @override
  void dispose() {
    _signalRService.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_messageController.text.isNotEmpty) {
      _signalRService.sendMessage(_messageController.text);
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.cafeName),
      ),
      body: Column(
        children: [
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: messagesBox!.listenable(), // Listen for changes in the box
              builder: (context, Box<SessionMessage> box, _) {
                // Filter messages by cafeId
                List<SessionMessage> messages = box.values.where((message) => message.cafeId == widget.cafeId).toList();

                return ListView.builder(
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    SessionMessage message = messages[index];
                    return ListTile(
                      title: Text(message.senderId), // Assuming you want to display the senderId as title
                      subtitle: Text(message.content),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      labelText: 'Type a message',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}