import 'package:flutter/material.dart';
import 'letter_pairs_tab.dart';
import 'commutators_tab.dart';

class PracticeScreen extends StatefulWidget {
  final String userName;
  const PracticeScreen({super.key, required this.userName});

  @override
  _PracticeScreenState createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this); // now 3 tabs
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Practice'),
        automaticallyImplyLeading: false,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Letter Pairs'),
            Tab(text: 'Commutators'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          LetterPairsTab(userName: widget.userName),
          CommutatorsTab(userName: widget.userName),
        ],
      ),
    );
  }
}
