import 'dart:io';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class PhotoViewWidget extends StatefulWidget {
  final List<File> photos;
  final int initialIndex;

  PhotoViewWidget({required this.photos, required this.initialIndex});

  @override
  _PhotoViewWidgetState createState() => _PhotoViewWidgetState();
}

class _PhotoViewWidgetState extends State<PhotoViewWidget> {
  late PageController _pageController;
  late int _currentIndex;
  double _verticalDragOffset = 0.0;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  void _onVerticalDragUpdate(DragUpdateDetails details) {
    setState(() {
      _verticalDragOffset += details.primaryDelta!;
    });
  }

  void _onVerticalDragEnd(DragEndDetails details) {
    // Check for absolute value to consider both upward and downward swipes
    if (_verticalDragOffset.abs() > 100) { // Adjust the threshold as needed
      Navigator.of(context).pop();
    } else {
      setState(() {
        _verticalDragOffset = 0.0; // Reset drag offset
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset(0.0, _verticalDragOffset), // Translate Scaffold based on drag offset
      child: Scaffold(
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? Colors.black
            : Colors.white,
        body: GestureDetector(
          onVerticalDragUpdate: _onVerticalDragUpdate,
          onVerticalDragEnd: _onVerticalDragEnd,
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: <Widget>[
              PhotoViewGallery.builder(
                scrollPhysics: const BouncingScrollPhysics(),
                pageController: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                itemCount: widget.photos.length,
                builder: (context, index) {
                  return PhotoViewGalleryPageOptions(
                    imageProvider: FileImage(widget.photos[index]),
                    minScale: PhotoViewComputedScale.contained,
                    maxScale: PhotoViewComputedScale.covered * 2,
                  );
                },
                backgroundDecoration: const BoxDecoration(
                  color: Colors.transparent,
                ),
              ),
              _buildIndicator(widget.photos.length, _currentIndex),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIndicator(int total, int currentIndex) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(total, (index) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 2.0),
            height: 8.0,
            width: 8.0,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: currentIndex == index ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.inversePrimary,
            ),
          );
        }),
      ),
    );
  }
}
