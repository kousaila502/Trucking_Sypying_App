import 'package:flutter/material.dart';
import 'package:trucking_spying_app/home_screen.dart';

void main() {
  runApp(TruckingAndSpyingApp());
}

class TruckingAndSpyingApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Trucking and Spying App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomeScreen(),
    );
  }
}