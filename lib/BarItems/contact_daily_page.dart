import 'package:en_masse_app/BarItems/rooms_page.dart';
import 'package:en_masse_app/Components/Action_post.dart';
import 'package:flutter/material.dart';
import 'card_details_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'chat_page.dart';
import 'daily_post.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:en_masse_app/Authentication/authentication.dart';
import 'package:en_masse_app/config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'dart:math' as math;
import 'package:en_masse_app/Components/daily_view.dart';


class ContactDaily extends StatefulWidget {
  @override
  _ContactDailyState createState() => _ContactDailyState();
}


class _ContactDailyState extends State<ContactDaily> with AutomaticKeepAliveClientMixin {
  List<DailyView> dailyViews = [];
  PageController _pageController = PageController();
  bool _isFieldVisible = false;

  @override
  void initState() {
    super.initState();
    fetchDailyViews();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _toggleFieldVisibility() {
    setState(() {
      _isFieldVisible = !_isFieldVisible;
    });
  }


  Future<void> fetchDailyViews() async {
    final userId = await AuthService.getUserId();

    if (userId == null) {
      // Handle the case where userId is null (not authenticated)
      return;
    }

    final lastTime = DateTime.now(); // Replace with the actual DateTime you want to use

    final response = await http.get(Uri.parse('https://${Config.apiBaseUrl}/api/Daily/GetContactDailiesByUser/$userId/$lastTime'));

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      List<DailyView> loadedDailyViews = data.map((json) => DailyView.fromJson(json)).toList();

      setState(() {
        dailyViews = loadedDailyViews;
      });
    } else {
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final screenHeight = MediaQuery.of(context).size.height;
    return Column(
      children: [
        AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          title: Stack(
            children: [
              Align(
                alignment: Alignment.center,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary,
                      width: 2.0,
                    ),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                  child: Text('Your Contacts'),
                ),
              ),
              Positioned(
                left: 0, // Aligns the IconButton to the left
                child: IconButton(
                  icon: Icon(Icons.home),
                  onPressed: () {
                    // Your icon button action here
                  },
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            scrollDirection: Axis.vertical,
            itemCount: dailyViews.length,
            itemBuilder: (context, index) {
              return AnimatedBuilder(
                animation: _pageController,
                builder: (context, child) {
                  double pageOffset = index - (_pageController.page ?? 0);
                  double scale = 1.0;
                  double opacity = 1.0;
                  double translateX = 0.0;
                  double translateY = 0.0;

                  if (pageOffset > 0) {
                    scale = 1 - (pageOffset / 3);
                    opacity = 1 - (pageOffset);
                    //translateX = -(MediaQuery.of(context).size.width / 2) * pageOffset;
                  } else if (pageOffset < 0) {
                    scale = 1 - (-pageOffset / 10);
                    opacity = 1 - (-pageOffset);
                    //translateX = -(MediaQuery.of(context).size.width / 2) * -pageOffset;
                    translateY = (MediaQuery.of(context).size.height / 2) * -pageOffset;
                  }

                  return Transform.scale(
                    scale: scale.clamp(0.0, 1.0),
                    child: Opacity(
                      opacity: opacity.clamp(0.0, 1.0),
                      child: Transform.translate(
                        offset: Offset(translateX, translateY),
                        child: child,
                      ),
                    ),
                  );
                },
                child: ActionPostScreen(dailyView: dailyViews[index]),
              );
            },
          ),
        ),
        /**Align(
          alignment: Alignment.bottomLeft,
          child: Container(
            height: 48,
            width: 48,
            margin: EdgeInsets.only(left: 8.0, bottom: 0.0),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Theme.of(context).colorScheme.primary),
                left: BorderSide(color: Theme.of(context).colorScheme.primary),
                right: BorderSide(color: Theme.of(context).colorScheme.primary),
              ),
              //borderRadius: BorderRadius.circular(5.0),
              //shape: BoxShape.circle,
            ),
            child: Center( // Wrap the CustomToggleButton with a Center widget
              child: CustomToggleButton(
                isExpanded: _isFieldVisible,
                onTap: _toggleFieldVisibility,
                //icon: _isFieldVisible ? Icons.arrow_upward : Icons.arrow_downward_sharp,
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                    color: Theme.of(context).colorScheme.primary
                ),
              ),
            ),
            child: AnimatedContainer(
              margin: EdgeInsets.only(left: 8.0, right: 8.0),
              duration: Duration(milliseconds: 300),
              height: _isFieldVisible ? 60 : 0, // Adjust the height as needed
              curve: Curves.easeInOut,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.attach_file, color: Theme.of(context).colorScheme.primary,), // Choose your left icon
                          onPressed: () {
                            // Action for the left icon button
                          },
                        ),
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(hintText: 'Enter something...'),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            // Action for the right button
                          },
                          child: Text('Share'), // Text for the right button
                        ),
                      ],
                    ),
                    //SizedBox(height: 10),
                    // If you need more widgets below, add them here
                  ],
                ),
              ),
            ),
          )
        ),*/
        Padding(
          padding: EdgeInsets.all(32.0),
        )
      ],
    );
  }

  @override
  bool get wantKeepAlive => true; // Keep the state of the widget across different tabs
}

class CustomToggleButton extends StatefulWidget {
  final bool isExpanded;
  final VoidCallback onTap;
  //final IconData icon;

  const CustomToggleButton({
    Key? key,
    required this.isExpanded,
    required this.onTap,
    //required this.icon,
  }) : super(key: key);

  @override
  State<CustomToggleButton> createState() => _CustomToggleButtonState();
}

class _CustomToggleButtonState extends State<CustomToggleButton> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _iconTurns;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(duration: const Duration(milliseconds: 250), vsync: this);
    _iconTurns = Tween<double>(begin: 0.0, end: 0.5).animate(_animationController);
  }

  @override
  void didUpdateWidget(covariant CustomToggleButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isExpanded != oldWidget.isExpanded) {
      if (widget.isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: AnimatedBuilder(
        animation: _animationController,
        builder: (_, child) {
          return RotationTransition(
            turns: _iconTurns,
            child: Icon(Icons.arrow_upward, size: 24, color: Theme.of(context).colorScheme.primary,),
          );
        },
      ),
      onPressed: widget.onTap,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}