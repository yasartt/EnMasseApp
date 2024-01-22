import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:en_masse_app/main.dart';
import 'package:en_masse_app/Authentication/authentication.dart';

class YourselfPage extends StatelessWidget {
  const YourselfPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          title: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).colorScheme.primary,
                width: 2.0,
              ),
              borderRadius: BorderRadius.circular(10.0),
            ),
            padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
            child: Text(
              'Yourself',
              style: GoogleFonts.pacifico(
                textStyle: TextStyle(
                  fontSize: 18.0,
                ),
              ),
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.settings),
              onPressed: () {
                _showLogoutDialog(context);
              },
            ),
          ],
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(15),
                  image: DecorationImage(
                    image: AssetImage('assets/images/Bio.jpg'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(width: 30),
              FutureBuilder<String?>(
                future: AuthService.getUsername(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    String? username = snapshot.data;

                    return username != null
                        ? Text(
                      username,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                        : Text('No username found');
                  }
                },
              ),

            ],
          ),
          SizedBox(height: 50),
          Expanded(
            child: AnotherPage(),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Logout'),
          content: Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Perform logout actions, e.g., clear SharedPreferences
                // and navigate to the main screen
                AuthService.logout(); // Implement your logout logic here
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => MyApp(isAuthenticated: false)), // Replace 'false' with the actual authentication status
                      (route) => false,
                );
              },
              child: Text('Logout'),
            ),
          ],
        );
      },
    );
  }
}

class AnotherPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'My Actions',
          style: GoogleFonts.openSans(
            textStyle: TextStyle(
              fontSize: 18.0,
            ),
          ),
        ),
        /**actions: [
          IconButton(
            icon: Icon(Icons.calendar_today),
            onPressed: () {
              YourselfPage()._showCalendarDialog(context);
            },
          ),
        ],*/
        elevation: 5,
        backgroundColor: Colors.white,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(4.0), // Specify the desired height
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                  width: 2.0,
                ),
              ),
            ),
          ),
        ),
        // Add a top border
        flexibleSpace: PreferredSize(
          preferredSize: Size.fromHeight(4.0),
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                  width: 2.0,
                ),
              ),
            ),
          ),
        ),
      ),
      body: Center(
        child: Text('This is another page'),
      ),
    );
  }
}


class CalendarWidget extends StatefulWidget {
  @override
  _CalendarWidgetState createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<CalendarWidget> {
  late DateTime _currentDate;

  @override
  void initState() {
    super.initState();
    _currentDate = DateTime.now();
  }

  void _previousMonth() {
    setState(() {
      _currentDate = DateTime(_currentDate.year, _currentDate.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _currentDate = DateTime(_currentDate.year, _currentDate.month + 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      child: Container(
        padding: EdgeInsets.all(5),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: _previousMonth,
                ),
                Text(
                  DateFormat('MMMM yyyy').format(_currentDate),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (!isCurrentMonth())
                  IconButton(
                    icon: Icon(Icons.arrow_forward),
                    onPressed: _nextMonth,
                  ),
              ],
            ),
            SizedBox(height: 20),
            Container(
              width: 300,
              child: GridView.builder(
                shrinkWrap: true,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  mainAxisSpacing: 1.0,
                  crossAxisSpacing: 1.0,
                ),
                itemCount: _getDaysInMonth(_currentDate.year, _currentDate.month),
                itemBuilder: (context, index) {
                  final day = index + 1;
                  return GestureDetector(
                    onTap: () {
                      print('Clicked on day: $day');
                    },
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.5),
                        border: Border.all(color: Colors.white),
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                      child: Center(
                        child: Text(
                          '$day',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  int _getDaysInMonth(int year, int month) {
    return DateTime(year, month + 1, 0).day;
  }

  bool isCurrentMonth() {
    final now = DateTime.now();
    return _currentDate.year == now.year && _currentDate.month == now.month;
  }
}