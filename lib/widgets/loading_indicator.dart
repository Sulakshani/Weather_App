import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

/// Loading Indicator Widget
/// Displays a loading animation while fetching data
class LoadingIndicator extends StatelessWidget {
  final String? message;

  const LoadingIndicator({
    Key? key,
    this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SpinKitFadingCircle(
            color: Colors.blue.shade600,
            size: 60.0,
          ),
          const SizedBox(height: 20),
          Text(
            message ?? 'Loading...',
            style: TextStyle(
              fontSize: 18,
              color: Colors.blue.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom Loading Widget with weather theme
class WeatherLoadingIndicator extends StatelessWidget {
  const WeatherLoadingIndicator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            '☁️',
            style: TextStyle(fontSize: 60),
          ),
          const SizedBox(height: 20),
          SpinKitWave(
            color: Colors.blue.shade600,
            size: 40.0,
          ),
          const SizedBox(height: 20),
          Text(
            'Fetching weather data...',
            style: TextStyle(
              fontSize: 18,
              color: Colors.blue.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
