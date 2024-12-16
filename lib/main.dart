import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:crypto/crypto.dart'; // Import for hashing
import 'screens/homepage.dart';
import 'app_info.dart'; // Import the app_info.dart file
import 'package:intl/intl.dart'; // Import for date formatting
import 'package:rubik_app/config.dart'; // Ensure this contains your baseUrl

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rubik BLD Copilot',
      home: UserSelectionScreen(),
    );
  }
}

class UserSelectionScreen extends StatefulWidget {
  const UserSelectionScreen({super.key});

  @override
  _UserSelectionScreenState createState() => _UserSelectionScreenState();
}

class _UserSelectionScreenState extends State<UserSelectionScreen> {
  List<String> users = [];

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/users'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          users = data.cast<String>();
        });
      } else {
        throw Exception('Failed to load users');
      }
    } catch (e) {
      print('Error fetching users: $e');
      // Optionally, show an error message to the user
    }
  }

  /// Function to handle password verification
  Future<bool> verifyPassword(String username, String password) async {
    try {
      // Hash the password using SHA-256
      var bytes = utf8.encode(password);
      var digest = sha256.convert(bytes);
      String hashedPassword = digest.toString();

      // Prepare the request body
      Map<String, String> requestBody = {
        'username': username,
        'hashedPassword': hashedPassword,
      };

      // Make the POST request to verify the password
      final response = await http.post(
        Uri.parse('$baseUrl/verify_password'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return responseData['isValid'] as bool;
      } else {
        // Handle server errors
        print('Server error: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error verifying password: $e');
      return false;
    }
  }

  /// Function to show the password dialog
  void _showPasswordDialog(String username) {
    final _passwordController = TextEditingController();
    final _formKey = GlobalKey<FormState>();
    bool _isLoading = false;

    showDialog(
      context: context,
      barrierDismissible: false, // User must tap a button
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Enter Password'),
              content: Form(
                key: _formKey,
                child: TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                ),
              ),
              actions: [
                if (_isLoading)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(),
                  )
                else ...[
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the dialog
                    },
                    child: Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        setState(() {
                          _isLoading = true;
                        });

                        String enteredPassword = _passwordController.text;

                        bool isValid = await verifyPassword(username, enteredPassword);

                        setState(() {
                          _isLoading = false;
                        });

                        if (isValid) {
                          Navigator.of(context).pop(); // Close the dialog
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Homepage(userName: username),
                            ),
                          );
                        } else {
                          // Show error message
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Incorrect password. Please try again.'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                    child: Text('Submit'),
                  ),
                ],
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/rubiks_cube.png',
              width: 24,
              height: 24,
            ),
            SizedBox(width: 8),
            Text('Rubik BLD Copilot'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Expanded widget to take up remaining space for the user list
          Expanded(
            child: users.isEmpty
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  child: ElevatedButton(
                    onPressed: () {
                      _showPasswordDialog(users[index]);
                    },
                    child: Text(users[index]),
                  ),
                );
              },
            ),
          ),
          // Divider to separate the user list from the app info
          Divider(height: 1, color: Colors.grey),
          // Container for app information
          Container(
            color: Colors.grey[200],
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'App Version: ${AppInfo.version}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text('${DateFormat('dd MMMM yyyy').format(DateTime.parse(AppInfo.releaseDate))}'),
                SizedBox(height: 8),
                Text(
                  'Features:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                ...AppInfo.features.map((feature) => Text('- $feature')).toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
