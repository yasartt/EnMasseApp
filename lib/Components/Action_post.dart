import 'dart:io';
import 'package:flutter/material.dart';
import 'package:en_masse_app/BarItems/Explore/explore_page.dart';
import 'photo_view_widget.dart';

class ActionPostScreen extends StatefulWidget {
  final DailyView dailyView;

  ActionPostScreen({required this.dailyView});

  @override
  _ActionPostScreenState createState() => _ActionPostScreenState();
}

class _ActionPostScreenState extends State<ActionPostScreen> {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8.0),
      elevation: 4.0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ListTile(
            leading: Icon(Icons.person), // Replace with user's profile image if available
            title: Text('User ID: ${widget.dailyView.userId}'),
            subtitle: Text(widget.dailyView.caption ?? ''),
          ),
          _buildImages(),
        ],
      ),
    );
  }

  Widget _buildImages() {
    if (widget.dailyView.images == null || widget.dailyView.images!.isEmpty) {
      return SizedBox.shrink();
    }

    int imageCount = widget.dailyView.images!.length;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GridView.builder(
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: imageCount == 3 ? 3 : 2, // 3 columns for 3 images, else 2
          crossAxisSpacing: 4.0,
          mainAxisSpacing: 4.0,
          childAspectRatio: (imageCount == 1)
              ? MediaQuery.of(context).size.width / (MediaQuery.of(context).size.width / 2)
              : 1,
        ),
        itemCount: imageCount,
        itemBuilder: (context, index) {
          File imageFile = File(widget.dailyView.images![index].imageName);
          return GestureDetector(
            onTap: () => _openPhotoView(index), // Pass the index of the tapped image
            child: Image.file(imageFile, fit: BoxFit.cover),
          );
        },
      ),
    );
  }

  void _openPhotoView(int tappedImageIndex) {
    List<File> imageFiles = widget.dailyView.images!
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
