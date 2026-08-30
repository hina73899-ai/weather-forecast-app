

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/weather_model.dart';

class DailyForecastGraphSection extends StatelessWidget {
  final DailyWeather daily;
  const DailyForecastGraphSection({required this.daily});

  String _getDayName(String rawDate) {
    try {
      DateTime dt = DateTime.parse(rawDate);
      return DateFormat('E').format(dt);
    } catch (_) {
      return '';
    }
  }

  String _getMonthDate(String rawDate) {
    try {
      DateTime dt = DateTime.parse(rawDate);
      return DateFormat('MMM d').format(dt);
    } catch (_) {
      return rawDate;
    }
  }

  IconData _getWeatherIcon(int code) {
    switch (code) {
      case 0:
        return Icons.wb_sunny_outlined;
      case 1:
      case 2:
      case 3:
        return Icons.cloud_outlined;
      default:
        return Icons.wb_sunny_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final int count = daily.time.length;
    final double itemWidth = 85.0;
    final double totalChartWidth = count * itemWidth;

    List<FlSpot> maxSpots = [];
    List<FlSpot> minSpots = [];

    for (int i = 0; i < count; i++) {
      maxSpots.add(FlSpot(i.toDouble(), daily.maxTemp[i]));
      minSpots.add(FlSpot(i.toDouble(), daily.minTemp[i]));
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        color: const Color(0xFF222532),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Daily",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Row(
                    children: [
                      Text("Detail ", style: TextStyle(color: Colors.white54, fontSize: 13)),
                      Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 12),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: SizedBox(
              width: totalChartWidth,
              child: Column(
                children: [
                  Row(
                    children: List.generate(count, (index) {
                      return SizedBox(
                        width: itemWidth,
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 6),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF323648),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              Text(
                                _getDayName(daily.time[index]),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _getMonthDate(daily.time[index]),
                                style: const TextStyle(
                                  color: Colors.white54,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: List.generate(count, (index) {
                      final code = daily.weatherCode.length > index ? daily.weatherCode[index] : 0;
                      return SizedBox(
                        width: itemWidth,
                        child: Icon(_getWeatherIcon(code), color: Colors.white70, size: 24),
                      );
                    }),
                  ),
                  const SizedBox(height: 10),

                  SizedBox(
                    height: 130,
                    width: totalChartWidth,
                    child: LineChart(
                      LineChartData(
                        gridData: const FlGridData(show: false),
                        titlesData: const FlTitlesData(show: false),
                        borderData: FlBorderData(show: false),
                        minX: 0,
                        maxX: (count - 1).toDouble(),
                        minY: daily.minTemp.reduce((a, b) => a < b ? a : b) - 10,
                        maxY: daily.maxTemp.reduce((a, b) => a > b ? a : b) + 10,
                        betweenBarsData: [
                          BetweenBarsData(
                            fromIndex: 0,
                            toIndex: 1,
                            gradient: LinearGradient(
                              colors: [
                                Colors.orangeAccent.withOpacity(0.4),
                                Colors.orangeAccent.withOpacity(0.05),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          )
                        ],
                        lineBarsData: [
                          LineChartBarData(
                            spots: maxSpots,
                            isCurved: true,
                            color: Colors.orangeAccent,
                            barWidth: 2,
                            dotData: FlDotData(
                              show: true,
                              getDotPainter: (spot, percent, barData, index) =>
                                  FlDotCirclePainter(
                                    radius: 4,
                                    color: Colors.white,
                                    strokeWidth: 2,
                                    strokeColor: Colors.orangeAccent,
                                  ),
                            ),
                          ),
                          LineChartBarData(
                            spots: minSpots,
                            isCurved: true,
                            color: Colors.orange,
                            barWidth: 2,
                            dotData: FlDotData(
                              show: true,
                              getDotPainter: (spot, percent, barData, index) =>
                                  FlDotCirclePainter(
                                    radius: 4,
                                    color: Colors.white,
                                    strokeWidth: 2,
                                    strokeColor: Colors.orange,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  Row(
                    children: List.generate(count, (index) {
                      final max = daily.maxTemp[index].round();
                      final min = daily.minTemp[index].round();
                      return SizedBox(
                        width: itemWidth,
                        child: Column(
                          children: [
                            Text("$max°", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 35),
                            Text("$min°", style: const TextStyle(color: Colors.white70, fontSize: 12)),
                          ],
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 20),

                  Row(
                    children: List.generate(count, (index) {
                      final rain = daily.precipitationMax.length > index ? daily.precipitationMax[index] : 0;
                      return SizedBox(
                        width: itemWidth,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.umbrella, color: Colors.white38, size: 12),
                            const SizedBox(width: 2),
                            Text("$rain%", style: const TextStyle(color: Colors.white54, fontSize: 11)),
                          ],
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: List.generate(count, (index) {
                      return SizedBox(
                        width: itemWidth,
                        child: const Center(
                          child: Text("0 in", style: TextStyle(color: Colors.white38, fontSize: 11)),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00A8B5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                onPressed: () {},
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Show next 30 days",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward, color: Colors.white, size: 18),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
