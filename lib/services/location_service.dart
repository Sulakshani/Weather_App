import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/location_model.dart';

class LocationService {
  static const String _savedLocationsKey = 'saved_locations';
  static const String _currentLocationKey = 'current_location';

  /// Get saved locations
  Future<List<LocationModel>> getSavedLocations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final locationsJson = prefs.getString(_savedLocationsKey);
      
      if (locationsJson == null) return [];
      
      final List<dynamic> decoded = jsonDecode(locationsJson);
      return decoded.map((json) => LocationModel.fromJson(json)).toList();
    } catch (e) {
      print('Error getting saved locations: $e');
      return [];
    }
  }

  /// Save a location
  Future<void> saveLocation(LocationModel location) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final locations = await getSavedLocations();
      
      // Check if location already exists
      final exists = locations.any((loc) => 
        loc.name == location.name && loc.country == location.country
      );
      
      if (!exists) {
        locations.add(location);
        final jsonList = locations.map((loc) => loc.toJson()).toList();
        await prefs.setString(_savedLocationsKey, jsonEncode(jsonList));
      }
    } catch (e) {
      print('Error saving location: $e');
    }
  }

  /// Remove a location
  Future<void> removeLocation(LocationModel location) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final locations = await getSavedLocations();
      
      locations.removeWhere((loc) => 
        loc.name == location.name && loc.country == location.country
      );
      
      final jsonList = locations.map((loc) => loc.toJson()).toList();
      await prefs.setString(_savedLocationsKey, jsonEncode(jsonList));
    } catch (e) {
      print('Error removing location: $e');
    }
  }

  /// Set current location
  Future<void> setCurrentLocation(LocationModel location) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_currentLocationKey, jsonEncode(location.toJson()));
    } catch (e) {
      print('Error setting current location: $e');
    }
  }

  /// Get current location
  Future<LocationModel?> getCurrentLocation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final locationJson = prefs.getString(_currentLocationKey);
      
      if (locationJson == null) return null;
      
      return LocationModel.fromJson(jsonDecode(locationJson));
    } catch (e) {
      print('Error getting current location: $e');
      return null;
    }
  }

  /// Get popular cities
  List<LocationModel> getPopularCities() {
    return [
      LocationModel(name: 'New York City', country: 'United States', latitude: 40.7128, longitude: -74.0060),
      LocationModel(name: 'London', country: 'United Kingdom', latitude: 51.5074, longitude: -0.1278),
      LocationModel(name: 'Paris', country: 'France', latitude: 48.8566, longitude: 2.3522),
      LocationModel(name: 'Tokyo', country: 'Japan', latitude: 35.6762, longitude: 139.6503),
      LocationModel(name: 'Sydney', country: 'Australia', latitude: -33.8688, longitude: 151.2093),
      LocationModel(name: 'Dubai', country: 'United Arab Emirates', latitude: 25.2048, longitude: 55.2708),
    ];
  }
}
