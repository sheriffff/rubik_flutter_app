import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CommutatorsConfigTab extends StatefulWidget {
  final String userName;

  const CommutatorsConfigTab({super.key, required this.userName});

  @override
  _CommutatorsConfigTabState createState() => _CommutatorsConfigTabState();
}

class _CommutatorsConfigTabState extends State<CommutatorsConfigTab> {
  List<Map<String, String>> edgesCommutators = [];
  List<Map<String, String>> cornersCommutators = [];
  bool isLoadingEdges = true;
  bool isLoadingCorners = true;

  @override
  void initState() {
    super.initState();
    fetchEdgesCommutators();
    fetchCornersCommutators();
  }

  Future<void> fetchEdgesCommutators() async {
    try {
      final response = await http.get(Uri.parse(
          'http://82.223.54.117:5000/commutators/edges/${widget.userName}'));

      if (response.statusCode == 200) {
        setState(() {
          edgesCommutators = List<Map<String, String>>.from(
              (json.decode(response.body) as List)
                  .map((item) => Map<String, String>.from(item)));
          isLoadingEdges = false;
        });
      } else {
        throw Exception('Failed to load edges commutators');
      }
    } catch (e) {
      print('Error fetching edges commutators: $e');
    }
  }

  Future<void> fetchCornersCommutators() async {
    try {
      final response = await http.get(Uri.parse(
          'http://82.223.54.117:5000/commutators/corners/${widget.userName}'));

      if (response.statusCode == 200) {
        setState(() {
          cornersCommutators = List<Map<String, String>>.from(
              (json.decode(response.body) as List)
                  .map((item) => Map<String, String>.from(item)));
          isLoadingCorners = false;
        });
      } else {
        throw Exception('Failed to load corners commutators');
      }
    } catch (e) {
      print('Error fetching corners commutators: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          toolbarHeight: 0,
          bottom: TabBar(
            tabs: [
              Tab(text: 'Corners'),
              Tab(text: 'Edges'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            isLoadingCorners
                ? Center(child: CircularProgressIndicator())
                : buildCornersTable(cornersCommutators),
            isLoadingEdges
                ? Center(child: CircularProgressIndicator())
                : buildEdgesTable(edgesCommutators),
          ],
        ),
      ),
    );
  }

  Widget buildEdgesTable(List<Map<String, String>> data) {
    return SingleChildScrollView(
      child: DataTable(
        columns: const [
          DataColumn(label: Text('L1')),
          DataColumn(label: Text('L2')),
          DataColumn(label: Text('Commutator')),
        ],
        rows: data
            .map(
              (item) => DataRow(
            cells: [
              DataCell(Text(item['first_sticker'] ?? '')),
              DataCell(Text(item['second_sticker'] ?? '')),
              DataCell(Text(item['commutator'] ?? '')),
            ],
          ),
        )
            .toList(),
      ),
    );
  }

    Widget buildCornersTable(List<Map<String, String>> data) {
    return SingleChildScrollView(
      child: DataTable(
        columns: const [
          DataColumn(label: Text('L1')),
          DataColumn(label: Text('L2')),
          DataColumn(label: Text('Commutator')),
        ],
        rows: data
            .map(
              (item) => DataRow(
            cells: [
              DataCell(Text(item['first_sticker'] ?? '')),
              DataCell(Text(item['second_sticker'] ?? '')),
              DataCell(Text(item['commutator'] ?? '')),
            ],
          ),
        )
            .toList(),
      ),
    );
  }
}
