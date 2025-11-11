import 'package:flutter/material.dart';
import 'weather_page.dart';

/// Login Page
/// Collects student index number and calculates coordinates
class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _indexController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Pre-fill with example index
    _indexController.text = '224045B';
  }

  @override
  void dispose() {
    _indexController.dispose();
    super.dispose();
  }

  /// Calculate latitude from index number
  double calculateLatitude(String index) {
    final firstTwo = int.parse(index.substring(0, 2));
    final lat = 5 + (firstTwo / 10.0);
    return double.parse(lat.toStringAsFixed(2));
  }

  /// Calculate longitude from index number
  double calculateLongitude(String index) {
    final nextTwo = int.parse(index.substring(2, 4));
    final lon = 79 + (nextTwo / 10.0);
    return double.parse(lon.toStringAsFixed(2));
  }

  /// Validate index number format
  String? validateIndex(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your index number';
    }
    
    // Remove any whitespace
    value = value.trim();
    
    // Check format: 6 digits followed by a letter
    final RegExp indexPattern = RegExp(r'^\d{6}[A-Za-z]$');
    if (!indexPattern.hasMatch(value)) {
      return 'Invalid format. Use: 6 digits + letter (e.g., 224045B)';
    }
    
    return null;
  }

  /// Handle continue button press
  void _handleContinue() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final index = _indexController.text.trim().toUpperCase();
      final latitude = calculateLatitude(index);
      final longitude = calculateLongitude(index);

      // Navigate to weather page
      Future.delayed(const Duration(milliseconds: 500), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => WeatherPage(
              indexNumber: index,
              latitude: latitude,
              longitude: longitude,
            ),
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade200,
              Colors.blue.shade400,
              Colors.blue.shade600,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(30.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 40),
                    
                    // Back button
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Icon
                    const Center(
                      child: Text(
                        '🎓',
                        style: TextStyle(fontSize: 80),
                      ),
                    ),
                    const SizedBox(height: 30),
                    
                    // Title
                    const Text(
                      'Enter Your\nStudent Index',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 15),
                    
                    // Subtitle
                    Text(
                      'We\'ll calculate your personalized\nweather location',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.9),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 50),
                    
                    // Input Card
                    Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(25.0),
                        child: Column(
                          children: [
                            // Index Number Input
                            TextFormField(
                              controller: _indexController,
                              validator: validateIndex,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2,
                              ),
                              textAlign: TextAlign.center,
                              decoration: InputDecoration(
                                labelText: 'Index Number',
                                hintText: 'e.g., 224045B',
                                labelStyle: TextStyle(
                                  color: Colors.blue.shade700,
                                  fontSize: 16,
                                ),
                                hintStyle: TextStyle(
                                  color: Colors.grey.shade400,
                                  letterSpacing: 2,
                                ),
                                prefixIcon: Icon(
                                  Icons.badge,
                                  color: Colors.blue.shade700,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: BorderSide(
                                    color: Colors.blue.shade300,
                                    width: 2,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: BorderSide(
                                    color: Colors.blue.shade300,
                                    width: 2,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: BorderSide(
                                    color: Colors.blue.shade700,
                                    width: 2,
                                  ),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: const BorderSide(
                                    color: Colors.red,
                                    width: 2,
                                  ),
                                ),
                                filled: true,
                                fillColor: Colors.blue.shade50,
                              ),
                            ),
                            const SizedBox(height: 20),
                            
                            // Info text
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    color: Colors.blue.shade700,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      'Format: 6 digits + letter',
                                      style: TextStyle(
                                        color: Colors.blue.shade700,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    
                    // Continue Button
                    ElevatedButton(
                      onPressed: _isLoading ? null : _handleContinue,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.blue.shade700,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 5,
                        disabledBackgroundColor: Colors.grey.shade300,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                              ),
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Continue',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(width: 10),
                                Icon(Icons.arrow_forward, size: 24),
                              ],
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
