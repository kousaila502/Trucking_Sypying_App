import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:table_calendar/table_calendar.dart';

class TruckingScreen extends StatefulWidget {
  @override
  _TruckingScreenState createState() => _TruckingScreenState();
}

class _TruckingScreenState extends State<TruckingScreen> {
  late Future<List<dynamic>> _journeys;
  List<List<LatLng>> _journeysCoordinates = [];
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  bool _showStats = false;
  bool _showCalendar =
      false; // new variable to control the visibility of the calendar
  BitmapDescriptor? _carIcon;
  List<Color> _journeyColors = [
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.yellow,
    Colors.purple
  ]; // add more colors if needed

  // Define a method to fetch journeys from a server
  Future<List<dynamic>> fetchJourneys() async {
    final response = await http.get(Uri.parse(
        'http://spying-adruino-production.up.railway.app/api/journey/'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load journeys from server');
    }
  }

  // Define a method to fetch coordinates from a journey
  List<LatLng> fetchCoordinates(dynamic journey) {
    return journey['gps_points']
        .map<LatLng>((item) => LatLng(
            double.parse(item['latitude']), double.parse(item['longitude'])))
        .toList();
  }

  @override
  void initState() {
    super.initState();
    _journeys =
        fetchJourneys(); // Fetch journeys when the widget is initialized
    rootBundle.load('images/car_icon.png').then((byteData) {
      _carIcon = BitmapDescriptor.fromBytes(byteData.buffer.asUint8List());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Trucking'),
        actions: [
          IconButton(
            icon: Icon(Icons.calendar_today),
            onPressed: () {
              setState(() {
                _showCalendar =
                    !_showCalendar; // toggle the visibility of the calendar
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.bar_chart),
            onPressed: () {
              setState(() {
                _showStats = !_showStats; // toggle the visibility of the stats
              });
            },
          ),
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _journeys,
        builder: (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (snapshot.hasData) {
            return Column(
              children: [
                if (_showCalendar) // only show the calendar if _showCalendar is true
                  TableCalendar(
                    firstDay: DateTime.utc(2010, 10, 16),
                    lastDay: DateTime.utc(2030, 3, 14),
                    focusedDay: _focusedDay,
                    calendarFormat: _calendarFormat,
                    onFormatChanged: (format) {
                      setState(() {
                        _calendarFormat = format;
                      });
                    },
                    selectedDayPredicate: (day) {
                      return isSameDay(_selectedDay, day);
                    },
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        _selectedDay = selectedDay;
                        _focusedDay = focusedDay;
                        _journeysCoordinates = snapshot.data!
                            .where((journey) {
                              DateTime journeyDate =
                                  DateTime.parse(journey['start_time']);
                              return journeyDate.day == selectedDay.day &&
                                  journeyDate.month == selectedDay.month &&
                                  journeyDate.year == selectedDay.year;
                            })
                            .map((journey) => fetchCoordinates(journey))
                            .toList();
                        _showCalendar = false;

                        if (_journeysCoordinates.isEmpty) {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('No Journey Data'),
                                content:
                                    Text('No journey data for selected day'),
                                actions: <Widget>[
                                  TextButton(
                                    child: Text('OK'),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        }
                      });
                    },
                  ),
                Expanded(
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: _journeysCoordinates.isNotEmpty
                          ? _journeysCoordinates.first.first
                          : LatLng(35.709370,
                              -0.656810), // default to (0, 0) if _coordinates is empty
                      zoom: 8,
                    ),
                    polylines: _buildPolylines(),
                    circles: _buildCircles(),
                    markers: _buildMarkers(),
                  ),
                ),
                if (_showStats) // only show the stats if _showStats is true
                  Expanded(
                    child: ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        var journey = snapshot.data![index];
                        return Card(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                radius:
                                    10, // adjust this value to change the size of the CircleAvatar
                                backgroundColor: _journeyColors[index %
                                    _journeyColors
                                        .length], // Use the color corresponding to the journey
                              ),
                              SizedBox(
                                  width:
                                      10), // add some space between the CircleAvatar and the title
                              Expanded(
                                child: ListTile(
                                  title: Text('Journey ${index + 1}'),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                          'Total Distance: ${journey["total_distance"]}'),
                                      Text(
                                          'Average Speed: ${journey["average_speed"]}'),
                                      Text('Duration: ${journey["duration"]}'),
                                      Text(
                                          'Max Speed: ${journey["max_speed"]}'),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
              ],
            );
          } else if (snapshot.hasError) {
            return Text('${snapshot.error}');
          }
          // By default, show a loading spinner.
          return Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }

  // Method to build polylines for each journey
  Set<Polyline> _buildPolylines() {
    List<Color> colors = [
      Colors.blue,
      Colors.green,
      Colors.red,
      Colors.orange
    ]; // Add more colors as needed
    Set<Polyline> polylines = {};
    for (int i = 0; i < _journeysCoordinates.length; i++) {
      polylines.add(
        Polyline(
          polylineId: PolylineId('route$i'),
          color: colors[i % colors.length],
          points: _journeysCoordinates[i],
        ),
      );
    }
    return polylines;
  }

  // Method to build circles for each journey
  Set<Circle> _buildCircles() {
    List<Color> colors = [
      Colors.blue,
      Colors.green,
      Colors.red,
      Colors.orange
    ]; // Add more colors as needed
    Set<Circle> circles = {};
    for (int i = 0; i < _journeysCoordinates.length; i++) {
      for (int j = 0; j < _journeysCoordinates[i].length - 1; j++) {
        circles.add(
          Circle(
            circleId: CircleId(
                '${_journeysCoordinates[i][j].latitude},${_journeysCoordinates[i][j].longitude}'),
            center: _journeysCoordinates[i][j],
            radius: 7, // adjust the radius as needed
            fillColor: colors[i % colors.length].withOpacity(0.5),
            strokeColor: colors[i % colors.length]
                .withOpacity(0.8), // make the border semi-transparent
            strokeWidth: 10,
          ),
        );
      }
    }
    return circles;
  }

  // Method to build markers for the last point of each journey
  Set<Marker> _buildMarkers() {
    Set<Marker> markers = {};
    for (int i = 0; i < _journeysCoordinates.length; i++) {
      if (_journeysCoordinates[i].isNotEmpty) {
        markers.add(
          Marker(
            markerId: MarkerId(
                '${_journeysCoordinates[i].last.latitude},${_journeysCoordinates[i].last.longitude}'),
            position: _journeysCoordinates[i].last,
            icon: _carIcon ?? BitmapDescriptor.defaultMarker,
          ),
        );
      }
    }
    return markers;
  }
}
