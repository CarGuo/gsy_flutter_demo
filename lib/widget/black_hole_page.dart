import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class GalaxyParticleScreen extends StatefulWidget {
  const GalaxyParticleScreen({super.key});

  @override
  State<GalaxyParticleScreen> createState() => _GalaxyParticleScreenState();
}

class _GalaxyParticleScreenState extends State<GalaxyParticleScreen>
    with SingleTickerProviderStateMixin {
  late Ticker _ticker;

  // 核心配置
  final int particleCount = 4000; // 粒子数量，可根据手机性能调整
  List<Particle> particles = [];

  // 引力点位置
  Offset? _whiteHolePos; // 喷射/排斥点
  Offset? _blackHolePos; // 吸引/吞噬点
  Offset _mousePos = Offset.zero; // 鼠标位置
  bool _isMouseActive = false;

  @override
  void initState() {
    super.initState();
    // 初始化粒子
    for (int i = 0; i < particleCount; i++) {
      particles.add(Particle());
    }

    // 启动这一帧的循环
    _ticker = createTicker((elapsed) {
      _updatePhysics();
    })..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _updatePhysics() {
    if (_whiteHolePos == null || _blackHolePos == null) return;

    for (var p in particles) {
      p.update(
        whiteHole: _whiteHolePos!,
        blackHole: _blackHolePos!,
        mousePos: _mousePos,
        isMouseActive: _isMouseActive,
      );
    }
    setState(() {}); // 触发重绘
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: LayoutBuilder(
        builder: (context, constraints) {
          // 初始化位置在屏幕中心附近
          final center = Offset(constraints.maxWidth / 2, constraints.maxHeight / 2);
          // 设置白洞和黑洞的相对位置 (参考动图: 白在下略偏左，黑在上略偏右)
          if (_whiteHolePos == null) {
            _whiteHolePos = center + const Offset(-50, 50);
            _blackHolePos = center + const Offset(50, -50);
          }

          return MouseRegion(
            onHover: (event) {
              _mousePos = event.localPosition;
              _isMouseActive = true;
            },
            onExit: (event) {
              _isMouseActive = false;
            },
            child: GestureDetector(
              onPanUpdate: (details) {
                _mousePos = details.localPosition;
                _isMouseActive = true;
              },
              onPanEnd: (details) {
                _isMouseActive = false;
              },
              child: CustomPaint(
                size: Size.infinite,
                painter: ParticlePainter(
                  particles: particles,
                  whiteHole: _whiteHolePos!,
                  blackHole: _blackHolePos!,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// --- 粒子类 ---
class Particle {
  double x = 0;
  double y = 0;
  double vx = 0; // X轴速度
  double vy = 0; // Y轴速度
  double life = 0; // 生命周期
  Color color = Colors.white;

  // 初始化状态
  Particle() {
    reset(randomStart: true);
  }

  void reset({bool randomStart = false}) {
    final random = Random();
    life = random.nextDouble() * 0.5 + 0.5; // 0.5 ~ 1.0

    // 如果是随机启动，屏幕随机分布；否则从"白洞"附近喷出
    if (randomStart) {
      x = random.nextDouble() * 1000; // 这里的范围会在update里被矫正，暂且随意
      y = random.nextDouble() * 1000;
    } else {
      // 从某个区域重生（模拟白洞喷射）
      // 我们暂定重生位置在 update逻辑里传入的 whiteHole 附近
      // 这里先设为 0，update 里会处理
    }

    vx = (random.nextDouble() - 0.5) * 2;
    vy = (random.nextDouble() - 0.5) * 2;
  }

  // 在 _GalaxyParticleScreenState 类中，修改 particleCount
  final int particleCount = 6000; // 增加密度，让太极流体感更强

// --- 替换 Particle 类的 update 方法 ---
// 这里的物理参数经过微调，专门用于生成“太极 S 线”
  void update({
    required Offset whiteHole,
    required Offset blackHole,
    required Offset mousePos,
    required bool isMouseActive,
  }) {
    // 1. 重生逻辑 (Yang - 生)
    // 如果粒子静止或被吞噬，从白洞附近重生
    if (x == 0 && y == 0 || life <= 0) {
      final r = Random();
      // 在白洞周围形成一个小的发射源
      double angle = r.nextDouble() * 2 * pi;
      double dist = r.nextDouble() * 5; // 发射源更集中
      x = whiteHole.dx + cos(angle) * dist;
      y = whiteHole.dy + sin(angle) * dist;

      // 赋予切向速度，让它一开始就是旋转出来的
      vx = -sin(angle) * 1.5;
      vy = cos(angle) * 1.5;

      life = 1.0;
      return;
    }

    // 计算到两极的距离
    double dxW = x - whiteHole.dx;
    double dyW = y - whiteHole.dy;
    double distWSq = dxW * dxW + dyW * dyW;
    double distW = sqrt(distWSq);

    double dxB = blackHole.dx - x;
    double dyB = blackHole.dy - y;
    double distBSq = dxB * dxB + dyB * dyB;
    // double distB = sqrt(distBSq); // 暂时不用开方，优化性能

    // --- 核心太极力场 ---

    // 1. 白洞斥力 (Yang Push)
    // 距离越近推力越大，但不要太大以免炸开
    double pushForce = 600 / (distWSq + 10);
    vx += (dxW / distW) * pushForce * 0.1;
    vy += (dyW / distW) * pushForce * 0.1;

    // 2. 黑洞引力 (Yin Pull)
    // 距离越近吸力越大
    double pullForce = 1500 / (distBSq + 50);
    vx += dxB * pullForce * 0.002;
    vy += dyB * pullForce * 0.002;

    // 3. 全局旋转力 (The "Qi" Flow) - 这是形成太极S形的关键
    // 我们计算粒子相对于两个洞中心点的旋转
    // 简单的做法是：给每个力都加一个切向分量

    // 白洞附近的旋转 (顺时针喷出)
    vx += (dyW / distW) * pushForce * 0.15;
    vy += -(dxW / distW) * pushForce * 0.15;

    // 黑洞附近的旋转 (顺时针吸入) -> 保持旋转方向一致是形成S线的关键
    // 注意这里向量方向的处理
    vx += -(dyB / sqrt(distBSq)) * pullForce * 0.08;
    vy += (dxB / sqrt(distBSq)) * pullForce * 0.08;

    // 4. 鼠标干扰 (依然保留，这就像是外力扰乱了气场)
    if (isMouseActive) {
      double dxM = mousePos.dx - x;
      double dyM = mousePos.dy - y;
      double distMSq = dxM * dxM + dyM * dyM;
      if (distMSq < 15000) {
        double mForce = 2000 / (distMSq + 100);
        vx += (dyM / sqrt(distMSq)) * mForce * 0.5; // 鼠标也产生旋转扰动
        vy += -(dxM / sqrt(distMSq)) * mForce * 0.5;
      }
    }

    // 5. 物理更新
    vx *= 0.94; // 稍微增加一点阻力，让流动更平滑粘稠
    vy *= 0.94;
    x += vx;
    y += vy;

    // 6. 吞噬逻辑 (Yin - 死)
    if (distBSq < 100) { // 进入黑洞核心
      life = 0; // 标记死亡，下一帧重生
    }
  }
}

// --- 绘制类 ---
class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final Offset whiteHole;
  final Offset blackHole;

  ParticlePainter({
    required this.particles,
    required this.whiteHole,
    required this.blackHole,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. 绘制背景元素（白洞和黑洞的视觉效果）

    // 白洞光晕
    final whiteGlow = Paint()
      ..shader = RadialGradient(
        colors: [Colors.white.withOpacity(0.8), Colors.transparent],
      ).createShader(Rect.fromCircle(center: whiteHole, radius: 40));
    canvas.drawCircle(whiteHole, 40, whiteGlow);

    // 白洞核心
    canvas.drawCircle(whiteHole, 4, Paint()..color = Colors.white);

    // 黑洞核心
    canvas.drawCircle(blackHole, 10, Paint()..color = Colors.black);


    // 2. 批量绘制粒子
    // 将粒子按颜色/透明度分组绘制会有些复杂，为了性能，我们这里使用 PointsMode
    // 如果追求极致还原不同透明度，需要分类或使用 shader。
    // 这里采用这种折中方案：统一用一种微透明的白色，靠重叠产生亮度。

    final paint = Paint()
      ..color = Colors.white.withOpacity(0.4) // 基础透明度
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    // 提取所有坐标
    // 优化：虽然把 offset 放入 list 稍微耗时，但在 Flutter 中 drawPoints 比 drawCircle 快得多
    List<Offset> points = [];
    for (var p in particles) {
      points.add(Offset(p.x, p.y));
    }

    canvas.drawPoints(PointMode.points, points, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true; // 每一帧都重绘
  }
}