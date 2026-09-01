import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/weather_model.dart';
import 'top_right_notched_badge.dart'; // Apni reusable notch badge file import karein

class HourlyForecastSection extends StatelessWidget {
  final HourlyWeather hourly;
  const HourlyForecastSection({super.key, required this.hourly});

  String _formatTime(String rawTime) {
    try {
      DateTime dt = DateTime.parse(rawTime);
      return DateFormat('hh:mm').format(dt);
    } catch (_) {
      return rawTime;
    }
  }

  String _getPeriod(String rawTime) {
    try {
      DateTime dt = DateTime.parse(rawTime);
      return DateFormat('a').format(dt);
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final int count = hourly.time.length > 24 ? 24 : hourly.time.length;
    const double itemWidth = 85.0;
    final double totalWidth = count * itemWidth;

    List<FlSpot> spots = [];
    for (int i = 0; i < count; i++) {
      spots.add(FlSpot(i.toDouble(), hourly.temperature[i]));
    }

    double minTemp = hourly.temperature.reduce((a, b) => a < b ? a : b);
    double maxTemp = hourly.temperature.reduce((a, b) => a > b ? a : b);

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: const Color(0xFF222532),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Stack(
        children: [
          // Reusable Top-Right Notched Badge
          Positioned(
            top: 0,
            right: 0,
            child: TopRightNotchedBadge(
              onTap: () {
                // Action for Detail click
              },
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Detail",
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
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Title
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    "Hourly",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Scrollable Chart Content
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: SizedBox(
                    width: totalWidth,
                    child: Column(
                      children: [
                        // Time Cards Row
                        Row(
                          children: List.generate(count, (index) {
                            return SizedBox(
                              width: itemWidth,
                              child: Center(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF323648),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.white12),
                                  ),
                                  child: RichText(
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                          text: _formatTime(hourly.time[index]),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        TextSpan(
                                          text:
                                          " ${_getPeriod(hourly.time[index])}",
                                          style: const TextStyle(
                                            color: Colors.white54,
                                            fontSize: 9,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                        const SizedBox(height: 16),

                        // Weather Icons Row
                        Row(
                          children: List.generate(count, (index) {
                            return const SizedBox(
                              width: itemWidth,
                              child: Icon(
                                Icons.wb_sunny_outlined,
                                color: Colors.white,
                                size: 24,
                              ),
                            );
                          }),
                        ),
                        const SizedBox(height: 12),

                        // Temperature Values Row
                        Row(
                          children: List.generate(count, (index) {
                            final temp = hourly.temperature[index].round();
                            return SizedBox(
                              width: itemWidth,
                              child: Center(
                                child: Text(
                                  "$temp°",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                        const SizedBox(height: 4),

                        // Area Line Chart
                        SizedBox(
                          height: 80,
                          width: totalWidth,
                          child: LineChart(
                            LineChartData(
                              gridData: const FlGridData(show: false),
                              titlesData: const FlTitlesData(show: false),
                              borderData: FlBorderData(show: false),
                              minX: 0,
                              maxX: (count - 1).toDouble(),
                              minY: minTemp - 5,
                              maxY: maxTemp + 5,
                              lineBarsData: [
                                LineChartBarData(
                                  spots: spots,
                                  isCurved: true,
                                  color: Colors.orangeAccent,
                                  barWidth: 2,
                                  belowBarData: BarAreaData(
                                    show: true,
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.orangeAccent.withOpacity(0.35),
                                        Colors.orangeAccent.withOpacity(0.0),
                                      ],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    ),
                                  ),
                                  dotData: FlDotData(
                                    show: true,
                                    getDotPainter:
                                        (spot, percent, barData, index) =>
                                        FlDotCirclePainter(
                                          radius: 4,
                                          color: Colors.orangeAccent,
                                          strokeWidth: 2,
                                          strokeColor: Colors.white,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Rain Percentage Row
                        Row(
                          children: List.generate(count, (index) {
                            final rain = hourly.precipitation.length > index
                                ? hourly.precipitation[index]
                                : 0;
                            return SizedBox(
                              width: itemWidth,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.umbrella_outlined,
                                      color: Colors.white54, size: 14),
                                  const SizedBox(width: 4),
                                  Text(
                                    "$rain%",
                                    style: const TextStyle(
                                        color: Colors.white70, fontSize: 12),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ),
                        const SizedBox(height: 20),

                        // Rain Amount Row
                        Row(
                          children: List.generate(count, (index) {
                            return const SizedBox(
                              width: itemWidth,
                              child: Center(
                                child: Text(
                                  "0 in",
                                  style: TextStyle(
                                    color: Colors.white54,
                                    fontSize: 12,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),
                const Divider(color: Colors.white12, thickness: 1),
                const SizedBox(height: 8),

                // Bottom Legend Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.umbrella_outlined,
                              color: Colors.white54, size: 16),
                          SizedBox(width: 4),
                          Text("Chance of rain",
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 13)),
                          SizedBox(width: 16),
                          Text("|", style: TextStyle(color: Colors.white24)),
                          SizedBox(width: 16),
                          Icon(Icons.ac_unit, color: Colors.white54, size: 16),
                          SizedBox(width: 4),
                          Text("Chance of snow",
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 13)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 18,
                            height: 4,
                            decoration: const BoxDecoration(
                              color: Color(0xFF00D2E0),
                              borderRadius:
                              BorderRadius.all(Radius.circular(2)),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text("Rain amount (in)",
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 13)),
                        ],
                      ),
                    ],
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