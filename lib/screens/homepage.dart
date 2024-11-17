import 'package:flutter/material.dart';

class Homepage extends StatelessWidget {
  final String userName;

  Homepage({required this.userName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Welcome')),
      body: Center(
        child: Text(
          'Hi $userName',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
