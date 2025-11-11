import 'package:flutter/material.dart';
import '../models/weather_model.dart';

/// Weather Card Widget
/// Displays weather information in a card format
class WeatherCard extends StatelessWidget {
  final WeatherModel weather;

  const WeatherCard({
    Key? key,
    required this.weather,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue.shade400,
              Colors.blue.shade600,
            ],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Weather Icon
            Text(
              weather.getWeatherIcon(),
              style: const TextStyle(fontSize: 80),
            ),
            const SizedBox(height: 10),
            
            // Temperature
            Text(
              '${weather.temperature.toStringAsFixed(1)}°C',
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            
            // Weather Description
            Text(
              weather.getWeatherDescription(),
              style: const TextStyle(
                fontSize: 24,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 20),
            
            // Divider
            const Divider(color: Colors.white70, thickness: 1),
            const SizedBox(height: 15),
            
            // Weather Details
            _buildDetailRow('💨 Wind Speed', '${weather.windSpeed} km/h'),
            const SizedBox(height: 10),
            _buildDetailRow('🔢 Weather Code', '${weather.weatherCode}'),
            const SizedBox(height: 10),
            _buildDetailRow('📍 Latitude', weather.latitude.toStringAsFixed(2)),
            const SizedBox(height: 10),
            _buildDetailRow('📍 Longitude', weather.longitude.toStringAsFixed(2)),
            const SizedBox(height: 10),
            _buildDetailRow('🎓 Index Number', weather.indexNumber),
            const SizedBox(height: 10),
            _buildDetailRow('🕐 Last Updated', _formatTime(weather.time)),
            
            // Cached indicator
            if (weather.isCached) ...[
              const SizedBox(height: 15),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.orange.shade600,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.offline_bolt, color: Colors.white, size: 16),
                    SizedBox(width: 6),
                    Text(
                      'CACHED DATA (Offline)',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 16,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  String _formatTime(String isoTime) {
    try {
      final dateTime = DateTime.parse(isoTime);
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return isoTime;
    }
  }
}
