import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';

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
  final Random _random = Random();

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

  Map<String, dynamic>? getRandomFilteredPair() {
    final filteredPairs = getFilteredLetterPairs();
    if (filteredPairs.isEmpty) return null;
    return filteredPairs[_random.nextInt(filteredPairs.length)];
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Center(child: CircularProgressIndicator())
        : Column(
            children: [
              buildFilterControls(),
              Expanded(child: buildRandomPairDisplay()),
            ],
          );
  }

  Widget buildFilterControls() {
    final letters = letterFilter.keys.toList();
    int total = letters.length;
    int columns = 7;
    int rows = (total / columns).ceil();

    return Column(
      children: [
        Row(
          children: [
            ElevatedButton(onPressed: checkAll, child: Text('All')),
            ElevatedButton(onPressed: clearAll, child: Text('None')),
          ],
        ),
        Table(
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          columnWidths: Map.fromEntries(
            List.generate(columns, (index) => MapEntry(index, IntrinsicColumnWidth())),
          ),
          children: List.generate(rows, (rowIndex) {
            return TableRow(
              children: List.generate(columns, (colIndex) {
                int letterIndex = rowIndex * columns + colIndex;
                if (letterIndex < total) {
                  String letter = letters[letterIndex];
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Checkbox(
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
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
                } else {
                  return SizedBox.shrink();
                }
              }),
            );
          }),
        ),
      ],
    );
  }

  Widget buildRandomPairDisplay() {
    final randomPair = getRandomFilteredPair();
    if (randomPair == null) {
      return Center(child: Text('No pairs available'));
    }
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('L1: ${randomPair['first_letter'] ?? ''}'),
          Text('L2: ${randomPair['second_letter'] ?? ''}'),
          Text('Word: ${randomPair['word'] ?? ''}'),
        ],
      ),
    );
  }
}