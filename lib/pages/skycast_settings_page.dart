import 'package:flutter/material.dart';

class SkyCastSettingsPage extends StatefulWidget {
  const SkyCastSettingsPage({Key? key}) : super(key: key);

  @override
  State<SkyCastSettingsPage> createState() => _SkyCastSettingsPageState();
}

class _SkyCastSettingsPageState extends State<SkyCastSettingsPage> {
  bool _darkMode = false;
  bool _celsius = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Settings', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text('Preferences', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildSwitch(Icons.dark_mode, 'Theme', 'Dark Mode', _darkMode, (val) => setState(() => _darkMode = val)),
            _buildSwitch(Icons.thermostat, 'Temperature Unit', 'Celsius (Â°C)', _celsius, (val) => setState(() => _celsius = val)),
            ListTile(
              leading: const Icon(Icons.location_on),
              title: const Text('Manage Saved Locations'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.pushNamed(context, '/saved-locations');
              },
            ),
            const SizedBox(height: 32),
            const Text('About SkyCast', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildInfoTile('Version', '1.0.0'),
            _buildInfoTile('Build', '20240320'),
            ListTile(
              leading: const Icon(Icons.privacy_tip),
              title: const Text('Privacy Policy'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            ),
            ListTile(
              leading: const Icon(Icons.description),
              title: const Text('Terms of Service'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            ),
            ListTile(
              leading: const Icon(Icons.feedback),
              title: const Text('Send Feedback'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitch(IconData icon, String title, String subtitle, bool value, Function(bool) onChanged) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: Colors.blue.shade400,
      ),
    );
  }

  Widget _buildInfoTile(String label, String value) {
    return ListTile(
      title: Text(label),
      trailing: Text(value, style: TextStyle(color: Colors.grey.shade600)),
    );
  }
}
