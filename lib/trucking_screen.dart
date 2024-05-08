import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class TruckingScreen extends StatefulWidget {
  @override
  _TruckingScreenState createState() => _TruckingScreenState();
}

class _TruckingScreenState extends State<TruckingScreen> {
  late Future<List<LatLng>> _coordinates;

  // Define a method to fetch coordinates from a server
  Future<List<LatLng>> fetchCoordinates() async {
    final response = await http.get(Uri.parse('http://web-production-39ae.up.railway.app/api/gps/'));

    if (response.statusCode == 200) {
      List<dynamic> json = jsonDecode(response.body);
      return json.map((item) => LatLng(double.parse(item['latitude']), double.parse(item['longitude']))).toList();
    } else {
      throw Exception('Failed to load coordinates from server');
    }
  }

  @override
  void initState() {
    super.initState();
    _coordinates = fetchCoordinates(); // Fetch coordinates when the widget is initialized
  }

 @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text('Trucking'),
    ),
    body: FutureBuilder<List<LatLng>>(
      future: _coordinates,
      builder: (BuildContext context, AsyncSnapshot<List<LatLng>> snapshot) {
        if (snapshot.hasData) {
          Polyline polyline = Polyline(
            polylineId: PolylineId('route1'),
            color: Colors.blue,
            points: snapshot.data!,
          );

          Set<Marker> markers = snapshot.data!.map((LatLng latLng) {
            return Marker(
              markerId: MarkerId('${latLng.latitude},${latLng.longitude}'),
              position: latLng,
            );
          }).toSet();

          return GoogleMap(
            initialCameraPosition: CameraPosition(
              target: snapshot.data!.first,
              zoom: 14.4746,
            ),
            polylines: {polyline},
            markers: markers,
          );
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