class WeatherModel {
  final String temperature;
  final String condition;
  final String iconUrl;
  final String humidity;
  final String windSpeed;
  final String uvIndex;

  WeatherModel({
    required this.temperature,
    required this.condition,
    required this.iconUrl,
    required this.humidity,
    required this.windSpeed,
    required this.uvIndex,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    return WeatherModel(
      temperature: json['temp'].toString(),
      condition: json['weather']['description'],
      iconUrl:
          "https://www.weatherbit.io/static/img/icons/${json['weather']['icon']}.png",
      humidity: json['rh'].toString(),
      windSpeed: json['wind_spd'].toString(),
      uvIndex: json['uv'].toString(),
    );
  }
}
