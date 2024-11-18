import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class StickerLettersTab extends StatefulWidget {
  final String userName;

  const StickerLettersTab({super.key, required this.userName});

  @override
  _StickerLettersTabState createState() => _StickerLettersTabState();
}

class _StickerLettersTabState extends State<StickerLettersTab> {
  List<Map<String, String>> edges = [];
  List<Map<String, String>> corners = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final edgesResponse = await http.get(Uri.parse('http://82.223.54.117:5000/stickers/edges/${widget.userName}'));
      final cornersResponse = await http.get(Uri.parse('http://82.223.54.117:5000/stickers/corners/${widget.userName}'));

      if (edgesResponse.statusCode == 200 && cornersResponse.statusCode == 200) {
        setState(() {
          edges = List<Map<String, String>>.from((json.decode(edgesResponse.body) as List).map((item) => Map<String, String>.from(item)));
          corners = List<Map<String, String>>.from((json.decode(cornersResponse.body) as List).map((item) => Map<String, String>.from(item)));
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          toolbarHeight: 0,  // This removes the blank space
          bottom: TabBar(
            tabs: [
              Tab(text: 'Edges'),
              Tab(text: 'Corners'),
            ],
          ),
        ),
        body: isLoading
            ? Center(child: CircularProgressIndicator())
            : TabBarView(
          children: [
            buildTable(edges),
            buildTable(corners),
          ],
        ),
      ),
    );
  }

  Widget buildTable(List<Map<String, String>> data) {
    return SingleChildScrollView(
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Sticker')),
          DataColumn(label: Text('Letter')),
        ],
        rows: data
            .map(
              (item) => DataRow(
            cells: [
              DataCell(Text(item['sticker'] ?? '')),
              DataCell(Text(item['letter'] ?? '')),
            ],
          ),
        )
            .toList(),
      ),
    );
  }
}