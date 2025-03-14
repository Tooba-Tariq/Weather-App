import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weather_app/widgets/theme_notifier.dart';

class ThemeSwitchScreen extends StatelessWidget {
  const ThemeSwitchScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
      ),
      body: ListView(
        children: [
          _buildSwitchTile(
            title: "Light Mode",
            value: !themeNotifier.isDarkMode,
            onChanged: (value) {
              if (value) themeNotifier.setTheme(isDarkMode: false);
            },
            icon: Icons.wb_sunny,
            iconColor: Colors.amber, // Bright yellow sun for light mode
          ),
          _buildSwitchTile(
            title: "Dark Mode",
            value: themeNotifier.isDarkMode,
            onChanged: (value) {
              if (value) themeNotifier.setTheme(isDarkMode: true);
            },
            icon: Icons.nights_stay,
            iconColor: Colors.deepPurple, // Night mode purple icon
          ),
          _buildSwitchTile(
            title: "Celsius Temperature",
            value: themeNotifier.isCelsius,
            onChanged: (value) {
              themeNotifier.setTemperature(isCelsius: value);
            },
            icon: Icons.thermostat,
            iconColor: Colors.red, // Thermostat color for Celsius
          ),
          _buildSwitchTile(
            title: "Fahrenheit Temperature",
            value: !themeNotifier.isCelsius,
            onChanged: (value) {
              themeNotifier.setTemperature(isCelsius: !value);
            },
            icon: Icons.thermostat_outlined,
            iconColor: Colors.orangeAccent, // Thermostat variant for Fahrenheit
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required bool value,
    required void Function(bool) onChanged,
    required IconData icon,
    required Color iconColor,
  }) {
    return SwitchListTile(
      title: Row(
        children: [
          Icon(icon, color: iconColor),
          const SizedBox(width: 10),
          Text(title),
        ],
      ),
      value: value,
      onChanged: onChanged,
    );
  }
}
