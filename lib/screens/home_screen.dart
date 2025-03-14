import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:weather_app/screens/theme_switch_screen.dart';
import 'package:weather_app/screens/weather_map_screen.dart';
import 'package:weather_app/widgets/additional_info_card.dart';
import 'package:weather_app/widgets/forecast_card.dart';
import 'package:weather_app/widgets/heading.dart';
import 'package:weather_app/widgets/theme_notifier.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  static final List<Widget> _screens = <Widget>[
    const HomeContent(),
    const MapScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
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
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Map',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
      ),
    );
  }
}

class HomeContent extends StatelessWidget {
  const HomeContent({Key? key}) : super(key: key);

  Future<Map<String, dynamic>?> getCurrentWeather() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location service is enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print("Location services are disabled.");
      return null;
    }

    // Check permission status
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print("Location permission denied.");
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      print("Location permission permanently denied. Enable from settings.");
      return null;
    }

    // Get current position
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    String apiUrl =
        "https://api.openweathermap.org/data/2.5/weather?lat=${position.latitude}&lon=${position.longitude}&appid=e49847117c11948f1286dd2f1c1c641c&units=metric";

    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print("Error: ${response.statusCode} - ${response.body}");
      return null;
    }
  }

  Future<Map<String, dynamic>?> getForecastWeather() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      String forecastWeatherApi =
          "https://api.openweathermap.org/data/2.5/forecast?lat=${position.latitude}&lon=${position.longitude}&appid=e49847117c11948f1286dd2f1c1c641c&units=metric";

      final response = await http.get(Uri.parse(forecastWeatherApi));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      print("Error fetching forecast weather: $e");
      return null;
    }
  }

  Image getWeatherIcon(String weatherDescription) {
    if (weatherDescription.toLowerCase().contains("sunny") ||
        weatherDescription.toLowerCase().contains("clear")) {
      return Image.asset('assets/icons/sun.png', width: 50, height: 50);
    } else if (weatherDescription.toLowerCase().contains("Cloud")) {
      return Image.asset('assets/icons/cloud.png', width: 50, height: 50);
    } else if (weatherDescription.toLowerCase().contains("Rain")) {
      return Image.asset('assets/icons/cloudy.png', width: 50, height: 50);
    } else if (weatherDescription.toLowerCase().contains("Snow")) {
      return Image.asset('assets/icons/snow.png', width: 50, height: 50);
    } else if (weatherDescription.toLowerCase().contains("Smoke") ||
        weatherDescription.toLowerCase().contains("Haze") ||
        weatherDescription.toLowerCase().contains("Fog")) {
      return Image.asset('assets/icons/fog.png', width: 50, height: 50);
    } else {
      return Image.asset('assets/icons/wind.png', width: 50, height: 50);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: FutureBuilder<Map<String, dynamic>?>(
        future: getCurrentWeather(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.connectionState == ConnectionState.done &&
              snapshot.hasData) {
            final data = snapshot.data!;
            final String tempInCelsius = data['main']['temp'].toString();
            final double tempInFahrenheit =
                (double.parse(tempInCelsius) * 9 / 5) + 32;

            bool isCelsius =
                Provider.of<ThemeNotifier>(context, listen: false).isCelsius;

            String temperature = isCelsius
                ? "${double.parse(tempInCelsius).toStringAsFixed(1)}°C"
                : "${tempInFahrenheit.toStringAsFixed(1)}°F";

            final String currentCond = data['weather'][0]['description'];
            final String humidity = data['main']['humidity'].toString();
            final String pressure = data['main']['pressure'].toString();
            final String windSpeed = data['wind']['speed'].toString();

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20.0, vertical: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                        elevation: 5.0,
                        child: ClipRRect(
                          borderRadius: const BorderRadius.all(
                            Radius.circular(16.0),
                          ),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10),
                            child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  children: [
                                    Text(
                                      data['name'] ?? "Unknown Location",
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8.0),
                                    Text(
                                      temperature,
                                      style: const TextStyle(
                                        fontSize: 34,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 10.0),
                                    getWeatherIcon(currentCond),
                                    const SizedBox(height: 10.0),
                                    Text(
                                      currentCond,
                                      style: const TextStyle(fontSize: 26),
                                    ),
                                  ],
                                )),
                          ),
                        ),
                      ),
                    ),
                    const Heading(title: "Hourly Forecast"),
                    FutureBuilder<Map<String, dynamic>?>(
                      future: getForecastWeather(),
                      builder: (context, forecastSnapshot) {
                        if (forecastSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        } else if (forecastSnapshot.hasData) {
                          final forecastData = forecastSnapshot.data!;
                          return SizedBox(
                            height: 140.0,
                            width: double.infinity,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: 6,
                              itemBuilder: (context, index) {
                                if (index >= forecastData['list'].length)
                                  return const SizedBox();
                                DateTime forecastDateTime = DateTime.parse(
                                    forecastData['list'][index]['dt_txt']);
                                String forecastTime =
                                    DateFormat('h a').format(forecastDateTime);

                                final String descriptionHourlyForecast =
                                    forecastData['list'][index]['weather'][0]
                                        ['description'];

                                return ForecastCard(
                                  time: forecastTime,
                                  description: descriptionHourlyForecast,
                                  icon:
                                      getWeatherIcon(descriptionHourlyForecast),
                                );
                              },
                            ),
                          );
                        } else {
                          return const Text("No forecast data available.");
                        }
                      },
                    ),
                    const Heading(title: "Additional Information"),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          AdditionalInfoCard(
                              title: "Humidity",
                              icon: Icons.water_drop,
                              value: "$humidity%"),
                          AdditionalInfoCard(
                              title: "Wind",
                              icon: Icons.air,
                              value: "$windSpeed m/s"),
                          AdditionalInfoCard(
                              title: "Pressure",
                              icon: Icons.thermostat,
                              value: "$pressure hPa"),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else {
            return const Center(child: Text("Error Occurred"));
          }
        },
      ),
    );
  }
}
