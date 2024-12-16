import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:rubik_app/config.dart';

class LetterPairsConfigTab extends StatefulWidget {
  final String userName;

  const LetterPairsConfigTab({super.key, required this.userName});

  @override
  _LetterPairsConfigTabState createState() => _LetterPairsConfigTabState();
}

class _LetterPairsConfigTabState extends State<LetterPairsConfigTab> {
  List<Map<String, dynamic>> letterPairs = [];
  bool isLoading = true;
  String selectedLetterFilter = 'All';

  @override
  void initState() {
    super.initState();
    fetchLetterPairs();
  }

  Future<void> fetchLetterPairs() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/letter_pairs/${widget.userName}'));

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

  Future<void> updateLetterPair(int id, String column, String newValue) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/update_letter_pair/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({"newWord": newValue}),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update letter pair');
      }
    } catch (e) {
      print('Error updating letter pair: $e');
    }
  }


  List<String> getUniqueLetters(List<Map<String, dynamic>> data) {
    final letters = data
        .map((item) => item['first_letter']?.toString() ?? '') // Safely extract as a string
        .toSet()
        .toList();
    letters.sort();
    return ['All', ...letters];
  }


  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Center(child: CircularProgressIndicator())
        : buildNestedTabView(letterPairs);
  }

  Widget buildNestedTabView(List<Map<String, dynamic>> data) {
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


  Widget buildDataTable(List<Map<String, dynamic>> data) {
    return DataTable(
      columns: const [
        DataColumn(label: Text('L1')),
        DataColumn(label: Text('L2')),
        DataColumn(label: Text('Word')),
      ],
      rows: data.map((pair) {
        return DataRow(
          cells: [
            DataCell(Text(pair['first_letter'] ?? '')),
            DataCell(Text(pair['second_letter'] ?? '')),
            DataCell(
              Text(pair['word'] ?? ''),
              onTap: () => _editCell(
                context,
                pair['id'], // Pass id as int
                'word',
                pair['word'] ?? '',
              ),
            ),
          ],
        );
      }).toList(),
    );
  }


  void _editCell(BuildContext context, int id, String column, String currentValue) {
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
                  await updateLetterPair(id, column, newValue);
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
