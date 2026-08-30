

import 'package:flutter/material.dart';

class MainTemperatureSection extends StatelessWidget {
  final double currentTemp;
  const MainTemperatureSection({required this.currentTemp});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wb_sunny_rounded, color: Colors.amber, size: 75),
            const SizedBox(width: 10),
            Text(
              "${currentTemp.round()}",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 72,
                fontWeight: FontWeight.w300,
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(bottom: 35.0),
              child: Text(
                "°C",
                style: TextStyle(color: Colors.white, fontSize: 28),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
