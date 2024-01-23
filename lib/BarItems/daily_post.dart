import 'package:flutter/material.dart';
import 'package:extended_image/extended_image.dart';

class DailyPost extends StatefulWidget {
  final String profilePhotoUrl;
  final String username;
  final List<String> postPhotoUrls;
  final String caption;

  DailyPost({
    required this.profilePhotoUrl,
    required this.username,
    required this.postPhotoUrls,
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
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    width: 40.0,
                    height: 40.0,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: AssetImage(widget.profilePhotoUrl),
                      ),
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
            Container(
              height: 1.0,
              color: Colors.black,
            ),
            SizedBox(height: 8.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.caption,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8.0),
                  _buildPhotoSection(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoSection(BuildContext context) {
    int photoCount = widget.postPhotoUrls.length;

    if (photoCount == 1) {
      return GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => _buildPhotoViewGallery(context),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: FractionallySizedBox(
            widthFactor: 0.8,
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: ExtendedImage.asset(
                  widget.postPhotoUrls[0],
                  fit: BoxFit.cover,
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
      );
    } else {
      // Handle other cases based on the number of photos (2, 3, or 4)
      return _buildMultiplePhotos(context, photoCount);
    }
  }

  Widget _buildMultiplePhotos(BuildContext context, int photoCount) {
    double photoWidth = MediaQuery.of(context).size.width * 0.4;

    List<Widget> photoWidgets = [];
    for (int i = 0; i < photoCount; i++) {
      photoWidgets.add(
        GestureDetector(
          onTap: () {
            // Handle individual photo click
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => _buildPhotoViewGallery(context, initialIndex: i),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10.0),
              child: Image.asset(
                widget.postPhotoUrls[i],
                width: photoWidth,
                height: photoWidth,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      );
    }

    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: photoWidgets,
    );
  }

  Widget _buildPhotoViewGallery(BuildContext context, {int initialIndex = 0}) {
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
                itemCount: widget.postPhotoUrls.length,
                itemBuilder: (context, index) {
                  return ExtendedImage.asset(
                    widget.postPhotoUrls[index],
                    fit: BoxFit.contain,
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
