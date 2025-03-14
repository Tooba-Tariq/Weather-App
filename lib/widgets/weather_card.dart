import 'package:flutter/material.dart';

class WeatherCard extends StatelessWidget {
  final Map<String, dynamic> data;

  const WeatherCard({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "${data['temp']}°C",
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            Text(data['weather']['description'],
                style: const TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
