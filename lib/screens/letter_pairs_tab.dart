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
  Map<String, dynamic>? currentPair;
  bool showWord = false;

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

  void handleTap() {
    setState(() {
      if (showWord) {
        currentPair = getRandomFilteredPair();
      }
      showWord = !showWord;
    });
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
    String selectedMode = 'Tap'; // Default mode

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
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Radio<String>(
              value: 'Tap',
              groupValue: selectedMode,
              onChanged: (String? value) {
                setState(() {
                  selectedMode = value!;
                });
              },
            ),
            Text('Tap'),
            Radio<String>(
              value: 'Time',
              groupValue: selectedMode,
              onChanged: (String? value) {
                setState(() {
                  selectedMode = value!;
                });
              },
            ),
            Text('Time'),
          ],
        ),
      ],
    );
  }

  Widget buildRandomPairDisplay() {
    final randomPair = currentPair ?? getRandomFilteredPair();
    if (randomPair == null) {
      return Center(child: Text('No pairs available'));
    }

    // Define fixed heights for each section to prevent shifting
    const double letterFontSize = 40;
    const double wordFontSize = 60;
    const double wordHeight = 80; // Enough space for the larger word font
    const double imageHeight = 200;
    const double verticalOffset = 30; // Adjust this value to move the letters lower
    const double imageOffset = 40; // Extra offset for the image

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: handleTap,
      child: Center(
        child: SizedBox(
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start, // Start at the upper part
            children: [
              // Add padding to move the letters lower
              Padding(
                padding: EdgeInsets.only(top: verticalOffset),
                child: SizedBox(
                  height: letterFontSize * 1.2,
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: Text(
                      '${randomPair['first_letter'] ?? ''} ${randomPair['second_letter'] ?? ''}',
                      style: TextStyle(fontSize: letterFontSize),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              // Word area, fixed height whether word is shown or not
              SizedBox(
                height: wordHeight,
                child: showWord
                    ? FittedBox(
                  fit: BoxFit.contain,
                  child: Text(
                    randomPair['word'] ?? '',
                    style: TextStyle(fontSize: wordFontSize),
                  ),
                )
                    : SizedBox.shrink(),
              ),
              SizedBox(height: imageOffset), // Extra offset for the image
              // Test image below
              SizedBox(
                height: imageHeight,
                child: Image.network(
                  'https://via.placeholder.com/150',
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}