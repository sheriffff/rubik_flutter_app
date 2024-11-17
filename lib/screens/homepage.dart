import 'package:flutter/material.dart';
import 'config_screen.dart';
import 'practice_screen.dart';

class Homepage extends StatefulWidget {
  final String userName;

  Homepage({required this.userName});

  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  int _currentIndex = 0;  // Index for bottom navigation

  // Screens for bottom navigation
  final List<Widget> _screens = [
    ConfigScreen(),
    PracticeScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.userName),
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
