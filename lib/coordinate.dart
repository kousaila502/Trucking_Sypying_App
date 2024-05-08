class Coordinate {
  final int id;
  final double latitude;
  final double longitude;
  final DateTime timestamp;

  Coordinate({required this.id, required this.latitude, required this.longitude, required this.timestamp});

  factory Coordinate.fromJson(Map<String, dynamic> json) {
    return Coordinate(
      id: json['id'],
      latitude: double.parse(json['latitude']),
      longitude: double.parse(json['longitude']),
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}