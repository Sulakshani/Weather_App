import '../models/location_model.dart';

/// Index to Location Mapping Service
/// Calculates coordinates directly from student index number
/// Formula: lat = 5 + (firstTwo / 10.0), lon = 79 + (nextTwo / 10.0)
class IndexCityService {
  /// Calculate location from index number
  /// Example: Index "194174T" -> lat=6.9, lon=83.1 (ignores the letter suffix)
  static LocationModel getCityFromIndex(String indexNumber) {
    // Remove any letter suffix and extract just the 6 digits
    final digitsOnly = indexNumber.replaceAll(RegExp(r'[^0-9]'), '');
    
    if (digitsOnly.length < 6) {
      throw ArgumentError('Index number must contain at least 6 digits');
    }

    // Use first 6 digits for calculation
    final indexDigits = digitsOnly.substring(0, 6);
    
    // Parse first two and next two digits
    final firstTwo = int.parse(indexDigits.substring(0, 2));
    final nextTwo = int.parse(indexDigits.substring(2, 4));

    // Calculate coordinates using the formula
    // lat = 5 + (firstTwo / 10.0)  // Range: 5.0 to 15.9
    // lon = 79 + (nextTwo / 10.0)  // Range: 79.0 to 89.9
    final latitude = 5.0 + (firstTwo / 10.0);
    final longitude = 79.0 + (nextTwo / 10.0);

    // Determine approximate location name based on coordinates
    final locationName = _getLocationName(latitude, longitude);

    return LocationModel(
      name: locationName,
      country: 'Calculated from Index',
      latitude: latitude,
      longitude: longitude,
    );
  }

  /// Get approximate location name based on coordinates
  static String _getLocationName(double lat, double lon) {
    // Sri Lanka region (expanded to cover all calculated coordinates)
    if (lat >= 5.0 && lat <= 10.0 && lon >= 79.0 && lon <= 89.9) {
      // Colombo Area (Central-West)
      if (lat >= 6.5 && lat <= 7.5 && lon >= 79.5 && lon <= 80.5) {
        return 'Colombo Region';
      } 
      // Kandy Area (Central)
      else if (lat >= 7.0 && lat <= 7.5 && lon >= 80.5 && lon <= 81.5) {
        return 'Kandy Region';
      } 
      // Jaffna Area (North)
      else if (lat >= 9.0 && lat <= 10.0 && lon >= 79.5 && lon <= 81.0) {
        return 'Jaffna Region';
      } 
      // Galle Area (South)
      else if (lat >= 5.5 && lat <= 6.5 && lon >= 79.5 && lon <= 80.5) {
        return 'Galle Region';
      } 
      // Trincomalee Area (East)
      else if (lat >= 8.0 && lat <= 9.0 && lon >= 80.5 && lon <= 81.5) {
        return 'Trincomalee Region';
      }
      // Eastern Sri Lanka
      else if (lon >= 81.5) {
        return 'Eastern Region';
      }
      // Western Sri Lanka
      else if (lon <= 80.0) {
        return 'Western Region';
      }
      // Central Sri Lanka
      else {
        return 'Central Region';
      }
    }
    // Northern region (10-13°N)
    else if (lat >= 10.0 && lat <= 13.0) {
      return 'Northern Territory';
    }
    // Far North (13-16°N)
    else if (lat >= 13.0 && lat <= 16.0) {
      return 'Far North Region';
    }
    // Default - show coordinates
    else {
      return 'Region ${lat.toStringAsFixed(1)}°N, ${lon.toStringAsFixed(1)}°E';
    }
  }

  /// Get description of the calculation method
  static String getCalculationInfo(String indexNumber) {
    final digitsOnly = indexNumber.replaceAll(RegExp(r'[^0-9]'), '');
    
    if (digitsOnly.length < 6) return 'Invalid index';
    
    final indexDigits = digitsOnly.substring(0, 6);
    final firstTwo = indexDigits.substring(0, 2);
    final nextTwo = indexDigits.substring(2, 4);
    final lat = 5.0 + (int.parse(firstTwo) / 10.0);
    final lon = 79.0 + (int.parse(nextTwo) / 10.0);
    
    return 'Index: $indexNumber\n'
           'Digits used: $indexDigits\n'
           'First two digits: $firstTwo\n'
           'Next two digits: $nextTwo\n'
           'Latitude: 5 + ($firstTwo / 10) = ${lat.toStringAsFixed(1)}°N\n'
           'Longitude: 79 + ($nextTwo / 10) = ${lon.toStringAsFixed(1)}°E';
  }
}
