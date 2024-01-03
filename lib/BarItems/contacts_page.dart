import 'package:flutter/material.dart';
import 'chat_page.dart';

class ContactsPage extends StatefulWidget {
  ContactsPage({Key? key}) : super(key: key);

  @override
  _ContactsPageState createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> with AutomaticKeepAliveClientMixin {
  final List<String> contactList = ['John Doe', 'Jane Smith', 'Bob Johnson'];

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return DefaultTabController(
      length: 2, // Number of tabs
      child: Scaffold(
        appBar: AppBar(
          title: Text('Your Network'),
          bottom: TabBar(
            tabs: [
              Tab(text: 'Messages'), // First tab
              Tab(text: 'Pals of The Month'), // Second tab
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // First tab content
            StatefulContactList(contactList: contactList),
            // Second tab content
            Center(
              child: Text(
                'Pals of The Month Content',
                style: TextStyle(fontSize: 20.0),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
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
