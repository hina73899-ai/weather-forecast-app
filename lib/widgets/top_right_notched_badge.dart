import 'package:flutter/material.dart';

class TopRightNotchedBadge extends StatelessWidget {
  final Widget child;
  final Color backgroundColor;
  final VoidCallback? onTap;

  const TopRightNotchedBadge({
    super.key,
    required this.child,
    this.backgroundColor = const Color(0xFF2E3244),
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: BadgeClipper(),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.only(
            left: 32,
            right: 16,
            top: 10,
            bottom: 10,
          ),
          color: backgroundColor,
          child: child,
        ),
      ),
    );
  }
}

// Reusable Figma Inverse-Curved Notch Clipper
class BadgeClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final double w = size.width;
    final double h = size.height;

    const double topConcaveR = 14.0;
    const double bottomR = 14.0;
    const double topRightR = 24.0;

    final path = Path();

    path.moveTo(0, 0);

    // Inward Smooth Curve
    path.quadraticBezierTo(
      topConcaveR, 0,
      topConcaveR, topConcaveR,
    );

    // Straight Line Down
    path.lineTo(topConcaveR, h - bottomR);

    // Outward Smooth Curve
    path.quadraticBezierTo(
      topConcaveR, h,
      topConcaveR + bottomR, h,
    );

    // Bottom line
    path.lineTo(w, h);

    // Right line
    path.lineTo(w, topRightR);

    // Top-right corner matching card container
    path.quadraticBezierTo(
      w, 0,
      w - topRightR, 0,
    );

    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}