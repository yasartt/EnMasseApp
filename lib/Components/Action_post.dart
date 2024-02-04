import 'package:en_masse_app/BarItems/contact_daily_page.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:en_masse_app/Components/photo_view_widget.dart'; // Ensure you have this import for PhotoViewWidget

class ActionPostScreen extends StatelessWidget {
  final DailyView dailyView;

  ActionPostScreen({required this.dailyView});

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
                      Expanded(child: Text('User ID: ${dailyView.userId}')),
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
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: Icon(Icons.reply), // You can change the icon as needed
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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => PhotoViewWidget(
        photos: imageFiles,
        initialIndex: tappedImageIndex,
      ),
    );
  }
}
