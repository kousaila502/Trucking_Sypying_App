import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
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
  bool _showCalendar = false;
  BitmapDescriptor? _carIcon;
  List<Color> _journeyColors = [
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.yellow,
    Colors.purple
  ];

  Future<List<dynamic>> fetchJourneys() async {
    final response = await http.get(Uri.parse(
        'http://spying-adruino-production.up.railway.app/api/journey/'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load journeys from server');
    }
  }

  List<LatLng> fetchCoordinates(dynamic journey) {
    return journey['gps_points']
        .map<LatLng>((item) => LatLng(
            double.parse(item['latitude']), double.parse(item['longitude'])))
        .toList();
  }

  @override
  void initState() {
    super.initState();
    _journeys = fetchJourneys();
    rootBundle.load('images/car_icon.png').then((byteData) {
      _carIcon = BitmapDescriptor.fromBytes(byteData.buffer.asUint8List());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Tracking',
          style: GoogleFonts.pacifico(
            textStyle: TextStyle(
              color: Colors.black,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.calendar_today),
            onPressed: () {
              setState(() {
                _showCalendar = !_showCalendar;
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.bar_chart),
            onPressed: () {
              setState(() {
                _showStats = !_showStats;
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
                if (_showCalendar)
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
                        _journeys = fetchJourneys().then((journeys) {
                          var filteredJourneys = journeys.where((journey) {
                            DateTime journeyDate =
                                DateTime.parse(journey['start_time']);
                            return journeyDate.day == selectedDay.day &&
                                journeyDate.month == selectedDay.month &&
                                journeyDate.year == selectedDay.year;
                          }).toList();

                          // Update _journeysCoordinates with the filtered journeys
                          _journeysCoordinates =
                              filteredJourneys.map(fetchCoordinates).toList();

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

                          return filteredJourneys;
                        });
                        _showCalendar = false;
                      });
                    },
                  ),
                Expanded(
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: _journeysCoordinates.isNotEmpty
                          ? _journeysCoordinates.first.first
                          : LatLng(35.709370, -0.656810),
                      zoom: 8,
                    ),
                    polylines: _buildPolylines(),
                    circles: _buildCircles(),
                    markers: _buildMarkers(),
                  ),
                ),
                if (_showStats &&
                    _selectedDay != null &&
                    _journeysCoordinates.isNotEmpty)
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
                                radius: 10,
                                backgroundColor: _journeyColors[
                                    index % _journeyColors.length],
                              ),
                              SizedBox(width: 10),
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
          return Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }

  Set<Polyline> _buildPolylines() {
    List<Color> colors = [Colors.blue, Colors.green, Colors.red, Colors.orange];
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

  Set<Circle> _buildCircles() {
    List<Color> colors = [Colors.blue, Colors.green, Colors.red, Colors.orange];
    Set<Circle> circles = {};
    for (int i = 0; i < _journeysCoordinates.length; i++) {
      for (int j = 0; j < _journeysCoordinates[i].length - 1; j++) {
        circles.add(
          Circle(
            circleId: CircleId(
                '${_journeysCoordinates[i][j].latitude},${_journeysCoordinates[i][j].longitude}'),
            center: _journeysCoordinates[i][j],
            radius: 7,
            fillColor: colors[i % colors.length].withOpacity(0.5),
            strokeColor: colors[i % colors.length].withOpacity(0.8),
            strokeWidth: 10,
          ),
        );
      }
    }
    return circles;
  }

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
