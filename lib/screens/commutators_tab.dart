import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:math';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:rubik_app/config.dart';

class CommutatorsTab extends StatefulWidget {
  final String userName;

  const CommutatorsTab({super.key, required this.userName});

  @override
  _CommutatorsTabState createState() => _CommutatorsTabState();
}

class _CommutatorsTabState extends State<CommutatorsTab> {
  List<Map<String, dynamic>> commutators = [];
  Map<String, bool> letterFilter = {};
  bool isLoading = true;
  String selectedMode = 'Tap';
  String selectedType = 'Edges';
  String selectedFormat = 'Ls'; // 'Ls' for letters, 'W' for word
  int timeInterval = 2;
  Map<String, dynamic>? currentPair;
  Timer? _timer;
  final Random _random = Random();

  // Map to store (first_letter, second_letter) -> word
  Map<String, String> letterPairsWords = {};

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final edgesResponse = await http.get(Uri.parse('$baseUrl/commutators/edges/${widget.userName}'));
      final cornersResponse = await http.get(Uri.parse('$baseUrl/commutators/corners/${widget.userName}'));

      if (edgesResponse.statusCode == 200 && cornersResponse.statusCode == 200) {
        final edgesData = List<Map<String, dynamic>>.from(json.decode(edgesResponse.body) as List);
        for (var item in edgesData) {
          item['type'] = 'Edges';
        }

        final cornersData = List<Map<String, dynamic>>.from(json.decode(cornersResponse.body) as List);
        for (var item in cornersData) {
          item['type'] = 'Corners';
        }

        final letterPairsResponse = await http.get(Uri.parse('$baseUrl/letter_pairs/${widget.userName}'));

        if (letterPairsResponse.statusCode == 200) {
          final letterPairsData = List<Map<String, dynamic>>.from(json.decode(letterPairsResponse.body) as List);
          for (var pairItem in letterPairsData) {
            final fl = pairItem['first_letter'];
            final sl = pairItem['second_letter'];
            final w = pairItem['word'];
            final key = '$fl $sl';
            letterPairsWords[key] = w;
          }
        }

        setState(() {
          commutators = [...edgesData, ...cornersData];
          isLoading = false;
          initializeLetterFilter();
          currentPair = getRandomFilteredPair();
        });
      } else {
        throw Exception('Failed to load commutators');
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  void initializeLetterFilter() {
    final uniqueLetters = commutators
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

  List<Map<String, dynamic>> getFilteredCommutators() {
    return commutators.where((pair) {
      return pair['type'] == selectedType && (letterFilter[pair['first_letter']] ?? false);
    }).toList();
  }

  Map<String, dynamic>? getRandomFilteredPair() {
    final filteredPairs = getFilteredCommutators();
    if (filteredPairs.isEmpty) return null;
    return filteredPairs[_random.nextInt(filteredPairs.length)];
  }

  void startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: timeInterval), (timer) {
      setState(() {
        currentPair = getRandomFilteredPair();
      });
    });
  }

  void handleNext() {
    setState(() {
      currentPair = getRandomFilteredPair();
    });
    if (selectedMode == 'Time') {
      startTimer();
    }
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
        // Row with All/None and Edges/Corners
        Row(
          children: [
            ElevatedButton(onPressed: checkAll, child: Text('All')),
            ElevatedButton(onPressed: clearAll, child: Text('None')),
            SizedBox(width: 16),
            Radio<String>(
              value: 'Edges',
              groupValue: selectedType,
              onChanged: (String? value) {
                setState(() {
                  selectedType = value!;
                  currentPair = getRandomFilteredPair();
                });
              },
            ),
            Text('Edges'),
            Radio<String>(
              value: 'Corners',
              groupValue: selectedType,
              onChanged: (String? value) {
                setState(() {
                  selectedType = value!;
                  currentPair = getRandomFilteredPair();
                });
              },
            ),
            Text('Corners'),
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
                  min: 2,
                  max: 20,
                  divisions: 18,
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
        SizedBox(height: 8),
        // Ls/W radio row, right beneath the Tap/Time radio, kept close
        Row(
          children: [
            Radio<String>(
              value: 'Ls',
              groupValue: selectedFormat,
              onChanged: (String? value) {
                setState(() {
                  selectedFormat = value!;
                });
              },
            ),
            Text('Ls'),
            Radio<String>(
              value: 'W',
              groupValue: selectedFormat,
              onChanged: (String? value) {
                setState(() {
                  selectedFormat = value!;
                });
              },
            ),
            Text('W'),
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
    const double commutatorSimplifiedFontSize = 30;
    const double commutatorFontSize = 20;
    const double buttonShowNextFontSize = 20;
    const double verticalOffset = 30;

    // Determine the displayed label based on selectedFormat
    String displayedLabel;
    if (selectedFormat == 'W') {
      final key = '${randomPair['first_letter']} ${randomPair['second_letter']}';
      displayedLabel = letterPairsWords[key] ?? '${randomPair['first_letter'] ?? ''} ${randomPair['second_letter'] ?? ''}';
    } else {
      displayedLabel = '${randomPair['first_letter'] ?? ''} ${randomPair['second_letter'] ?? ''}';
    }

    return Center(
      child: SizedBox(
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(height: verticalOffset),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(width: 60),
                  Text(
                    displayedLabel,
                    style: TextStyle(fontSize: letterFontSize),
                  ),
                  GestureDetector(
                    onTap: handleNext,
                    child: Text(
                      'NEXT',
                      style: TextStyle(
                        fontSize: buttonShowNextFontSize,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 40),
              SizedBox(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        randomPair['commutator_simplified'] ?? '',
                        style: TextStyle(
                          fontSize: commutatorSimplifiedFontSize,
                          color: Colors.blue,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 20),
                      Text(
                        randomPair['commutator'] ?? '',
                        style: TextStyle(fontSize: commutatorFontSize),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

