import 'package:flutter/material.dart';
import 'card_details_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'chat_page.dart';

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
                'Enrolled Rooms',
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
    );
  }
}


class SecondTabContent extends StatelessWidget {
  final List<String> contactList;

  SecondTabContent({required this.contactList});

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
                'Contacts',
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
      body: StatefulContactList(contactList: contactList),
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
                  icon: Icon(Icons.hail),
                ),
                Tab(
                  icon: Icon(Icons.people),
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
            SecondTabContent(contactList: contactList), // Pass the contactList to SecondTabContent
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
