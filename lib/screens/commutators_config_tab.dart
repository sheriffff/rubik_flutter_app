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

  String selectedLetterFilter = 'All';

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

  List<String> getUniqueLetters(List<Map<String, String>> data) {
    final letters = data.map((item) => item['first_letter'] ?? '').toSet().toList();
    letters.sort();
    return ['All', ...letters];
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
                : buildNestedTabView(cornersCommutators),
            isLoadingEdges
                ? Center(child: CircularProgressIndicator())
                : buildNestedTabView(edgesCommutators),
          ],
        ),
      ),
    );
  }

  Widget buildNestedTabView(List<Map<String, String>> data) {
    final uniqueLetters = getUniqueLetters(data);

    return DefaultTabController(
      length: uniqueLetters.length,
      child: Column(
        children: [
          TabBar(
            isScrollable: true,
            tabs: uniqueLetters.map((letter) => Tab(text: letter)).toList(),
            onTap: (index) {
              setState(() {
                selectedLetterFilter = uniqueLetters[index];
              });
            },
          ),
          Expanded(
            child: TabBarView(
              physics: NeverScrollableScrollPhysics(),
              children: uniqueLetters.map((letter) {
                final filteredData = letter == 'All'
                    ? data
                    : data.where((item) => item['first_letter'] == letter).toList();
                return SingleChildScrollView(
                  child: buildDataTable(filteredData),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildDataTable(List<Map<String, String>> data) {
    return DataTable(
      columns: const [
        DataColumn(label: Text('L1')),
        DataColumn(label: Text('L2')),
        DataColumn(label: Text('Commutator')),
        DataColumn(label: Text('Comm')),
      ],
      rows: data
          .map(
            (item) => DataRow(
          cells: [
            DataCell(Text(item['first_letter'] ?? '')),
            DataCell(Text(item['second_letter'] ?? '')),
            DataCell(Text(item['commutator'] ?? '')),
            DataCell(Text(item['commutator_simplified'] ?? '')),
          ],
        ),
      )
          .toList(),
    );
  }
}
