import 'package:flutter/material.dart';

class SkyCastSavedLocationsPage extends StatelessWidget {
  const SkyCastSavedLocationsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final locations = [
      {'name': 'New York', 'desc': 'Partly Cloudy', 'temp': '22°C', 'icon': '⛅'},
      {'name': 'London', 'desc': 'Light Rain', 'temp': '18°C', 'icon': '🌧️'},
      {'name': 'Tokyo', 'desc': 'Sunny', 'temp': '25°C', 'icon': '☀️'},
      {'name': 'Sydney', 'desc': 'Clear Skies', 'temp': '28°C', 'icon': '☀️'},
      {'name': 'Paris', 'desc': 'Overcast', 'temp': '20°C', 'icon': '☁️'},
      {'name': 'Berlin', 'desc': 'Windy', 'temp': '15°C', 'icon': '💨'},
      {'name': 'Dubai', 'desc': 'Hot & Clear', 'temp': '35°C', 'icon': '☀️'},
      {'name': 'Cairo', 'desc': 'Sunny Day', 'temp': '30°C', 'icon': '☀️'},
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Saved Locations', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: locations.length,
          itemBuilder: (context, index) {
            final loc = locations[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(loc['name']!, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(loc['desc']!, style: TextStyle(color: Colors.grey.shade600)),
                    ],
                  ),
                  Row(
                    children: [
                      Text(loc['temp']!, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 8),
                      Text(loc['icon']!, style: const TextStyle(fontSize: 24)),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
