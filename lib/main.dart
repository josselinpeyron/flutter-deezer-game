import 'package:blindtest/screens/radio_deezer_list_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Blind Test', theme: ThemeData.dark(), home: RadioDeezerListPage());
  }
}




