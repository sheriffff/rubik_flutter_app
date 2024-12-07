import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LetterPairsConfigTab extends StatefulWidget {
  final String userName;

  const LetterPairsConfigTab({super.key, required this.userName});

  @override
  _LetterPairsConfigTabState createState() => _LetterPairsConfigTabState();
}

class _LetterPairsConfigTabState extends State<LetterPairsConfigTab> {
  List<Map<String, String>> letterPairs = [];
  bool isLoading = true;
  String selectedLetterFilter = 'All';

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
          letterPairs = List<Map<String, String>>.from(
              (json.decode(response.body) as List)
                  .map((item) => Map<String, String>.from(item)));
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load letter pairs');
      }
    } catch (e) {
      print('Error fetching letter pairs: $e');
    }
  }

  Future<void> updateLetterPair(int id, String column, String newValue) async {
    try {
      final response = await http.patch(
        Uri.parse('http://82.223.54.117:5000/letter_pairs/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({column: newValue}),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update letter pair');
      }
    } catch (e) {
      print('Error updating letter pair: $e');
    }
  }

  List<String> getUniqueLetters(List<Map<String, String>> data) {
    final letters = data.map((item) => item['first_letter'] ?? '').toSet().toList();
    letters.sort();
    return ['All', ...letters];
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Center(child: CircularProgressIndicator())
        : buildNestedTabView(letterPairs);
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
        DataColumn(label: Text('Word')),
      ],
      rows: data
          .map(
            (pair) => DataRow(
          cells: [
            DataCell(Text(pair['first_letter'] ?? '')),
            DataCell(Text(pair['second_letter'] ?? '')),
            DataCell(
              Text(pair['word'] ?? ''),
              onTap: () => _editCell(context, pair['id']!, 'word', pair['word'] ?? ''),
            ),
          ],
        ),
      )
          .toList(),
    );
  }

  void _editCell(BuildContext context, String id, String column, String currentValue) {
    final controller = TextEditingController(text: currentValue);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit $column'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(labelText: 'New value'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final newValue = controller.text.trim();
                if (newValue.isNotEmpty) {
                  setState(() {
                    final index = letterPairs.indexWhere((pair) => pair['id'] == id);
                    if (index != -1) letterPairs[index][column] = newValue;
                  });
                  await updateLetterPair(int.parse(id), column, newValue);
                }
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
