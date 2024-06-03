import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

class SpyingScreen extends StatefulWidget {
  @override
  _SpyingScreenState createState() => _SpyingScreenState();
}

class _SpyingScreenState extends State<SpyingScreen> {
  Future<void> _makePhoneCall(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Spying'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
               onPressed: () => launchUrlString("tel://+213665947813"),
              child: Text('Start call'),
            ),
          ],
        ),
      ),
    );
  }
}