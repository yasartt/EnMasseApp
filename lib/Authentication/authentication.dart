import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:en_masse_app/main.dart';

class LoginPage extends StatelessWidget {
  // Create a TextEditingController for the username
  final TextEditingController usernameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(
          'Enteract',
          style: GoogleFonts.pacifico(
            textStyle: TextStyle(
              fontSize: 20.0,
            ),
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Use the TextEditingController for the TextField
            TextField(
              controller: usernameController,
              decoration: InputDecoration(
                labelText: 'Username',
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
              ),
            ),
            SizedBox(height: 24.0),
            ElevatedButton(
              onPressed: () async {
                // Get the entered username from the TextEditingController
                String username = usernameController.text;

                // Replace this with your actual password input handling
                String password = 'examplePassword';

                // Call the authenticate method in AuthService
                bool isAuthenticated = await AuthService.authenticate(username, password);

                if (isAuthenticated) {
                  // Authentication successful, navigate to the main content
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => MyHomePage(title: 'Enteract')),
                  );
                } else {
                  // Authentication failed, you might show an error message
                  // For simplicity, we'll print a message to the console
                  print('Authentication failed');
                }
              },
              child: Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}


class AuthService {
  static Future<String?> getAuthToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('authToken');
  }

  static Future<void> saveAuthToken(String authToken) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('authToken', authToken);
  }

  static Future<String?> getUsername() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('username');
  }

  static Future<void> saveUsername(String username) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', username);
  }

  static Future<bool> checkAuthentication() async {
    String? authToken = await getAuthToken();
    return authToken != null;
  }

  static Future<bool> authenticate(String username, String password) async {
    // Simulating authentication logic
    // In a real scenario, you would perform actual authentication

    // Save the username when the user enters it
    await saveUsername(username);

    // Simulating successful authentication and saving a token
    await saveAuthToken('exampleToken');

    return true;
  }
}

