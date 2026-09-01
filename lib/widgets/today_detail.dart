import 'package:flutter/material.dart';
import 'top_right_notched_badge.dart'; // Apni reusable notch badge file ka path yahan add karein

class TodayDetail extends StatelessWidget {
  const TodayDetail({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: const Color(0xFF292B3A),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Stack(
        children: [
          // Top-Right Curved Badge with Question Mark Icon
          Positioned(
            top: 0,
            right: 0,
            child: TopRightNotchedBadge(
              onTap: () {
                // Action jab question icon tap ho
              },
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white70,
                    width: 1.5,
                  ),
                ),
                child: const Center(
                  child: Text(
                    "?",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Title
                const Text(
                  "Today's detail",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 16),

                // Details Grid
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 2.35,
                  children: const [
                    WeatherDetailItem(
                      icon: Icons.umbrella_outlined,
                      value: '0%',
                      title: 'Chance of rain',
                    ),
                    WeatherDetailItem(
                      icon: Icons.water_drop_outlined,
                      value: '52%',
                      title: 'Humidity',
                    ),
                    WeatherDetailItem(
                      icon: Icons.thermostat_outlined,
                      value: '73°F',
                      title: 'Dew point',
                    ),
                    WeatherDetailItem(
                      icon: Icons.air,
                      value: '9.2 mph',
                      title: 'Wind speed',
                    ),
                    WeatherDetailItem(
                      icon: Icons.cloud_outlined,
                      value: '45%',
                      title: 'Cloud cover',
                    ),
                    WeatherDetailItem(
                      icon: Icons.wb_sunny_outlined,
                      value: '7.4',
                      title: 'UV index',
                    ),
                    WeatherDetailItem(
                      icon: Icons.speed_outlined,
                      value: '1002 hPa',
                      title: 'Pressure',
                    ),
                    WeatherDetailItem(
                      icon: Icons.thunderstorm_outlined,
                      value: '0 in',
                      title: 'Precipitation',
                    ),
                    WeatherDetailItem(
                      icon: Icons.wb_twilight,
                      value: '05:37 AM',
                      title: 'Sunrise',
                    ),
                    WeatherDetailItem(
                      icon: Icons.wb_twilight,
                      value: '06:29 PM',
                      title: 'Sunset',
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
}

class WeatherDetailItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String title;

  const WeatherDetailItem({
    super.key,
    required this.icon,
    required this.value,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF3A3C4B),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.white38,
                width: 1,
              ),
            ),
            child: Icon(
              icon,
              color: Colors.white70,
              size: 19,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white60,
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}