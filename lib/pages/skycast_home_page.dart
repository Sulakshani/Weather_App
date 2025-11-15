import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/weather_service.dart';
import '../services/index_city_service.dart';
import '../models/weather_model.dart';
import '../models/location_model.dart';
import 'skycast_forecasts_page.dart';
import 'skycast_search_page.dart';
import 'skycast_profile_page.dart';
import 'skycast_weather_details_page.dart';

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
  String? _errorMessage;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadWeather();
  }

  Future<void> _loadWeather() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

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

      if (mounted) {
        setState(() {
          _weather = weather;
          _currentLocation = city;
          _isLoading = false;
          
          // Check if the returned data is cached (offline mode)
          if (weather?.isCached == true) {
            _errorMessage = 'No internet connection. Showing last saved weather data.';
          } else {
            _errorMessage = null;
          }
        });
        
        // Show snackbar if data is cached (offline)
        if (weather?.isCached == true && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.wifi_off, color: Colors.white),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Offline mode: Showing last saved weather data',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.orange.shade600,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    } catch (e) {
      print('❌ Error loading weather: $e');
      
      // Determine the type of error
      final isNetworkError = e.toString().contains('SocketException') ||
          e.toString().contains('Failed host lookup') ||
          e.toString().contains('Network is unreachable') ||
          e.toString().contains('timeout');
      
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = isNetworkError
              ? 'No internet connection. Unable to fetch weather data.'
              : 'Unable to load weather data. Please try again.';
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  isNetworkError ? Icons.wifi_off : Icons.error_outline,
                  color: Colors.white,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    isNetworkError
                        ? 'No internet connection. Please check your network settings.'
                        : 'Failed to load weather. Please try again.',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.red.shade400,
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: _loadWeather,
            ),
            duration: const Duration(seconds: 5),
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
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 20),
                  Text(
                    'Fetching weather data...',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadWeather,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    _buildContent(),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildContent() {
    if (_weather == null) {
      return SizedBox(
        height: 600,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.cloud_off, size: 80, color: Colors.grey.shade400),
              const SizedBox(height: 20),
              Text(
                'No weather data available',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: _loadWeather,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        _buildHeader(),
        _buildMainWeatherCard(),
        
        // Weather Code Display
        if (_weather != null)
          Container(
            margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.code, size: 20, color: Colors.blue.shade600),
                const SizedBox(width: 8),
                Text(
                  'Weather Code: ${_weather!.weatherCode}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _weather!.getWeatherDescription(),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        
        // Error banner if there's an error (moved below weather box)
        if (_errorMessage != null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.wifi_off, color: Colors.orange.shade700, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Connection Issue',
                        style: TextStyle(
                          color: Colors.orange.shade900,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _errorMessage!,
                        style: TextStyle(
                          color: Colors.orange.shade800,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        
        _buildTodaysForecast(),
        _buildDebugInfo(),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 20),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        _currentLocation?.name ?? 'Location',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                // Cache indicator
                if (_weather?.isCached == true)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Row(
                      children: [
                        Icon(
                          Icons.cloud_off,
                          size: 12,
                          color: Colors.orange.shade600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '(Cached)',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.orange.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
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
                    Row(
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
                        if (_weather!.isCached)
                          Padding(
                            padding: const EdgeInsets.only(top: 8, left: 4),
                            child: Text(
                              '(cached)',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 14,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                      ],
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
            
            // Show cached indicator on main card if offline
            if (_weather!.isCached)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.offline_bolt, color: Colors.white, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        'Offline Mode - Last Saved Data',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
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
                  isCached: _weather!.isCached,
                ),
                _buildWeatherDetail(
                  Icons.water_drop_outlined,
                  '75%',
                  'Humidity',
                  isCached: _weather!.isCached,
                ),
                _buildWeatherDetail(
                  Icons.wb_cloudy_outlined,
                  '60%',
                  'Cloudiness',
                  isCached: _weather!.isCached,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherDetail(IconData icon, String value, String label, {bool isCached = false}) {
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
          isCached ? '$label (cached)' : label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 12,
            fontStyle: isCached ? FontStyle.italic : FontStyle.normal,
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

  Widget _buildDebugInfo() {
    if (_weather == null || _currentLocation == null) return const SizedBox.shrink();
    
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, size: 18, color: Colors.blue.shade600),
              const SizedBox(width: 8),
              Text(
                'Debug Information',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade600,
                ),
              ),
            ],
          ),
          const Divider(height: 20),
          
          _buildDebugRow('Index Number', widget.indexNumber),
          const SizedBox(height: 8),
          
          _buildDebugRow(
            'Coordinates',
            '${_currentLocation!.latitude.toStringAsFixed(2)}°N, ${_currentLocation!.longitude.toStringAsFixed(2)}°E',
          ),
          const SizedBox(height: 8),
          
          _buildDebugRow(
            'Last Update',
            _weather!.isCached 
                ? '${_weather!.lastUpdated} (Cached)' 
                : DateTime.now().toString().split('.')[0],
          ),
          const SizedBox(height: 8),
          
          _buildDebugRow('Request URL', _weather!.requestUrl, isUrl: true),
        ],
      ),
    );
  }

  Widget _buildDebugRow(String label, String value, {bool isUrl = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 4),
        if (isUrl)
          InkWell(
            onTap: () {
              // Copy URL to clipboard
              Clipboard.setData(ClipboardData(text: value));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('URL copied to clipboard'),
                  duration: const Duration(seconds: 2),
                  backgroundColor: Colors.blue.shade400,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      value,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.blue.shade700,
                        fontFamily: 'monospace',
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(Icons.content_copy, size: 16, color: Colors.grey.shade600),
                ],
              ),
            ),
          )
        else
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade900,
              fontWeight: FontWeight.w500,
            ),
          ),
      ],
    );
  }
}
