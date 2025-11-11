# Personalized Weather Dashboard 🌦️

A multi-page Flutter weather dashboard application with offline support, caching, and index-based coordinate calculation. This app fetches real-time weather data from the Open-Meteo API and displays it in a beautiful, modern UI.

![Flutter](https://img.shields.io/badge/Flutter-3.0+-blue.svg)
![Dart](https://img.shields.io/badge/Dart-3.0+-blue.svg)
![License](https://img.shields.io/badge/License-MIT-green.svg)

## 📱 Features

- **Multi-Page Navigation**: Smooth navigation between Get Started, Login, and Weather Dashboard pages
- **Index-Based Coordinates**: Automatically calculates latitude and longitude from student index number
- **Real-Time Weather Data**: Fetches current weather from Open-Meteo API
- **Offline Support**: Displays cached data when internet is unavailable
- **Modern UI Design**: Blue gradient theme with card-based layouts
- **Error Handling**: Graceful error messages and retry mechanisms
- **Data Caching**: Uses SharedPreferences for local data persistence
- **Connectivity Detection**: Automatically detects network status

## 🎯 App Flow

```
Get Started Page → Login Page → Weather Dashboard Page
      ↓               ↓                    ↓
  Welcome UI    Index Input         Weather Display
                Calculate Coords    + Offline Cache
```

## 📂 Project Structure

```
lib/
├── main.dart                      # App entry point
├── models/
│   └── weather_model.dart         # Weather data model
├── services/
│   ├── cache_service.dart         # Local storage service
│   └── weather_service.dart       # API service
├── widgets/
│   ├── loading_indicator.dart     # Loading animations
│   └── weather_card.dart          # Weather display card
└── pages/
    ├── get_started_page.dart      # Welcome screen
    ├── login_page.dart            # Index input screen
    └── weather_page.dart          # Weather dashboard
```

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (3.0 or higher)
- Dart SDK (3.0 or higher)
- Android Studio / VS Code with Flutter extensions
- An Android/iOS device or emulator

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/Weather_App.git
   cd Weather_App
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

## 📦 Dependencies

```yaml
dependencies:
  http: ^1.2.0                    # API requests
  shared_preferences: ^2.2.2      # Local caching
  connectivity_plus: ^6.0.2       # Network status
  flutter_spinkit: ^5.2.0         # Loading animations
```

## 🧮 Coordinate Calculation

The app calculates location coordinates from your student index number:

```dart
Index Format: XYZZAAB (e.g., 224045B)

Latitude  = 5 + (XY / 10.0)    // First 2 digits
Longitude = 79 + (ZZ / 10.0)   // Next 2 digits

Example: 224045B
  → Latitude  = 5 + (22 / 10.0) = 7.20
  → Longitude = 79 + (40 / 10.0) = 83.00
```

## 🌐 API Integration

### Open-Meteo API

The app uses the free Open-Meteo API (no authentication required):

```
https://api.open-meteo.com/v1/forecast?latitude={LAT}&longitude={LON}&current_weather=true
```

**Response includes:**
- Temperature (°C)
- Wind speed (km/h)
- Weather code (WMO codes)
- Timestamp

## 💾 Caching & Offline Support

### How it works:

1. **Online Mode**: Fetches fresh data from API and caches it locally
2. **Offline Mode**: Displays cached data with "(cached)" label
3. **Cache Updates**: Automatic timestamp tracking
4. **Error Handling**: Falls back to cache on network errors

### Implementation:

```dart
// Cache Service stores:
- weatherData: JSON string of weather data
- lastUpdate: Timestamp of last successful fetch
```

## 🧪 Testing Instructions

### Test Case 1: Normal Flow
1. Launch app → tap "Get Started"
2. Enter index (e.g., `224045B`)
3. Tap "Continue"
4. View weather data with:
   - Temperature
   - Wind speed
   - Weather code
   - Coordinates
   - API URL

### Test Case 2: Offline Support
1. Complete Test Case 1 (to cache data)
2. Enable Airplane Mode
3. Pull down to refresh OR restart app
4. View cached data with "(cached)" label

### Test Case 3: Error Handling
1. Turn off internet before first launch
2. Enter index and continue
3. See error message: "Could not fetch weather"
4. Tap "Try Again" after enabling internet

## 📸 Screenshots

### 1. Get Started Page
- Welcome screen with weather icon
- Blue gradient background
- "Get Started" button

### 2. Login Page
- Index number input field
- Format validation (6 digits + letter)
- Pre-filled example: `224045B`

### 3. Weather Dashboard
- Large temperature display
- Weather icon and description
- Wind speed and weather code
- Coordinates display
- API request URL
- Cached data indicator (when offline)

## 🎨 UI Design

**Color Scheme:**
- Primary: Blue shades (#2196F3 family)
- Background: Gradient (blue → white)
- Cards: White with elevation
- Text: Black87 / White

**Typography:**
- Headers: Bold, 24-32px
- Body: Regular, 14-16px
- Monospace: API URLs

## 📝 Report Template

### Sample Report Content:

```markdown
## Assignment: Personalized Weather Dashboard

### Student Information
- **Index Number**: 224045B
- **Calculated Coordinates**:
  - Latitude: 7.20
  - Longitude: 83.00

### API Request URL
```
https://api.open-meteo.com/v1/forecast?latitude=7.2&longitude=83.0&current_weather=true
```

### Screenshots
[Include screenshots of all three pages]

### Reflection
I learned how to integrate REST APIs in Flutter and handle JSON parsing 
efficiently. Using shared_preferences taught me how to cache data locally 
for offline use. The coordinate generation from my index number was 
interesting and showed how logic can drive API customization. I faced 
minor challenges with async functions and managing UI updates but 
overcame them by using FutureBuilder and setState properly.
```

## 🔧 Troubleshooting

### Issue: Dependencies not installing
```bash
flutter clean
flutter pub get
```

### Issue: API not responding
- Check internet connection
- Verify coordinates are valid (lat: -90 to 90, lon: -180 to 180)
- Check API URL format

### Issue: Cache not working
- Check app permissions
- Clear app data and restart
- Verify SharedPreferences initialization

## 🛠️ Development

### Run in debug mode
```bash
flutter run
```

### Build APK
```bash
flutter build apk --release
```

### Run tests
```bash
flutter test
```

### Check for issues
```bash
flutter analyze
```

## 📚 Learning Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [Open-Meteo API Docs](https://open-meteo.com/en/docs)
- [Dart Language Tour](https://dart.dev/guides/language/language-tour)
- [SharedPreferences Guide](https://pub.dev/packages/shared_preferences)

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 👨‍💻 Author

**Your Name**
- GitHub: [@yourusername](https://github.com/yourusername)
- Email: your.email@example.com

## 🙏 Acknowledgments

- Open-Meteo for providing free weather API
- Flutter team for the amazing framework
- UI inspiration from [realflutternuggets/flutter-weather-app](https://github.com/realflutternuggets/flutter-weather-app)

## 📞 Support

If you have any questions or need help, please:
1. Check the [Issues](https://github.com/yourusername/Weather_App/issues) page
2. Create a new issue with detailed description
3. Contact via email

---

**Made with ❤️ using Flutter**