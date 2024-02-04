import 'package:en_masse_app/BarItems/rooms_page.dart';
import 'package:en_masse_app/Components/Action_post.dart';
import 'package:flutter/material.dart';
import 'card_details_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'chat_page.dart';
import 'daily_post.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:en_masse_app/Authentication/authentication.dart';
import 'package:en_masse_app/config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'dart:math' as math;

class ContactDaily extends StatefulWidget {
  @override
  _ContactDailyState createState() => _ContactDailyState();
}

class _ContactDailyState extends State<ContactDaily> with AutomaticKeepAliveClientMixin {
  List<DailyView> dailyViews = [];
  PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    fetchDailyViews();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> fetchDailyViews() async {
    final userId = await AuthService.getUserId();

    if (userId == null) {
      // Handle the case where userId is null (not authenticated)
      return;
    }

    final lastTime = DateTime.now(); // Replace with the actual DateTime you want to use

    final response = await http.get(Uri.parse('https://${Config.apiBaseUrl}/api/Daily/GetContactDailiesByUser/$userId/$lastTime'));

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      List<DailyView> loadedDailyViews = data.map((json) => DailyView.fromJson(json)).toList();

      setState(() {
        dailyViews = loadedDailyViews;
      });
    } else {
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Ensure you call super.build(context) when using AutomaticKeepAliveClientMixin
    return Column(
      children: [
        AppBar(
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
                      'Your Contacts'
                  ),
                ),
              ],
            ),
          ),
        Padding(
          padding: EdgeInsets.all(8.0),
          child: Align(
            alignment: Alignment.topLeft,
            child: IconButton(
              icon: Icon(Icons.sunny), // Replace `your_icon` with the desired icon
              onPressed: () {
                // Your icon button action here
              },
            ),
          ),
        ),
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            scrollDirection: Axis.vertical,
            itemCount: dailyViews.length,
            itemBuilder: (context, index) {
              return AnimatedBuilder(
                animation: _pageController,
                builder: (context, child) {
                  double pageOffset = index - (_pageController.page ?? 0);
                  double scale = 1.0;
                  double opacity = 1.0;
                  double translateX = 0.0;
                  double translateY = 0.0;

                  if (pageOffset > 0) {
                    scale = 1 - (pageOffset / 3);
                    opacity = 1 - (pageOffset);
                    //translateX = -(MediaQuery.of(context).size.width / 2) * pageOffset;
                  } else if (pageOffset < 0) {
                    scale = 1 - (-pageOffset / 10);
                    opacity = 1 - (-pageOffset);
                    //translateX = -(MediaQuery.of(context).size.width / 2) * -pageOffset;
                    translateY = (MediaQuery.of(context).size.height / 2) * -pageOffset;
                  }

                  return Transform.scale(
                    scale: scale.clamp(0.0, 1.0),
                    child: Opacity(
                      opacity: opacity.clamp(0.0, 1.0),
                      child: Transform.translate(
                        offset: Offset(translateX, translateY),
                        child: child,
                      ),
                    ),
                  );
                },
                child: ActionPostScreen(dailyView: dailyViews[index]),
              );
            },
          ),
        ),
        Padding(
          padding: EdgeInsets.all(32.0),
          /***child: Align(
            alignment: Alignment.topRight,
            child: IconButton(
              icon: Icon(Icons.sunny), // Replace `your_icon` with the desired icon
              onPressed: () {
                // Your icon button action here
              },
            ),
          ),*/
        ),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true; // Keep the state of the widget across different tabs
}

class DailyView {
  final int dailyId;
  final int userId;
  final String? caption;
  final DateTime? created;
  final List<ImageDTO>? images;

  DailyView({
    required this.dailyId,
    required this.userId,
    this.caption,
    this.created,
    this.images,
  });

  factory DailyView.fromJson(Map<String, dynamic> json) {
    return DailyView(
      dailyId: json['dailyId'] ?? 0,
      userId: json['userId'] ?? 0,
      caption: json['caption'] ?? "",
      created: json['created'] != null ? DateTime.parse(json['created']) : null,
      images: (json['images'] as List<dynamic>?)
          ?.map((image) => ImageDTO.fromJson(image))
          .toList(),
    );
  }
}


class ImageDTO {
  final String id;
  final String imageName;
  final int dailyId;

  ImageDTO({
    required this.id,
    required this.imageName,
    required this.dailyId,
  });

  factory ImageDTO.fromJson(Map<String, dynamic> json) {
    return ImageDTO(
      id: json['id'],
      imageName: json['imageName'],
      dailyId: json['dailyId'],
    );
  }
}