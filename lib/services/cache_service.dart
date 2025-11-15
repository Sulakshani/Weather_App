import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Cache Service
/// Handles local storage of weather data for offline access
/// Now supports location-specific caching to prevent showing same weather for different locations
class CacheService {
  static const String _weatherDataPrefix = 'weatherData_';
  static const String _lastUpdatePrefix = 'lastUpdate_';

  /// Generate unique cache key for location
  String _getCacheKey(double latitude, double longitude) {
    // Round to 1 decimal to group nearby locations
    final latKey = latitude.toStringAsFixed(1);
    final lonKey = longitude.toStringAsFixed(1);
    return '${latKey}_$lonKey';
  }

  /// Save weather data to local cache with location-specific key
  Future<void> cacheWeatherData(
    Map<String, dynamic> weatherData,
    double latitude,
    double longitude,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = _getCacheKey(latitude, longitude);
      final jsonString = jsonEncode(weatherData);
      
      await prefs.setString('$_weatherDataPrefix$cacheKey', jsonString);
      await prefs.setString('$_lastUpdatePrefix$cacheKey', DateTime.now().toIso8601String());
      
      print('✅ Weather data cached for location ($latitude, $longitude)');
    } catch (e) {
      print('❌ Error caching weather data: $e');
    }
  }

  /// Retrieve cached weather data for specific location
  Future<Map<String, dynamic>?> getCachedWeatherData(
    double latitude,
    double longitude,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = _getCacheKey(latitude, longitude);
      final jsonString = prefs.getString('$_weatherDataPrefix$cacheKey');
      
      if (jsonString == null) {
        print('ℹ️ No cached weather data for location ($latitude, $longitude)');
        return null;
      }
      
      final weatherData = jsonDecode(jsonString) as Map<String, dynamic>;
      print('✅ Loaded cached weather data for location ($latitude, $longitude)');
      return weatherData;
    } catch (e) {
      print('❌ Error retrieving cached data: $e');
      return null;
    }
  }

  /// Get the last update timestamp for specific location
  Future<DateTime?> getLastUpdateTime(double latitude, double longitude) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = _getCacheKey(latitude, longitude);
      final timestamp = prefs.getString('$_lastUpdatePrefix$cacheKey');
      
      if (timestamp == null) return null;
      
      return DateTime.parse(timestamp);
    } catch (e) {
      print('❌ Error retrieving last update time: $e');
      return null;
    }
  }

  /// Check if cached data exists for specific location
  Future<bool> hasCachedData(double latitude, double longitude) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheKey = _getCacheKey(latitude, longitude);
    return prefs.containsKey('$_weatherDataPrefix$cacheKey');
  }

  /// Clear cache for specific location
  Future<void> clearCache(double latitude, double longitude) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = _getCacheKey(latitude, longitude);
      await prefs.remove('$_weatherDataPrefix$cacheKey');
      await prefs.remove('$_lastUpdatePrefix$cacheKey');
      print('✅ Cache cleared for location ($latitude, $longitude)');
    } catch (e) {
      print('❌ Error clearing cache: $e');
    }
  }

  /// Clear all cached weather data (all locations)
  Future<void> clearAllCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      
      for (final key in keys) {
        if (key.startsWith(_weatherDataPrefix) || key.startsWith(_lastUpdatePrefix)) {
          await prefs.remove(key);
        }
      }
      
      print('✅ All cache cleared successfully');
    } catch (e) {
      print('❌ Error clearing all cache: $e');
    }
  }

  /// Get cache age in minutes for specific location
  Future<int?> getCacheAgeInMinutes(double latitude, double longitude) async {
    final lastUpdate = await getLastUpdateTime(latitude, longitude);
    if (lastUpdate == null) return null;
    
    final now = DateTime.now();
    final difference = now.difference(lastUpdate);
    return difference.inMinutes;
  }
}
