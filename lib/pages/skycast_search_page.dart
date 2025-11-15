import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/location_model.dart';
import '../models/weather_model.dart';
import '../services/weather_service.dart';

class SkyCastSearchPage extends StatefulWidget {
  const SkyCastSearchPage({Key? key}) : super(key: key);

  @override
  State<SkyCastSearchPage> createState() => _SkyCastSearchPageState();
}

class _SkyCastSearchPageState extends State<SkyCastSearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final WeatherService _weatherService = WeatherService();
  
  List<LocationModel> _searchResults = [];
  List<LocationModel> _popularCities = [];
  Map<String, WeatherModel?> _cityWeather = {};
  bool _isSearching = false;
  bool _isLoadingWeather = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _initializePopularCities();
    _loadPopularCitiesWeather();
  }

  void _initializePopularCities() {
    _popularCities = [
      LocationModel(name: 'Colombo', country: 'Sri Lanka', latitude: 6.9271, longitude: 79.8612),
      LocationModel(name: 'Kandy', country: 'Sri Lanka', latitude: 7.2906, longitude: 80.6337),
      LocationModel(name: 'Galle', country: 'Sri Lanka', latitude: 6.0535, longitude: 80.2210),
      LocationModel(name: 'Jaffna', country: 'Sri Lanka', latitude: 9.6615, longitude: 80.0255),
      LocationModel(name: 'New York', country: 'United States', latitude: 40.7128, longitude: -74.0060),
      LocationModel(name: 'London', country: 'United Kingdom', latitude: 51.5074, longitude: -0.1278),
      LocationModel(name: 'Tokyo', country: 'Japan', latitude: 35.6762, longitude: 139.6503),
      LocationModel(name: 'Paris', country: 'France', latitude: 48.8566, longitude: 2.3522),
    ];
  }

  Future<void> _loadPopularCitiesWeather() async {
    setState(() => _isLoadingWeather = true);
    
    for (var city in _popularCities) {
      try {
        final weather = await _weatherService.fetchWeather(
          indexNumber: '000000',
          latitude: city.latitude,
          longitude: city.longitude,
        );
        setState(() {
          _cityWeather[city.name] = weather;
        });
      } catch (e) {
        print('Error loading weather for ${city.name}: $e');
      }
    }
    
    setState(() => _isLoadingWeather = false);
  }

  Future<void> _searchCity(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _errorMessage = '';
    });

    try {
      // Use Open-Meteo Geocoding API to search for cities
      final url = 'https://geocoding-api.open-meteo.com/v1/search?name=$query&count=10&language=en&format=json';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['results'] != null) {
          final List results = data['results'];
          final List<LocationModel> cities = results.map((city) {
            return LocationModel(
              name: city['name'] ?? 'Unknown',
              country: city['country'] ?? '',
              latitude: (city['latitude'] as num).toDouble(),
              longitude: (city['longitude'] as num).toDouble(),
            );
          }).toList();

          setState(() {
            _searchResults = cities;
            _isSearching = false;
          });

          // Load weather for search results
          _loadSearchResultsWeather();
        } else {
          setState(() {
            _searchResults = [];
            _isSearching = false;
            _errorMessage = 'No cities found';
          });
        }
      }
    } catch (e) {
      setState(() {
        _isSearching = false;
        _errorMessage = 'Search failed: $e';
      });
      print('Search error: $e');
    }
  }

  Future<void> _loadSearchResultsWeather() async {
    for (var city in _searchResults) {
      try {
        final weather = await _weatherService.fetchWeather(
          indexNumber: '000000',
          latitude: city.latitude,
          longitude: city.longitude,
        );
        setState(() {
          _cityWeather[city.name] = weather;
        });
      } catch (e) {
        print('Error loading weather for ${city.name}: $e');
      }
    }
  }

  void _showCityWeather(LocationModel city) {
    final weather = _cityWeather[city.name];
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              Expanded(
                child: weather == null
                    ? const Center(child: CircularProgressIndicator())
                    : SingleChildScrollView(
                        controller: scrollController,
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // City name
                            Text(
                              city.name,
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              city.country,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 24),
                            
                            // Weather card
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Colors.blue.shade400, Colors.blue.shade600],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    weather.getWeatherIcon(),
                                    style: const TextStyle(fontSize: 64),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    '${weather.temperature.round()}°C',
                                    style: const TextStyle(
                                      fontSize: 56,
                                      fontWeight: FontWeight.w300,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    weather.getWeatherDescription(),
                                    style: const TextStyle(
                                      fontSize: 20,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: [
                                      _buildWeatherDetail(
                                        Icons.air,
                                        '${weather.windSpeed.round()} km/h',
                                        'Wind',
                                      ),
                                      _buildWeatherDetail(
                                        Icons.location_on,
                                        '${city.latitude.toStringAsFixed(2)}°, ${city.longitude.toStringAsFixed(2)}°',
                                        'Coordinates',
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            
                            const SizedBox(height: 24),
                            
                            // Action buttons
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('${city.name} added to saved locations'),
                                          duration: const Duration(seconds: 2),
                                        ),
                                      );
                                    },
                                    icon: const Icon(Icons.bookmark_add),
                                    label: const Text('Save Location'),
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
              ),
            ],
          ),
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
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayCities = _searchResults.isEmpty && _searchController.text.isEmpty
        ? _popularCities
        : _searchResults;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Search Cities'),
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  if (value.length >= 2) {
                    _searchCity(value);
                  } else if (value.isEmpty) {
                    setState(() {
                      _searchResults = [];
                      _errorMessage = '';
                    });
                  }
                },
                decoration: InputDecoration(
                  hintText: 'Search for a city...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchResults = [];
                              _errorMessage = '';
                            });
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.blue.shade400, width: 2),
                  ),
                ),
              ),
            ),

            // Section title
            if (!_isSearching)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Text(
                      _searchResults.isEmpty && _searchController.text.isEmpty
                          ? 'Popular Cities'
                          : 'Search Results',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

            // Loading or error
            if (_isSearching)
              const Expanded(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_errorMessage.isNotEmpty)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off, size: 64, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage,
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
              )
            else
              // City list
              Expanded(
                child: ListView.builder(
                  itemCount: displayCities.length,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemBuilder: (context, index) {
                    final city = displayCities[index];
                    final weather = _cityWeather[city.name];
                    
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => _showCityWeather(city),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              // Weather icon
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: weather != null
                                      ? Text(
                                          weather.getWeatherIcon(),
                                          style: const TextStyle(fontSize: 32),
                                        )
                                      : const SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(strokeWidth: 2),
                                        ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              
                              // City info
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      city.name,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      city.country,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              
                              // Temperature
                              if (weather != null)
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '${weather.temperature.round()}°C',
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      weather.getWeatherDescription(),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              
                              const SizedBox(width: 8),
                              const Icon(Icons.arrow_forward_ios, size: 16),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
