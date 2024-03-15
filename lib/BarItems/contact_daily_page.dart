import 'dart:async';
import 'package:en_masse_app/BarItems/explore_daily_page.dart';
import 'package:en_masse_app/BarItems/rooms_page.dart';
import 'package:en_masse_app/Components/Action_post.dart';
import 'package:flutter/material.dart';
import 'card_details_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'chat_page.dart';
import 'daily_post.dart';
import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:en_masse_app/Authentication/authentication.dart';
import 'contact_daily_page.dart';
import 'dart:math';
import 'package:en_masse_app/config.dart';
import 'package:en_masse_app/Components/daily_view.dart';

class ContactDaily extends StatefulWidget {
  ContactDaily({Key? key}) : super(key: key);

  @override
  _ContactDailyState createState() => _ContactDailyState();
}

class RoundedIndicator extends Decoration {
  final Color color; // Add a color field to pass to the painter

  RoundedIndicator({required this.color}); // Constructor requires a color

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    return _RoundedPainter(this, color, onChanged); // Pass the color to the painter
  }
}


class _RoundedPainter extends BoxPainter {
  final RoundedIndicator decoration;
  final Color color; // Add a color field

  _RoundedPainter(this.decoration, this.color, VoidCallback? onChanged)
      : super(onChanged);

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final Paint paint = Paint()
      ..color = color // Use the passed color
      ..style = PaintingStyle.fill;
    final Rect rect = offset & configuration.size!;
    final RRect roundedRect = RRect.fromRectAndRadius(rect, Radius.circular(8));
    canvas.drawRRect(roundedRect, paint);
  }
}


class _ContactDailyState extends State<ContactDaily> with AutomaticKeepAliveClientMixin {

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return
      DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(kToolbarHeight),
            child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: SizedBox.shrink(), // Empty SizedBox to remove the title
            bottom: TabBar(
              //indicator: RoundedIndicator(color: Theme.of(context).colorScheme.primary),
              tabs: [
                Tab(
                  icon: Icon(Icons.hail),
                ),
                Tab(
                  icon: Icon(Icons.travel_explore)
                ),
              ],
            ),
            ),
          ),
          body: TabBarView(
          children: [
            FirstTabContent(),
            ExplorePage(),
          ],
          ),
        ),
      );
  }

  @override
  bool get wantKeepAlive => true;
}

class FirstTabContent extends StatefulWidget {
  @override
  _FirstTabContentState createState() => _FirstTabContentState();
}

class _FirstTabContentState extends State<FirstTabContent> {
  List<DailyView> dailyViews = [];
  PageController _pageController = PageController();
  bool _isDataLoaded = false;
  StreamSubscription? _boxSubscription; // Declare a subscription variable
  int _currentIndex = 0;
  bool _shouldUpdatePageController = false; // Flag to indicate when to update the PageController

  @override
  void initState() {
    super.initState();
    _initializeDataAndListenToBox();
  }

  void _initializeDataAndListenToBox() async {
    final userId = await AuthService.getUserId();
    if (userId == null) return;

    // Ensure the Hive box for DailyView is opened before accessing it
    final box = await Hive.openBox<DailyView>('contactsPosts');
    _updateDailyViewsList(box.values.toList());

    _boxSubscription = box.watch().listen((event) {
      _updateDailyViewsList(box.values.toList());
    });

    await fetchDailyViews();
  }


  void _updateDailyViewsList(List<DailyView> updatedList) {
    setState(() {
      dailyViews = updatedList;
      _isDataLoaded = true;
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _boxSubscription?.cancel(); // Cancel the subscription when disposing
    super.dispose();
  }

  Future<void> fetchDailyViews() async {
    final userId = await AuthService.getUserId();
    if (userId == null) {
      // Handle the case where userId is null (not authenticated)
      return;
    }

    final box = Hive.box<DailyView>('contactsPosts');

    final oneWeekAgo = DateTime.now().subtract(Duration(days: 7));

    List<dynamic> keysToDelete = [];

    box.toMap().forEach((key, dailyView) {
      if (dailyView.created != null && dailyView.created!.isBefore(oneWeekAgo)) {
        keysToDelete.add(key);
      }
    });

    for (var key in keysToDelete) {
      await box.delete(key);
    }

    final lastTime = dailyViews.isNotEmpty ? dailyViews.last.created?.toIso8601String() : null;
    final lastDailyId = dailyViews.isNotEmpty ? dailyViews.last.dailyId : null;

    final url = Uri.parse('https://${Config.apiBaseUrl}/api/Daily/GetContactDailiesByUser');
    final body = jsonEncode({
      'userId': userId,
      'lastTime': lastTime,
      'lastDailyId': lastDailyId
    });

    final response = await http.post(url, headers: {'Content-Type': 'application/json'}, body: body);
    print('Try');
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      List<DailyView> loadedDailyViews = data.map((json) => DailyView.fromJson(json)).toList();

      if (loadedDailyViews.isNotEmpty) {
        var existingLengthIndex = dailyViews.length - 1;
        // Assuming successful response with data
        box.addAll(loadedDailyViews); // Adds new data to the Hive box
        setState(() {
          dailyViews = box.values.toList(); // Refresh the list from the box to include new items
          _isDataLoaded = true;
          _currentIndex = existingLengthIndex + 1;
          _shouldUpdatePageController = true;
        });
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_shouldUpdatePageController) {
            print('Here 1');
            //_pageController = PageController(initialPage: _currentIndex);
            _pageController.animateToPage(
              _currentIndex,
              duration: Duration(milliseconds: 900), // Duration of the animation
              curve: Curves.easeInOut, // Animation curve
            );
            _shouldUpdatePageController = false; // Reset the flag
            setState(() {}); // Trigger a rebuild with the updated PageController
          }
        });

      }
    } else {
      setState(() {
        _currentIndex = dailyViews.length - 1;
        _shouldUpdatePageController = true;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_shouldUpdatePageController) {
          print('Here 2');
          print(_currentIndex);
          //_pageController = PageController(initialPage: _currentIndex);
          _pageController.animateToPage(
            _currentIndex,
            duration: Duration(milliseconds: 900), // Duration of the animation
            curve: Curves.easeInOut, // Animation curve
          );
          setState(() {
            _shouldUpdatePageController = false;
          }); // Trigger a rebuild with the updated PageController
        }
      });
      // No new data to add, but let's ensure the user is taken to the latest available view
      if (_pageController.hasClients && dailyViews.isNotEmpty) {
        setState(() {
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return
      Column(
          children: [
            /*AppBar(
              elevation: 0,
              backgroundColor: Colors.transparent,
              title: Stack(
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Theme
                              .of(context)
                              .colorScheme
                              .primary,
                          width: 2.0,
                        ),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      padding: EdgeInsets.symmetric(
                          horizontal: 12.0, vertical: 6.0),
                      child: Text('Your Contacts'),
                    ),
                  ),
                  /**Positioned(
                    left: 0,
                    child: IconButton(
                      icon: Icon(Icons.sunny_snowing),
                      onPressed: () {
                        // Your icon button action here
                      },
                    ),
                  ),*/
                ],
              ),
            ),*/

            Expanded(
              child: PageView.builder(
                controller: _pageController,
                scrollDirection: Axis.vertical,
                itemCount: dailyViews.length,
                itemBuilder: (context, index) {
                  return AnimatedBuilder(
                    animation: _pageController,
                    builder: (context, child) {
                      if (!_pageController.hasClients) {
                        return Container(); // Or some placeholder widget
                      }
                      double pageOffset = index - (_pageController.page ?? 0);
                      double scale = max(1 - (pageOffset.abs() * 0.3), 0.7);
                      double opacity = max(1 - (pageOffset.abs() * 0.5), 0.5);

                      return Opacity(
                        opacity: opacity,
                        child: Transform.scale(
                          scale: scale,
                          child: child,
                        ),
                      );
                    },
                    child: ActionPostScreen(dailyView: dailyViews[index]),
                  );
                },
              ),
            ),
          ],
    );
  }
}


class SecondTabContent extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //backgroundColor: Colors.black, // Set background color
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
                  'People For You'
              ),
            ),
          ],
        ),
      ),
      /**body: Column(
          children: [
          Expanded(
          child: ,a
          ),
          ],
          ),*/
    );
  }
}
