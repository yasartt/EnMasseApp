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

class ExplorePage extends StatefulWidget {
  ExplorePage({Key? key}) : super(key: key);

  @override
  _ExplorePageState createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> with AutomaticKeepAliveClientMixin {

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(kToolbarHeight),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: SizedBox.shrink(), // Empty SizedBox to remove the title
            bottom: TabBar(
              tabs: [
                Tab(
                  icon: Icon(Icons.hail_outlined),
                ),
                Tab(
                  icon: Icon(Icons.travel_explore),
                ),
              ],
            ),
          ),
        ),
        body: TabBarView(
          children: [
            // First tab content
            FirstTabContent(),
            // Second tab content
            SecondTabContent(), // Pass the contactList to SecondTabContent
          ],
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class FirstTabContent extends StatefulWidget {
  @override
  _FirstTabContentState createState() => _FirstTabContentState();
}

class _FirstTabContentState extends State<FirstTabContent> {
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
      // You may navigate to the login page or take appropriate action
      return;
    }

    final lastTime = DateTime.now(); // Replace with the actual DateTime you want to use

    final response = await http.get(Uri.parse('https://192.168.1.38:7181/api/Daily/GetContactDailiesByUser/$userId/$lastTime'));

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
    return Column( // Wrap with a Column widget
      children: [
        Expanded(
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: dailyViews.length,
            itemBuilder: (context, index) {
              return ActionPostScreen(dailyView: dailyViews[index]);
            },
          ),
        ),
      ],
    );
  }
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

class SecondTabContent extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //backgroundColor: Colors.black, // Set background color
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
                'People For You'
              ),
            ),
          ],
        ),
      ),
      /**body: Column(
          children: [
          Expanded(
          child: ,
          ),
          ],
          ),*/
    );
  }
}


class StatefulContactList extends StatefulWidget {
  final List<String> contactList;

  StatefulContactList({required this.contactList});

  @override
  _StatefulContactListState createState() => _StatefulContactListState();
}

class _StatefulContactListState extends State<StatefulContactList> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget.contactList.length,
      itemBuilder: (context, index) {
        return ContactTile(contactName: widget.contactList[index]);
      },
    );
  }
}

class ContactTile extends StatelessWidget {
  final String contactName;

  const ContactTile({Key? key, required this.contactName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2.0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatPage(contactName: contactName),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(12.0),
          child: Text(
            contactName,
            style: TextStyle(fontSize: 18.0),
          ),
        ),
      ),
    );
  }
}