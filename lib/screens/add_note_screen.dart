// Thêm Ghi chú

import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/note_model.dart';


class AddNoteScreen extends StatefulWidget {
  final Note? note;
  const AddNoteScreen({super.key, this.note});

  @override
  State<AddNoteScreen> createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends State<AddNoteScreen> {
  final _textController = TextEditingController();
  final DatabaseHelper _dbHelper = DatabaseHelper();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    if (widget.note != null) {
      _isEditing = true;
      _textController.text = widget.note!.content;
    }
  }

  void _saveOrUpdateNote() async {
    final content = _textController.text;
    if (content.trim().isNotEmpty) {
      if (_isEditing) {
        final updatedNote = Note(
          id: widget.note!.id,
          content: content,
        );
        await _dbHelper.updateNote(updatedNote);
      } else {
        final newNote = Note(content: content);
        await _dbHelper.insertNote(newNote);
      }

      if (mounted) {
        Navigator.pop(context);
      }
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nội dung không được để trống!'),
          backgroundColor: Colors.orangeAccent,
        ),
      );
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Chỉnh sửa Ghi chú' : 'Ghi chú mới'),
        actions: [

          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveOrUpdateNote,
            tooltip: 'Lưu Ghi chú',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: TextField(
          controller: _textController,
          autofocus: true,
          maxLines: null,
          expands: true,
          decoration: const InputDecoration(
            hintText: 'Nhập nội dung của bạn ở đây...',
            border: InputBorder.none,
          ),
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
