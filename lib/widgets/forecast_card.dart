import 'package:flutter/material.dart';

class ForecastCard extends StatelessWidget {
  final String time;
  final String description;
  final Widget icon;

  const ForecastCard({
    Key? key,
    required this.time,
    required this.description,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            Text(time, style: const TextStyle(fontSize: 18)),
            icon,
            Text(description, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
