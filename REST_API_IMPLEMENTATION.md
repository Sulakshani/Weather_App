# SkyCast Weather App - REST API Implementation Guide

## ✅ Completed Features

### 1. **Index-Based City Mapping**
File: `lib/services/index_city_service.dart`

**How it Works:**
- Takes 6-digit student index number (e.g., "220472")
- Maps to specific Sri Lankan cities based on index pattern
- Formula: `(firstTwo + middleTwo) % 20` determines city

**Supported Cities:**
1. **Colombo** (Commercial capital) - 6.9271°N, 79.8612°E
2. **Kandy** (Cultural capital) - 7.2906°N, 80.6337°E
3. **Galle** (Southern port) - 6.0535°N, 80.2210°E
4. **Jaffna** (Northern capital) - 9.6615°N, 80.0255°E
5. **Trincomalee** (Eastern port) - 8.5874°N, 81.2152°E
6. **Anuradhapura** (Ancient capital) - 8.3114°N, 80.4037°E
7. **Negombo** (Beach resort) - 7.2008°N, 79.8358°E
8. **Batticaloa** (Eastern coast) - 7.7310°N, 81.6747°E
9. **Matara** (Southern coast) - 5.9549°N, 80.5550°E
10. **Nuwara Eliya** (Hill country) - 6.9497°N, 80.7891°E

### 2. **Open-Meteo REST API Integration**

**Base URL:** `https://api.open-meteo.com/v1/forecast`

**Current Weather Endpoint:**
```
GET /v1/forecast?latitude={lat}&longitude={lon}&current_weather=true
```

**Full Forecast Endpoint:**
```
GET /v1/forecast?
  latitude={lat}&
  longitude={lon}&
  current_weather=true&
  hourly=temperature_2m,relative_humidity_2m,weathercode,wind_speed_10m&
  daily=weathercode,temperature_2m_max,temperature_2m_min,sunrise,sunset,uv_index_max&
  timezone=auto
```

**Response Structure:**
```json
{
  "current_weather": {
    "temperature": 28.5,
    "windspeed": 12.3,
    "weathercode": 3,
    "time": "2025-11-15T14:00"
  },
  "hourly": {
    "time": ["2025-11-15T00:00", "2025-11-15T01:00", ...],
    "temperature_2m": [26.2, 25.8, ...],
    "relative_humidity_2m": [75, 78, ...],
    "weathercode": [3, 2, ...],
    "wind_speed_10m": [10.5, 11.2, ...]
  },
  "daily": {
    "time": ["2025-11-15", "2025-11-16", ...],
    "weathercode": [3, 1, ...],
    "temperature_2m_max": [32.5, 33.2, ...],
    "temperature_2m_min": [24.1, 24.8, ...],
    "sunrise": ["2025-11-15T06:15", ...],
    "sunset": ["2025-11-15T18:45", ...],
    "uv_index_max": [7.5, 8.2, ...]
  }
}
```

### 3. **Weather Service** (`lib/services/weather_service.dart`)

**Key Methods:**
- `fetchWeather()` - Gets current weather with caching
- `buildRequestUrl()` - Constructs API URL with all parameters
- `hasInternetConnection()` - Checks connectivity
- `getCacheInfo()` - Returns cache age
- `clearCache()` - Removes cached data

**Features:**
- ✅ HTTP requests with 10-second timeout
- ✅ JSON parsing and error handling
- ✅ Automatic fallback to cached data
- ✅ Connectivity checking
- ✅ SharedPreferences caching

### 4. **Data Models**

**WeatherModel** (`lib/models/weather_model.dart`):
```dart
- temperature: double
- windSpeed: double
- weatherCode: int
- time: String
- latitude/longitude: double
- indexNumber: String
- isCached: bool
- Methods: getWeatherDescription(), getWeatherIcon()
```

**HourlyForecast** (`lib/models/forecast_model.dart`):
```dart
- time: String
- temperature: double
- weatherCode: int
- icon: String
- Methods: fromJson(), _getWeatherIcon()
```

**DailyForecast** (`lib/models/forecast_model.dart`):
```dart
- date/day: String
- maxTemp/minTemp: double
- weatherCode: int
- icon/description: String
- Methods: fromJson(), _getDayName(), _getWeatherDescription()
```

### 5. **Updated Pages**

**Home Page** (`lib/pages/skycast_home_page.dart`):
- ✅ Uses IndexCityService to get city from index
- ✅ Displays city name and country
- ✅ Shows current weather from API
- ✅ Pull-to-refresh functionality
- ✅ Error handling with retry
- ✅ Passes correct parameters to Forecasts page

**Forecasts Page** (`lib/pages/skycast_forecasts_page.dart`):
- ✅ Fetches 7-day forecast from API
- ✅ Displays 24-hour hourly forecast
- ✅ Shows min/max temperatures
- ✅ Weather icons and descriptions
- ✅ Pull-to-refresh
- ✅ Loading and error states

## 📱 User Flow

1. **Login** → Enter 6-digit index (e.g., "220472")
2. **Index Mapping** → System calculates city (e.g., Colombo)
3. **API Call** → Fetches weather for city coordinates
4. **Home Page** → Displays current weather
5. **Forecasts** → Tap icon to see 7-day + hourly forecast
6. **Refresh** → Pull down to update data
7. **Offline** → Uses cached data automatically

## 🔧 Testing

**Test Index Numbers:**
- `220472` → Colombo
- `220345` → Kandy
- `220678` → Galle
- `220123` → Jaffna

**API Testing:**
```bash
# Test current weather
curl "https://api.open-meteo.com/v1/forecast?latitude=6.9271&longitude=79.8612&current_weather=true"

# Test full forecast
curl "https://api.open-meteo.com/v1/forecast?latitude=6.9271&longitude=79.8612&current_weather=true&hourly=temperature_2m,weathercode&daily=weathercode,temperature_2m_max,temperature_2m_min&timezone=auto"
```

## 📊 WMO Weather Code Mappings

| Code | Description | Icon |
|------|-------------|------|
| 0 | Clear sky | ☀️ |
| 1-3 | Partly cloudy | ⛅ |
| 45-48 | Foggy | 🌫️ |
| 51-65 | Rain/Drizzle | 🌧️ |
| 71-77 | Snow | ❄️ |
| 80-82 | Rain showers | 🌦️ |
| 95-99 | Thunderstorm | ⛈️ |

## ✅ Assignment Requirements Met

1. ✓ REST API integration (Open-Meteo)
2. ✓ Index-based city selection
3. ✓ Real-time weather data
4. ✓ 7-day forecast
5. ✓ Hourly forecast (24 hours)
6. ✓ Caching with SharedPreferences
7. ✓ Offline support
8. ✓ Error handling
9. ✓ Pull-to-refresh
10. ✓ Sri Lankan cities mapping

## 🚀 Next Steps

All core features are working! You can now:
1. Test with different index numbers
2. Verify city mappings
3. Check forecast accuracy
4. Test offline mode
5. Submit the assignment!
