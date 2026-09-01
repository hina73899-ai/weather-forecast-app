import 'package:flutter/material.dart';
import 'top_right_notched_badge.dart'; // Apni file path yahan import karein

class AQI extends StatelessWidget {
  const AQI({super.key});

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
          // Reusable Top-Right Curved Badge Call
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
            padding: const EdgeInsets.all(18.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Section Title
                const Text(
                  "AQI – Air Quality Index",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 20),

                // Main Info Row (Avatar/Icon + AQI Value & Status)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: Colors.orange.shade700,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white24, width: 1.5),
                      ),
                      child: const Icon(
                        Icons.face_retouching_natural_rounded,
                        color: Colors.white,
                        size: 38,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                "142",
                                style: TextStyle(
                                  color: Colors.orange.shade600,
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  height: 1.0,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                "AQI (US Standard)",
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          const Row(
                            children: [
                              Text(
                                "Unhealthy for sensitive\ngroups",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  height: 1.2,
                                ),
                              ),
                              SizedBox(width: 4),
                              Icon(
                                Icons.help_outline_rounded,
                                color: Colors.white54,
                                size: 16,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Description Paragraph
                const Text(
                  "Everyone should reduce outdoor exercise. Close your windows to avoid dirty outdoor air. Sensitive groups should wear a mask outdoors. Run an air purifier.",
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: 12.5,
                    height: 1.35,
                  ),
                ),

                const SizedBox(height: 24),

                // Pollutants Row
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _PollutantItem(label: "PM2.5", value: "52", active: true),
                    _PollutantItem(label: "PM10", value: "--"),
                    _PollutantItem(label: "O3", value: "--"),
                    _PollutantItem(label: "NO2", value: "--"),
                    _PollutantItem(label: "SO2", value: "--"),
                    _PollutantItem(label: "CO", value: "--"),
                  ],
                ),

                const SizedBox(height: 24),

                // Bottom Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: _ActionButton(
                        label: "AQI Map",
                        onTap: () {},
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ActionButton(
                        label: "AQI Ranking",
                        onTap: () {},
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
}

// Sub-widget for Pollutants
class _PollutantItem extends StatelessWidget {
  final String label;
  final String value;
  final bool active;

  const _PollutantItem({
    required this.label,
    required this.value,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: 24,
          height: 3,
          decoration: BoxDecoration(
            color: active ? Colors.orange.shade700 : Colors.white24,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: 8),
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

// Sub-widget for Bottom Buttons
class _ActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF009EA9),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        elevation: 0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 6),
          const Icon(Icons.arrow_forward_rounded, size: 16),
        ],
      ),
    );
  }
}