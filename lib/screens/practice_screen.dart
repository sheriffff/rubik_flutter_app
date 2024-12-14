import 'package:flutter/material.dart';
import 'letter_pairs_tab.dart';    // Import Letter Pairs Tab
import 'commutators_tab.dart';    // Import Commutators Tab

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
    _tabController = TabController(length: 2, vsync: this); // Number of tabs
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
        title: Text('Practice'),
        automaticallyImplyLeading: false,  // This removes the extra back button
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
          CommutatorsTab(),
        ],
      ),
    );
  }
}
