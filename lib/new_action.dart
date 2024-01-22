import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';


class NewActionPage extends StatefulWidget {
  @override
  _NewActionPageState createState() => _NewActionPageState();
}

class _NewActionPageState extends State<NewActionPage> {
  List<File> uploadedPhotos = []; // List to store uploaded photos

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ElevatedButton(
              onPressed: () {
                // Handle share button press
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
              ),
              child: Text(
                'Share',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
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
                maxLines: null, // Allow multiple lines
                expands: true,
                textAlignVertical: TextAlignVertical.top, // Set to top
                decoration: InputDecoration(
                  filled: true,
                  hintText: 'Type here...',
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
                        return Stack(
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
                                    color: Colors.white,
                                    size: 16.0,
                                  ),
                                ),
                              ),
                            ),
                          ],
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

  // Function to pick an image and add it to the list
  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    try {
      final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        // Add the picked image to the uploadedPhotos list
        setState(() {
          uploadedPhotos.add(File(pickedFile.path));
        });
      }
    } catch (e) {
      print("Error picking image: $e");
    }
  }

  void _deleteImage(int index) {
    setState(() {
      uploadedPhotos.removeAt(index);
    });
  }
}
