import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:en_masse_app/Authentication/authentication.dart';
import 'package:en_masse_app/config.dart';

class NewActionPage extends StatefulWidget {
  @override
  _NewActionPageState createState() => _NewActionPageState();
}

class _NewActionPageState extends State<NewActionPage> {
  List<File> uploadedPhotos = [];
  int currentPhotoIndex = 0;
  TextEditingController _captionController = TextEditingController();
  bool isShareEnabled = false; // Initialize as disabled

  @override
  void initState() {
    super.initState();
    _captionController.addListener(_updateShareButtonState);
  }

  // This function updates the state of the share button
  void _updateShareButtonState() {
    bool shouldEnable = uploadedPhotos.isNotEmpty || _captionController.text.isNotEmpty;
    if (isShareEnabled != shouldEnable) {
      setState(() {
        isShareEnabled = shouldEnable;
      });
    }
  }

  void _sendPostRequest() async {
    final String url = 'https://${Config.apiBaseUrl}/api/Daily/AddNewDaily';
    String caption = _captionController.text;

    int? userId = await AuthService.getUserId();

    List<Map<String, dynamic>> imageList = [];
    for (int index = 0; index < uploadedPhotos.length; index++) {
      imageList.add({'Name': index.toString(), 'ImageName': uploadedPhotos[index].path});
    }

    DateTime currentTime = DateTime.now();
    Map<String, dynamic> requestData = {
      'UserId': userId,
      'DailyTypeId': 0,
      'Caption': caption,
      'Images': imageList,
      'RequestDateTime': currentTime.toIso8601String(),
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(requestData),
      );

      if (response.statusCode == 200) {
        print('POST request successful');

        // Optionally process response data here

        // Navigate back to the previous screen if the post is successful
        Navigator.pop(context);
      } else {
        print('POST request failed with status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error sending POST request: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ElevatedButton(
              onPressed: isShareEnabled ? () {
                _sendPostRequest();
              } : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: isShareEnabled
                    ? Theme.of(context).colorScheme.primary // Enabled color
                    : Colors.grey[300], // Default disabled color
                disabledBackgroundColor: Colors.grey, // Disabled background color
                disabledForegroundColor: Colors.white, // Disabled text color
              ),
              child: Text(
                'Share',
                style: TextStyle(
                  color: isShareEnabled
                      ? Theme.of(context).colorScheme.onPrimary // Enabled text color
                      : Colors.white, // Disabled text color
                ),
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: TextField(
                controller: _captionController, // Connect the controller to the TextField
                maxLines: null, // Allow multiple lines
                expands: true,
                textAlignVertical: TextAlignVertical.top, // Set to top
                decoration: InputDecoration(
                  filled: true,
                  hintText: "Share Anything!",
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Container(
                    height: 80.0,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: uploadedPhotos.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            // Handle image click to open photo view
                            _openPhotoView(index);
                          },
                          child: Stack(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10.0),
                                  child: Image.file(
                                    uploadedPhotos[index],
                                    height: 60.0,
                                    width: 60.0,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 0,
                                right: 0,
                                child: GestureDetector(
                                  onTap: () {
                                    // Handle delete button press
                                    _deleteImage(index);
                                  },
                                  child: Container(
                                    padding: EdgeInsets.all(4.0),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Theme.of(context).colorScheme.inversePrimary,
                                    ),
                                    child: Icon(
                                      Icons.close,
                                      color: Theme.of(context).colorScheme.primary,
                                      size: 16.0,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () async{
                    // Handle attach button press
                    await _pickImage(); // Call a function to pick an image
                  },
                  child: Text('Attach'),
                ),
                SizedBox(width: 16.0),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    try {
      final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          uploadedPhotos.add(File(pickedFile.path));
          _updateShareButtonState(); // Update share button state when a photo is added
        });
      }
    } catch (e) {
      print("Error picking image: $e");
    }
  }

  void _deleteImage(int index) {
    setState(() {
      uploadedPhotos.removeAt(index);
      _updateShareButtonState();
    });
  }

  void _openPhotoView(int initialIndex) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => PhotoViewWidget(
        photos: uploadedPhotos,
        initialIndex: initialIndex,
      ),
    );
  }

  @override
  void dispose() {
    _captionController.removeListener(_updateShareButtonState);
    _captionController.dispose();
    super.dispose();
  }
}

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