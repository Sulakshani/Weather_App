import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'pages/get_started_page.dart';

void main() {
  // Set device orientation to portrait only
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  runApp(const PersonalizedWeatherApp());
}

/// Main Application Widget
class PersonalizedWeatherApp extends StatelessWidget {
  const PersonalizedWeatherApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Personalized Weather Dashboard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: Colors.white,
        
        // AppBar Theme
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.blue.shade600,
          elevation: 0,
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.white),
          titleTextStyle: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        
        // Card Theme
        cardTheme: CardThemeData(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        ),
        
        // Elevated Button Theme
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 4,
            padding: const EdgeInsets.symmetric(
              horizontal: 32,
              vertical: 16,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
          ),
        ),
        
        // Input Decoration Theme
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.blue.shade50,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.blue.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.blue.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.blue.shade700, width: 2),
          ),
        ),
        
        // Text Theme
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          displayMedium: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            color: Colors.black87,
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
      ),
      
      // Start with Get Started Page
      home: const GetStartedPage(),
    );
  }
}
