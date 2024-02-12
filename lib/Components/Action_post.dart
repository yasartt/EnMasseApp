import 'package:en_masse_app/BarItems/contact_daily_page.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:en_masse_app/Components/photo_view_widget.dart'; // Ensure you have this import for PhotoViewWidget
import 'package:en_masse_app/Components/daily_view.dart';
import 'package:intl/intl.dart';

class ActionPostScreen extends StatelessWidget {
  final DailyView dailyView;

  ActionPostScreen({required this.dailyView});

  String _formatDateTime(DateTime? created) {
    if (created == null) return 'Date Unknown';

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day).subtract(Duration(days: 1));
    final dateCreated = DateTime(created.year, created.month, created.day);

    // Check if the post was created today
    if (dateCreated == today) {
      // If so, return the time only
      return DateFormat('h:mm a').format(created);
    } else {
      // If not, calculate how many days ago it was and return that information
      final difference = today.difference(dateCreated).inDays;
      if (difference == 1) {
        return 'Yesterday';
      } else {
        return '$difference days ago';
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: 600), // Set your desired max height here
        child: SingleChildScrollView(
          child: Card(
            margin: EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            elevation: 8.0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  child: Row(
                    children: [
                      Icon(Icons.person), // Placeholder for user's profile image
                      SizedBox(width: 10),
                      Expanded(child: Text('${dailyView.userName}')),
                    ],
                  ),
                ),
                Divider(),
                if (dailyView.caption != null && dailyView.caption!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(dailyView.caption!),
                  ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: _buildImages(context),
                ),
                Divider(), // Add a divider below the images and text
                Padding(
                  padding: const EdgeInsets.only(left: 16.0, right: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatDateTime(dailyView.created),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.reply),
                        onPressed: () {
                          // Handle the reply button action here
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImages(BuildContext context) {
    if (dailyView.images == null || dailyView.images!.isEmpty) {
      return SizedBox.shrink();
    }

    int imageCount = dailyView.images!.length;

    // For a single image, make it clickable and constrained
    if (imageCount == 1) {
      File imageFile = File(dailyView.images![0].imageName);
      return GestureDetector(
        onTap: () => _openPhotoView(context, 0), // Make the single image clickable
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: 300), // Limit the height of the single image
          child: Image.file(imageFile, fit: BoxFit.cover),
        ),
      );
    }

    // For multiple images, use GridView within a constrained area
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: 300), // Adjust this value as needed
      child: GridView.builder(
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: imageCount, // Adjust based on the number of images
          crossAxisSpacing: 4.0,
          mainAxisSpacing: 4.0,
        ),
        itemCount: imageCount,
        itemBuilder: (context, index) {
          File imageFile = File(dailyView.images![index].imageName);
          return GestureDetector(
            onTap: () => _openPhotoView(context, index),
            child: Image.file(imageFile, fit: BoxFit.cover),
          );
        },
      ),
    );
  }

  void _openPhotoView(BuildContext context, int tappedImageIndex) {
    List<File> imageFiles = dailyView.images!.map((image) => File(image.imageName)).toList();

    Navigator.of(context).push(PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => PhotoViewWidget(
        photos: imageFiles,
        initialIndex: tappedImageIndex,
      ),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var begin = 0.0;
        var end = 1.0;
        var curve = Curves.ease;

        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return ScaleTransition(
          scale: animation.drive(tween),
          child: child,
        );
      },
    ));
  }

}
