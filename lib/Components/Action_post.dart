import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'photo_view_widget.dart';

class ActionPostScreen extends StatefulWidget {
  final int dailyId;

  ActionPostScreen({required this.dailyId});

  @override
  _ActionPostScreenState createState() => _ActionPostScreenState();
}

class _ActionPostScreenState extends State<ActionPostScreen> {
  List<ImageDTO> actionPostImages = [];

  @override
  void initState() {
    super.initState();
    fetchActionPostImages();
  }

  Future<void> fetchActionPostImages() async {
    final response = await http.get(Uri.parse('https://192.168.1.38:7181/api/Daily/GetImagesByDailyId/${widget.dailyId}'));

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      List<ImageDTO> loadedImages = data.map((json) => ImageDTO.fromJson(json)).toList();

      setState(() {
        actionPostImages = loadedImages;
      });
    } else {
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Action Post Images'),
      ),
      body: ListView.builder(
        itemCount: 1, // Only one post in the list
        itemBuilder: (context, index) {
          return Container(
            height: 200, // Set the desired height for each post
            margin: EdgeInsets.all(8.0),
            child: _buildPostComponent(),
          );
        },
      ),
    );
  }

  Widget _buildPostComponent() {
    if (actionPostImages.isEmpty) {
      // No images, return an empty container
      return Container();
    }

    if (actionPostImages.length == 1) {
      // Single image, take all the space
      return _buildImageContainer(actionPostImages[0].imageName);
    }

    // Multiple images, split the space
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.inversePrimary,
        border: Border.all(
          color: Colors.black,
          width: 1.0,
        ),
        borderRadius: BorderRadius.circular(12.0), // Adjust the border radius as needed
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0), // Adjust the padding as needed
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // First row: Profile photo
            Row(
              children: [
                Container(
                  width: 40.0, // Set the width as needed
                  height: 40.0, // Set the height as needed
                  decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(8.0), // Adjust the border radius as needed
                    image: DecorationImage(
                      image: FileImage(File(actionPostImages[0].imageName)),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(width: 8.0), // Adjust the spacing as needed
                Text('Username'), // Replace 'Username' with the actual username
              ],
            ),
            SizedBox(height: 8.0), // Adjust the spacing as needed

            // Second row: Text
            Row(
              children: [
                Expanded(
                  child: Text(
                    'The caption for the action',
                    style: TextStyle(fontSize: 16.0), // Adjust the font size as needed
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.0), // Adjust the spacing as needed

            // Third row: Photos
            Container(
              height: 100.0, // Adjust the height as needed
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: actionPostImages.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0), // Adjust the horizontal padding as needed
                    child: _buildImageContainer(actionPostImages[index].imageName),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageContainer(String imagePath) {
    File imageFile = File(imagePath);

    return GestureDetector(
      onTap: () {
        _openPhotoView(imageFile);
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(
            color: Colors.black,
            width: 1.0,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12.0),
          child: Image.file(
            imageFile,
            width: 80.0, // Set the width as needed
            height: 80.0, // Set the height as needed
            fit: BoxFit.cover, // Use BoxFit.cover to ensure the image fits within the container
          ),
        ),
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

class ImageDTO {
  final String id;
  final String imageName;
  final int dailyId;

  ImageDTO({
    required this.id,
    required this.imageName,
    required this.dailyId,
  });

  factory ImageDTO.fromJson(Map<String, dynamic> json) {
    return ImageDTO(
      id: json['id'],
      imageName: json['imageName'],
      dailyId: json['dailyId'],
    );
  }
}