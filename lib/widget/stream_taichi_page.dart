import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';


// 粒子类，记录位置、速度和轨迹
class NebulaTaiChiParticle {
  Offset pos;      // 当前位置 (归一化坐标 -1.0 ~ 1.0)
  Offset vel;      // 当前速度
  List<Offset> trail; // 轨迹记录
  double baseSpeed; // 基础速度因子

  NebulaTaiChiParticle({
    required this.pos,
    required this.vel,
    required this.baseSpeed,
  }) : trail = [];
}

class NebulaTaiChiPage extends StatefulWidget {
  const NebulaTaiChiPage({super.key});

  @override
  State<NebulaTaiChiPage> createState() => _NebulaTaiChiPageState();
}

class _NebulaTaiChiPageState extends State<NebulaTaiChiPage>
    with SingleTickerProviderStateMixin {
  late Ticker _ticker;
  final List<NebulaTaiChiParticle> _particles = [];
  final int _count = 8000;    // 粒子数量，越多越密集
  final int _trailLen = 8;    // 拖尾长度
  double _time = 0;
  final Random _rng = Random();

  @override
  void initState() {
    super.initState();
    _initParticles();
    _ticker = createTicker(_tick);
    _ticker.start();
  }

  void _initParticles() {
    for (int i = 0; i < _count; i++) {
      _particles.add(_spawnParticle());
    }
  }

  // 初始化一个粒子在随机位置
  NebulaTaiChiParticle _spawnParticle() {
    double r = sqrt(_rng.nextDouble()); // 均匀分布在圆内
    double theta = _rng.nextDouble() * 2 * pi;
    return NebulaTaiChiParticle(
      pos: Offset(r * cos(theta), r * sin(theta)),
      vel: Offset.zero,
      // 速度随机差异，增加层次感
      baseSpeed: 0.2 + _rng.nextDouble() * 0.3,
    );
  }

  void _tick(Duration elapsed) {
    setState(() {
      _time = elapsed.inMilliseconds / 1000.0;
      _updateParticles();
    });
  }

  void _updateParticles() {
    // 时间步长，控制运动速度
    const double dt = 0.016;

    for (var p in _particles) {
      // --- 核心：计算向量场速度 ---
      // 1. 基础旋转力 (绕原点逆时针)
      double vx = -p.pos.dy * p.baseSpeed;
      double vy = p.pos.dx * p.baseSpeed;

      // 2. 噪声扰动力 (模拟湍流/烟雾)
      // 使用时间和位置作为参数生成变化的噪声
      double noiseScale = 0.8; // 噪声强度
      double noiseFreq = 3.0;  // 噪声频率
      vx += sin(p.pos.dy * noiseFreq + _time) * noiseScale * p.baseSpeed;
      vy += cos(p.pos.dx * noiseFreq + _time * 1.1) * noiseScale * p.baseSpeed;

      // 更新速度和位置
      p.vel = Offset(vx, vy);
      p.pos += p.vel * dt;

      // 记录轨迹
      p.trail.insert(0, p.pos);
      if (p.trail.length > _trailLen) {
        p.trail.removeLast();
      }

      // 边界处理：如果粒子跑出大圆太远，重置它
      if (p.pos.distanceSquared > 1.2 * 1.2) {
        var newP = _spawnParticle();
        p.pos = newP.pos;
        p.vel = Offset.zero;
        p.trail.clear();
      }
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
      backgroundColor: Colors.black,
      body: Center(
        // 使用 RepaintBoundary 可以提高静态背景下的性能
        child: RepaintBoundary(
          child: CustomPaint(
            size: const Size(400, 400),
            painter: NebulaPainter(
              particles: _particles,
              time: _time,
            ),
          ),
        ),
      ),
    );
  }
}

class NebulaPainter extends CustomPainter {
  final List<NebulaTaiChiParticle> particles;
  final double time;

  NebulaPainter({required this.particles, required this.time});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // 辉光画笔
    final Paint blurPaint = Paint()
      ..color = Colors.white
      ..strokeCap = StrokeCap.round
    // 添加模糊滤镜来实现辉光效果
      ..imageFilter = ImageFilter.blur(sigmaX: 1.2, sigmaY: 1.2);

    // 批量绘制点列表
    List<Offset> headPoints = [];
    List<List<Offset>> trailSegments = List.generate(8, (_) => []);

    for (var p in particles) {
      // 获取当前位置的太极亮度
      double brightness = _getTaiChiBrightness(p.pos.dx, p.pos.dy);

      // 映射到屏幕坐标
      Offset screenPos = center + p.pos * radius;

      // 只有亮度足够才绘制头部
      if (brightness > 0.1) {
        headPoints.add(screenPos);
      }

      // 处理轨迹
      for (int i = 0; i < p.trail.length; i++) {
        // 轨迹越往后越暗，且受当前位置亮度影响
        double trailAlpha = (1.0 - i / p.trail.length) * brightness * 0.5;
        if (trailAlpha > 0.05) {
          trailSegments[i].add(center + p.trail[i] * radius);
        }
      }
    }

    // 1. 绘制拖尾 (分层绘制以实现渐变透明度)
    for (int i = 0; i < trailSegments.length; i++) {
      double alpha = (1.0 - i / trailSegments.length) * 0.3;
      blurPaint.color = Colors.white.withValues(alpha:   alpha);
      blurPaint.strokeWidth = 1.0; // 拖尾稍细
      canvas.drawPoints(PointMode.points, trailSegments[i], blurPaint);
    }

    // 2. 绘制粒子头部 (最亮)
    blurPaint.color = Colors.white.withValues(alpha: 0.8);
    blurPaint.strokeWidth = 1.5; // 头部稍粗
    canvas.drawPoints(PointMode.points, headPoints, blurPaint);
  }

  // 计算太极图的亮度场 (0.0 ~ 1.0)
  // 这里的逻辑决定了太极图的形状
  double _getTaiChiBrightness(double x, double y) {
    double distSq = x * x + y * y;
    // 让边缘柔和地消失
    double edgeFade = (1.0 - distSq * 0.8).clamp(0.0, 1.0);

    double distTop = sqrt(x * x + (y - 0.5) * (y - 0.5));
    double distBot = sqrt(x * x + (y + 0.5) * (y + 0.5));

    // 鱼眼
    if (distTop < 0.15) return 0.1 * edgeFade; // 上黑眼
    if (distBot < 0.15) return 1.0 * edgeFade; // 下白眼

    // 中圆
    if (distTop < 0.5) return 1.0 * edgeFade; // 上白中
    if (distBot < 0.5) return 0.1 * edgeFade; // 下黑中

    // 基础左右
    return (x > 0 ? 1.0 : 0.1) * edgeFade;
  }

  @override
  bool shouldRepaint(covariant NebulaPainter oldDelegate) {
    return oldDelegate.time != time;
  }
}