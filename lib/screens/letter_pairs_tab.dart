import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';
import 'dart:async';

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
  String selectedMode = 'Tap'; // Default mode
  int timeInterval = 1; // Default time interval
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    fetchLetterPairs();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
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

  void startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: timeInterval), (timer) {
      setState(() {
        showWord = !showWord;
        if (!showWord) {
          currentPair = getRandomFilteredPair();
        }
      });
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
          children: [
            Radio<String>(
              value: 'Tap',
              groupValue: selectedMode,
              onChanged: (String? value) {
                setState(() {
                  selectedMode = value!;
                  _timer?.cancel();
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
                  startTimer();
                });
              },
            ),
            Text('Time'),
            if (selectedMode == 'Time') ...[
              SizedBox(width: 16),
              Text('t: ${timeInterval}s'),
              SizedBox(width: 8),
              SizedBox(
                width: 150,
                child: Slider(
                  value: timeInterval.toDouble(),
                  min: 1,
                  max: 5,
                  divisions: 4,
                  label: timeInterval.toString(),
                  onChanged: (double value) {
                    setState(() {
                      timeInterval = value.toInt();
                      startTimer();
                    });
                  },
                ),
              ),
            ],
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

    const double letterFontSize = 40;
    const double wordFontSize = 60;
    const double wordHeight = 80;
    const double imageHeight = 140;
    const double verticalOffset = 30;
    const double imageOffset = 40;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: selectedMode == 'Tap' ? handleTap : null,
      child: Center(
        child: SizedBox(
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
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
              SizedBox(height: imageOffset),
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