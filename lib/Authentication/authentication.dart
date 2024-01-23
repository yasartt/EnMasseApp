import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:en_masse_app/main.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LoginPage extends StatelessWidget {
  // Create a TextEditingController for the username
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

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
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
              ),
            ),
            SizedBox(height: 24.0),
            ElevatedButton(
              onPressed: () async {
                // Check if username and password fields are not empty
                if (usernameController.text.isEmpty || passwordController.text.isEmpty) {
                  // Show an error message or handle it as per your requirement
                  print('Username and password are required');
                  return;
                }

                // Get the entered username and password
                String username = usernameController.text;
                String password = passwordController.text;

                // Send HTTP request to login controller
                var response = await http.post(
                  Uri.parse('https://192.168.1.38:7181/api/Auth/Login'), // Replace with your actual API URL
                  headers: {'Content-Type': 'application/json'},
                  body: jsonEncode({'userName': username, 'password': password}),
                );

                if (response.statusCode == 200) {
                  // Successful login, parse the response JSON
                  var responseBody = jsonDecode(response.body);

                  // Save user-related information to SharedPreferences
                  await AuthService.saveAuthToken(responseBody['token']);
                  await AuthService.saveUsername(responseBody['user']['userName']);
                  await AuthService.saveUserId(responseBody['user']['userId']);
                  await AuthService.saveEmail(responseBody['user']['email']);

                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => MyHomePage(title: 'Enteract')),
                  );

                } else {
                  // Failed login, show an error message
                  print('Login failed. Status code: ${response.statusCode}');
                  print('Error message: ${response.body}');
                }
              },
              child: Text('Login'),
            ),          ],
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

  static Future<void> saveUserId(int userId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('userId', userId);
  }

  static Future<int?> getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt('userId');
  }

  static Future<void> saveEmail(String email) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('email', email);
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

  static Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Clear the stored data
    await prefs.remove('authToken');
    await prefs.remove('username');
  }
}

