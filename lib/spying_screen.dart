import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SpyingScreen extends StatefulWidget {
  @override
  _SpyingScreenState createState() => _SpyingScreenState();
}

class _SpyingScreenState extends State<SpyingScreen> {
  late Future<String> _response;

  // Define a method to fetch coordinates from a server
  Future<String> fetchCoordinates() async {
    final response = await http.get(Uri.parse('http://web-production-39ae.up.railway.app/api/gps/'));

    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed to load coordinates from server');
    }
  }

  @override
  void initState() {
    super.initState();
    _response = fetchCoordinates(); // Fetch coordinates when the widget is initialized
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Spying'),
      ),
      body: FutureBuilder<String>(
        future: _response,
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          if (snapshot.hasData) {
            return Text(snapshot.data ?? ''); // Display the response
          } else if (snapshot.hasError) {
            return Text('${snapshot.error}');
          }
          // By default, show a loading spinner.
          return CircularProgressIndicator();
        },
      ),
    );
  }
}