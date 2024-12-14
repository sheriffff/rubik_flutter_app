import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LetterPairsTab extends StatefulWidget {
  final String userName;

  const LetterPairsTab({super.key, required this.userName});

  @override
  _LetterPairsTabState createState() => _LetterPairsTabState();
}

class _LetterPairsTabState extends State<LetterPairsTab> {
  List<Map<String, dynamic>> letterPairs = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchLetterPairs();
  }

  Future<void> fetchLetterPairs() async {
    try {
      final response = await http.get(Uri.parse(
          'http://82.223.54.117:5000/letter_pairs/${widget.userName}'));

      if (response.statusCode == 200) {
        setState(() {
          letterPairs = List<Map<String, dynamic>>.from(
              (json.decode(response.body) as List)
                  .map((item) => Map<String, dynamic>.from(item)));
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load letter pairs');
      }
    } catch (e) {
      print('Error fetching letter pairs: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Letter Pairs Practice Content',
        style: TextStyle(fontSize: 24),
      ),
    );
  }
}
