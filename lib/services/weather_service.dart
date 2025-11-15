import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/weather_model.dart';
import 'cache_service.dart';

/// Weather Service
/// Handles API calls to Open-Meteo and manages caching
class WeatherService {
  final CacheService _cacheService = CacheService();
  static const String _baseUrl = 'https://api.open-meteo.com/v1/forecast';

  /// Build the complete API request URL with hourly and daily forecasts
  String buildRequestUrl(double latitude, double longitude) {
    return '$_baseUrl?latitude=$latitude&longitude=$longitude'
        '&current_weather=true'
        '&hourly=temperature_2m,relative_humidity_2m,weather_code,wind_speed_10m'
        '&daily=weather_code,temperature_2m_max,temperature_2m_min,sunrise,sunset,uv_index_max'
        '&timezone=auto';
  }

  /// Check internet connectivity
  Future<bool> hasInternetConnection() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      return connectivityResult != ConnectivityResult.none;
    } catch (e) {
      print('❌ Error checking connectivity: $e');
      return false;
    }
  }

  /// Fetch weather data from Open-Meteo API
  Future<WeatherModel?> fetchWeather({
    required String indexNumber,
    required double latitude,
    required double longitude,
  }) async {
    final url = buildRequestUrl(latitude, longitude);
    
    try {
      // Check internet connection
      final hasInternet = await hasInternetConnection();
      
      if (!hasInternet) {
        print('⚠️ No internet connection. Loading cached data...');
        return await _loadCachedWeather(indexNumber, latitude, longitude, url);
      }

      print('🌐 Fetching weather from API...');
      print('📍 URL: $url');

      // Make HTTP request
      final response = await http.get(
        Uri.parse(url),
        headers: {'Accept': 'application/json'},
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Request timeout');
        },
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
        
        // Cache the successful response with location-specific key
        await _cacheService.cacheWeatherData(jsonData, latitude, longitude);
        
        print('✅ Weather data fetched successfully');
        
        return WeatherModel.fromJson(
          jsonData,
          indexNumber,
          latitude,
          longitude,
          url,
        );
      } else {
        print('❌ API Error: ${response.statusCode}');
        throw Exception('Failed to fetch weather: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error fetching weather: $e');
      
      // Try to load cached data on error
      final cachedWeather = await _loadCachedWeather(
        indexNumber,
        latitude,
        longitude,
        url,
      );
      
      if (cachedWeather != null) {
        return cachedWeather;
      }
      
      rethrow;
    }
  }

  /// Load cached weather data for specific location
  Future<WeatherModel?> _loadCachedWeather(
    String indexNumber,
    double latitude,
    double longitude,
    String url,
  ) async {
    try {
      final cachedData = await _cacheService.getCachedWeatherData(latitude, longitude);
      
      if (cachedData == null) {
        print('ℹ️ No cached weather data available for this location');
        return null;
      }

      print('✅ Loaded cached weather data for this location');
      
      return WeatherModel.fromJson(
        cachedData,
        indexNumber,
        latitude,
        longitude,
        url,
        cached: true,
      );
    } catch (e) {
      print('❌ Error loading cached weather: $e');
      return null;
    }
  }

  /// Get cache information for specific location
  Future<String> getCacheInfo(double latitude, double longitude) async {
    final hasCache = await _cacheService.hasCachedData(latitude, longitude);
    if (!hasCache) return 'No cached data';

    final lastUpdate = await _cacheService.getLastUpdateTime(latitude, longitude);
    final ageInMinutes = await _cacheService.getCacheAgeInMinutes(latitude, longitude);

    if (lastUpdate == null || ageInMinutes == null) {
      return 'Cache info unavailable';
    }

    if (ageInMinutes < 60) {
      return 'Cached $ageInMinutes minutes ago';
    } else {
      final hours = (ageInMinutes / 60).floor();
      return 'Cached $hours hours ago';
    }
  }

  /// Clear cached data for specific location
  Future<void> clearCache(double latitude, double longitude) async {
    await _cacheService.clearCache(latitude, longitude);
  }

  /// Clear all cached data
  Future<void> clearAllCache() async {
    await _cacheService.clearAllCache();
  }
}
