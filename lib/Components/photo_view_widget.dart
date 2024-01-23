import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:en_masse_app/Authentication/authentication.dart';

class PhotoViewWidget extends StatefulWidget {
  final List<File> photos;
  final int initialIndex;

  PhotoViewWidget({required this.photos, required this.initialIndex});

  @override
  _PhotoViewWidgetState createState() => _PhotoViewWidgetState();
}

class _PhotoViewWidgetState extends State<PhotoViewWidget> {
  late PageController _pageController;
  int _currentIndex = 0;
  double _verticalDragDistance = 0.0;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
          onPanUpdate: (details) {
            setState(() {
              _verticalDragDistance += details.primaryDelta!;
            });
          },
          onPanEnd: (details) {
            if (_verticalDragDistance > 200.0) {
              Navigator.pop(context);
            } else {
              setState(() {
                _verticalDragDistance = 0.0;
              });
            }
          },
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: PhotoViewGallery.builder(
              itemCount: widget.photos.length,
              pageController: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              backgroundDecoration: BoxDecoration(
                color: Colors.black,
              ),
              builder: (context, index) {
                return PhotoViewGalleryPageOptions(
                  imageProvider: FileImage(widget.photos[index]),
                  minScale: PhotoViewComputedScale.contained,
                  maxScale: PhotoViewComputedScale.covered * 2,
                );
              },
            ),
          ),
        ),
        Positioned(
          top: _verticalDragDistance,
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(color: Colors.transparent),
        ),
      ],
    );
  }
}