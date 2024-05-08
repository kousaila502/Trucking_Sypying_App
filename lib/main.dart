import 'package:flutter/material.dart';
import 'package:trucking_spying_app/home_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';


void main() async {
  await dotenv.load();
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