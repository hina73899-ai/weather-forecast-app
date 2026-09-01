import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/weather_model.dart';
import 'top_right_notched_badge.dart'; // Adjust import path as needed

class MoonPhaseSection extends StatelessWidget {
  final DailyWeather daily;
  const MoonPhaseSection({super.key, required this.daily});

  String _getDayName(String rawDate) {
    try {
      DateTime dt = DateTime.parse(rawDate);
      return DateFormat('E').format(dt);
    } catch (_) {
      return '';
    }
  }

  String _getDayNum(String rawDate) {
    try {
      DateTime dt = DateTime.parse(rawDate);
      return DateFormat('d').format(dt);
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final int count = daily.time.length;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: const Color(0xFF222532),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Stack(
        children: [
          // Top-Right Curved Badge Call
          Positioned(
            top: 0,
            right: 0,
            child: TopRightNotchedBadge(
              onTap: () {
                // Action for Detail tap
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
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Title
                const Text(
                  "Moon phase",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // Moon Title & Time
                const Text(
                  "Full Moon",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  "Aug 27, 2026 - 01:01 PM",
                  style: TextStyle(color: Colors.white54, fontSize: 13),
                ),
                const SizedBox(height: 16),

                // Info Grid & Custom Canvas Moon
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _MoonInfoRow(label: "Illumination:", value: "100%"),
                          SizedBox(height: 6),
                          _MoonInfoRow(label: "Moon rise:", value: "06:37 PM"),
                          SizedBox(height: 6),
                          _MoonInfoRow(label: "Moon set:", value: "05:31 AM"),
                          SizedBox(height: 6),
                          _MoonInfoRow(label: "Next new moon:", value: "14 days"),
                          SizedBox(height: 6),
                          _MoonInfoRow(label: "Next full moon:", value: "29 days"),
                        ],
                      ),
                    ),

                    // Realistic Custom Painted Full Moon
                    CustomPaint(
                      size: const Size(100, 100),
                      painter: RealisticMoonPainter(phaseRatio: 1.0),
                    ),
                  ],
                ),

                const SizedBox(height: 20),
                const Divider(color: Colors.white12, thickness: 1),
                const SizedBox(height: 12),

                // Horizontal List with Custom Moon Renderers
                SizedBox(
                  height: 110,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemCount: count,
                    itemBuilder: (context, index) {
                      final isFull = index == 0;
                      final phase = isFull ? 1.0 : 0.85;

                      return Container(
                        width: 65,
                        margin: const EdgeInsets.only(right: 8),
                        child: Column(
                          children: [
                            Text(
                              _getDayName(daily.time[index]),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _getDayNum(daily.time[index]),
                              style: const TextStyle(color: Colors.white54, fontSize: 12),
                            ),
                            const SizedBox(height: 8),

                            // Realistic Miniature Moon Widget
                            CustomPaint(
                              size: const Size(28, 28),
                              painter: RealisticMoonPainter(phaseRatio: phase),
                            ),

                            const SizedBox(height: 6),
                            Text(
                              isFull ? "Full Moon" : "Waning gibbous",
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
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

class RealisticMoonPainter extends CustomPainter {
  final double phaseRatio;

  RealisticMoonPainter({this.phaseRatio = 1.0});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // 1. Soft Outer Atmosphere Glow
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white.withOpacity(0.35),
          Colors.white.withOpacity(0.0),
        ],
        stops: const [0.7, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius * 1.25));

    canvas.drawCircle(center, radius * 1.25, glowPaint);

    // 2. Base Sphere Texture Gradient
    final moonBasePaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.3, -0.3),
        colors: const [
          Color(0xFFFFFFFF),
          Color(0xFFE2E4EA),
          Color(0xFFB0B5C3),
          Color(0xFF717788),
        ],
        stops: const [0.0, 0.4, 0.8, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawCircle(center, radius, moonBasePaint);

    // 3. Crater/Surface Details
    final craterPaint = Paint()
      ..color = const Color(0xFF535866).withOpacity(0.25)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(center.dx - radius * 0.25, center.dy - radius * 0.2), radius * 0.18, craterPaint);
    canvas.drawCircle(Offset(center.dx + radius * 0.2, center.dy - radius * 0.3), radius * 0.14, craterPaint);
    canvas.drawCircle(Offset(center.dx + radius * 0.1, center.dy + radius * 0.25), radius * 0.22, craterPaint);
    canvas.drawCircle(Offset(center.dx - radius * 0.35, center.dy + radius * 0.15), radius * 0.12, craterPaint);
    canvas.drawCircle(Offset(center.dx - radius * 0.05, center.dy - radius * 0.05), radius * 0.28, craterPaint);

    // 4. Moon Phase Shadowing
    if (phaseRatio < 1.0) {
      final shadowPaint = Paint()
        ..color = const Color(0xFF191B26).withOpacity(0.85)
        ..style = PaintingStyle.fill;

      Path shadowPath = Path();
      shadowPath.addOval(Rect.fromCircle(center: center, radius: radius));

      Path shadowCut = Path();
      double shadowOffset = (1.0 - phaseRatio) * (radius * 2);
      shadowCut.addOval(Rect.fromLTWH(
        center.dx - radius + shadowOffset,
        center.dy - radius,
        radius * 2,
        radius * 2,
      ));

      Path finalShadow = Path.combine(PathOperation.difference, shadowPath, shadowCut);
      canvas.drawPath(finalShadow, shadowPaint);
    }
  }

  @override
  bool shouldRepaint(covariant RealisticMoonPainter oldDelegate) {
    return oldDelegate.phaseRatio != phaseRatio;
  }
}

class _MoonInfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _MoonInfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white60, fontSize: 13),
        ),
        const SizedBox(width: 6),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}