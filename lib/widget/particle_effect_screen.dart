import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';

class ParticleEffectScreen extends StatefulWidget {
  const ParticleEffectScreen({super.key});

  @override
  State<ParticleEffectScreen> createState() => _ParticleEffectScreenState();
}

class _ParticleEffectScreenState extends State<ParticleEffectScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  List<_Particle> floorParticles = [];
  List<_Particle> beamParticles = [];
  List<_Particle> snowParticles = [];
  List<_Particle> bgParticles = [];

  final int snowCount = 5000;
  bool _isCyberpunk = false;

  @override
  void initState() {
    super.initState();
    _initParticles();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  void _initParticles() {
    final rnd = Random();

    // 1. 地面同心圆
    // 【修改】减小间距，增加密度，让波浪线条更密集，更容易看清起伏
    const double maxRadius = 900.0;
    const double ringGap = 14.0; // 间距更密 (16 -> 14)
    for (double r = 40.0; r < maxRadius; r += ringGap) {
      double circumference = 2 * pi * r;
      // 粒子密度
      int pointCount = (circumference / 5.0).floor();
      for (int i = 0; i < pointCount; i++) {
        floorParticles.add(_Particle(
          baseRadius: r,
          baseAngle: (i / pointCount) * 2 * pi,
          type: _ParticleType.floor,
        ));
      }
    }

    // 2. 光柱
    for (int i = 0; i < 2000; i++) {
      beamParticles.add(_Particle(
        x: (rnd.nextDouble() - 0.5) * 6.0,
        y: -rnd.nextDouble() * 1200,
        z: (rnd.nextDouble() - 0.5) * 6.0,
        speed: 30.0 + rnd.nextDouble() * 20.0,
        type: _ParticleType.beam,
      ));
    }

    // 3. 喷泉粒子
    for (int i = 0; i < snowCount; i++) {
      snowParticles.add(_createFountainParticle(rnd, true));
    }

    // 4. 背景
    for (int i = 0; i < 400; i++) {
      bgParticles.add(_Particle(
        x: (rnd.nextDouble() - 0.5) * 2000,
        y: -rnd.nextDouble() * 1500,
        z: (rnd.nextDouble() - 0.5) * 1000,
        speed: 0.5 + rnd.nextDouble(),
        type: _ParticleType.bg,
      ));
    }
  }

  _Particle _createFountainParticle(Random rnd, bool initRandom) {
    double initialRadius = rnd.nextDouble() * 10.0;
    double initialAngle = rnd.nextDouble() * 2 * pi;

    double startY = 0;
    double startVy = 0;
    double baseVy = -25.0 - rnd.nextDouble() * 20.0;

    if (initRandom) {
      startY = -rnd.nextDouble() * 1000;
      startVy = baseVy + rnd.nextDouble() * 20;
    } else {
      startVy = baseVy;
    }

    return _Particle(
      baseRadius: initialRadius,
      baseAngle: initialAngle,
      y: startY,
      vy: startVy,
      radialSpeed: 2.0 + rnd.nextDouble() * 3.5,
      angularSpeed: (0.05 + rnd.nextDouble() * 0.1) * (rnd.nextBool() ? 1 : -1),
      turbulence: rnd.nextDouble(),
      type: _ParticleType.snow,
      life: 1.0,
      decay: 0.0,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = _isCyberpunk ? const Color(0xFF02040A) : Colors.black;
    final btnColor = _isCyberpunk ? const Color(0xFF00FFFF) : Colors.white;

    return Scaffold(
      appBar: AppBar(),
      backgroundColor: bgColor,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          setState(() {
            _isCyberpunk = !_isCyberpunk;
          });
        },
        backgroundColor: btnColor,
        foregroundColor: Colors.black,
        icon: Icon(_isCyberpunk ? Icons.radar : Icons.filter_drama),
        label: Text(
          _isCyberpunk ? "MODE: CYBER" : "MODE: NORMAL",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: _ParticlePainter(
              floorParticles: floorParticles,
              beamParticles: beamParticles,
              snowParticles: snowParticles,
              bgParticles: bgParticles,
              time: _controller.value,
              random: Random(),
              resetSnowParticle: _createFountainParticle,
              isCyberpunk: _isCyberpunk,
            ),
            size: Size.infinite,
          );
        },
      ),
    );
  }
}

enum _ParticleType { floor, beam, snow, bg }

class _Particle {
  double x, y, z;
  double baseRadius;
  double baseAngle;
  double vy;
  double radialSpeed;
  double angularSpeed;
  double turbulence;
  double speed;
  double life;
  double decay;
  _ParticleType type;

  _Particle({
    this.x = 0, this.y = 0, this.z = 0,
    this.baseRadius = 0, this.baseAngle = 0,
    this.vy = 0,
    this.radialSpeed = 0,
    this.angularSpeed = 0,
    this.turbulence = 0,
    this.speed = 0,
    this.life = 1.0,
    this.decay = 0.0,
    required this.type,
  });
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> floorParticles;
  final List<_Particle> beamParticles;
  final List<_Particle> snowParticles;
  final List<_Particle> bgParticles;
  final double time;
  final Random random;
  final Function(Random, bool) resetSnowParticle;
  final bool isCyberpunk;

  _ParticlePainter({
    required this.floorParticles,
    required this.beamParticles,
    required this.snowParticles,
    required this.bgParticles,
    required this.time,
    required this.random,
    required this.resetSnowParticle,
    required this.isCyberpunk,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.9);
    final paint = Paint()..strokeCap = StrokeCap.round;

    // --- 分层容器 ---
    // 1. 基础网格 (Base Grid) - 始终可见
    List<Offset> floorBasePoints = [];
    // 2. 波浪体 (Wave Body) - 波浪隆起的部分
    List<Offset> floorBodyPoints = [];
    // 3. 波峰 (Wave Crest) - 最高点亮光
    List<Offset> floorCrestPoints = [];

    List<Offset> beamPoints = [];
    List<Offset> snowPoints = [];
    List<Offset> bgPoints = [];

    const double perspectiveY = 0.25;

    // --- 1. 地面波浪逻辑 ---
    double waveFreq = 0.022;
    double waveAmp = 15.0; // 稍微增加振幅
    double phase = time * 8 * pi;

    for (var p in floorParticles) {
      double sinVal = sin(p.baseRadius * waveFreq - phase);

      double waveZ = sinVal * waveAmp;
      double attenuation = (1.0 - p.baseRadius / 800.0).clamp(0.0, 1.0);
      waveZ *= attenuation;

      double px = cos(p.baseAngle) * p.baseRadius;
      double py = sin(p.baseAngle) * p.baseRadius;
      double screenX = center.dx + px;
      double screenY = center.dy + py * perspectiveY - waveZ;

      final pointOffset = Offset(screenX, screenY);

      // 【分层收集逻辑】
      floorBasePoints.add(pointOffset); // 所有点都进基础层

      if (isCyberpunk) {
        // 只要是隆起的部分 (sinVal > -0.2)，都算作"波浪体"
        // 这样波浪的"形状"就会被强调出来
        if (sinVal > -0.2) {
          floorBodyPoints.add(pointOffset);
        }
        // 只有最顶端 (sinVal > 0.8)，算作"波峰高光"
        if (sinVal > 0.8) {
          floorCrestPoints.add(pointOffset);
        }
      }
    }

    // --- 2. 喷泉粒子 ---
    const double gravity = 0.60;
    for (int i = 0; i < snowParticles.length; i++) {
      var p = snowParticles[i];
      p.vy += gravity;

      if (p.vy > 0) {
        p.vy *= 0.97;
      }

      p.y += p.vy;
      p.baseRadius += p.radialSpeed;
      p.baseAngle += p.angularSpeed;

      if (p.y > 150 || p.baseRadius > 1500) {
        snowParticles[i] = resetSnowParticle(random, false);
        continue;
      }

      double px = cos(p.baseAngle) * p.baseRadius;
      double pz = sin(p.baseAngle) * p.baseRadius;

      double currentTurbulence = (p.vy > 0) ? 15.0 : 3.0;
      if (isCyberpunk) currentTurbulence *= 1.5;

      double noiseX = sin(p.y * 0.02 + p.turbulence) * currentTurbulence;

      double screenX = center.dx + px + noiseX;
      double screenY = center.dy + p.y + (pz * perspectiveY);

      if (screenX > -100 && screenX < size.width + 100 && screenY > -100) {
        snowPoints.add(Offset(screenX, screenY));
      }
    }

    // --- 3. 光柱 ---
    for (var p in beamParticles) {
      p.y -= p.speed;
      if (p.y < -1200) p.y = 0;
      double jitter = (random.nextDouble() - 0.5) * 1.5;
      beamPoints.add(Offset(center.dx + p.x + jitter, center.dy + p.y));
    }

    // --- 4. 背景 ---
    for (var p in bgParticles) {
      p.y += p.speed * 0.5;
      if (p.y > 0) p.y = -1200;
      bgPoints.add(Offset(center.dx + p.x, center.dy + p.y));
    }

    // ================== 绘制层 (核心颜色修正) ==================

    // A. 地面 - 基础网格 (Base Grid)
    if (isCyberpunk) {
      // 【关键修改】颜色改为亮青色 (CyanAccent)，且透明度提高到 0.3
      // 之前是深蓝 (DarkBlue)，在黑色背景下几乎看不见
      // 现在即使是暗部，也能看清圆环线条
      paint.color = Colors.cyanAccent.withValues(alpha: 0.3);
      paint.strokeWidth = 1.8; // 线条加粗
    } else {
      paint.color = const Color(0xFFE0E0E0);
      paint.strokeWidth = 1.8;
    }
    canvas.drawPoints(PointMode.points, floorBasePoints, paint);

    // B. 地面 - 波浪体 (Wave Body) - 赛博朋克专属
    if (isCyberpunk && floorBodyPoints.isNotEmpty) {
      // 叠加一层淡淡的蓝色，强调波浪的体积
      // 当线条运动时，这层颜色会随波浪移动，产生明显的视觉反馈
      paint.color = const Color(0xFF00B0FF).withValues(alpha: 0.35);
      paint.strokeWidth = 2.2;
      canvas.drawPoints(PointMode.points, floorBodyPoints, paint);
    }

    // C. 地面 - 波峰高光 (Wave Crest)
    if (isCyberpunk && floorCrestPoints.isNotEmpty) {
      // 光晕 (Glow)
      paint.color = Colors.cyanAccent.withValues(alpha: 0.6);
      paint.strokeWidth = 4.0;
      canvas.drawPoints(PointMode.points, floorCrestPoints, paint);

      // 核心白亮 (Core)
      paint.color = Colors.white;
      paint.strokeWidth = 2.0;
      canvas.drawPoints(PointMode.points, floorCrestPoints, paint);
    }

    // D. 光柱
    if (isCyberpunk) {
      paint.color = const Color(0xFF00FFFF).withValues(alpha: 0.3);
      paint.strokeWidth = 4.0;
      canvas.drawPoints(PointMode.points, beamPoints, paint);

      paint.color = Colors.white;
      paint.strokeWidth = 1.2;
      canvas.drawPoints(PointMode.points, beamPoints, paint);
    } else {
      paint.color = Colors.white;
      paint.strokeWidth = 1.2;
      canvas.drawPoints(PointMode.points, beamPoints, paint);
    }

    // E. 喷泉/散落粒子
    if (isCyberpunk) {
      paint.color = const Color(0xFF69F0AE).withValues(alpha: 0.8);
      paint.strokeWidth = 1.8;
    } else {
      paint.color = Colors.white.withValues(alpha: 0.5);
      paint.strokeWidth = 1.4;
    }
    canvas.drawPoints(PointMode.points, snowPoints, paint);

    // F. 背景
    if (isCyberpunk) {
      paint.color = const Color(0xFF00B0FF).withValues(alpha: 0.2);
      paint.strokeWidth = 1.5;
    } else {
      paint.color = Colors.white.withValues(alpha: 0.2);
      paint.strokeWidth = 1.0;
    }
    canvas.drawPoints(PointMode.points, bgPoints, paint);
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) => true;
}