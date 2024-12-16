import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:rubik_app/config.dart';

class NotesScreen extends StatefulWidget {
  final String userName;
  const NotesScreen({Key? key, required this.userName}) : super(key: key);

  @override
  _NotesScreenState createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  List<dynamic> _notes = [];
  Future<void> _fetchNotes() async {
    final response = await http.get(Uri.parse('$baseUrl/notes/${widget.userName}'));
    if (response.statusCode == 200) {
      setState(() {
        _notes = json.decode(response.body);
      });
    }
  }

  Future<void> _addNote() async {
    String? newContent = await _showNoteDialog();
    if (newContent != null && newContent.isNotEmpty) {
      final response = await http.post(
        Uri.parse('$baseUrl/notes'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'username': widget.userName, 'content': newContent}),
      );
      if (response.statusCode == 201) {
        _fetchNotes();
      }
    }
  }

  Future<void> _editNote(int id, String oldContent) async {
    String? updatedContent = await _showNoteDialog(initialContent: oldContent);
    if (updatedContent != null && updatedContent.isNotEmpty) {
      final response = await http.put(
        Uri.parse('$baseUrl/notes/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'content': updatedContent}),
      );
      if (response.statusCode == 200) {
        _fetchNotes();
      }
    }
  }

  Future<void> _deleteNote(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/notes/$id'));
    if (response.statusCode == 200) {
      _fetchNotes();
    }
  }

  Future<String?> _showNoteDialog({String initialContent = ''}) async {
    TextEditingController controller = TextEditingController(text: initialContent);
    FocusNode focusNode = FocusNode();

    return showDialog<String>(
      context: context,
      builder: (ctx) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          focusNode.requestFocus();
        });

        return AlertDialog(
          title: const Text('Note'),
          content: TextField(
            controller: controller,
            focusNode: focusNode,
            maxLines: 3,
            decoration: const InputDecoration(hintText: 'Enter note content'),
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.pop(ctx),
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () => Navigator.pop(ctx, controller.text),
            ),
          ],
        );
      },
    ).then((value) {
      focusNode.dispose();
      return value;
    });
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final item = _notes.removeAt(oldIndex);
      _notes.insert(newIndex, item);
    });
    // If you want to persist this order, call an API endpoint here.
  }

  @override
  void initState() {
    super.initState();
    _fetchNotes();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes'),
        automaticallyImplyLeading: false,
      ),
      body: _notes.isEmpty
          ? const Center(child: Text('No notes found'))
          : ReorderableListView.builder(
        itemCount: _notes.length,
        onReorder: _onReorder,
        itemBuilder: (context, index) {
          final note = _notes[index];
          return ListTile(
            key: ValueKey(note['id']),
            title: GestureDetector(
              onTap: () => _editNote(note['id'], note['content']),
              child: Text(note['content']),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _deleteNote(note['id']),
                ),
                const SizedBox(width: 20),
                // Replace the Icon with ReorderableDragStartListener
                ReorderableDragStartListener(
                  index: index,
                  child: const Icon(Icons.drag_handle),
                ),
                const SizedBox(width: 20),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNote,
        child: const Icon(Icons.add),
      ),
    );
  }

}
