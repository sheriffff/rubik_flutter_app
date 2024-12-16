import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'screens/homepage.dart';
import 'app_info.dart'; // Import the app_info.dart file
import 'package:intl/intl.dart'; // Add this import for date formatting
import 'package:rubik_app/config.dart';


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
    }
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Homepage(userName: users[index]),
                        ),
                      );
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
