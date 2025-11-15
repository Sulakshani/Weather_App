/// Forecast Model for hourly and daily forecasts
class HourlyForecast {
  final String time;
  final double temperature;
  final int weatherCode;
  final String icon;

  HourlyForecast({
    required this.time,
    required this.temperature,
    required this.weatherCode,
    required this.icon,
  });

  factory HourlyForecast.fromJson(Map<String, dynamic> json, int index) {
    return HourlyForecast(
      time: json['time'][index],
      temperature: (json['temperature_2m'][index] as num).toDouble(),
      weatherCode: json['weathercode'][index] as int,
      icon: _getWeatherIcon(json['weathercode'][index] as int),
    );
  }

  static String _getWeatherIcon(int code) {
    if (code == 0) return '☀️';
    if (code <= 3) return '⛅';
    if (code <= 48) return '🌫️';
    if (code <= 67) return '🌧️';
    if (code <= 77) return '❄️';
    if (code <= 82) return '🌦️';
    if (code <= 86) return '🌨️';
    return '⛈️';
  }
}

class DailyForecast {
  final String date;
  final String day;
  final double maxTemp;
  final double minTemp;
  final int weatherCode;
  final String icon;
  final String description;

  DailyForecast({
    required this.date,
    required this.day,
    required this.maxTemp,
    required this.minTemp,
    required this.weatherCode,
    required this.icon,
    required this.description,
  });

  factory DailyForecast.fromJson(Map<String, dynamic> json, int index) {
    final date = DateTime.parse(json['time'][index]);
    return DailyForecast(
      date: json['time'][index],
      day: _getDayName(date),
      maxTemp: (json['temperature_2m_max'][index] as num).toDouble(),
      minTemp: (json['temperature_2m_min'][index] as num).toDouble(),
      weatherCode: json['weathercode'][index] as int,
      icon: _getWeatherIcon(json['weathercode'][index] as int),
      description: _getWeatherDescription(json['weathercode'][index] as int),
    );
  }

  static String _getDayName(DateTime date) {
    final now = DateTime.now();
    if (date.day == now.day && date.month == now.month) return 'Today';
    if (date.day == now.add(const Duration(days: 1)).day) return 'Tomorrow';
    
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return days[date.weekday - 1];
  }

  static String _getWeatherIcon(int code) {
    if (code == 0) return '☀️';
    if (code <= 3) return '⛅';
    if (code <= 48) return '🌫️';
    if (code <= 67) return '🌧️';
    if (code <= 77) return '❄️';
    if (code <= 82) return '🌦️';
    if (code <= 86) return '🌨️';
    return '⛈️';
  }

  static String _getWeatherDescription(int code) {
    if (code == 0) return 'Clear Sky';
    if (code <= 3) return 'Partly Cloudy';
    if (code <= 48) return 'Foggy';
    if (code <= 67) return 'Rainy';
    if (code <= 77) return 'Snowy';
    if (code <= 82) return 'Rain Showers';
    if (code <= 86) return 'Snow Showers';
    return 'Thunderstorm';
  }
}

class WeatherDetails {
  final int uvIndex;
  final String sunrise;
  final String sunset;
  final double feelsLike;
  final double pressure;
  final double visibility;
  final double dewPoint;

  WeatherDetails({
    required this.uvIndex,
    required this.sunrise,
    required this.sunset,
    required this.feelsLike,
    required this.pressure,
    required this.visibility,
    required this.dewPoint,
  });

  factory WeatherDetails.fromJson(Map<String, dynamic> json) {
    return WeatherDetails(
      uvIndex: ((json['current_weather']?['uv_index'] ?? 0) as num).round(),
      sunrise: json['daily']?['sunrise']?[0] ?? '06:30 AM',
      sunset: json['daily']?['sunset']?[0] ?? '07:45 PM',
      feelsLike: ((json['current_weather']?['apparent_temperature'] ?? 
          json['current_weather']?['temperature'] ?? 25) as num).toDouble(),
      pressure: ((json['current_weather']?['pressure'] ?? 1012) as num).toDouble(),
      visibility: ((json['current_weather']?['visibility'] ?? 10) as num).toDouble(),
      dewPoint: ((json['current_weather']?['dewpoint'] ?? 15) as num).toDouble(),
    );
  }

  String getUVLevel() {
    if (uvIndex <= 2) return 'Low';
    if (uvIndex <= 5) return 'Moderate';
    if (uvIndex <= 7) return 'High';
    if (uvIndex <= 10) return 'Very High';
    return 'Extreme';
  }
}
