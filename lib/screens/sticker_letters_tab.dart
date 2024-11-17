import 'package:flutter/material.dart';

class StickerLettersTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Number of tabs
      child: Scaffold(
        body: Column(
          children: [
            // TabBar
            TabBar(
              tabs: [
                Tab(text: 'Edges'),
                Tab(text: 'Corners'),
              ],
            ),
            // TabBarView
            Expanded(
              child: TabBarView(
                children: [
                  Center(
                    child: Text(
                      'Edges Content',
                      style: TextStyle(fontSize: 24),
                    ),
                  ),
                  Center(
                    child: Text(
                      'Corners Content',
                      style: TextStyle(fontSize: 24),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
