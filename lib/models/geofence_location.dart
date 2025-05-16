class GeofenceLocation {
  final double latitude;
  final double longitude;
  final double radius;
  final String? name;

  GeofenceLocation({
    required this.latitude,
    required this.longitude,
    required this.radius,
    this.name,
  });

  // For storing in SharedPreferences
  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'radius': radius,
      'name': name,
    };
  }

  // For retrieving from SharedPreferences
  factory GeofenceLocation.fromJson(Map<String, dynamic> json) {
    return GeofenceLocation(
      latitude: json['latitude'],
      longitude: json['longitude'],
      radius: json['radius'],
      name: json['name'],
    );
  }
}
