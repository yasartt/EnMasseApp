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
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 20.0),
        child: Center(child: Text('No Images')),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GridView.builder(
        physics: NeverScrollableScrollPhysics(), // To disable GridView's scrolling
        shrinkWrap: true, // To fit GridView into the card
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // Adjust the number of columns
          crossAxisSpacing: 4.0,
          mainAxisSpacing: 4.0,
        ),
        itemCount: widget.dailyView.images!.length,
        itemBuilder: (context, index) {
          File imageFile = File(widget.dailyView.images![index].imageName);
          return GestureDetector(
            onTap: () => _openPhotoView(imageFile),
            child: Image.file(imageFile, fit: BoxFit.cover),
          );
        },
      ),
    );
  }

  void _openPhotoView(File imageFile) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => PhotoViewWidget(
        photos: [imageFile],
        initialIndex: 0,
      ),
    );
  }
}
