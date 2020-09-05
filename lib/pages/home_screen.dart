import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tugas_note/pages/add_note_screen.dart';
import 'package:tugas_note/pages/login_screen.dart';
import 'package:tugas_note/widgets/widget_note_list.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TextEditingController _searchController = TextEditingController();
  String name = '';
  int userId;

  Future _getNotes() async {
    final responseData =
        await http.get("http://10.0.2.2:8000/api/notes-by-user/${userId.toString()}");
    if (responseData.statusCode == 200) {
      final data = jsonDecode(responseData.body);
      return data['notes'];
    }
  }

  getDataPref() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      String userName = pref.getString("name");
      final idUser = pref.getInt('id_user');
      name = userName;
      userId = idUser;
    });
  }

  logout() async {
    final pref = await SharedPreferences.getInstance();
    await pref.clear();
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => LoginScreen()),
        (route) => false);
  }

  @override
  void initState() {
    super.initState();
    getDataPref();
    _getNotes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.note_add),
        elevation: 3,
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddNoteScreen(),
            ),
          );

          setState(() {});
        },
      ),
      body: Container(
        padding: EdgeInsets.all(18),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      "Welcome Back, \n" + name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  RaisedButton(
                    onPressed: logout,
                    child: Icon(Icons.exit_to_app),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                  )
                ],
              ),
              SizedBox(height: 20),
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: 'Search',
                  prefixIcon: Icon(
                    Icons.search,
                  ),
                  border: OutlineInputBorder(),
                ),
              ),
              Expanded(
                child: FutureBuilder(
                  future: _getNotes(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      // print(snapshot.data.length);
                      return snapshot.data.length == 0
                          ? Center(child: Text('Nothing to show'))
                          : GridView.count(
                              crossAxisCount: 2,
                              crossAxisSpacing: 2,
                              children:
                                  List.generate(snapshot.data.length, (index) {
                                return Note(list: snapshot.data, index: index);
                              }),
                            );
                    } else if (snapshot.hasError) {
                      return Text("${snapshot.error}");
                    }
                    // By default, show a loading spinner.
                    return Center(child: CircularProgressIndicator());
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
