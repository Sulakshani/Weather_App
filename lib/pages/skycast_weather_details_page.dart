import 'package:flutter/material.dart';
import '../models/weather_model.dart';

class SkyCastWeatherDetailsPage extends StatelessWidget {
  final WeatherModel weather;

  const SkyCastWeatherDetailsPage({
    Key? key,
    required this.weather,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Weather Details', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _buildDetail(Icons.wb_sunny, 'UV Index', '6', 'Moderate'),
              _buildDetail(Icons.wb_twilight, 'Sunrise', '06:30 AM', ''),
              _buildDetail(Icons.nightlight, 'Sunset', '07:45 PM', ''),
              _buildDetail(Icons.thermostat, 'Feels Like', '${weather.temperature.round()}°C', ''),
              _buildDetail(Icons.speed, 'Pressure', '1012 hPa', ''),
              _buildDetail(Icons.visibility, 'Visibility', '10 km', ''),
              _buildDetail(Icons.water, 'Dew Point', '15°C', ''),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetail(IconData icon, String label, String value, String extra) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue.shade400, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                if (extra.isNotEmpty) Text(extra, style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
