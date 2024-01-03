import 'package:flutter/material.dart';
import 'card_details_page.dart';
import 'package:google_fonts/google_fonts.dart';

class FirstTabContent extends StatelessWidget {
  final List<Map<String, String>> cardList;

  FirstTabContent({required this.cardList});

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
                'Currently Enrolled Rooms',
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
      body: Column(
        children: [
          Expanded(
            child: StatefulCardList(cardList: cardList),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Handle FloatingActionButton click
          // You can navigate to another page or perform any action here
          print('FloatingActionButton Clicked');
        },
        child: Icon(Icons.add),
      ),
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
                'Explore new rooms and new people',
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
      body: Center(
        child: Text(
          'Explore kinda rooms',
          style: TextStyle(fontSize: 20.0),
        ),
      ),
    );
  }
}

class OutsidePage extends StatefulWidget {
  OutsidePage({Key? key}) : super(key: key);

  @override
  _OutsidePageState createState() => _OutsidePageState();
}

class _OutsidePageState extends State<OutsidePage> with AutomaticKeepAliveClientMixin {
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
                  icon: Icon(Icons.hail),
                ),
                Tab(
                  icon: Icon(Icons.nature_people_sharp),
                ),
              ],
            ),
          ),
        ),
        body: TabBarView(
          children: [
            // First tab content
            FirstTabContent(cardList: cardList),
            // Second tab content
            SecondTabContent(),
          ],
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
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
