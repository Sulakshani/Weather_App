import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Cache Service
/// Handles local storage of weather data for offline access
class CacheService {
  static const String _weatherDataKey = 'weatherData';
  static const String _lastUpdateKey = 'lastUpdate';

  /// Save weather data to local cache
  Future<void> cacheWeatherData(Map<String, dynamic> weatherData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(weatherData);
      
      await prefs.setString(_weatherDataKey, jsonString);
      await prefs.setString(_lastUpdateKey, DateTime.now().toIso8601String());
      
      print('✅ Weather data cached successfully');
    } catch (e) {
      print('❌ Error caching weather data: $e');
    }
  }

  /// Retrieve cached weather data
  Future<Map<String, dynamic>?> getCachedWeatherData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_weatherDataKey);
      
      if (jsonString == null) {
        print('ℹ️ No cached weather data found');
        return null;
      }
      
      final weatherData = jsonDecode(jsonString) as Map<String, dynamic>;
      print('✅ Loaded cached weather data');
      return weatherData;
    } catch (e) {
      print('❌ Error retrieving cached data: $e');
      return null;
    }
  }

  /// Get the last update timestamp
  Future<DateTime?> getLastUpdateTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timestamp = prefs.getString(_lastUpdateKey);
      
      if (timestamp == null) return null;
      
      return DateTime.parse(timestamp);
    } catch (e) {
      print('❌ Error retrieving last update time: $e');
      return null;
    }
  }

  /// Check if cached data exists
  Future<bool> hasCachedData() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_weatherDataKey);
  }

  /// Clear all cached data
  Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_weatherDataKey);
      await prefs.remove(_lastUpdateKey);
      print('✅ Cache cleared successfully');
    } catch (e) {
      print('❌ Error clearing cache: $e');
    }
  }

  /// Get cache age in minutes
  Future<int?> getCacheAgeInMinutes() async {
    final lastUpdate = await getLastUpdateTime();
    if (lastUpdate == null) return null;
    
    final now = DateTime.now();
    final difference = now.difference(lastUpdate);
    return difference.inMinutes;
  }
}
