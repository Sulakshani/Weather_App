/// Weather Model
/// Represents the weather data structure from Open-Meteo API
class WeatherModel {
  final double temperature;
  final double windSpeed;
  final int weatherCode;
  final String time;
  final double latitude;
  final double longitude;
  final String indexNumber;
  final String requestUrl;
  final bool isCached;
  final DateTime lastUpdated;

  WeatherModel({
    required this.temperature,
    required this.windSpeed,
    required this.weatherCode,
    required this.time,
    required this.latitude,
    required this.longitude,
    required this.indexNumber,
    required this.requestUrl,
    this.isCached = false,
    required this.lastUpdated,
  });

  /// Convert API response to WeatherModel
  factory WeatherModel.fromJson(
    Map<String, dynamic> json,
    String indexNumber,
    double lat,
    double lon,
    String url, {
    bool cached = false,
  }) {
    final currentWeather = json['current_weather'] as Map<String, dynamic>;
    
    return WeatherModel(
      temperature: (currentWeather['temperature'] as num).toDouble(),
      windSpeed: (currentWeather['windspeed'] as num).toDouble(),
      weatherCode: currentWeather['weathercode'] as int,
      time: currentWeather['time'] as String,
      latitude: lat,
      longitude: lon,
      indexNumber: indexNumber,
      requestUrl: url,
      isCached: cached,
      lastUpdated: DateTime.now(),
    );
  }

  /// Convert WeatherModel to JSON for caching
  Map<String, dynamic> toJson() {
    return {
      'current_weather': {
        'temperature': temperature,
        'windspeed': windSpeed,
        'weathercode': weatherCode,
        'time': time,
      },
      'latitude': latitude,
      'longitude': longitude,
      'indexNumber': indexNumber,
      'requestUrl': requestUrl,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  /// Get weather description based on WMO Weather codes
  String getWeatherDescription() {
    switch (weatherCode) {
      case 0:
        return 'Clear sky';
      case 1:
      case 2:
      case 3:
        return 'Partly cloudy';
      case 45:
      case 48:
        return 'Foggy';
      case 51:
      case 53:
      case 55:
        return 'Drizzle';
      case 61:
      case 63:
      case 65:
        return 'Rain';
      case 71:
      case 73:
      case 75:
        return 'Snow';
      case 77:
        return 'Snow grains';
      case 80:
      case 81:
      case 82:
        return 'Rain showers';
      case 85:
      case 86:
        return 'Snow showers';
      case 95:
        return 'Thunderstorm';
      case 96:
      case 99:
        return 'Thunderstorm with hail';
      default:
        return 'Unknown';
    }
  }

  /// Get weather icon emoji based on weather code
  String getWeatherIcon() {
    switch (weatherCode) {
      case 0:
        return '☀️';
      case 1:
      case 2:
      case 3:
        return '⛅';
      case 45:
      case 48:
        return '🌫️';
      case 51:
      case 53:
      case 55:
      case 61:
      case 63:
      case 65:
        return '🌧️';
      case 71:
      case 73:
      case 75:
      case 77:
        return '❄️';
      case 80:
      case 81:
      case 82:
        return '🌦️';
      case 85:
      case 86:
        return '🌨️';
      case 95:
      case 96:
      case 99:
        return '⛈️';
      default:
        return '🌡️';
    }
  }
}
