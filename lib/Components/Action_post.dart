import 'package:en_masse_app/BarItems/contact_daily_page.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:en_masse_app/Components/photo_view_widget.dart'; // Ensure you have this import for PhotoViewWidget
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

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
                  padding: const EdgeInsets.all(4.0),
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
        onTap: () => _openPhotoView(context, 0),
        child: Hero(
          tag: 'photoHero${dailyView.images![0].imageName}',
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: 300),
            child: Image.file(imageFile, fit: BoxFit.cover),
          ),
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
            child: Hero(
              tag: 'photoHero${dailyView.images![index].imageName}',
              child: Image.file(imageFile, fit: BoxFit.cover),
            ),
          );
        },
      ),
    );
  }

  void _openPhotoView(BuildContext context, int tappedImageIndex) {
    List<File> imageFiles = dailyView.images!.map((image) => File(image.imageName)).toList();

    // Instead of showModalBottomSheet, use Navigator to push a custom route
    Navigator.of(context).push(PageRouteBuilder(
      opaque: false, // Ensure the background remains visible
      pageBuilder: (BuildContext context, _, __) {
        return PhotoViewOverlayWidget(
          photos: imageFiles,
          initialIndex: tappedImageIndex,
          // Pass any additional necessary parameters
        );
      },
    ));
  }
}

class PhotoViewOverlayWidget extends StatefulWidget {
  final List<File> photos;
  final int initialIndex;

  PhotoViewOverlayWidget({required this.photos, required this.initialIndex});

  @override
  _PhotoViewOverlayWidgetState createState() => _PhotoViewOverlayWidgetState();
}

class _PhotoViewOverlayWidgetState extends State<PhotoViewOverlayWidget> {
  double _currentScale = 1.0;
  Offset _currentOffset = Offset.zero; // Tracks the current offset for drag
  late double _initialFocalPointY; // Tracks the initial vertical position of the drag

  void _handleVerticalDragStart(DragStartDetails details) {
    _initialFocalPointY = details.globalPosition.dy;
  }

  void _handleVerticalDragUpdate(DragUpdateDetails details) {
    // Calculate the drag offset
    double verticalDrag = details.globalPosition.dy - _initialFocalPointY;
    // Adjust scale based on the drag distance
    double scaleDelta = verticalDrag / 1000;
    setState(() {
      _currentScale = (1.0 - scaleDelta).clamp(0.5, 1.0);
      _currentOffset = Offset(0, verticalDrag * 0.5); // Modify this factor to control the drag sensitivity
    });
  }

  void _handleVerticalDragEnd(DragEndDetails details) {
    if (_currentScale < 0.8) { // Use a threshold to determine if the widget should close
      Navigator.of(context).pop();
    } else {
      // Reset scale and position if the photo is not dismissed
      setState(() {
        _currentScale = 1.0;
        _currentOffset = Offset.zero;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragStart: _handleVerticalDragStart,
      onVerticalDragUpdate: _handleVerticalDragUpdate,
      onVerticalDragEnd: _handleVerticalDragEnd,
      child: Transform(
        alignment: Alignment.center,
        transform: Matrix4.identity()
          ..translate(_currentOffset.dx, _currentOffset.dy)
          ..scale(_currentScale),
        child: PhotoViewGallery.builder(
          itemCount: widget.photos.length,
          builder: (context, index) {
            return PhotoViewGalleryPageOptions(
              imageProvider: FileImage(widget.photos[index]),
              initialScale: PhotoViewComputedScale.contained,
              heroAttributes: PhotoViewHeroAttributes(tag: index),
            );
          },
          pageController: PageController(initialPage: widget.initialIndex),
          backgroundDecoration: BoxDecoration(
            color: Colors.transparent,
          ),
        ),
      ),
    );
  }
}
