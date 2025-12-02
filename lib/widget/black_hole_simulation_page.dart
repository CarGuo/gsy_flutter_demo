import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class BlackHoleSimulation extends StatefulWidget {
  const BlackHoleSimulation({super.key});

  @override
  State<BlackHoleSimulation> createState() => _BlackHoleSimulationState();
}

class _BlackHoleSimulationState extends State<BlackHoleSimulation>
    with SingleTickerProviderStateMixin {
  late Ticker _ticker;
  final List<BHParticle> _particles = [];
  double _time = 0.0;

  // --- 参数配置 ---
  final int _count = 12000; // 保持 12000 粒子
  final double _rs = 65.0;
  final double _diskMinRatio = 1.6;
  final double _diskMaxRatio = 7.0;
  final double _tilt = pi / 2.3;

  // ----------------

  @override
  void initState() {
    super.initState();
    _initParticles();
    _ticker = createTicker((elapsed) {
      _time = elapsed.inMilliseconds / 1000.0;
      _update(_time);
      setState(() {});
    });
    _ticker.start();
  }

  void _initParticles() {
    final rng = Random();
    for (int i = 0; i < _count; i++) {
      double rNorm = pow(rng.nextDouble(), 2.0).toDouble();
      double r = _rs * _diskMinRatio +
          rNorm * (_rs * _diskMaxRatio - _rs * _diskMinRatio);

      _particles.add(BHParticle(
        r: r,
        theta: rng.nextDouble() * 2 * pi,
        size: (1.0 - rNorm) * 2.0 + 1.0 + rng.nextDouble(),
        speedFactor: 0.8 + rng.nextDouble() * 0.4,
      ));
    }
  }

  void _update(double t) {
    for (var p in _particles) {
      // [修改] 速度基数从 12000 大幅提升至 30000
      // 现在的流动会非常迅速，极具动感
      double speed = 30000.0 / pow(p.r, 1.5);

      p.theta -= speed * 0.0008 * p.speedFactor;
      p.theta %= (2 * pi);
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: RepaintBoundary(
        child: CustomPaint(
          painter: InterstellarPainter(
            particles: _particles,
            rs: _rs,
            tilt: _tilt,
            diskMinRatio: _diskMinRatio,
            diskMaxRatio: _diskMaxRatio,
            time: _time,
          ),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class BHParticle {
  double r;
  double theta;
  double size;
  double speedFactor;

  BHParticle(
      {required this.r,
      required this.theta,
      required this.size,
      required this.speedFactor});
}

class InterstellarPainter extends CustomPainter {
  final List<BHParticle> particles;
  final double rs;
  final double tilt;
  final double diskMinRatio;
  final double diskMaxRatio;
  final double time;

  InterstellarPainter({
    required this.particles,
    required this.rs,
    required this.tilt,
    required this.diskMinRatio,
    required this.diskMaxRatio,
    required this.time,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // 背景纯黑
    canvas.drawColor(Colors.black, BlendMode.src);

    final paint = Paint()..blendMode = BlendMode.plus;

    List<BHParticle> backParticles = [];
    List<BHParticle> frontParticles = [];

    for (var p in particles) {
      if (sin(p.theta) < 0) {
        backParticles.add(p);
      } else {
        frontParticles.add(p);
      }
    }

    // 1. 绘制背面粒子
    for (var p in backParticles) {
      _drawLensedParticle(canvas, center, p, paint, lensMode: LensMode.top);
      if (p.r < rs * 5.0) {
        _drawLensedParticle(canvas, center, p, paint,
            lensMode: LensMode.bottom);
      }
    }

    // --- 绘制动态黑洞本体 ---
    double shadowRadius = rs * 1.5;

    // 2. 核心黑洞 (纯黑遮罩，无光边)
    Path corePath = _createDistortedPath(
        center,
        shadowRadius * 0.88,
        time,
        120, // 采样点
        1.0, // 扭动幅度
        1.5);
    canvas.drawPath(corePath, Paint()..color = Colors.black);

    // --- 3. 绘制前面粒子 ---
    for (var p in frontParticles) {
      _drawLensedParticle(canvas, center, p, paint, lensMode: LensMode.none);
    }
  }

  // 连续扭曲路径生成
  Path _createDistortedPath(Offset center, double radius, double time,
      int items, double amplitude, double waveSpeed) {
    Path path = Path();
    path.reset();
    for (int i = 0; i <= items; i++) {
      double angle = (i / items) * 2 * pi;

      double distortion = sin(angle * 3 + time * waveSpeed) * amplitude +
          cos(angle * 5 - time * waveSpeed * 0.7) * (amplitude * 0.3);

      double r = radius + distortion;
      double x = center.dx + r * cos(angle);
      double y = center.dy + r * sin(angle);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    return path;
  }

  void _drawLensedParticle(
      Canvas canvas, Offset center, BHParticle p, Paint paint,
      {required LensMode lensMode}) {
    double x3d = p.r * cos(p.theta);
    double y3d = p.r * sin(p.theta);
    double yProj = y3d * cos(tilt);
    double finalX = x3d;
    double finalY = yProj;

    if (lensMode != LensMode.none) {
      double orbitFactor =
          (p.r - rs * diskMinRatio) / (rs * (diskMaxRatio - diskMinRatio));
      double minArchH = rs * 1.4;
      double maxArchH = rs * 3.5;
      double currentArchHeight = minArchH + (maxArchH - minArchH) * orbitFactor;
      double currentArchWidth = currentArchHeight * 1.6;

      if (finalX.abs() < currentArchWidth) {
        double normalizedX = finalX / currentArchWidth;
        double shapeCurve =
            pow(1.0 - normalizedX * normalizedX, 2.0).toDouble();

        double bentY;
        if (lensMode == LensMode.top) {
          bentY = -currentArchHeight * shapeCurve * 0.9;
        } else {
          bentY = (currentArchHeight * 0.55) * shapeCurve + rs * 0.2;
        }

        double mix = pow(shapeCurve, 0.5).toDouble();
        finalY = lerpDouble(yProj, bentY, mix)!;

        if (lensMode == LensMode.bottom) finalY += 2.0;
        if (lensMode == LensMode.top) finalY -= 2.0;
      }
    }

    double rNorm =
        (p.r - rs * diskMinRatio) / (rs * (diskMaxRatio - diskMinRatio));
    Color baseColor;
    if (rNorm < 0.15) {
      baseColor = Colors.white;
    } else if (rNorm < 0.4) {
      baseColor =
          Color.lerp(Colors.cyanAccent, Colors.amber, (rNorm - 0.15) / 0.25)!;
    } else {
      baseColor = Color.lerp(
          Colors.amber, Colors.deepOrange.shade900, (rNorm - 0.4) / 0.6)!;
    }

    double doppler = -finalX / (rs * diskMaxRatio * 1.0);
    double alpha = 0.5;

    if (lensMode == LensMode.bottom) alpha *= 0.85;

    if (doppler > 0) {
      alpha += doppler * 0.55;
      baseColor = Color.lerp(baseColor, Colors.white, doppler * 0.6)!;
    } else {
      alpha += doppler * 0.35;
      baseColor = Color.lerp(baseColor, Colors.black, doppler.abs() * 0.5)!;
    }

    paint.color = baseColor.withValues(alpha: alpha.clamp(0.0, 1.0));

    canvas.drawCircle(
      center + Offset(finalX, finalY),
      p.size,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant InterstellarPainter oldDelegate) => true;
}

enum LensMode { none, top, bottom }
