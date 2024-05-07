import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class TruckingScreen extends StatefulWidget {
  @override
  _TruckingScreenState createState() => _TruckingScreenState();
}

class _TruckingScreenState extends State<TruckingScreen> {
  // TODO: Implement Google Maps and Django API integration
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Trucking'),
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(35.2163516,-0.689445)) ,)
    );
  }
}