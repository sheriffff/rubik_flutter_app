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
  Map<String, bool> letterFilter = {};

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
          initializeLetterFilter();
        });
      } else {
        throw Exception('Failed to load letter pairs');
      }
    } catch (e) {
      print('Error fetching letter pairs: $e');
    }
  }

  void initializeLetterFilter() {
    final uniqueLetters = letterPairs
        .map((pair) => pair['first_letter'] as String)
        .toSet()
        .toList();
    uniqueLetters.sort();
    setState(() {
      letterFilter = {for (var letter in uniqueLetters) letter: true};
    });
  }

  void checkAll() {
    setState(() {
      letterFilter.updateAll((key, value) => true);
    });
  }

  void clearAll() {
    setState(() {
      letterFilter.updateAll((key, value) => false);
    });
  }

  List<Map<String, dynamic>> getFilteredLetterPairs() {
    return letterPairs
        .where((pair) => letterFilter[pair['first_letter']] ?? false)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Center(child: CircularProgressIndicator())
        : Column(
      children: [
        buildFilterControls(),
        Expanded(child: buildDataTable(getFilteredLetterPairs())),
      ],
    );
  }

  Widget buildFilterControls() {
    return Column(
      children: [
        Row(
          children: [
            ElevatedButton(onPressed: checkAll, child: Text('Check All')),
            ElevatedButton(onPressed: clearAll, child: Text('Clear All')),
          ],
        ),
        Wrap(
          children: letterFilter.keys.map((letter) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Checkbox(
                  value: letterFilter[letter],
                  onChanged: (bool? value) {
                    setState(() {
                      letterFilter[letter] = value ?? false;
                    });
                  },
                ),
                Text(letter),
              ],
            );
          }).toList(),
        ),
      ],
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
            DataCell(Text(pair['word'] ?? '')),
          ],
        );
      }).toList(),
    );
  }
}