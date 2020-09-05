import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tugas_note/pages/home_screen.dart';

class EditNoteScreen extends StatefulWidget {
  final note;
  EditNoteScreen({this.note});

  @override
  _EditNoteScreenState createState() => _EditNoteScreenState();
}

class _EditNoteScreenState extends State<EditNoteScreen> {
  bool _isLoading = false;
  final _formKey = new GlobalKey<FormState>();

  TextEditingController _titleController = TextEditingController();
  TextEditingController _messageController = TextEditingController();
  FocusNode _titleNode = FocusNode();
  FocusNode _messageNode = FocusNode();

  void check() {
    final form = _formKey.currentState;

    if (form.validate()) {
      form.save();
      setState(() {
        _isLoading = true;
      });
      updateNote();
    }
  }

  deleteNote() async {
    final responseData = await http
        .delete("http://10.0.2.2:8000/api/notes/${widget.note['id']}");

    // final data = jsonDecode(responseData.body);
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(),
        ));
  }

  updateNote() async {
    final responseData = await http
        .put("http://10.0.2.2:8000/api/notes/${widget.note['id']}", body: {
      "title": _titleController.text.trim(),
      "message": _messageController.text.trim(),
    });

    // final data = jsonDecode(responseData.body);
     Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(),
        ));
  }

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.note['title'];
    _messageController.text = widget.note['message'];
    print(widget.note);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Note'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 15),
            child: GestureDetector(
              onTap: deleteNote,
              child: Icon(
                Icons.delete_forever,
              ),
            ),
          ),
        ],
      ),
      body: Container(
        padding: EdgeInsets.all(18),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    validator: (e) {
                      return e.isEmpty ? 'please insert title' : null;
                    },
                    controller: _titleController,
                    focusNode: _titleNode,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      labelText: "Note's title",
                      prefixIcon: Icon(Icons.title),
                    ),
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    controller: _messageController,
                    focusNode: _messageNode,
                    maxLines: 5,
                    decoration: InputDecoration(border: OutlineInputBorder()),
                  ),
                  SizedBox(height: 20),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    child: RaisedButton(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      onPressed: _isLoading ? null : check,
                      child: _isLoading
                          ? CircularProgressIndicator()
                          : Text('Update Note'),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
