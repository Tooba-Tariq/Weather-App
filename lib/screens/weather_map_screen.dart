import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:weather_app/secrets.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({
    Key? key,
  }) : super(key: key);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  LatLng _currentLocation = LatLng(30.3753, 69.3451); // Default to Pakistan
  String _temperature = "N/A";
  String _locationName = "Fetching...";
  String _weatherIcon = "";
  final TextEditingController _searchController = TextEditingController();
  List<String> _suggestions = [];
  Timer? _debounce;
  bool _showSearchBar = false;

  @override
  void initState() {
    super.initState();
    fetchWeatherAndLocation(
        _currentLocation.latitude, _currentLocation.longitude);
  }

  Future<void> fetchWeatherAndLocation(double lat, double lon) async {
    await fetchWeather(lat, lon);
    await fetchLocationName(lat, lon);
  }

  Future<void> fetchWeather(double lat, double lon) async {
    final weatherResponse = await http.get(
      Uri.parse(
        "https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$API_KEY&units=metric",
      ),
    );
    if (weatherResponse.statusCode == 200) {
      final weatherData = jsonDecode(weatherResponse.body);
      setState(() {
        _temperature = "${weatherData['main']['temp']}°C";
        _weatherIcon =
            "https://openweathermap.org/img/wn/${weatherData['weather'][0]['icon']}@2x.png";
      });
    } else {
      setState(() {
        _temperature = "N/A";
        _weatherIcon = "";
      });
    }
  }

  Future<void> fetchLocationName(double lat, double lon) async {
    final geoResponse = await http.get(
      Uri.parse(
        "https://api.bigdatacloud.net/data/reverse-geocode-client?latitude=$lat&longitude=$lon&localityLanguage=en",
      ),
    );
    if (geoResponse.statusCode == 200) {
      final data = jsonDecode(geoResponse.body);
      setState(() {
        _locationName = data['city'] ?? data['locality'] ?? "Unknown Location";
      });
    } else {
      setState(() {
        _locationName = "Unknown";
      });
    }
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      fetchSuggestions(query);
    });
  }

  Future<void> fetchSuggestions(String query) async {
    if (query.isEmpty) {
      setState(() {
        _suggestions.clear();
      });
      return;
    }

    final url =
        "https://api.locationiq.com/v1/autocomplete.php?key=pk.7b5827497b7c1d36a63309740867db5e&q=$query&limit=5&format=json";

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      setState(() {
        _suggestions =
            data.map<String>((item) => item["display_name"]).toList();
      });
    }
  }

  void _searchLocation(String query) async {
    if (query.isEmpty) return;

    final geoResponse = await http.get(Uri.parse(
        "https://api.locationiq.com/v1/search.php?key=pk.7b5827497b7c1d36a63309740867db5e&q=$query&format=json"));

    if (geoResponse.statusCode == 200) {
      final List<dynamic> data = jsonDecode(geoResponse.body);
      final double lat = double.parse(data[0]["lat"]);
      final double lon = double.parse(data[0]["lon"]);

      setState(() {
        _currentLocation = LatLng(lat, lon);
        _suggestions.clear(); // Clear suggestions
        _showSearchBar = false; // Hide search bar after search
      });

      await fetchWeatherAndLocation(lat, lon);

      setState(() {
        _mapController.move(_currentLocation, 16.0);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Location not found")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          if (_showSearchBar)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: "Search Location",
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () => _searchLocation(_searchController.text),
                  ),
                  border: const OutlineInputBorder(),
                ),
                onSubmitted: _searchLocation,
              ),
            ),
          if (_showSearchBar && _suggestions.isNotEmpty)
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _suggestions.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_suggestions[index]),
                    onTap: () => _searchLocation(_suggestions[index]),
                  );
                },
              ),
            ),
          Expanded(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                center: _currentLocation,
                zoom: 10.0,
                onTap: (_, LatLng latLng) async {
                  setState(() {
                    _currentLocation = latLng;
                  });
                  await fetchWeatherAndLocation(
                      latLng.latitude, latLng.longitude);
                },
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                  subdomains: const ['a', 'b', 'c'],
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _currentLocation,
                      width: 40,
                      height: 40,
                      builder: (ctx) => const Icon(
                        Icons.location_on,
                        color: Colors.red,
                        size: 40,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _showSearchBar = !_showSearchBar;
          });
        },
        child: const Icon(Icons.search),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.blueAccent,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.location_on, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(
                    _locationName,
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
              Row(
                children: [
                  if (_weatherIcon.isNotEmpty)
                    Image.network(
                      _weatherIcon,
                      width: 24,
                      height: 24,
                    ),
                  const SizedBox(width: 8),
                  Text(
                    _temperature,
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
