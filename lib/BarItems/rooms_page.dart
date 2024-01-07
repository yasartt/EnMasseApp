import 'package:flutter/material.dart';
import 'card_details_page.dart';
import 'package:google_fonts/google_fonts.dart';

class RoomsPage extends StatefulWidget {
  RoomsPage({Key? key}) : super(key: key);

  @override
  _RoomsPageState createState() => _RoomsPageState();
}

class _RoomsPageState extends State<RoomsPage> with AutomaticKeepAliveClientMixin {
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
      length: 1, // Number of tabs
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(kToolbarHeight),
          child: AppBar(
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
                    'Explore',
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
        ),
        body: TabBarView(
          children: [
            // First tab content
            StatefulCardList(cardList: cardList),
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
