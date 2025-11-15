import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../services/weather_service.dart';
import '../services/index_city_service.dart';
import '../models/weather_model.dart';
import '../models/location_model.dart';
import 'skycast_forecasts_page.dart';
import 'skycast_search_page.dart';
import 'skycast_profile_page.dart';
import 'skycast_weather_details_page.dart';
import 'no_internet_page.dart';

/// SkyCast Home Page - Main weather dashboard
class SkyCastHomePage extends StatefulWidget {
  final String indexNumber;

  const SkyCastHomePage({
    Key? key,
    required this.indexNumber,
  }) : super(key: key);

  @override
  State<SkyCastHomePage> createState() => _SkyCastHomePageState();
}

class _SkyCastHomePageState extends State<SkyCastHomePage> {
  final WeatherService _weatherService = WeatherService();
  WeatherModel? _weather;
  LocationModel? _currentLocation;
  bool _isLoading = false;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _checkConnectivityAndLoadWeather();
  }

  Future<void> _checkConnectivityAndLoadWeather() async {
    final hasInternet = await _weatherService.hasInternetConnection();
    
    if (!hasInternet) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const NoInternetPage()),
      );
      return;
    }

    await _loadWeather();
  }

  Future<void> _loadWeather() async {
    setState(() => _isLoading = true);

    try {
      // Get city from index number using the formula
      final city = IndexCityService.getCityFromIndex(widget.indexNumber);
      
      print('📍 Index: ${widget.indexNumber}');
      print('📍 Calculated Location: ${city.name}');
      print('📍 Coordinates: ${city.latitude}°N, ${city.longitude}°E');
      
      final weather = await _weatherService.fetchWeather(
        indexNumber: widget.indexNumber,
        latitude: city.latitude,
        longitude: city.longitude,
      );

      setState(() {
        _weather = weather;
        _currentLocation = city;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading weather: $e');
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load weather data: $e'),
            action: SnackBarAction(
              label: 'Retry',
              onPressed: _loadWeather,
            ),
          ),
        );
      }
    }
  }

  void _onNavItemTapped(int index) {
    if (index == _selectedIndex) return;

    setState(() => _selectedIndex = index);

    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SkyCastForecastsPage(
            latitude: _currentLocation?.latitude ?? 0,
            longitude: _currentLocation?.longitude ?? 0,
            cityName: _currentLocation?.name ?? 'Current Location',
          ),
        ),
      ).then((_) => setState(() => _selectedIndex = 0));
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SkyCastSearchPage()),
      ).then((_) => setState(() => _selectedIndex = 0));
    } else if (index == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SkyCastProfilePage(indexNumber: widget.indexNumber),
        ),
      ).then((_) => setState(() => _selectedIndex = 0));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadWeather,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: _buildContent(),
              ),
            ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildContent() {
    if (_weather == null) {
      return const SizedBox(
        height: 600,
        child: Center(child: Text('No weather data available')),
      );
    }

    return Column(
      children: [
        _buildHeader(),
        _buildMainWeatherCard(),
        _buildTodaysForecast(),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.location_on, size: 20),
              const SizedBox(width: 4),
              Text(
                _currentLocation?.name ?? 'Dhaka, Bangladesh',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SkyCastSearchPage()),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.settings_outlined),
                onPressed: () {
                  Navigator.pushNamed(context, '/settings');
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMainWeatherCard() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SkyCastWeatherDetailsPage(weather: _weather!),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue.shade400, Colors.blue.shade600],
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          children: [
            // Location and Date
            Text(
              '${_currentLocation?.name ?? "Dhaka"}, ${_currentLocation?.country ?? "Bangladesh"}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _getFormattedDate(),
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            
            // Weather Icon and Temperature
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _weather!.getWeatherIcon(),
                  style: const TextStyle(fontSize: 80),
                ),
                const SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_weather!.temperature.round()}°',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 72,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            // Weather Description
            Text(
              _weather!.getWeatherDescription(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Weather Details Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildWeatherDetail(
                  Icons.air,
                  '${_weather!.windSpeed.round()} km/h',
                  'Wind',
                ),
                _buildWeatherDetail(
                  Icons.water_drop_outlined,
                  '75%',
                  'Humidity',
                ),
                _buildWeatherDetail(
                  Icons.wb_cloudy_outlined,
                  '60%',
                  'Cloudiness',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherDetail(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildTodaysForecast() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Today's Forecast",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 120,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildHourlyForecast('09:00', '☀️', '25°'),
                _buildHourlyForecast('10:00', '⛅', '26°'),
                _buildHourlyForecast('11:00', '🌧️', '27°'),
                _buildHourlyForecast('12:00', '☀️', '28°'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHourlyForecast(String time, String icon, String temp) {
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
            time,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          Text(icon, style: const TextStyle(fontSize: 32)),
          Text(
            temp,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.home, 'Home', 0),
              _buildNavItem(Icons.wb_cloudy_outlined, 'Forecasts', 1),
              _buildNavItem(Icons.search, 'Search', 2),
              _buildNavItem(Icons.person_outline, 'Profile', 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _selectedIndex == index;
    return InkWell(
      onTap: () => _onNavItemTapped(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? Colors.blue.shade400 : Colors.grey.shade600,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isSelected ? Colors.blue.shade400 : Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  String _getFormattedDate() {
    final now = DateTime.now();
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    
    return '${days[now.weekday - 1]}, ${months[now.month - 1]} ${now.day}';
  }
}
