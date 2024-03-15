import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
import 'package:en_masse_app/config.dart';
import 'package:flutter/material.dart';
import 'package:en_masse_app/signalr_service.dart';

import '../Authentication/authentication.dart';

class RoomsPage extends StatefulWidget {
  RoomsPage({Key? key}) : super(key: key);

  @override
  _RoomsPageState createState() => _RoomsPageState();
}

class _RoomsPageState extends State<RoomsPage> with AutomaticKeepAliveClientMixin {
  List<Map<String, dynamic>> cafeList = []; // Updated to store cafes

  @override
  void initState() {
    super.initState();
    fetchCafes(); // Fetch cafes when the page is initialized
  }

  Future<void> fetchCafes() async {
    try {
      // Use Future.timeout to set a timeout for the http request
      final response = await http.get(Uri.parse('https://${Config.apiBaseUrl}/api/Cafe/GetAllCafes'))
          .timeout(Duration(seconds: 5));

      if (response.statusCode == 200) {
        // If the server returns a 200 OK response, parse the JSON
        final List<dynamic> cafes = jsonDecode(response.body);
        setState(() {
          // Update the state with the fetched cafes
          cafeList = cafes.cast<Map<String, dynamic>>();
        });

        // Print the response to the console
        print('Response: ${response.body}');
      } else {
        // If the server did not return a 200 OK response,
        // throw an exception or handle the error as needed.
        throw Exception('Failed to load cafes');
      }
    } on TimeoutException {
      // Handle the case where the request times out
      throw Exception('Request timed out');
    } catch (error) {
      // Handle other errors
      throw Exception('Failed to load cafes: $error');
    }
  }


  Future<void> _refreshCafes() async {
    await fetchCafes();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return DefaultTabController(
      length: 1,
      child: Scaffold(
        /**appBar: PreferredSize(
          preferredSize: Size.fromHeight(kToolbarHeight),
          child: AppBar(
            elevation: 0,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary,
                      width: 2.0,
                    ),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                  child: Text(
                    'Weekly Cafes For You'
                  ),
                ),
              ],
            ),
          ),
        ),*/
        body: RefreshIndicator(
          onRefresh: _refreshCafes,
          child: Column(
            children: [
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(top: 10.0), // Adjust the top padding as needed
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: cafeList.length,
                    itemBuilder: (context, index) {
                      final cafeName = cafeList[index]['name'] as String?;
                      final cafeId = cafeList[index]['cafeId'] as String?;

                      if (cafeName != null && cafeId != null) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (context, animation, secondaryAnimation) =>
                                    CafeDetailsPage(cafeId: cafeId, cafeName: cafeName,),
                                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                  const begin = Offset(0.0, 1.0);
                                  const end = Offset.zero;
                                  const curve = Curves.easeInOut;

                                  var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

                                  var offsetAnimation = animation.drive(tween);

                                  return SlideTransition(
                                    position: offsetAnimation,
                                    child: child,
                                  );
                                },
                              ),
                            );
                          },
                          child: CafeComponent(
                            cafeId: cafeId,
                            cafeName: cafeName,
                            onJoinCafe: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text('Join Cafe'),
                                  content: Text('Are you sure you want to join this cafe?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.of(context).pop(false),
                                      child: Text('No'),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.of(context).pop(true),
                                      child: Text('Yes'),
                                    ),
                                  ],
                                ),
                              );

                              if (confirm == true) {
                                Navigator.of(context).pop(true); // Close the dialog
                                SignalRService().joinCafeGroup(cafeId, AuthService.getUserId() as String); // Join the cafe group
                              }
                            },
                          ),

                        );
                      } else {
                        // Handle the case where 'name' or 'id' is null (if needed)
                        return SizedBox.shrink();
                      }
                    },
                  ),
                ),
              ),
              // Centered Text Widget
              /**Center(
                child: Text(
                  '2 Days Until Next Week',
                  style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                ),
              ),*/
            ],
          ),
        ),

      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class CafeComponent extends StatelessWidget {
  final String cafeId;
  final String cafeName;
  final VoidCallback onJoinCafe; // Callback for when the join button is pressed

  CafeComponent({
    required this.cafeId,
    required this.cafeName,
    required this.onJoinCafe,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      elevation: 30.0,
      child: Container(
        padding: EdgeInsets.all(8.0),
        height: 100,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                cafeName,
                style: TextStyle(fontSize: 18.0),
              ),
            ),
            TextButton(
              onPressed: () => onJoinCafe(),
              child: Text('Join'),
            ),
          ],
        ),
      ),
    );
  }
}

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
  List<Map<String, String>> messages = [];

  @override
  void initState() {
    super.initState();
    _signalRService = SignalRService();

    _signalRService.onMessageReceived = (userName, message) {
      setState(() {
        messages.add({'userName': userName, 'message': message});
      });
    };

    _signalRService.startConnection().then((_) {
      _signalRService.joinCafeGroup(widget.cafeId, AuthService.getUserId() as String);
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
      _signalRService.sendMessage(widget.cafeId, "YourUserName", _messageController.text);
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
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                var message = messages[index];
                return ListTile(
                  title: Text(message['userName'] ?? 'Unknown'),
                  subtitle: Text(message['message'] ?? ''),
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
