import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

// 定义吸引子的类型
enum AttractorType { halvorsen, lorenz, aizawa, sprottB }

// 粒子类
class Particle {
  double x, y, z;
  Particle(this.x, this.y, this.z);
}

class AttractorPage extends StatefulWidget {
  const AttractorPage({super.key});

  @override
  State<AttractorPage> createState() => _AttractorPageState();
}

class _AttractorPageState extends State<AttractorPage>
    with SingleTickerProviderStateMixin {
  late Ticker _ticker;

  // 配置参数
  final int _particleCount = 2000; // 粒子数量，如果卡顿可适当减小
  final List<Particle> _particles = [];

  AttractorType _currentType = AttractorType.halvorsen;
  double _angle = 0.0; // 用于旋转视图

  @override
  void initState() {
    super.initState();
    _resetParticles();
    // 使用 Ticker 实现 60FPS 刷新
    _ticker = createTicker((elapsed) {
      setState(() {
        _updatePhysics();
        _angle += 0.005; // 缓慢自动旋转视角
      });
    });
    _ticker.start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  // 切换到下一个效果
  void _switchAttractor() {
    setState(() {
      int nextIndex = (_currentType.index + 1) % AttractorType.values.length;
      _currentType = AttractorType.values[nextIndex];
      _resetParticles();
    });
  }

  // 重置粒子位置
  void _resetParticles() {
    _particles.clear();
    for (int i = 0; i < _particleCount; i++) {
      // 给一个随机初始位置，避免所有粒子重叠
      // 大部分吸引子从 (0.1, 0, 0) 附近开始会有较好效果
      _particles.add(Particle(
        (Random().nextDouble() - 0.5) * 2.0,
        (Random().nextDouble() - 0.5) * 2.0,
        (Random().nextDouble() - 0.5) * 2.0,
      ));
    }
  }

  // 核心物理计算：更新每个粒子的位置
  void _updatePhysics() {
    // dt 是时间步长，不同模型需要不同的步长来保证稳定
    double dt = 0.01;

    for (var p in _particles) {
      double dx = 0, dy = 0, dz = 0;

      switch (_currentType) {
        case AttractorType.halvorsen:
        // Halvorsen: dx = -ax -4y -4z -y^2 ...
        // const a = 1.4; // 图片没给具体数值，通常取 1.4
        // 为了视觉效果调整 dt
          dt = 0.005;
          const a = 1.4;
          dx = -a * p.x - 4 * p.y - 4 * p.z - (p.y * p.y);
          dy = -a * p.y - 4 * p.z - 4 * p.x - (p.z * p.z);
          dz = -a * p.z - 4 * p.x - 4 * p.y - (p.x * p.x);
          break;

        case AttractorType.lorenz:
        // Lorenz: Standard params sigma=10, rho=28, beta=8/3
          dt = 0.008;
          const sigma = 10.0;
          const rho = 28.0;
          const beta = 8.0 / 3.0;
          dx = sigma * (p.y - p.x);
          dy = p.x * (rho - p.z) - p.y;
          dz = p.x * p.y - beta * p.z;
          break;

        case AttractorType.aizawa:
        // Aizawa: Complex params
          dt = 0.01;
          const a = 0.95;
          const b = 0.7;
          const c = 0.6;
          const d = 3.5;
          const e = 0.25;
          const f = 0.1;

          dx = (p.z - b) * p.x - d * p.y;
          dy = d * p.x + (p.z - b) * p.y;
          dz = c + a * p.z - (p.z * p.z * p.z) / 3 - (p.x * p.x + p.y * p.y) * (1 + e * p.z) + f * p.z * (p.x * p.x * p.x);
          break;

        case AttractorType.sprottB:
        // Sprott B: dx=ayz, dy=x-y, dz=b-xy
          dt = 0.02;
          const a = 0.4;
          const b = 1.2;
          dx = a * p.y * p.z;
          dy = p.x - p.y;
          dz = b - p.x * p.y;
          break;
      }

      // 欧拉积分更新位置
      p.x += dx * dt;
      p.y += dy * dt;
      p.z += dz * dt;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      backgroundColor: Colors.black,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _switchAttractor,
        label: Text("Switch: ${_currentType.name.toUpperCase()}"),
        icon: const Icon(Icons.swap_horiz),
        backgroundColor: Colors.white,
      ),
      body: CustomPaint(
        painter: AttractorPainter(
          particles: _particles,
          type: _currentType,
          angle: _angle,
        ),
        child: Container(), // 撑满屏幕
      ),
    );
  }
}

class AttractorPainter extends CustomPainter {
  final List<Particle> particles;
  final AttractorType type;
  final double angle;

  AttractorPainter({
    required this.particles,
    required this.type,
    required this.angle,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 1.5; // 粒子大小

    // 设置中心点
    canvas.translate(size.width / 2, size.height / 2);

    // 根据不同类型设置颜色和缩放比例
    // 不同的方程计算出的坐标范围差异很大，需要 scale 调整到屏幕可见范围
    Color particleColor = Colors.white;
    double scale = 1.0;

    switch (type) {
      case AttractorType.halvorsen:
        particleColor = const Color(0xFFFFD700); // 金黄色
        scale = 12.0;
        break;
      case AttractorType.lorenz:
        particleColor = const Color(0xFF00FF7F); // 翠绿色
        scale = 8.0;
        break;
      case AttractorType.aizawa:
        particleColor = const Color(0xFFE0FFFF); // 亮白色/银色
        scale = 120.0; // Aizawa 的数值通常很小 (<1.0)，需要放大很多
        // Aizawa 需要往下移一点才能居中
        canvas.translate(0, 100);
        break;
      case AttractorType.sprottB:
        particleColor = const Color(0xFFFF4040); // 红色
        scale = 40.0;
        break;
    }

    paint.color = particleColor.withOpacity(0.6);

    // 简单的 3D 旋转矩阵和投影
    // 我们绕 Y 轴旋转
    final cosA = cos(angle);
    final sinA = sin(angle);

    List<Offset> points = [];
    for (var p in particles) {
      // 旋转公式 (绕 Y 轴)
      double rotX = p.x * cosA - p.z * sinA;
      double rotZ = p.x * sinA + p.z * cosA;
      double rotY = p.y;

      // 简单的透视投影 (或者直接用正交投影)
      // 正交投影：直接把 X 和 Y 映射到屏幕
      double screenX = rotX * scale;
      double screenY = rotY * scale;

      // 对于 Aizawa，它的 Z 轴是高度，所以我们需要把 Z 映射到屏幕 Y 上才能看清形状
      if (type == AttractorType.aizawa) {
        screenX = rotX * scale;
        screenY = -p.z * scale; // Aizawa 通常侧面看比较美
      }

      points.add(Offset(screenX, screenY));
    }

    // 批量绘制点，性能极高
    canvas.drawPoints(PointMode.points, points, paint);

    // 绘制名字
    TextSpan span = TextSpan(
      style: TextStyle(
        color: particleColor,
        fontSize: 30,
        fontWeight: FontWeight.bold,
        fontFamily: "Courier", // 类似代码风格的字体
        letterSpacing: 2,
      ),
      text: type.name.toUpperCase(),
    );
    TextPainter tp = TextPainter(
        text: span,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr
    );
    tp.layout();
    tp.paint(canvas, Offset(-tp.width / 2, -size.height / 2 + 60));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true; // 每一帧都需要重绘
  }
}