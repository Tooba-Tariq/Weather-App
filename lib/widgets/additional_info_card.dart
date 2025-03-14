import 'package:flutter/material.dart';

class AdditionalInfoCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final String value;

  const AdditionalInfoCard({
    Key? key,
    required this.title,
    required this.icon,
    required this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Text(title, style: const TextStyle(fontSize: 20)),
            Icon(icon, size: 28),
            Text(value, style: const TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
