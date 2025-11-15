/// Location Model
class LocationModel {
  final String name;
  final String country;
  final double latitude;
  final double longitude;
  final String? weatherDescription;
  final double? temperature;
  final String? weatherIcon;

  LocationModel({
    required this.name,
    required this.country,
    required this.latitude,
    required this.longitude,
    this.weatherDescription,
    this.temperature,
    this.weatherIcon,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'country': country,
      'latitude': latitude,
      'longitude': longitude,
      'weatherDescription': weatherDescription,
      'temperature': temperature,
      'weatherIcon': weatherIcon,
    };
  }

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      name: json['name'] as String,
      country: json['country'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      weatherDescription: json['weatherDescription'] as String?,
      temperature: json['temperature'] != null 
          ? (json['temperature'] as num).toDouble() 
          : null,
      weatherIcon: json['weatherIcon'] as String?,
    );
  }
}
