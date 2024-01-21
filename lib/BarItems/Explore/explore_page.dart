import 'package:en_masse_app/BarItems/Explore/rooms_page.dart';
import 'package:flutter/material.dart';
import '../card_details_page.dart';
import 'package:google_fonts/google_fonts.dart';
import '../chat_page.dart';
import '../daily_post.dart';

class ExplorePage extends StatefulWidget {
  ExplorePage({Key? key}) : super(key: key);

  @override
  _ExplorePageState createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> with AutomaticKeepAliveClientMixin {
  final List<Map<String, String>> cardList = [
    {"cardNumber": "1", "description": "Description 1"},
    {"cardNumber": "2", "description": "Description 2"},
    {"cardNumber": "2", "description": "Description 2"},
    {"cardNumber": "8", "description": "Description 2"},
    {"cardNumber": "8", "description": "Description 2"},
    {"cardNumber": "8", "description": "Description 2"},
    {"cardNumber": "8", "description": "Description 2"},
    {"cardNumber": "8", "description": "Description 2"},
    {"cardNumber": "8", "description": "Description 2"},
    {"cardNumber": "8", "description": "Description 2"},
    {"cardNumber": "8", "description": "Description 2"},
    // Add more entries as needed
  ];

  final List<String> contactList = ['John Doe', 'Jane Smith', 'Bob Johnson'];


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

class FirstTabContent extends StatelessWidget {
  // Assuming this list contains your DailyPost data
  final List<Map<String, String>> dailyPosts = [
    {"profilePhotoUrl": "assets/images/Bio.jpg", "username": "User1", "postPhotoUrl": "assets/images/screenshot_example.jpg", "caption": "Caption 1"},
    {"profilePhotoUrl": "assets/images/Bio.jpg", "username": "User1", "postPhotoUrl": "assets/images/examplethreeuzun.png", "caption": "Caption 1Caption 1Caption 1Caption 1Caption 1Caption 1Caption 1Caption 1Caption 1Caption 1Caption 1Caption 1Caption 1Caption 1Caption 1Caption 1Caption 1"},
    {"profilePhotoUrl": "assets/images/Bio.jpg", "username": "User1", "postPhotoUrl": "assets/images/travisladder.jpg", "caption": "Caption 1"},
    {"profilePhotoUrl": "assets/images/Bio.jpg", "username": "User1", "postPhotoUrl": "assets/images/examplepostlocation.png", "caption": "Caption 1"},
    {"profilePhotoUrl": "assets/images/Bio.jpg", "username": "User1", "postPhotoUrl": "assets/images/screenshot_example.jpg", "caption": "Caption 1"},
    {"profilePhotoUrl": "assets/images/Bio.jpg", "username": "User1", "postPhotoUrl": "assets/images/yatay.jpg", "caption": "Caption 1"},


    // Add more entries as needed
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
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
                'Your Contacts',
                style: GoogleFonts.pacifico(
                  textStyle: TextStyle(
                    fontSize: 20.0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      body: ListView.builder(
        itemCount: dailyPosts.length,
        itemBuilder: (context, index) {
          final post = dailyPosts[index];
          return DailyPost(
            profilePhotoUrl: post["profilePhotoUrl"]!,
            username: post["username"]!,
            postPhotoUrl: post["postPhotoUrl"]!,
            caption: post["caption"]!,
          );
        },
      ),
    );
  }
}

class StatefulDailyPost extends StatefulWidget {
  @override
  _StatefulDailyPostState createState() => _StatefulDailyPostState();
}

class _StatefulDailyPostState extends State<StatefulDailyPost> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        DailyPost(
          profilePhotoUrl: 'assets/images/Bio.jpg',
          username: 'Username',
          postPhotoUrl: 'assets/images/travisladder.jpg',
          caption: 'Caption goes here...',
        ),
        // Add more Daily posts as needed
      ],
    );
  }
}

class SecondTabContent extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
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
                'People For You',
                style: GoogleFonts.pacifico(
                  textStyle: TextStyle(
                    fontSize: 20.0,
                  ),
                ),
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

class StatefulCardList extends StatefulWidget {
  final List<Map<String, String>> cardList;

  StatefulCardList({required this.cardList});

  @override
  _StatefulCardListState createState() => _StatefulCardListState();
}

class _StatefulCardListState extends State<StatefulCardList> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: widget.cardList.map((card) {
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CardDetailsPage(
                  cardNumber: int.parse(card['cardNumber']!),
                ),
              ),
            );
          },
          child: Card(
            child: ListTile(
              title: Text('Card ${card['cardNumber']}'),
              subtitle: Text(card['description']!),
            ),
          ),
        );
      }).toList(),
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