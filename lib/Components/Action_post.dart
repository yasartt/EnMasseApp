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
              borderRadius: BorderRadius.circular(16.0), // Adjust for more rounded corners
            ),
            elevation: 8.0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  child: Row(
                    children: [
                      Icon(Icons.person), // Replace with user's profile image if available
                      SizedBox(width: 10),
                      Expanded(child: Text('User ID: ${dailyView.userId}')),
                    ],
                  ),
                ),
                Divider(), // Adds a line to separate the user details from the rest of the post content
                if (dailyView.caption != null && dailyView.caption!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(dailyView.caption!),
                  ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: _buildImages(context),
                )
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

    return GridView.builder(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: (imageCount > 2) ? 3 : imageCount, // Adjust based on the number of images
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
    );
  }

  void _openPhotoView(BuildContext context, int tappedImageIndex) {
    List<File> imageFiles = dailyView.images!
        .map((image) => File(image.imageName))
        .toList();

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
