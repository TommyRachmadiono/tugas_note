import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class AddNoteScreen extends StatefulWidget {
  @override
  _AddNoteScreenState createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends State<AddNoteScreen> {
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
      submitNote();
    }
  }

  submitNote() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    final userId = pref.getInt('id_user');
    final responseData =
        await http.post("http://10.0.2.2:8000/api/notes", body: {
      "title": _titleController.text.trim(),
      "message": _messageController.text.trim(),
      "user_id": userId.toString(),
    });

    final data = jsonDecode(responseData.body);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Note')),
      body: SingleChildScrollView(
        child: Container(
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
                            : Text('Add Note'),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
