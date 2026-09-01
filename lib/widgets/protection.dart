// =========================================================
// FILE: protection.dart
// =========================================================
import 'package:flutter/material.dart';
import '../services/uv_api_services.dart';

// =========================================================
// MODEL
// =========================================================
class HourlyUV {
  final DateTime time;
  final double uv;

  const HourlyUV({required this.time, required this.uv});
}

class Protection extends StatefulWidget {
  final double latitude;
  final double longitude;

  const Protection({
    super.key,
    required this.latitude,
    required this.longitude,
  });

  @override
  State<Protection> createState() => _ProtectionState();
}

class _ProtectionState extends State<Protection> {
  int? selectedPoint;

  List<HourlyUV>? data;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final result = await UvApiService.fetchHourlyUV(
        latitude: widget.latitude,
        longitude: widget.longitude,
      );
      setState(() {
        data = result;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Could not load UV data. Pull to retry.';
        isLoading = false;
      });
    }
  }

  int get displayIndex => selectedPoint ?? 0;

  void selectPoint(int index) => setState(() => selectedPoint = index);

  String _getUVLevel(double uv) {
    if (uv < 3) return 'Low';
    if (uv < 6) return 'Moderate';
    if (uv < 8) return 'High';
    if (uv < 11) return 'Very high';
    return 'Extreme';
  }

  Color _getUVColor(double uv) {
    if (uv < 3) return const Color(0xFF3DBE5B);
    if (uv < 6) return const Color(0xFFF2B705);
    if (uv < 8) return const Color(0xFFFF681F);
    if (uv < 11) return const Color(0xFFE53935);
    return const Color(0xFF9C27B0);
  }

  String _getUVDescription(double uv) {
    switch (_getUVLevel(uv)) {
      case 'Low':
        return 'Wear sunglasses on bright days. In winter, reflection off snow can nearly double UV exposure.';
      case 'Moderate':
        return 'Stay in shade during midday hours and wear protective clothing when outdoors.';
      case 'High':
        return 'Protection against sunburn is needed.';
      case 'Very high':
        return 'Take extra precautions. Unprotected skin will be damaged and can burn quickly.';
      default:
        return 'Avoid sun exposure between 10 AM and 4 PM. Unprotected skin can burn in minutes.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF2B2D3B),
        borderRadius: BorderRadius.circular(10),
      ),
      child: _buildContent(),
    );
  }

  Widget _buildContent() {
    if (isLoading) {
      return const SizedBox(
        height: 260,
        child: Center(
          child: CircularProgressIndicator(color: Colors.orange, strokeWidth: 2.5),
        ),
      );
    }

    if (errorMessage != null || data == null || data!.isEmpty) {
      return SizedBox(
        height: 260,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off, color: Colors.white38, size: 32),
              const SizedBox(height: 8),
              Text(
                errorMessage ?? 'No UV data available.',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: _loadData,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3A3C4B),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('Retry', style: TextStyle(color: Colors.white, fontSize: 12)),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final list = data!;
    final safeIndex = displayIndex.clamp(0, list.length - 1);
    final currentValue = list[safeIndex].uv;
    final currentColor = _getUVColor(currentValue);
    final currentLevel = _getUVLevel(currentValue);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFF3A3C4B),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Text('☀', style: TextStyle(color: Colors.white, fontSize: 23)),
              ),
            ),
            const SizedBox(width: 8),
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: currentColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                currentValue.toStringAsFixed(1),
                style: const TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              currentLevel,
              style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () => debugPrint('Detail clicked'),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                decoration: BoxDecoration(
                  color: const Color(0xFF3A3C4B),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Detail', style: TextStyle(color: Colors.white70, fontSize: 12)),
                    SizedBox(width: 3),
                    Icon(Icons.chevron_right, color: Colors.white70, size: 16),
                  ],
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            height: 198,
            width: double.infinity,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTapDown: (details) {
                    final width = constraints.maxWidth;
                    final x = details.localPosition.dx;
                    const chartLeft = 10.0;
                    final chartRight = width - 10;
                    final chartWidth = chartRight - chartLeft;

                    double relativeX = (x - chartLeft) / chartWidth;
                    relativeX = relativeX.clamp(0.0, 1.0);

                    final index = (relativeX * (list.length - 1)).round();
                    selectPoint(index);
                  },
                  child: Stack(
                    clipBehavior: Clip.hardEdge,
                    children: [
                      Positioned.fill(
                        child: CustomPaint(
                          painter: UVChartPainter(data: list),
                        ),
                      ),
                      if (selectedPoint != null)
                        Positioned(
                          left: _tooltipX(constraints.maxWidth, safeIndex, list),
                          top: _tooltipY(198, safeIndex, list),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
                            decoration: BoxDecoration(
                              color: _getUVColor(list[safeIndex].uv),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${list[safeIndex].uv.toStringAsFixed(1)} '
                                  '${_getUVLevel(list[safeIndex].uv)}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),

        const SizedBox(height: 10),

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('•', style: TextStyle(color: Colors.white, fontSize: 16)),
            const SizedBox(width: 5),
            Expanded(
              child: Text(
                _getUVDescription(currentValue),
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ),
          ],
        ),

        const SizedBox(height: 22),

        GestureDetector(
          onTap: () => debugPrint('More protection guides clicked'),
          child: const Align(
            alignment: Alignment.centerRight,
            child: Text(
              'More protection guides',
              style: TextStyle(color: Colors.white, fontSize: 12, decoration: TextDecoration.underline),
            ),
          ),
        ),
      ],
    );
  }

  double _getPointX(double width, int index, List<HourlyUV> list) {
    const left = 10.0;
    final right = width - 10;
    final chartWidth = right - left;
    return left + (chartWidth / (list.length - 1)) * index;
  }

  double _getPointY(double height, int index, List<HourlyUV> list) {
    const top = 10.0;
    final bottom = height - 27;
    final chartHeight = bottom - top;
    const maxUV = 10.0;
    return bottom - (list[index].uv / maxUV) * chartHeight;
  }

  double _tooltipX(double width, int index, List<HourlyUV> list) {
    final pointX = _getPointX(width, index, list);
    const tooltipWidth = 68.0;
    double x = pointX - tooltipWidth / 2;
    if (x < 5) x = 5;
    if (x + tooltipWidth > width - 5) x = width - tooltipWidth - 5;
    return x;
  }

  double _tooltipY(double height, int index, List<HourlyUV> list) {
    final pointY = _getPointY(height, index, list);
    double y = pointY - 48;
    if (y < 5) y = 5;
    return y;
  }
}

// =========================================================
// UV CHART PAINTER — monotone cubic interpolation
// (rounded bell-shaped peaks, flat valleys — matches Figma)
// =========================================================
class UVChartPainter extends CustomPainter {
  final List<HourlyUV> data;

  UVChartPainter({required this.data});

  String _formatLabel(DateTime t) {
    final period = t.hour >= 12 ? 'PM' : 'AM';
    int hour12 = t.hour % 12;
    if (hour12 == 0) hour12 = 12;
    return '${hour12.toString().padLeft(2, '0')} $period';
  }

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;

    const left = 10.0;
    final right = width - 10;
    const top = 10.0;
    final bottom = height - 27;
    final chartWidth = right - left;
    final chartHeight = bottom - top;
    const maxUV = 10.0;

    canvas.drawRect(
      Rect.fromLTWH(0, 0, width, height),
      Paint()..color = const Color(0xFF171820),
    );

    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.15)
      ..strokeWidth = 1;

    for (int i = 0; i <= 7; i++) {
      final y = top + (chartHeight / 7) * i;
      canvas.drawLine(Offset(left, y), Offset(right, y), gridPaint);
    }
    for (int i = 0; i <= 6; i++) {
      final x = left + (chartWidth / 6) * i;
      canvas.drawLine(Offset(x, top), Offset(x, bottom), gridPaint);
    }

    final n = data.length;
    if (n < 2) return;

    final xs = List<double>.generate(n, (i) => left + (chartWidth / (n - 1)) * i);
    final ys = List<double>.generate(n, (i) => bottom - (data[i].uv / maxUV) * chartHeight);

    final delta = List<double>.generate(n - 1, (i) => (ys[i + 1] - ys[i]) / (xs[i + 1] - xs[i]));
    final m = List<double>.filled(n, 0);
    m[0] = delta[0];
    m[n - 1] = delta[n - 2];
    for (int i = 1; i < n - 1; i++) {
      if (delta[i - 1] == 0 || delta[i] == 0 || (delta[i - 1] > 0) != (delta[i] > 0)) {
        m[i] = 0;
      } else {
        m[i] = (delta[i - 1] + delta[i]) / 2;
      }
    }

    final path = Path()..moveTo(xs[0], ys[0]);
    for (int i = 0; i < n - 1; i++) {
      final dx = xs[i + 1] - xs[i];
      final cp1x = xs[i] + dx / 3;
      final cp1y = ys[i] + m[i] * dx / 3;
      final cp2x = xs[i + 1] - dx / 3;
      final cp2y = ys[i + 1] - m[i + 1] * dx / 3;
      path.cubicTo(cp1x, cp1y, cp2x, cp2y, xs[i + 1], ys[i + 1]);
    }

    final fillPath = Path.from(path)
      ..lineTo(right, bottom)
      ..lineTo(left, bottom)
      ..close();

    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Colors.orange.withOpacity(0.8),
        Colors.yellow.withOpacity(0.55),
        Colors.green.withOpacity(0.45),
        Colors.green.withOpacity(0.05),
      ],
    );

    canvas.drawPath(
      fillPath,
      Paint()..shader = gradient.createShader(Rect.fromLTWH(left, top, chartWidth, chartHeight)),
    );

    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.orange
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round,
    );

    // 5 evenly spaced labels across the whole window
    final labelIndices = [0, (n - 1) ~/ 4, (n - 1) ~/ 2, (3 * (n - 1)) ~/ 4, n - 1];

    for (final i in labelIndices) {
      final label = _formatLabel(data[i].time);
      final textPainter = TextPainter(
        text: TextSpan(text: label, style: const TextStyle(color: Colors.white, fontSize: 9)),
        textDirection: TextDirection.ltr,
      )..layout();

      textPainter.paint(canvas, Offset(xs[i] - textPainter.width / 2, bottom + 5));
    }
  }

  @override
  bool shouldRepaint(covariant UVChartPainter oldDelegate) {
    return oldDelegate.data != data;
  }
}