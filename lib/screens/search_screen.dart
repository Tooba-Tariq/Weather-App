import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:weather_app/screens/theme_switch_screen.dart';

void main() {
  runApp(const SearchScreen());
}

class SearchScreen extends StatelessWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const WeatherScreen(),
    );
  }
}

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({Key? key}) : super(key: key);

  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  double? temperature;
  int? high;
  int? low;
  String location = "Fetching location...";
  String weatherCondition = "";
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchWeatherByLocation();
  }

  Future<void> fetchWeather(String city) async {
    final String apiUrl =
        'https://api.openweathermap.org/data/2.5/weather?q=$city&appid=e49847117c11948f1286dd2f1c1c641c&units=metric';

    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        temperature = data['main']['temp'].toDouble();
        high = data['main']['temp_max'].toInt();
        low = data['main']['temp_min'].toInt();
        location = data['name'];
        weatherCondition = data['weather'][0]['description'];
      });
    } else {
      throw Exception('Failed to load weather data');
    }
  }

  Future<void> fetchWeatherByLocation() async {
    Position position = await _determinePosition();
    final String apiUrl =
        'https://api.openweathermap.org/data/2.5/weather?lat=${position.latitude}&lon=${position.longitude}&appid=e49847117c11948f1286dd2f1c1c641c&units=metric';

    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        temperature = data['main']['temp'].toDouble();
        high = data['main']['temp_max'].toInt();
        low = data['main']['temp_min'].toInt();
        location = data['name'];
        weatherCondition = data['weather'][0]['description'];
      });
    } else {
      throw Exception('Failed to load weather data');
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied');
    }

    return await Geolocator.getCurrentPosition();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Weather App"),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ThemeSwitchScreen(),
                ),
              );
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search for a city or airport',
                filled: true,
                fillColor: Colors.grey[300],
                prefixIcon: const Icon(Icons.search, color: Colors.black54),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: (value) {
                if (value.isNotEmpty) {
                  fetchWeather(value);
                }
              },
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: [
                  WeatherCard(
                    location: location,
                    address: "Current Location",
                    temp: temperature?.toInt() ?? 0,
                    high: high ?? 0,
                    low: low ?? 0,
                    condition: weatherCondition,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WeatherCard extends StatelessWidget {
  final String location;
  final String address;
  final int temp;
  final int high;
  final int low;
  final String condition;

  const WeatherCard({
    required this.location,
    required this.address,
    required this.temp,
    required this.high,
    required this.low,
    required this.condition,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.blue[100],
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(location,
                    style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black)),
                const SizedBox(height: 4),
                Text(address,
                    style:
                        const TextStyle(fontSize: 16, color: Colors.black54)),
                const SizedBox(height: 4),
                Text(condition,
                    style: const TextStyle(fontSize: 16, color: Colors.black)),
              ],
            ),
            Column(
              children: [
                Text('$temp°',
                    style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.black)),
                Text('H:$high° L:$low°',
                    style:
                        const TextStyle(fontSize: 14, color: Colors.black54)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
