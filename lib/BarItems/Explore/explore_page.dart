import 'package:en_masse_app/BarItems/Explore/rooms_page.dart';
import 'package:en_masse_app/Components/Action_post.dart';
import 'package:flutter/material.dart';
import '../card_details_page.dart';
import 'package:google_fonts/google_fonts.dart';
import '../chat_page.dart';
import '../daily_post.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:en_masse_app/Authentication/authentication.dart';
import 'package:en_masse_app/config.dart';

class ContactDaily extends StatefulWidget {
  @override
  _ContactDailyState createState() => _ContactDailyState();
}

class _ContactDailyState extends State<ContactDaily> with AutomaticKeepAliveClientMixin {
  List<DailyView> dailyViews = [];

  @override
  void initState() {
    super.initState();
    fetchDailyViews();
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
    super.build(context);
    return Column(
      children: [
        Expanded(
          child: Center( // Use Center to position the PageView in the middle of the screen
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: 600, // Maximum height for the content, adjust as needed
                // You can also use MediaQuery to set this relative to screen size, for example:
                // maxHeight: MediaQuery.of(context).size.height * 0.75,
              ),
              child: PageView.builder(
                scrollDirection: Axis.vertical,
                itemCount: dailyViews.length,
                itemBuilder: (context, index) {
                  return ActionPostScreen(dailyView: dailyViews[index]);
                  // Wrap ActionPostScreen with a widget that limits its height, if necessary
                },
              ),
            ),
          ),
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
