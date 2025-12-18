import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class TaiChiMasterpiece extends StatefulWidget {
  const TaiChiMasterpiece({super.key});

  @override
  State<TaiChiMasterpiece> createState() => _TaiChiMasterpieceState();
}

class _TaiChiMasterpieceState extends State<TaiChiMasterpiece>
    with SingleTickerProviderStateMixin {
  late Ticker _ticker;

  final int maxParticles = 8000;
  final List<SandParticle> particles = [];

  double angle = 0.0;
  final double rotationSpeed = 0.05;
  final double radius = 100.0;

  final Random rng = Random();

  // false = 原始柔和模式 (Imp 1)
  // true = 几何切割模式 (Imp 2)
  bool _isSharpMode = false;

  @override
  void initState() {
    super.initState();
    // 初始化粒子池
    for (int i = 0; i < maxParticles; i++) {
      particles.add(SandParticle());
    }

    _ticker = createTicker((elapsed) {
      _updatePhysics();
      setState(() {});
    });
    _ticker.start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  // 切换并重置
  void _toggleMode() {
    setState(() {
      _isSharpMode = !_isSharpMode;
      _reset();
    });
  }

  void _reset() {
    angle = 0.0;
    // 让所有粒子"死亡"，从而触发重新发射逻辑
    for (var p in particles) {
      p.isDead = true;
      p.life = 0;
      p.alpha = 0;
    }
  }

  void _updatePhysics() {
    angle += rotationSpeed;

    // --- 1. 发射源逻辑 (两种模式通用) ---
    final double eyeOrbitRadius = radius * 0.25;
    final double denseCenterX = cos(angle) * eyeOrbitRadius;
    final double denseCenterY = sin(angle) * eyeOrbitRadius;
    const double blackEyeRadius = 8.0;

    int spawnCount = 200; // 每帧发射数量

    for (var p in particles) {
      if (p.isDead && spawnCount > 0) {
        double theta = rng.nextDouble() * 2 * pi;

        // 稍微增加一点随机散布
        double r = blackEyeRadius + 2.0 + (rng.nextDouble() * rng.nextDouble() * 30.0);

        double pX = denseCenterX + r * cos(theta);
        double pY = denseCenterY + r * sin(theta);

        double tangent = angle + pi / 2;
        // 两种模式稍微调整下速度感，或保持一致均可
        double speed = 2.0 + rng.nextDouble() * 5.0;

        p.spawn(
          x: pX,
          y: pY,
          vx: cos(tangent) * speed + (rng.nextDouble() - 0.5) * 2.0,
          vy: sin(tangent) * speed + (rng.nextDouble() - 0.5) * 2.0,
        );
        spawnCount--;
      }
    }

    // --- 2. 几何参数准备 ---
    // 模式2需要的参数
    final double cosA = cos(angle);
    final double sinA = sin(angle);
    final double lobeRadiusSq = pow(radius * 0.5, 2).toDouble();
    final double lobeCenterDist = radius * 0.5;

    // 模式1需要的参数
    final double voidCenterXImp1 = cos(angle + pi) * eyeOrbitRadius;
    final double voidCenterYImp1 = sin(angle + pi) * eyeOrbitRadius;
    final double voidRadiusImp1 = radius * 0.36;

    // --- 3. 粒子更新与消亡判定 ---
    for (var p in particles) {
      if (!p.isDead) {
        p.update();

        bool shouldDie = false;

        if (_isSharpMode) {
          // >>>>>> 模式 2: 严格几何 S 形切割 <<<<<<

          // 投影到相对坐标系
          double relY = p.x * cosA + p.y * sinA;
          double relX = p.x * sinA - p.y * cosA;

          // 计算到两个“鱼头”圆心的距离平方
          double distToWhiteLobeSq = pow(relX, 2) + pow(relY - lobeCenterDist, 2).toDouble();
          double distToBlackLobeSq = pow(relX, 2) + pow(relY + lobeCenterDist, 2).toDouble();

          if (distToWhiteLobeSq < lobeRadiusSq) {
            shouldDie = false; // 白鱼头内：存活
          } else if (distToBlackLobeSq < lobeRadiusSq) {
            shouldDie = true;  // 黑鱼头内：死亡
          } else {
            // 中轴线划分：左侧虚空，右侧实体
            if (relX < 0) {
              shouldDie = true;
            } else {
              shouldDie = false;
            }
          }

        } else {
          // >>>>>> 模式 1: 简单圆形排斥 (柔和模式) <<<<<<

          double distToVoid = sqrt(pow(p.x - voidCenterXImp1, 2) + pow(p.y - voidCenterYImp1, 2));
          if (distToVoid < voidRadiusImp1) {
            shouldDie = true;
          }
        }

        // --- 执行消亡 ---
        if (shouldDie) {
          p.life -= 15.0; // 快速消亡
          p.alpha *= 0.8;
        }

        // --- 全局边界检查 ---
        double distToGlobalCenter = sqrt(p.x * p.x + p.y * p.y);
        if (distToGlobalCenter > radius * 1.3) {
          p.alpha *= 0.9;
        }

        if (p.alpha < 0.05) p.isDead = true;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      backgroundColor: Colors.black, // 确保背景色
      body: Stack(
        children: [
          // 1. 核心绘制层
          Center(
            child: CustomPaint(
              painter: MasterpiecePainter(
                particles: particles,
                radius: radius,
                angle: angle,
              ),
              child: Container(),
            ),
          ),

          // 2. 切换按钮
          Positioned(
            bottom: 50,
            right: 30,
            child: FloatingActionButton.extended(
              onPressed: _toggleMode,
              icon: const Icon(Icons.swap_calls),
              label: Text(_isSharpMode ? "当前: 几何S形" : "当前: 柔和圆"),
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}

// --- 粒子类 (通用) ---
class SandParticle {
  double x = 0, y = 0;
  double vx = 0, vy = 0;
  double life = 0;
  double maxLife = 100;
  bool isDead = true;
  double alpha = 1.0;
  double size = 1.0;

  void spawn({
    required double x,
    required double y,
    required double vx,
    required double vy,
  }) {
    this.x = x;
    this.y = y;
    this.vx = vx;
    this.vy = vy;
    life = 80 + Random().nextDouble() * 40;
    maxLife = life;
    isDead = false;
    alpha = 1.0;
    size = 1.2;
  }

  void update() {
    x += vx;
    y += vy;
    vx *= 0.92;
    vy *= 0.92;
    life -= 1.0;
    if (life <= 0) {
      isDead = true;
    } else {
      alpha = life / maxLife;
    }
  }
}

// --- 画笔类 (通用) ---
class MasterpiecePainter extends CustomPainter {
  final List<SandParticle> particles;
  final double radius;
  final double angle;

  MasterpiecePainter({
    required this.particles,
    required this.radius,
    required this.angle,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    canvas.translate(center.dx, center.dy);

    final Paint paint = Paint()
      ..strokeCap = StrokeCap.round
      ..color = Colors.white;

    // 绘制所有存活粒子
    for (var p in particles) {
      if (p.isDead || p.alpha < 0.05) continue;
      paint.color = Colors.white.withValues(alpha: p.alpha);
      paint.strokeWidth = p.size;
      canvas.drawPoints(PointMode.points, [Offset(p.x, p.y)], paint);
    }

    // 绘制太极眼 (保持一致)
    final double eyeOrbitRadius = radius * 0.25;

    Offset blackEyePos = Offset(cos(angle) * eyeOrbitRadius, sin(angle) * eyeOrbitRadius);
    Offset whiteEyePos = Offset(cos(angle + pi) * eyeOrbitRadius, sin(angle + pi) * eyeOrbitRadius);

    // 黑眼 (实体黑圆)
    canvas.drawCircle(blackEyePos, 8.0, Paint()..color = Colors.black);

    // 白眼 (带辉光的白圆)
    canvas.drawCircle(
      whiteEyePos,
      12.0,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );
    canvas.drawCircle(whiteEyePos, 5.0, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant MasterpiecePainter oldDelegate) {
    return true;
  }
}