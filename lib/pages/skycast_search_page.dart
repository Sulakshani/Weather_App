import 'package:flutter/material.dart';

class SkyCastSearchPage extends StatelessWidget {
  const SkyCastSearchPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cities = [
      {'name': 'New York City', 'country': 'United States'},
      {'name': 'London', 'country': 'United Kingdom'},
      {'name': 'Paris', 'country': 'France'},
      {'name': 'Tokyo', 'country': 'Japan'},
      {'name': 'Sydney', 'country': 'Australia'},
      {'name': 'Dubai', 'country': 'United Arab Emirates'},
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search city or location',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: cities.length,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemBuilder: (context, index) {
                  final city = cities[index];
                  return ListTile(
                    leading: const Icon(Icons.location_on, color: Colors.blue),
                    title: Text(city['name']!),
                    subtitle: Text(city['country']!),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
