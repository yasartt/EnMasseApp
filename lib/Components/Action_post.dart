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
    return Row(
      children: List.generate(
        actionPostImages.length,
            (index) => Expanded(
          child: _buildImageContainer(actionPostImages[index].imageName),
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
          child: Padding(
            padding: EdgeInsets.all(8.0), // Add padding here
            child: Image.file(
              imageFile,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
            ),
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