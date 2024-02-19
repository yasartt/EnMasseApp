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
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:en_masse_app/Components/daily_view.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) =>
      true;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = MyHttpOverrides();

  final appDocumentDir = await getApplicationDocumentsDirectory();
  Hive.init(appDocumentDir.path);

  // Register adapters
  Hive.registerAdapter(DailyViewAdapter());
  Hive.registerAdapter(ImageDTOAdapter());

  // Open Hive box
  await Hive.openBox<DailyView>('dailyViews');

  bool isAuthenticated = await AuthService.checkAuthentication();
  runApp(MyApp(isAuthenticated: isAuthenticated));
}


Map<int, Color> coolYellowSwatch = {
  50: Color(0xFFFFF9E8), // Lightest
  100: Color(0xFFFFF3C2),
  200: Color(0xFFFFED9B),
  300: Color(0xFFFFE774),
  400: Color(0xFFFFE14D),
  500: Color(0xFFFFDB26), // Base color
  600: Color(0xFFE6C423),
  700: Color(0xFFCCAD1F),
  800: Color(0xFFB3961B),
  900: Color(0xFF997F17), // Darkest
};

MaterialColor customCoolYellow = MaterialColor(0xFFFFDB26, coolYellowSwatch);

Map<int, Color> darkCoolYellowSwatch = {
  50: Color(0xFFE6C423), // Lightest in dark theme
  100: Color(0xFFCCAD1F),
  200: Color(0xFFB3961B),
  300: Color(0xFF997F17),
  400: Color(0xFF806814),
  500: Color(0xFF665211), // Base color for dark theme
  600: Color(0xFF4C3C0E),
  700: Color(0xFF33260B),
  800: Color(0xFF191307),
  900: Color(0xFF000000), // Darkest in dark theme
};

MaterialColor customDarkCoolYellow = MaterialColor(0xFFCCAD1F, darkCoolYellowSwatch);

class MyApp extends StatelessWidget {
  final bool isAuthenticated;

  const MyApp({Key? key, required this.isAuthenticated}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: customCoolYellow,
        fontFamily: GoogleFonts.roboto().fontFamily,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: customDarkCoolYellow,
        fontFamily: GoogleFonts.roboto().fontFamily,
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