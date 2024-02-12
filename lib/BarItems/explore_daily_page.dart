import 'dart:async';

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

class ExplorePage extends StatefulWidget {
  ExplorePage({Key? key}) : super(key: key);

  @override
  _ExplorePageState createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> with AutomaticKeepAliveClientMixin {

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return FirstTabContent();

    /** DefaultTabController(
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
                  icon: Icon(Icons.nature_people_outlined, color: Theme.of(context).colorScheme.primary,),
                ),
                Tab(
                  icon: Icon(Icons.hail_outlined, color: Theme.of(context).colorScheme.primary),
                ),
              ],
            ),
          ),
        ),
        body: TabBarView(
          children: [
            // First tab content
            FirstTabContent(),
            // Second tab content
            SecondTabContent(), // Pass the contactList to SecondTabContent
          ],
        ),
      ),
    );*/
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

  @override
  void initState() {
    super.initState();
    _initializeDataAndListenToBox();
  }

  void _initializeDataAndListenToBox() async {
    final userId = await AuthService.getUserId();
    if (userId == null) return;

    final box = Hive.box<DailyView>('dailyViews');
    _updateDailyViewsList(box.values.toList()); // Initial load of data

    // Listen to changes in the box
    _boxSubscription = box.watch().listen((event) {
      _updateDailyViewsList(box.values.toList()); // Update UI on change
    });

    fetchDailyViews();
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

    final box = Hive.box<DailyView>('dailyViews');
    final int initialCount = box.length; // Store the initial count of items in the box

    DailyView? lastDailyView = box.values.isNotEmpty ? box.values.last : null;

    // If there's a lastDailyView, use its `created` date and `dailyId`, otherwise use current time
    final lastTime = lastDailyView?.created?.toIso8601String() ?? null;
    final lastDailyId = lastDailyView?.dailyId;

    // Define the request URL
    final url = Uri.parse('https://${Config.apiBaseUrl}/api/Daily/GetEntheriaDailiesByUser');

    // Create the request body
    final body = jsonEncode({
      'userId': userId,
      'lastDailyId': lastDailyId, // Adjust API to accept this if needed
      'lastTime': lastTime,
    });

    // Send the POST request
    final response = await http.post(url, headers: {'Content-Type': 'application/json'}, body: body);

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      List<DailyView> loadedDailyViews = data.map((json) => DailyView.fromJson(json)).toList();

      // Append new data to the Hive box and update the local list
      for (var dailyView in loadedDailyViews) {
        box.add(dailyView);
      }

      // Calculate the starting index of the newly appended data
      int newIndexStart = initialCount - loadedDailyViews.length;

      setState(() {
        dailyViews = box.values.toList();
        _isDataLoaded = true;
      });

      // After the state is updated, jump to the starting index of the newly appended data
      if (newIndexStart >= 0 && newIndexStart < dailyViews.length) {
        _pageController.jumpToPage(newIndexStart);
      }
    } else {
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  child: Text('Entherians'),
                ),
              ),
              Positioned(
                left: 0,
                child: IconButton(
                  icon: Icon(Icons.sunny_snowing),
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
