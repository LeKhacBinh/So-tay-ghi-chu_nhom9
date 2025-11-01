// Danh sách Ghi chú

import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/note_model.dart';
import 'add_note_screen.dart';


class NotesListScreen extends StatefulWidget {
  const NotesListScreen({super.key});

  @override
  State<NotesListScreen> createState() => _NotesListScreenState();
}

class _NotesListScreenState extends State<NotesListScreen> {

  final DatabaseHelper _dbHelper = DatabaseHelper();
  late Future<List<Note>> _notesFuture;

  @override
  void initState() {
    super.initState();
    _refreshNotesList();
  }


  void _refreshNotesList() {
    setState(() {
      _notesFuture = _dbHelper.getNotes();
    });
  }


  void _navigateToEditScreen(Note note) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddNoteScreen(note: note)),
    );
    // Khi quay lại từ màn hình sửa, làm mới danh sách.
    _refreshNotesList();
  }


  void _navigateToAddScreen() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddNoteScreen()),
    );
    _refreshNotesList();
  }


  void _deleteNoteAndRefresh(int id) async {
    await _dbHelper.deleteNote(id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã xóa ghi chú!'),
        backgroundColor: Colors.redAccent,
      ),
    );
    _refreshNotesList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ghi Chú Của Tôi'),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Note>>(
        future: _notesFuture,
        builder: (context, snapshot) {
          // Hiển thị chỉ báo tải trong khi chờ dữ liệu.
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          // Hiển thị thông báo nếu không có ghi chú nào.
          else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'Chưa có ghi chú nào.\nNhấn + để thêm ghi chú mới!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }
          // Hiển thị danh sách ghi chú.
          else {
            final notes = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: notes.length,
              itemBuilder: (context, index) {
                final note = notes[index];
                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.symmetric(vertical: 6.0),
                  child: ListTile(
                    title: Text(
                      note.content,
                      style: const TextStyle(fontSize: 16),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'edit') {
                          _navigateToEditScreen(note);
                        } else if (value == 'delete') {
                          // Thêm hộp thoại xác nhận trước khi xoá
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Xác nhận Xoá'),
                                content: const Text(
                                    'Bạn có chắc chắn muốn xoá ghi chú này không?'),
                                actions: <Widget>[
                                  TextButton(
                                    child: const Text('Huỷ'),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                  TextButton(
                                    child: const Text('Xoá',
                                        style: TextStyle(color: Colors.red)),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                      _deleteNoteAndRefresh(note.id!);
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        }
                      },
                      itemBuilder: (BuildContext context) =>
                      <PopupMenuEntry<String>>[
                        const PopupMenuItem<String>(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit, size: 20),
                              SizedBox(width: 8),
                              Text('Chỉnh sửa'),
                            ],
                          ),
                        ),
                        const PopupMenuItem<String>(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, size: 20),
                              SizedBox(width: 8),
                              Text('Xoá'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddScreen,
        tooltip: 'Thêm Ghi chú',
        child: const Icon(Icons.add),
      ),
    );
  }
}

