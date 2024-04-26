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
import 'cafe_details_page.dart';

class RoomsPage extends StatefulWidget {
  RoomsPage({Key? key}) : super(key: key);

  @override
  _RoomsPageState createState() => _RoomsPageState();
}

class _RoomsPageState extends State<RoomsPage> with AutomaticKeepAliveClientMixin {
  //Initial values can be from local storage (drift).
  List<Map<String, dynamic>> enrolledCafeList = [];
  List<Map<String, dynamic>> cafeList = [];

  int selectedIndex = 0;

  void _onSelectionChanged(int selectionIndex) {
    setState(() {
      // how many list we have will be the second parameter for clamp method.
      selectedIndex = selectionIndex.clamp(0, 1);
    });
  }

  late SignalRService _signalRService;

  @override
  void initState() {
    super.initState();
    _signalRService = SignalRService();
    _initializeSignalR();
    fetchCafes();
  }

  Future<void> _initializeSignalR() async {
    String? userId = await AuthService.getUserId();
    if (userId != null) {
      await _signalRService.startConnection();
    } else {
      print('User ID is null. Please ensure the user is logged in.');
    }
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

    return Scaffold(
        body: RefreshIndicator(
          onRefresh: _refreshCafes,
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 20),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                height: 40,
                child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      SelectionBox(
                        text: "Enrolled",
                        isSelected: selectedIndex == 0,
                        onSelectionChanged: _onSelectionChanged,
                        width: 80,
                        selectedIndex: selectedIndex,
                      ),
                      SizedBox(width: 10), // Space between boxes
                      SelectionBox(
                        text: "All",
                        isSelected: selectedIndex == 1,
                        onSelectionChanged: _onSelectionChanged,
                        width: 80,
                        selectedIndex: selectedIndex,
                      ),
                    ],
                    ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(top: 10.0),
                  child: selectedIndex == 0 ? _buildEnrolledCafes() : _buildAllCafes(),
                ),
              ),
            ],
          ),
        ),
      );
  }

  Widget _buildEnrolledCafes() {
    // Placeholder for enrolled cafes content
    return ListView.builder(
      itemCount: enrolledCafeList.length,
      itemBuilder: (context, index) {
        final cafeName = enrolledCafeList[index]['name'] as String?;
        final cafeId = enrolledCafeList[index]['cafeId'] as String?;
        return ListTile(
          title: Text(cafeName ?? "No Name"),
          subtitle: Text("Enrolled Cafe ID: $cafeId"),
        );
      },
    );
  }

  Widget _buildAllCafes() {
    // Placeholder for all cafes content
    return ListView.builder(
      itemCount: cafeList.length,
      itemBuilder: (context, index) {
        final cafeName = cafeList[index]['name'] as String?;
        final cafeId = cafeList[index]['cafeId'] as String?;
        return ListTile(
          title: Text(cafeName ?? "No Name"),
          subtitle: Text("Cafe ID: $cafeId"),
        );
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class SelectionBox extends StatelessWidget {
  final String text;
  final bool isSelected;
  final Function(int) onSelectionChanged;
  final int selectedIndex;
  final double width;

  const SelectionBox({
    required this.text,
    required this.isSelected,
    required this.onSelectionChanged,
    required this.selectedIndex,
    this.width = 80.0,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onSelectionChanged(isSelected ? 1 - selectedIndex : selectedIndex),
      child: Card(
        color: isSelected ? Colors.black : Colors.white,
        child: Container(
          width: width,
          // Adjust padding based on available height
          padding: EdgeInsets.symmetric(vertical: 6.0, horizontal: 12.0),
          child: Center(
            child: FittedBox( // Ensures the text scales down to fit the available space
              fit: BoxFit.scaleDown,
              child: Text(
                text,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black,
                  fontSize: 12.0,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4.0),
        ),
        elevation: 4.0,
      ),
    );
  }
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
