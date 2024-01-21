import 'package:flutter/material.dart';
import 'package:extended_image/extended_image.dart';

class DailyPost extends StatefulWidget {
  final String profilePhotoUrl;
  final String username;
  final String postPhotoUrl;
  final String caption;

  DailyPost({
    required this.profilePhotoUrl,
    required this.username,
    required this.postPhotoUrl,
    required this.caption,
  });

  @override
  _DailyPostState createState() => _DailyPostState();
}

class _DailyPostState extends State<DailyPost> {
  final _controller = ExtendedPageController();
  final _transformationController = TransformationController();
  late TapDownDetails _doubleTapDetails;

  void _handleDoubleTap() {
    if (_transformationController.value != Matrix4.identity()) {
      _transformationController.value = Matrix4.identity();
    } else {
      final position = _doubleTapDetails.localPosition;
      _transformationController.value = Matrix4.identity()
        ..translate(-position.dx * 2, -position.dy * 2)
        ..scale(3.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 50.0,
      margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
        side: BorderSide(
          color: Theme.of(context).colorScheme.primary,
          width: 2.0,
        ),
      ),
      child: Container(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40.0,
                  height: 40.0,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: AssetImage(widget.profilePhotoUrl),
                    ),
                  ),
                ),
                SizedBox(width: 8.0),
                Text(
                  widget.username,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.0),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => _buildPhotoViewGallery(context),
                  ),
                );
              },
              child: FractionallySizedBox(
                widthFactor: 1.0,
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10.0),
                    child: ExtendedImage.asset(
                      widget.postPhotoUrl,
                      fit: BoxFit.cover,
                      //cache: true,
                      enableSlideOutPage: true,
                      mode: ExtendedImageMode.gesture,
                      initGestureConfigHandler: (state) {
                        return GestureConfig(
                          minScale: 0.5,
                          animationMinScale: 0.1,
                          maxScale: 3.0,
                          animationMaxScale: 3.5,
                          speed: 1.0,
                          inertialSpeed: 100.0,
                          initialScale: 1.0,
                          inPageView: true,
                          initialAlignment: InitialAlignment.center,
                        );
                      },
                      onDoubleTap: (state) {
                        _handleDoubleTap();
                      },
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 8.0),
            Text(
              widget.caption,
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoViewGallery(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          setState(() {}); // Dummy setState to enable it
        },
        child: Column(
          children: [
            Expanded(
              child: ExtendedImageGesturePageView.builder(
                controller: _controller,
                scrollDirection: Axis.horizontal,
                itemCount: 1,
                itemBuilder: (context, index) {
                  return ExtendedImage.asset(
                    widget.postPhotoUrl,
                    fit: BoxFit.contain,
                    //cache: true,
                    enableSlideOutPage: true,
                    mode: ExtendedImageMode.gesture,
                    initGestureConfigHandler: (state) {
                      return GestureConfig(
                        minScale: 0.5,
                        animationMinScale: 0.1,
                        maxScale: 3.0,
                        animationMaxScale: 3.5,
                        speed: 1.0,
                        inertialSpeed: 100.0,
                        initialScale: 1.0,
                        inPageView: true,
                        initialAlignment: InitialAlignment.center,
                      );
                    },
                    onDoubleTap: (state) {
                      _handleDoubleTap();
                    },
                  );
                },
                onPageChanged: (index) {
                  if (index == 0) {
                    Navigator.pop(context);
                  }
                },
              ),
            ),
            SizedBox(height: 8.0),
            Text(
              widget.caption,
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
