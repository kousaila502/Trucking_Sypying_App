import 'package:flutter/material.dart';


class SpyingScreen extends StatefulWidget {
  @override
  _SpyingScreenState createState() => _SpyingScreenState();
}

class _SpyingScreenState extends State<SpyingScreen> {
  // TODO: Implement Google Maps and Django API integration
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Spying'),
      ),
      body: Center(
        child: Text('Spying Screen'),
      ),
    );
  }
}