import 'dart:math';
import 'package:flutter/material.dart';

class FibonacciSpherePage extends StatefulWidget {
  const FibonacciSpherePage({super.key});

  @override
  State<FibonacciSpherePage> createState() => _FibonacciSpherePageState();
}

class _FibonacciSpherePageState extends State<FibonacciSpherePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  double _numPoints = 3000;
  double _speed = 0.25;
  double _wobble = 0.0;
  double _pointSize = 4.0;
  double _trails = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(),
      body: Stack(
        children: [
          // 1. 3D 球体渲染
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                // 核心修复：使用 SizedBox.expand 强制撑满画布
                return SizedBox.expand(
                  child: CustomPaint(
                    painter: SpherePainter(
                      time: _controller.value * 2 * pi,
                      numPoints: _numPoints.toInt(),
                      speed: _speed,
                      wobble: _wobble,
                      basePointSize: _pointSize,
                      trailsStrength: _trails,
                    ),
                  ),
                );
              },
            ),
          ),
          // 3. 底部控制面板
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
              decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.6),
                  // 修复: 使用 withValues
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                      color: Colors.blue.withValues(alpha: 0.3), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 20,
                      spreadRadius: 5,
                    )
                  ]),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildCustomSlider("POINTS", _numPoints, 100, 5000,
                      (v) => setState(() => _numPoints = v),
                      isInt: true),
                  _buildCustomSlider("SPEED", _speed, 0.0, 2.0,
                      (v) => setState(() => _speed = v)),
                  _buildCustomSlider("WOBBLE", _wobble, 0.0, 1.0,
                      (v) => setState(() => _wobble = v)),
                  _buildCustomSlider("SIZE", _pointSize, 1.0, 10.0,
                      (v) => setState(() => _pointSize = v)),
                  _buildCustomSlider("TRAILS", _trails, 0.0, 1.0,
                      (v) => setState(() => _trails = v)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomSlider(String label, double value, double min, double max,
      ValueChanged<double> onChanged,
      {bool isInt = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 11,
                letterSpacing: 0.5,
              ),
            ),
          ),
          Expanded(
            child: SizedBox(
              height: 24,
              child: SliderTheme(
                data: SliderThemeData(
                  trackHeight: 6,
                  activeTrackColor: Colors.white.withValues(alpha: 0.9),
                  inactiveTrackColor:
                      const Color(0xFF5E3A48).withValues(alpha: 0.4),
                  thumbColor: Colors.white,
                  overlayColor: Colors.white.withValues(alpha: 0.1),
                  thumbShape: const CapsuleSliderThumbShape(
                      thumbWidth: 34, thumbHeight: 20),
                  trackShape: const RoundedRectSliderTrackShape(),
                ),
                child: Slider(
                  value: value,
                  min: min,
                  max: max,
                  onChanged: onChanged,
                ),
              ),
            ),
          ),
          SizedBox(
            width: 50,
            child: Text(
              isInt
                  ? value.toInt().toString().replaceAllMapped(
                      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                      (Match m) => '${m[1]},')
                  : value.toStringAsFixed(2),
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: Colors.white,
                fontFamily: "Monospace",
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CapsuleSliderThumbShape extends SliderComponentShape {
  final double thumbWidth;
  final double thumbHeight;

  const CapsuleSliderThumbShape({
    this.thumbWidth = 30.0,
    this.thumbHeight = 18.0,
  });

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size(thumbWidth, thumbHeight);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final Canvas canvas = context.canvas;
    final Paint paint = Paint()
      ..color = sliderTheme.thumbColor ?? Colors.white
      ..style = PaintingStyle.fill;

    final RRect rRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: center, width: thumbWidth, height: thumbHeight),
      const Radius.circular(12),
    );

    final Paint shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

    canvas.drawRRect(rRect.shift(const Offset(0, 2)), shadowPaint);
    canvas.drawRRect(rRect, paint);
  }
}

class SpherePainter extends CustomPainter {
  final double time;
  final int numPoints;
  final double speed;
  final double wobble;
  final double basePointSize;
  final double trailsStrength;

  SpherePainter({
    required this.time,
    required this.numPoints,
    required this.speed,
    required this.wobble,
    required this.basePointSize,
    required this.trailsStrength,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 修复：增加对 size.height 为 0 的保护，虽然外面加了 SizedBox.expand 应该不会发生了
    if (size.height == 0 || size.width == 0) return;

    final center = Offset(size.width / 2, size.height / 3);
    final radius = min(size.width, size.height) * 0.40; // 修复：使用宽高中较小的一个来计算半径
    final double goldenAngle = pi * (3 - sqrt(5));

    double rotationY = time * speed;
    double rotationX = time * speed * 0.3;

    final paint = Paint()..strokeCap = StrokeCap.round;

    for (int i = 0; i < numPoints; i++) {
      double y = 1 - (i / (numPoints - 1)) * 2;
      double radiusAtY = sqrt(1 - y * y);
      double theta = goldenAngle * i;

      double x = cos(theta) * radiusAtY;
      double z = sin(theta) * radiusAtY;

      if (wobble > 0) {
        double offset = sin(time * 5 + y * 4) * wobble * 0.1;
        x += offset;
        z += offset;
      }

      double x1 = x * cos(rotationY) - z * sin(rotationY);
      double z1 = x * sin(rotationY) + z * cos(rotationY);
      double y2 = y * cos(rotationX) - z1 * sin(rotationX);
      double z2 = y * sin(rotationX) + z1 * cos(rotationX);

      double px = x1 * radius;
      double py = y2 * radius;
      double pz = z2 * radius;

      double focalLength = 800.0;
      double perspective = focalLength / (focalLength - pz);

      double screenX = center.dx + px * perspective;
      double screenY = center.dy + py * perspective;

      double alpha = (pz + radius) / (2 * radius);
      alpha = alpha.clamp(0.2, 1.0);

      paint.color = Colors.white.withValues(alpha: alpha); // 修复: 使用 withValues
      double pointSize = basePointSize * perspective;

      if (trailsStrength > 0) {
        double tailLen = trailsStrength * 20 * perspective;
        canvas.drawLine(Offset(screenX, screenY),
            Offset(screenX + tailLen, screenY), paint..strokeWidth = pointSize);
      } else {
        canvas.drawCircle(Offset(screenX, screenY), pointSize, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant SpherePainter oldDelegate) => true;
}
