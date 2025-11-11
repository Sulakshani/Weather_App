import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/weather_model.dart';
import '../services/weather_service.dart';
import '../widgets/weather_card.dart';
import '../widgets/loading_indicator.dart';

/// Weather Page
/// Displays weather data with offline support and caching
class WeatherPage extends StatefulWidget {
  final String indexNumber;
  final double latitude;
  final double longitude;

  const WeatherPage({
    Key? key,
    required this.indexNumber,
    required this.latitude,
    required this.longitude,
  }) : super(key: key);

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  final WeatherService _weatherService = WeatherService();
  WeatherModel? _weather;
  bool _isLoading = false;
  String? _errorMessage;
  String _cacheInfo = '';

  @override
  void initState() {
    super.initState();
    _fetchWeather();
    _loadCacheInfo();
  }

  /// Fetch weather data from API
  Future<void> _fetchWeather() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final weather = await _weatherService.fetchWeather(
        indexNumber: widget.indexNumber,
        latitude: widget.latitude,
        longitude: widget.longitude,
      );

      setState(() {
        _weather = weather;
        _isLoading = false;
      });

      await _loadCacheInfo();
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  /// Load cache information
  Future<void> _loadCacheInfo() async {
    final info = await _weatherService.getCacheInfo();
    setState(() {
      _cacheInfo = info;
    });
  }

  /// Copy URL to clipboard
  void _copyUrl() {
    if (_weather != null) {
      Clipboard.setData(ClipboardData(text: _weather!.requestUrl));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('URL copied to clipboard!'),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade200,
              Colors.blue.shade50,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // App Bar
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Title
                    const Text(
                      'Weather Dashboard',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    
                    // Refresh Button
                    IconButton(
                      icon: const Icon(Icons.refresh, size: 28),
                      color: Colors.blue.shade700,
                      onPressed: _isLoading ? null : _fetchWeather,
                    ),
                  ],
                ),
              ),
              
              // Content
              Expanded(
                child: _buildContent(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build main content based on state
  Widget _buildContent() {
    if (_isLoading && _weather == null) {
      return const WeatherLoadingIndicator();
    }

    if (_errorMessage != null && _weather == null) {
      return _buildErrorView();
    }

    if (_weather != null) {
      return _buildWeatherView();
    }

    return const Center(
      child: Text('No weather data available'),
    );
  }

  /// Build error view with retry option
  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Card(
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(30.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.cloud_off,
                  size: 80,
                  color: Colors.red,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Could not fetch weather',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 15),
                Text(
                  'Check your internet connection\nand try again.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  'Error: $_errorMessage',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 25),
                ElevatedButton.icon(
                  onPressed: _fetchWeather,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Try Again'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 15,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Build weather view with data
  Widget _buildWeatherView() {
    return RefreshIndicator(
      onRefresh: _fetchWeather,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // Weather Card
              WeatherCard(weather: _weather!),
              
              const SizedBox(height: 20),
              
              // Cache Info Card
              if (_cacheInfo.isNotEmpty)
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Row(
                      children: [
                        Icon(
                          Icons.storage,
                          color: Colors.blue.shade700,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          _cacheInfo,
                          style: TextStyle(
                            color: Colors.blue.shade700,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              
              const SizedBox(height: 20),
              
              // Request URL Card
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'API Request URL',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade700,
                              fontSize: 14,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.copy, size: 20),
                            onPressed: _copyUrl,
                            tooltip: 'Copy URL',
                            color: Colors.blue.shade700,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _weather!.requestUrl,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Coordinates Info Card
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Text(
                        'Location Details',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      const SizedBox(height: 15),
                      _buildInfoRow(
                        '🎓 Index Number',
                        widget.indexNumber,
                      ),
                      const Divider(height: 20),
                      _buildInfoRow(
                        '📍 Latitude',
                        widget.latitude.toStringAsFixed(2),
                      ),
                      const Divider(height: 20),
                      _buildInfoRow(
                        '📍 Longitude',
                        widget.longitude.toStringAsFixed(2),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 30),
              
              // Footer
              Text(
                '🌦️ Data provided by Open-Meteo API',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  /// Build info row widget
  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 16,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}
