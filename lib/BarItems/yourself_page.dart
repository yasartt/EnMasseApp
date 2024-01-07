import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:en_masse_app/main.dart';
import 'package:en_masse_app/Authentication/authentication.dart';
//import 'package:your_app_name_here/auth_service.dart'; // Import your AuthService file

class YourselfPage extends StatelessWidget {
  const YourselfPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2.0,
                  ),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                child: Text(
                  'Yourself',
                  style: GoogleFonts.pacifico(
                    textStyle: TextStyle(
                      fontSize: 20.0,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: Center(
        child: Column(
          children: [
            SizedBox(height: 40), // Adjust the height
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey, // Adjust the color as needed
                borderRadius: BorderRadius.circular(20), // Adjust the radius
              ),
              // You can add any other widgets or content here
            ),
            SizedBox(height: 20),
            FutureBuilder<String?>(
              future: AuthService.getUsername(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (snapshot.hasData) {
                  return Text(
                    snapshot.data ?? 'No username found',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                } else {
                  return Text('No username found');
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
