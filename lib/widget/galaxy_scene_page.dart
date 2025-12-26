import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:vector_math/vector_math_64.dart' show Vector3;

class GalaxyScene extends StatefulWidget {
  const GalaxyScene({super.key});

  @override
  State<GalaxyScene> createState() => _GalaxySceneState();
}

class _GalaxySceneState extends State<GalaxyScene>
    with SingleTickerProviderStateMixin {
  late Ticker _ticker;

  // 维持高粒子数
  static const int starCount = 30000;
  static const int halfCount = starCount ~/ 2;

  final Float32List _posX = Float32List(starCount);
  final Float32List _posY = Float32List(starCount);
  final Float32List _velX = Float32List(starCount);
  final Float32List _velY = Float32List(starCount);

  // --- 核心噪点数据 ---
  final int _coreBlobCount = 45;
  late final List<Offset> _leftLobeOffsets;
  late final List<double> _leftLobeSizes;
  late final List<double> _leftLobePhases;
  late final List<Offset> _rightLobeOffsets;
  late final List<double> _rightLobeSizes;
  late final List<double> _rightLobePhases;
  final List<double> _blackHoleAngles = List.generate(5, (index) => Random().nextDouble() * pi);

  double _barAngle = 0.0;
  double _totalTime = 0.0;

  // --- 循环设置优化 ---
  // 延长周期，让淡入淡出更从容
  final double _cycleDuration = 20.0;

  double _opacityA = 0.0;
  double _opacityB = 0.0;

  final Random _rng = Random();

  @override
  void initState() {
    super.initState();
    _initNoise();
    _initAllParticles();

    _ticker = createTicker((elapsed) {
      _totalTime = elapsed.inMilliseconds / 1000.0;
      _updatePhysics();
      _updateOpacities();
      setState(() {});
    });
    _ticker.start();
  }

  void _initNoise() {
    final random = Random(42);
    _leftLobeOffsets = []; _leftLobeSizes = []; _leftLobePhases = [];
    _rightLobeOffsets = []; _rightLobeSizes = []; _rightLobePhases = [];
    for(int i=0; i<_coreBlobCount; i++) {
      _leftLobeOffsets.add(Offset((random.nextDouble()-0.5)*0.6, (random.nextDouble()-0.5)*0.7));
      _leftLobeSizes.add(0.2 + random.nextDouble() * 0.4);
      _leftLobePhases.add(random.nextDouble() * 2 * pi);
      _rightLobeOffsets.add(Offset((random.nextDouble()-0.5)*0.6, (random.nextDouble()-0.5)*0.7));
      _rightLobeSizes.add(0.2 + random.nextDouble() * 0.4);
      _rightLobePhases.add(random.nextDouble() * 2 * pi);
    }
  }

  void _resetParticleGroup(int start, int end) {
    for (int i = start; i < end; i++) {
      double angle = _rng.nextDouble() * 2 * pi;
      // 初始圆盘分布
      double r = 0.25 + sqrt(_rng.nextDouble()) * 0.75;

      _posX[i] = r * cos(angle);
      _posY[i] = r * sin(angle);

      // 完美的圆周速度
      double v = (0.028 / sqrt(r));
      _velX[i] = -v * sin(angle);
      _velY[i] = v * cos(angle);
    }
  }

  void _initAllParticles() {
    _resetParticleGroup(0, starCount);
  }

  void _updateOpacities() {
    double timeA = _totalTime % _cycleDuration;
    double timeB = (_totalTime + _cycleDuration / 2) % _cycleDuration;

    // --- 关键优化：正弦波缓动曲线 ---
    // 使用 Sine Ease-In-Out 替代线性插值，消除"突兀感"
    // 0s-5s: 极慢速渐入
    // 5s-15s: 保持可见
    // 15s-20s: 极慢速渐出
    double calcOpacity(double t) {
      // Fade In (0 ~ 5s)
      if (t < 5.0) {
        double progress = t / 5.0;
        return 0.5 - 0.5 * cos(progress * pi); // Sine Ease-In
      }
      // Fade Out (15 ~ 20s)
      if (t > 15.0) {
        double progress = (t - 15.0) / 5.0;
        return 0.5 + 0.5 * cos(progress * pi); // Sine Ease-Out
      }
      // Stable
      return 1.0;
    }

    _opacityA = calcOpacity(timeA);
    _opacityB = calcOpacity(timeB);

    // 检测重置点
    // 这里的阈值要很小，确保只触发一次重置
    if (timeA < 0.05) {
      _resetParticleGroup(0, halfCount);
    }
    if (timeB < 0.05) {
      _resetParticleGroup(halfCount, starCount);
    }
  }

  void _updatePhysics() {
    _barAngle += 0.035;
    double cosBar = cos(_barAngle);
    double sinBar = sin(_barAngle);

    const double barMass = 0.0005;
    const double barLength = 0.25;
    const double dt = 0.8;
    const double softening = 0.1;

    for (int i = 0; i < starCount; i++) {
      double x = _posX[i];
      double y = _posY[i];
      double r2 = x * x + y * y;

      if (r2 > 5.0) continue;

      double xRel = x * cosBar + y * sinBar;
      double yRel = -x * sinBar + y * cosBar;

      double centralForce = 0.0003 / (r2 + 0.02);
      double fx = -x * centralForce;
      double fy = -y * centralForce;

      double distToTip1 = sqrt(pow(xRel - barLength, 2) + pow(yRel, 2));
      double distToTip2 = sqrt(pow(xRel + barLength, 2) + pow(yRel, 2));
      double fTip1 = barMass / (distToTip1 * distToTip1 + softening);
      double fTip2 = barMass / (distToTip2 * distToTip2 + softening);

      double fxRelTip1 = -(xRel - barLength) * fTip1;
      double fyRelTip1 = -yRel * fTip1;
      double fxRelTip2 = -(xRel + barLength) * fTip2;
      double fyRelTip2 = -yRel * fTip2;

      double fxTotalRel = fxRelTip1 + fxRelTip2;
      double fyTotalRel = fyRelTip1 + fyRelTip2;

      fx += fxTotalRel * cosBar - fyTotalRel * sinBar;
      fy += fxTotalRel * sinBar + fyTotalRel * cosBar;

      _velX[i] += fx * dt;
      _velY[i] += fy * dt;
      _posX[i] += _velX[i] * dt;
      _posY[i] += _velY[i] * dt;

      _velX[i] *= 0.9995;
      _velY[i] *= 0.9995;
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
      backgroundColor: const Color(0xFF020205),
      body: LayoutBuilder(
        builder: (context, constraints) {
          double size = min(constraints.maxWidth, constraints.maxHeight);
          return Center(
            child: CustomPaint(
              size: Size(size, size),
              painter: GalaxyPainter(
                posX: _posX,
                posY: _posY,
                barAngle: _barAngle,
                starCount: starCount,
                halfCount: halfCount,
                leftLobeOffsets: _leftLobeOffsets,
                leftLobeSizes: _leftLobeSizes,
                leftLobePhases: _leftLobePhases,
                rightLobeOffsets: _rightLobeOffsets,
                rightLobeSizes: _rightLobeSizes,
                rightLobePhases: _rightLobePhases,
                blackHoleAngles: _blackHoleAngles,
                time: _totalTime,
                opacityA: _opacityA,
                opacityB: _opacityB,
              ),
            ),
          );
        },
      ),
    );
  }
}

class GalaxyPainter extends CustomPainter {
  final Float32List posX;
  final Float32List posY;
  final double barAngle;
  final int starCount;
  final int halfCount;

  final List<Offset> leftLobeOffsets;
  final List<double> leftLobeSizes;
  final List<double> leftLobePhases;

  final List<Offset> rightLobeOffsets;
  final List<double> rightLobeSizes;
  final List<double> rightLobePhases;

  final List<double> blackHoleAngles;
  final double time;

  final double opacityA;
  final double opacityB;

  GalaxyPainter({
    required this.posX,
    required this.posY,
    required this.barAngle,
    required this.starCount,
    required this.halfCount,
    required this.leftLobeOffsets,
    required this.leftLobeSizes,
    required this.leftLobePhases,
    required this.rightLobeOffsets,
    required this.rightLobeSizes,
    required this.rightLobePhases,
    required this.blackHoleAngles,
    required this.time,
    required this.opacityA,
    required this.opacityB,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final double scale = size.width / 2 * 0.85;

    _drawActiveCore(canvas, center, scale, barAngle, time);
    _drawStars(canvas, center, scale);
  }

  void _drawActiveCore(
      Canvas canvas, Offset center, double scale, double angle, double t) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angle);

    double coreBaseSize = scale * (0.3 + 0.05 * sin(t * 1.5));

    // A. 光晕
    final Paint bigHaloPaint = Paint()
      ..shader = ui.Gradient.radial(
          Offset.zero,
          coreBaseSize * 2.2,
          [
            const Color(0xFF005533).withValues(alpha:0.15),
            const Color(0xFF884400).withValues(alpha:0.08),
            Colors.black
          ],
          [0.3, 0.6, 1.0],
          TileMode.clamp
      )
      ..blendMode = BlendMode.screen;
    canvas.drawCircle(Offset.zero, coreBaseSize * 2.2, bigHaloPaint);

    // B. 橙色团块
    final List<Color> blobColors = [
      const Color(0xFFFFD050).withValues(alpha:0.55),
      const Color(0xFFFF8000).withValues(alpha:0.25),
      Colors.black
    ];
    final List<double> blobStops = [0.0, 0.5, 1.0];

    Offset getTurbulence(int i, double phase, double t) {
      double speed = 2.0;
      double dx = 0.06 * sin(t * speed + phase) + 0.03 * cos(t * speed * 2.3 + i * 0.1);
      double dy = 0.06 * cos(t * speed * 1.5 + phase) + 0.03 * sin(t * speed * 1.9 + i * 0.1);
      double rotAngle = t * 0.5 * (i % 2 == 0 ? 1 : -1);
      double rx = dx * cos(rotAngle) - dy * sin(rotAngle);
      double ry = dx * sin(rotAngle) + dy * cos(rotAngle);
      return Offset(rx, ry);
    }

    void drawLobes(List<Offset> offsets, List<double> sizes, List<double> phases, int side) {
      Offset baseCenter = Offset(side * coreBaseSize * 0.3, 0);
      for(int i=0; i<offsets.length; i++) {
        Offset baseNoise = offsets[i] * coreBaseSize;
        Offset turbulence = getTurbulence(i, phases[i], t) * coreBaseSize;
        double pulsingSize = sizes[i] * (1.0 + 0.25 * sin(t * 3.0 + phases[i]));
        Offset pos = baseCenter + baseNoise + turbulence;
        double size = coreBaseSize * 0.45 * pulsingSize;

        final Paint blobPaint = Paint()
          ..shader = ui.Gradient.radial(pos, size, blobColors, blobStops, TileMode.clamp)
          ..blendMode = BlendMode.plus;

        canvas.drawCircle(pos, size, blobPaint);
      }
    }

    drawLobes(leftLobeOffsets, leftLobeSizes, leftLobePhases, -1);
    drawLobes(rightLobeOffsets, rightLobeSizes, rightLobePhases, 1);

    // C. 黑洞
    final List<Color> blackHoleColors = [Colors.black, Colors.black.withValues(alpha:0.85), Colors.transparent];
    final List<double> blackHoleStops = [0.0, 0.5, 1.0];

    for (int i = 0; i < blackHoleAngles.length; i++) {
      canvas.save();
      double twist = 0.15 * sin(t * 5.0 + i * 1.5);
      canvas.rotate(blackHoleAngles[i] + twist);
      double stretch = 1.0 + 0.1 * sin(t * 4.0 + i);
      double width = coreBaseSize * (0.15 + i * 0.02) * stretch;
      double height = coreBaseSize * (0.12 + (5 - i) * 0.02) / stretch;

      final Float64List matrixStorage = (Matrix4.identity()..scaleByVector3(Vector3(1.0, height / width, 1.0))).storage;
      final Paint bhPaint = Paint()..shader = ui.Gradient.radial(Offset.zero, width, blackHoleColors, blackHoleStops, TileMode.clamp, matrixStorage);

      canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: width * 1.8, height: height * 1.8), bhPaint);
      canvas.restore();
    }
    canvas.restore();
  }

  void _drawStars(Canvas canvas, Offset center, double scale) {
    //final Float32List points = Float32List(starCount * 2);

    // --- A 组 ---
    if (opacityA > 0.005) {
      int pIndex = 0;
      final Float32List pointsA = Float32List(halfCount * 2);
      for (int i = 0; i < halfCount; i++) {
        pointsA[pIndex++] = center.dx + posX[i] * scale;
        pointsA[pIndex++] = center.dy + posY[i] * scale;
      }
      final Paint starPaintA = Paint()
        ..color = const Color(0xFF20FFFF).withValues(alpha:0.35 * opacityA)
        ..strokeWidth = 1.5
        ..strokeCap = StrokeCap.round
        ..blendMode = BlendMode.plus;
      canvas.drawRawPoints(ui.PointMode.points, pointsA, starPaintA);
    }

    // --- B 组 ---
    if (opacityB > 0.005) {
      int pIndex = 0;
      final Float32List pointsB = Float32List((starCount - halfCount) * 2);
      for (int i = halfCount; i < starCount; i++) {
        pointsB[pIndex++] = center.dx + posX[i] * scale;
        pointsB[pIndex++] = center.dy + posY[i] * scale;
      }
      final Paint starPaintB = Paint()
        ..color = const Color(0xFF20FFFF).withValues(alpha:0.35 * opacityB)
        ..strokeWidth = 1.5
        ..strokeCap = StrokeCap.round
        ..blendMode = BlendMode.plus;
      canvas.drawRawPoints(ui.PointMode.points, pointsB, starPaintB);
    }
  }

  @override
  bool shouldRepaint(covariant GalaxyPainter oldDelegate) {
    return true;
  }
}