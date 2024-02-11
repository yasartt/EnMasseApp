import 'dart:io';

import 'package:en_masse_app/BarItems/explore_daily_page.dart';
import 'package:en_masse_app/Components/Action_post.dart';
import 'package:en_masse_app/BarItems/contact_daily_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'BarItems/outside_page.dart';
import 'BarItems/rooms_page.dart';
import 'BarItems/yourself_page.dart';
import 'package:en_masse_app/Authentication/authentication.dart';
import 'new_action.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) =>
      true;
  }
}

void main() async {
  HttpOverrides.global = MyHttpOverrides();

  WidgetsFlutterBinding.ensureInitialized();

  // Check if the user is already authenticated
  bool isAuthenticated = await AuthService.checkAuthentication();

  runApp(MyApp(isAuthenticated: isAuthenticated));
}

Map<int, Color> neonGreenSwatch = {
  50: Color(0xFFE8FFD6),
  100: Color(0xFFC2FFAD),
  200: Color(0xFF9BFF84),
  300: Color(0xFF74FF5B),
  400: Color(0xFF4DFF32),
  500: Color(0xFF33FF00), // base color
  600: Color(0xFF29CC00),
  700: Color(0xFF1F9900),
  800: Color(0xFF146600),
  900: Color(0xFF0A3300),
};

MaterialColor customNeonGreen = MaterialColor(0xFF33FF00, neonGreenSwatch);


class MyApp extends StatelessWidget {
  final bool isAuthenticated;

  const MyApp({Key? key, required this.isAuthenticated}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.lightBlue,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.lightBlue,
      ),
      themeMode: ThemeMode.system, // Use system theme mode
      home: isAuthenticated ? MyHomePage(title: 'Enteract') : LoginPage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;

  final PageController _pageController = PageController();
  final List<Widget> _pages = [
    ContactDaily(),
    ExplorePage(),
    RoomsPage(),
    OutsidePage(),
    YourselfPage(),
  ];

  void _onItemTapped(int index) {
    _pageController.jumpToPage(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              widget.title,
              style: GoogleFonts.pacifico(
                textStyle: TextStyle(
                  fontSize: 20.0,
                ),
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          PageView(
            physics: NeverScrollableScrollPhysics(),
            controller: _pageController,
            children: _pages,
            onPageChanged: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
          ),
          if (_selectedIndex == 0 || _selectedIndex == 1)
            Positioned(
              bottom: 16.0,
              right: 16.0,
              child: FloatingActionButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => NewActionPage()),
                  );
                },
                child: Icon(Icons.add),
                backgroundColor: Theme.of(context).colorScheme.primary,
              ),
            ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.today_outlined),
            label: 'Daily',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.travel_explore),
            label: 'Entheria',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_cafe_outlined),
            label: 'Cafe',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_outlined),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_2_outlined),
            label: 'You',
          ),
        ],
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        onTap: _onItemTapped,
      ),
    );
  }
}