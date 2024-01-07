import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'BarItems/outside_page.dart';
import 'BarItems/rooms_page.dart';
import 'BarItems/yourself_page.dart';
import 'package:en_masse_app/Authentication/authentication.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Check if the user is already authenticated
  bool isAuthenticated = await AuthService.checkAuthentication();

  runApp(MyApp(isAuthenticated: isAuthenticated));
}

class MyApp extends StatelessWidget {
  final bool isAuthenticated;

  const MyApp({Key? key, required this.isAuthenticated}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
        useMaterial3: true,
      ),
      home: isAuthenticated ? MyHomePage(title: 'Enteract') : LoginPage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;

  final PageController _pageController = PageController();
  final List<Widget> _pages = [
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
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(
          widget.title,
          style: GoogleFonts.pacifico(
            textStyle: TextStyle(
              fontSize: 20.0,
            ),
          ),
        ),
        centerTitle: true,
      ),
      body: PageView(
        controller: _pageController,
        children: _pages,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.people_sharp),
            label: 'Outside',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.waving_hand_sharp),
            label: 'Contacts',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'You',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        onTap: _onItemTapped,
      ),
    );
  }
}
