import 'package:flutter/material.dart';
import 'letter_pairs_config_tab.dart';
import 'sticker_letters_config_tab.dart';  // Import Sticker Letters Tab
import 'commutators_config_tab.dart';  // Import Commutators Config Tab

class ConfigScreen extends StatefulWidget {
  final String userName;

  const ConfigScreen({super.key, required this.userName});

  @override
  _ConfigScreenState createState() => _ConfigScreenState();
}

class _ConfigScreenState extends State<ConfigScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this); // Number of tabs
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
        title: Text('Config'),
        automaticallyImplyLeading: false,  // This removes the extra back button
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Sticker Letters'),
            Tab(text: 'Letter Pairs'),
            Tab(text: 'Commutators'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          StickerLettersConfigTab(userName: widget.userName),
          LetterPairsConfigTab(),
          CommutatorsConfigTab(userName: widget.userName),
        ],
      ),
    );
  }
}