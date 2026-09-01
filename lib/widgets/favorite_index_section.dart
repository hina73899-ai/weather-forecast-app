import 'package:flutter/material.dart';
import '../models/weather_model.dart';
import 'favorite_index_edit_screen.dart';
import 'top_right_notched_badge.dart'; // Apna path adjust kar lein

class FavoriteIndexSection extends StatelessWidget {
  final WeatherModel weather;
  const FavoriteIndexSection({super.key, required this.weather});

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: const Color(0xFF222532),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Stack(
        children: [
          // Reusable Notch Badge Usage
          Positioned(
            top: 0,
            right: 0,
            child: TopRightNotchedBadge(
              onTap: () async {
                final updatedIds = await Navigator.push<List<String>>(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FavoriteIndexEditScreen(),
                  ),
                );
                if (updatedIds != null) {
                  // State update call karein
                }
              },
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Edit",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(width: 2),
                  Icon(
                    Icons.keyboard_double_arrow_right_rounded,
                    color: Colors.white70,
                    size: 14,
                  ),
                ],
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
                    Expanded(
                      child: _IndexCard(
                        color: const Color(0xFF007AFF),
                        icon: Icons.thunderstorm_outlined,
                        value: "${weather.rainChance}%",
                        label: "Rain",
                      ),
                    ),
                    const SizedBox(width: 10),
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