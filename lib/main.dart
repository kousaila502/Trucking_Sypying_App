import 'package:flutter/material.dart';
import 'package:trucking_spying_app/home_screen.dart';

void main() async {
  //await dotenv.load();
  runApp(TruckingAndSpyingApp());
}

class TruckingAndSpyingApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Trucking and Spying App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white, 
        appBarTheme: const AppBarTheme(
          titleTextStyle: TextStyle(
            fontFamily: 'Pacifico',
            fontSize: 20,
            color: Colors.black,
          ),
        ),
      ),
      home: HomeScreen(),
    );
  }
}
