import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LastPositionScreen extends StatefulWidget {
  @override
  _LastPositionScreenState createState() => _LastPositionScreenState();
}

class _LastPositionScreenState extends State<LastPositionScreen> {
  late Future<List<dynamic>> lastPosition;

  Future<List<dynamic>> fetchLastPosition() async {
    final response = await http.get(Uri.parse(
        'https://spying-adruino-production.up.railway.app/api/lastgps/'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load last position');
    }
  }

  @override
  void initState() {
    super.initState();
    lastPosition = fetchLastPosition();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: lastPosition,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final positionData = snapshot.data!.last;
          final position = LatLng(
            double.parse(positionData['latitude']),
            double.parse(positionData['longitude']),
          );
          return GoogleMap(
            initialCameraPosition: CameraPosition(
              target: position,
              zoom: 10,
            ),
            markers: {
              Marker(
                markerId: MarkerId('lastPosition'),
                position: position,
              ),
            },
          );
        } else if (snapshot.hasError) {
          return Text("${snapshot.error}");
        }
        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }
}
