import 'package:flutter/material.dart';
import 'package:trucking_spying_app/spying_screen.dart';
import 'package:trucking_spying_app/trucking_screen.dart';




class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              child: Text('Trucking'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TruckingScreen()),
                );
              },
            ),
            ElevatedButton(
              child: Text('Spying'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SpyingScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}