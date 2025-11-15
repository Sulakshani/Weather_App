import '../models/location_model.dart';

/// Index to Location Mapping Service
/// Calculates coordinates directly from student index number
/// Formula: lat = 5 + (firstTwo / 10.0), lon = 79 + (nextTwo / 10.0)
class IndexCityService {
  /// Calculate location from index number
  /// Example: Index "194174" -> lat=6.9, lon=83.1
  static LocationModel getCityFromIndex(String indexNumber) {
    if (indexNumber.length != 6) {
      throw ArgumentError('Index number must be 6 digits');
    }

    // Parse first two and next two digits
    final firstTwo = int.parse(indexNumber.substring(0, 2));
    final nextTwo = int.parse(indexNumber.substring(2, 4));

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
    // Sri Lanka region (5-10°N, 79-82°E)
    if (lat >= 5.0 && lat <= 10.0 && lon >= 79.0 && lon <= 82.0) {
      if (lat >= 6.5 && lat <= 7.5 && lon >= 79.5 && lon <= 80.5) {
        return 'Colombo Area';
      } else if (lat >= 7.0 && lat <= 7.5 && lon >= 80.5 && lon <= 81.0) {
        return 'Kandy Area';
      } else if (lat >= 9.0 && lat <= 10.0 && lon >= 79.5 && lon <= 80.5) {
        return 'Jaffna Area';
      } else if (lat >= 5.5 && lat <= 6.5 && lon >= 80.0 && lon <= 80.5) {
        return 'Galle Area';
      } else if (lat >= 8.0 && lat <= 9.0 && lon >= 81.0 && lon <= 82.0) {
        return 'Trincomalee Area';
      } else {
        return 'Sri Lanka';
      }
    }
    // India region (10-16°N)
    else if (lat >= 10.0 && lat <= 16.0) {
      return 'South India';
    }
    // Default - show coordinates
    else {
      return 'Location ${lat.toStringAsFixed(1)}°N, ${lon.toStringAsFixed(1)}°E';
    }
  }

  /// Get description of the calculation method
  static String getCalculationInfo(String indexNumber) {
    if (indexNumber.length != 6) return 'Invalid index';
    
    final firstTwo = indexNumber.substring(0, 2);
    final nextTwo = indexNumber.substring(2, 4);
    final lat = 5.0 + (int.parse(firstTwo) / 10.0);
    final lon = 79.0 + (int.parse(nextTwo) / 10.0);
    
    return 'Index: $indexNumber\n'
           'First two digits: $firstTwo\n'
           'Next two digits: $nextTwo\n'
           'Latitude: 5 + ($firstTwo / 10) = ${lat.toStringAsFixed(1)}°N\n'
           'Longitude: 79 + ($nextTwo / 10) = ${lon.toStringAsFixed(1)}°E';
  }
}
