import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:weather_app/secrets.dart';

import '../models/weather_model.dart';

class WeatherService {
  // Fetch Current Weather Data
  Future<WeatherModel> fetchCurrentWeather(String cityName) async {
    try {
      final response = await http.get(
        Uri.parse(
            "https://api.weatherbit.io/v2.0/current?city=$cityName&key=$API_KEY"),
      );
      final data = jsonDecode(response.body)['data'][0];
      return WeatherModel.fromJson(data);
    } catch (e) {
      throw Exception("Failed to fetch current weather data");
    }
  }

  // Fetch Hourly Forecast
  Future<List<WeatherModel>> fetchHourlyForecast(String cityName) async {
    try {
      final response = await http.get(
        Uri.parse(
            "https://api.weatherbit.io/v2.0/forecast/hourly?city=$cityName&key=$API_KEY&hours=6"),
      );
      final data = jsonDecode(response.body)['data'];
      return List<WeatherModel>.from(
        data.map((item) => WeatherModel.fromJson(item)),
      );
    } catch (e) {
      throw Exception("Failed to fetch hourly weather data");
    }
  }
}
