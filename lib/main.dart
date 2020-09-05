import 'package:flutter/material.dart';
import 'package:tugas_note/pages/splash_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Note App',
      home: SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
