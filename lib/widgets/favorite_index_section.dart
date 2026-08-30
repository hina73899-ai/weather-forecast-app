import 'package:flutter/material.dart';
import '../models/weather_model.dart';

class FavoriteIndexSection extends StatelessWidget {
  final WeatherModel weather;
  const FavoriteIndexSection({super.key, required this.weather});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF222532),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Stack(
        children: [
          // Curved Edit Badge using Custom Clipper
          Positioned(
            top: 0,
            right: 0,
            child: ClipPath(
              clipper: BadgeClipper(),
              child: Container(
                padding: const EdgeInsets.only(
                  left: 20,
                  right: 16,
                  top: 10,
                  bottom: 10,
                ),
                color: const Color(0xFF2E3244),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Edit ",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Icon(
                      Icons.keyboard_double_arrow_right_rounded,
                      color: Colors.white70,
                      size: 14,
                    ),
                  ],
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Favorite index",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    // Rain Card
                    Expanded(
                      child: _IndexCard(
                        color: const Color(0xFF007AFF),
                        icon: Icons.thunderstorm_outlined,
                        value: "${weather.rainChance}%",
                        label: "Rain",
                      ),
                    ),
                    const SizedBox(width: 10),

                    // UV Card
                    Expanded(
                      child: _IndexCard(
                        color: const Color(0xFFD32F2F),
                        icon: Icons.wb_sunny_outlined,
                        topTag: "UV",
                        value: weather.uvIndex.toStringAsFixed(1),
                        label: _getUvLabel(weather.uvIndex),
                      ),
                    ),
                    const SizedBox(width: 10),

                    // RealFeel Card
                    Expanded(
                      child: _IndexCard(
                        color: const Color(0xFF00838F),
                        icon: Icons.thermostat_outlined,
                        value: "${weather.apparentTemp.round()}°",
                        label: "RealFeel",
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getUvLabel(double uvIndex) {
    if (uvIndex >= 8) return "Very high";
    if (uvIndex >= 6) return "High";
    if (uvIndex >= 3) return "Moderate";
    return "Low";
  }
}

// Custom Clipper for Smooth Figma Inward Curve
class BadgeClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();

    // Start from top-left smooth curve
    path.moveTo(0, 0);
    path.quadraticBezierTo(size.width * 0.25, size.height * 0.6, 0, size.height);
    path.lineTo(size.width - 24, size.height);

    // Bottom-right corner rounding
    path.quadraticBezierTo(size.width, size.height, size.width, size.height - 16);
    path.lineTo(size.width, 24);

    // Top-right corner rounding
    path.quadraticBezierTo(size.width, 0, size.width - 24, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class _IndexCard extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String? topTag;
  final String value;
  final String label;

  const _IndexCard({
    required this.color,
    required this.icon,
    this.topTag,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 95,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(icon, color: Colors.white, size: 22),
                  if (topTag != null) ...[
                    const SizedBox(width: 4),
                    Text(
                      topTag!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ],
              ),
              Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  color: Colors.black26,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_forward,
                  color: Colors.white,
                  size: 10,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    height: 1.0,
                  ),
                ),
              ),
              const SizedBox(height: 3),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}