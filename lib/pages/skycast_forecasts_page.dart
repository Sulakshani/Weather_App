import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/forecast_model.dart';

class SkyCastForecastsPage extends StatefulWidget {
  final double latitude;
  final double longitude;
  final String cityName;
  
  const SkyCastForecastsPage({
    Key? key,
    required this.latitude,
    required this.longitude,
    this.cityName = 'Current Location',
  }) : super(key: key);

  @override
  State<SkyCastForecastsPage> createState() => _SkyCastForecastsPageState();
}

class _SkyCastForecastsPageState extends State<SkyCastForecastsPage> {
  List<DailyForecast> _forecasts = [];
  List<HourlyForecast> _hourlyForecasts = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadForecastData();
  }

  Future<void> _loadForecastData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final url = 'https://api.open-meteo.com/v1/forecast?'
          'latitude=${widget.latitude}&longitude=${widget.longitude}'
          '&hourly=temperature_2m,relative_humidity_2m,weathercode,wind_speed_10m'
          '&daily=weathercode,temperature_2m_max,temperature_2m_min,sunrise,sunset,uv_index_max'
          '&timezone=auto';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // Parse daily forecasts
        final List<DailyForecast> dailyList = [];
        final dailyData = data['daily'];
        for (int i = 0; i < 7 && i < dailyData['time'].length; i++) {
          dailyList.add(DailyForecast.fromJson(dailyData, i));
        }

        // Parse hourly forecasts (next 24 hours)
        final List<HourlyForecast> hourlyList = [];
        final hourlyData = data['hourly'];
        for (int i = 0; i < 24 && i < hourlyData['time'].length; i++) {
          hourlyList.add(HourlyForecast.fromJson(hourlyData, i));
        }

        setState(() {
          _forecasts = dailyList;
          _hourlyForecasts = hourlyList;
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load forecast');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load forecast data';
      });
      print('Error loading forecast: $e');
    }
  }

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
        title: Text(
          widget.cityName,
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black),
            onPressed: _loadForecastData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text(_errorMessage),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadForecastData,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadForecastData,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Current Weather Summary
                        if (_forecasts.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.blue.shade400, Colors.blue.shade600],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.blue.shade200,
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Text(
                                  _forecasts[0].icon,
                                  style: const TextStyle(fontSize: 64),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  '${_forecasts[0].maxTemp.round()}°C',
                                  style: const TextStyle(
                                    fontSize: 48,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                                Text(
                                  _forecasts[0].description,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    _buildWeatherStat('High', '${_forecasts[0].maxTemp.round()}°'),
                                    _buildWeatherStat('Low', '${_forecasts[0].minTemp.round()}°'),
                                  ],
                                ),
                              ],
                            ),
                          ),

                        const SizedBox(height: 24),

                        // Hourly Forecast
                        const Text(
                          'Hourly Forecast',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 120,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _hourlyForecasts.length,
                            itemBuilder: (context, index) {
                              final forecast = _hourlyForecasts[index];
                              final time = DateTime.parse(forecast.time);
                              return Container(
                                width: 80,
                                margin: const EdgeInsets.only(right: 12),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    Text(
                                      '${time.hour}:00',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      forecast.icon,
                                      style: const TextStyle(fontSize: 24),
                                    ),
                                    Text(
                                      '${forecast.temperature.round()}°',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),

                        const SizedBox(height: 24),

                        // 7-Day Forecast
                        const Text(
                          '7-Day Forecast',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _forecasts.length,
                          itemBuilder: (context, index) {
                            final forecast = _forecasts[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    // Day
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        forecast.day,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    // Icon
                                    Text(
                                      forecast.icon,
                                      style: const TextStyle(fontSize: 32),
                                    ),
                                    const SizedBox(width: 16),
                                    // Description
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        forecast.description,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ),
                                    // Temperature
                                    Text(
                                      '${forecast.maxTemp.round()}° / ${forecast.minTemp.round()}°',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildWeatherStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }
}
