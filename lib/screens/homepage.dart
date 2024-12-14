import 'package:flutter/material.dart';
import 'config_screen.dart';
import 'practice_screen.dart';

class Homepage extends StatefulWidget {
  final String userName;

  const Homepage({super.key, required this.userName});

  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  int _currentIndex = 0;  // Index for bottom navigation

  // Screens for bottom navigation
  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      ConfigScreen(userName: widget.userName),
      PracticeScreen(userName: widget.userName),
    ];
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
            Text(widget.userName),
          ],
        ),
      ),
      body: _screens[_currentIndex],  // Show selected screen
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;  // Update the current index
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Config',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.play_arrow),
            label: 'Practice',
          ),
        ],
      ),
    );
  }
}