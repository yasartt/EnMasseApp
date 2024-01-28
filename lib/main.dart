import 'dart:io';

import 'package:en_masse_app/Components/Action_post.dart';
import 'package:en_masse_app/BarItems/Explore/explore_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'BarItems/outside_page.dart';
import 'BarItems/Explore/rooms_page.dart';
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

class MyApp extends StatelessWidget {
  final bool isAuthenticated;

  const MyApp({Key? key, required this.isAuthenticated}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
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
  bool isLightTheme = true; // Default to light theme
  int _selectedIndex = 0;
  ColorScheme _currentColorScheme = ColorScheme.fromSwatch(primarySwatch: Colors.blue);

  final PageController _pageController = PageController();
  final List<Widget> _pages = [
    ExplorePage(), // Pass isLightTheme parameter
    RoomsPage(),
    OutsidePage(),
    YourselfPage(),
  ];

  void _onItemTapped(int index) {
    _pageController.jumpToPage(index);
  }

  void _changeColorScheme(ColorScheme newColorScheme, {bool isLightTheme = true}) {
    setState(() {
      _currentColorScheme = newColorScheme;
      this.isLightTheme = isLightTheme;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: _currentColorScheme,
        useMaterial3: true,
      ),
      home: Scaffold(
        backgroundColor: isLightTheme ? Colors.white : Colors.black, // Set background color
        appBar: AppBar(
          backgroundColor: _currentColorScheme.primary,
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
          actions: [
            IconButton(
              icon: Icon(Icons.color_lens),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Choose Color Scheme'),
                      content: Column(
                        children: [
                          _buildColorOption(Colors.blue),
                          _buildColorOption(Colors.green),
                          _buildColorOption(Colors.orange),
                          _buildColorOption(Colors.purple),
                          _buildColorOption(Colors.red),
                          _buildColorOption(Colors.teal),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
            Switch(
              value: isLightTheme,
              onChanged: (value) {
                setState(() {
                  isLightTheme = value;
                  // Update the color scheme based on the selected theme
                  _changeColorScheme(
                    isLightTheme
                        ? ColorScheme.light(primary: Colors.blue, onPrimary: Colors.black)
                        : ColorScheme.dark(primary: Colors.blue, onPrimary: Colors.white),
                    isLightTheme: isLightTheme,
                  );
                });
              },
            ),
          ],
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
            if (_selectedIndex == 0 || _selectedIndex == _pages.length - 1)
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
                  child: Text(
                    'A',
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  backgroundColor: _currentColorScheme.primary,
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
          selectedItemColor: _currentColorScheme.primary,
          onTap: _onItemTapped,
        ),
      ),
    );
  }

  Widget _buildColorOption(Color color, {bool isLightTheme = true}) {
    MaterialColor materialColor = MaterialColor(color.value, {
      50: color,
      100: color,
      200: color,
      300: color,
      400: color,
      500: color,
      600: color,
      700: color,
      800: color,
      900: color,
    });

    return InkWell(
      onTap: () {
        ColorScheme newColorScheme;
        if (isLightTheme) {
          newColorScheme = ColorScheme.light(primary: color, onPrimary: Colors.black);
        } else {
          newColorScheme = ColorScheme.fromSwatch(primarySwatch: materialColor);
        }
        _changeColorScheme(newColorScheme, isLightTheme: isLightTheme);
        Navigator.pop(context);
      },
      child: Container(
        height: 40,
        width: 40,
        color: color,
        margin: EdgeInsets.all(8),
      ),
    );
  }
}
