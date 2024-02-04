import 'dart:io';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

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
  double _scaleFactor = 1.0; // Add a scale factor

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  void _onVerticalDragUpdate(DragUpdateDetails details) {
    setState(() {
      _verticalDragOffset += details.primaryDelta!;
      // Calculate scale factor based on drag distance, adjust the divisor for sensitivity
      _scaleFactor = 1 - (_verticalDragOffset.abs() / 1000);
      _scaleFactor = _scaleFactor.clamp(0.5, 1.0); // Ensure scale factor does not invert or exceed original size
    });
  }

  void _onVerticalDragEnd(DragEndDetails details) {
    if (_verticalDragOffset.abs() > 100) { // Adjust the threshold as needed
      Navigator.of(context).pop();
    } else {
      setState(() {
        _verticalDragOffset = 0.0; // Reset drag offset
        _scaleFactor = 1.0; // Reset scale factor
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Apply transformations to the entire Scaffold
    return GestureDetector(
      onVerticalDragUpdate: _onVerticalDragUpdate,
      onVerticalDragEnd: _onVerticalDragEnd,
      child: Transform(
        transform: Matrix4.identity()
          ..translate(0.0, _verticalDragOffset)
          ..scale(_scaleFactor),
        alignment: FractionalOffset.center,
        child: Scaffold(
          backgroundColor: Theme.of(context).brightness == Brightness.dark
              ? Colors.black
              : Colors.white,
          body: Stack(
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
    if (total <= 1) {
      return SizedBox.shrink(); // Returns an empty widget if there's only one photo
    }

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

