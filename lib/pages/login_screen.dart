import 'dart:convert';

import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

enum statusLogin { guest, signIn }

class _LoginScreenState extends State<LoginScreen> {
  statusLogin _loginStatus = statusLogin.guest;
  final _key = new GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  bool _secureText = true;
  bool _isLoading = false;
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  FocusNode _emailNode = FocusNode();
  FocusNode _passwordNode = FocusNode();

  void showHide() {
    setState(() {
      _secureText = !_secureText;
    });
  }

  void check() {
    final form = _key.currentState;

    if (form.validate()) {
      form.save();
      setState(() {
        _isLoading = true;
      });
      submitDataLogin();
    }
  }

  submitDataLogin() async {
    final responseData =
        await http.post("http://10.0.2.2:8000/api/login-mobile", body: {
      "email": _emailController.text.trim(),
      "password": _passwordController.text.trim(),
    });

    final data = jsonDecode(responseData.body);
    int value = data["value"];
    String msg = data["msg"];
    // print(data);

    if (value == 1) {
      int dataIdUser = data["user"]["id"];
      String dataName = data["user"]["name"];
      String dataEmail = data["user"]["email"];
      String dataAlamat = data["user"]["alamat"];
      String dataJenisKelamin = data["user"]["jenis_kelamin"];
      String dataTanggalDaftar = data["user"]["created_at"];
      setState(() {
        _loginStatus = statusLogin.signIn;
        saveDataPref(value, dataIdUser, dataName, dataEmail, dataAlamat,
            dataJenisKelamin, dataTanggalDaftar);
      });
    } else {
      _scaffoldKey.currentState
          .showSnackBar(SnackBar(content: Text('Email atau Password salah')));
      print(msg);
    }

    setState(() {
      _isLoading = false;
    });
  }

  saveDataPref(int value, int dIdUser, dName, dEmail, dAlamat, dJenisKelamin,
      dCreatedAt) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      pref.setInt("value", value);
      pref.setInt("id_user", dIdUser);
      pref.setString("name", dName);
      pref.setString("email", dEmail);
      pref.setString("alamat", dAlamat);
      pref.setString("jenis_kelamin", dJenisKelamin);
      pref.setString("created_at", dCreatedAt);
    });
  }

  getDataPref() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      int nValue = pref.getInt("value");
      _loginStatus = nValue == 1 ? statusLogin.signIn : statusLogin.guest;
    });
  }

  @override
  void initState() {
    super.initState();
    getDataPref();
  }

  @override
  Widget build(BuildContext context) {
    switch (_loginStatus) {
      case statusLogin.guest:
        return Scaffold(
          key: _scaffoldKey,
          body: SingleChildScrollView(
            child: Container(
              width: MediaQuery.of(context).size.width,
              child: Padding(
                padding: EdgeInsets.all(50),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    FlutterLogo(
                      size: 200,
                      style: FlutterLogoStyle.horizontal,
                    ),
                    Form(
                      key: _key,
                      child: Column(
                        children: <Widget>[
                          TextFormField(
                            validator: (e) {
                              return e.isEmpty ? 'please insert email' : null;
                            },
                            controller: _emailController,
                            focusNode: _emailNode,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              labelText: 'Email',
                              prefixIcon: Icon(Icons.email),
                            ),
                          ),
                          TextFormField(
                            validator: (e) {
                              return e.isEmpty
                                  ? 'please insert password'
                                  : null;
                            },
                            controller: _passwordController,
                            focusNode: _passwordNode,
                            obscureText: _secureText,
                            decoration: InputDecoration(
                                labelText: 'Password',
                                prefixIcon: Icon(Icons.lock),
                                suffixIcon: IconButton(
                                  icon: Icon(_secureText
                                      ? Icons.visibility_off
                                      : Icons.visibility),
                                  onPressed: showHide,
                                )),
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
                                  : Text('Sign In'),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        );
        break;
      case statusLogin.signIn:
        return HomeScreen();
        break;
      default:
        return Container();
        break;
    }
  }
}
