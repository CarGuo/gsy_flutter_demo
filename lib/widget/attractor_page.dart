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
  final int _particleCount = 2000;
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
      _particles.add(Particle(
        (Random().nextDouble() - 0.5) * 2.0,
        (Random().nextDouble() - 0.5) * 2.0,
        (Random().nextDouble() - 0.5) * 2.0,
      ));
    }
  }

  // 核心物理计算：更新每个粒子的位置
  void _updatePhysics() {
    // 默认值
    double dt = 0.01;
    int steps = 1;

    // 1. 配置参数
    switch (_currentType) {
      case AttractorType.halvorsen:
      // Halvorsen 专用优化：
      // 减小步长(dt)并增加频次(steps)，提高精度以消除闪烁
        dt = 0.001;
        steps = 5;
        break;
      case AttractorType.lorenz:
        dt = 0.008;
        steps = 1; // 保持原样
        break;
      case AttractorType.aizawa:
        dt = 0.01;
        steps = 1; // 保持原样
        break;
      case AttractorType.sprottB:
        dt = 0.02;
        steps = 1; // 保持原样
        break;
    }

    // 2. 物理循环
    for (int k = 0; k < steps; k++) {
      for (var p in _particles) {
        double dx = 0, dy = 0, dz = 0;

        switch (_currentType) {
          case AttractorType.halvorsen:
            const a = 1.4;
            dx = -a * p.x - 4 * p.y - 4 * p.z - (p.y * p.y);
            dy = -a * p.y - 4 * p.z - 4 * p.x - (p.z * p.z);
            dz = -a * p.z - 4 * p.x - 4 * p.y - (p.x * p.x);
            break;

          case AttractorType.lorenz:
            const sigma = 10.0;
            const rho = 28.0;
            const beta = 8.0 / 3.0;
            dx = sigma * (p.y - p.x);
            dy = p.x * (rho - p.z) - p.y;
            dz = p.x * p.y - beta * p.z;
            break;

          case AttractorType.aizawa:
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
            const a = 0.4;
            const b = 1.2;
            dx = a * p.y * p.z;
            dy = p.x - p.y;
            dz = b - p.x * p.y;
            break;
        }

        // 欧拉积分
        p.x += dx * dt;
        p.y += dy * dt;
        p.z += dz * dt;

        // 3. 状态检查与重置
        bool shouldReset = false;

        // 检查 A: 是否因为计算溢出变成了 NaN (所有类型都需要，防止崩溃)
        if (!p.x.isFinite || !p.y.isFinite || !p.z.isFinite) {
          shouldReset = true;
        }
        // 检查 B: 距离检测 (只针对 Halvorsen)
        // Halvorsen 容易发散到无限远，需要拉回；
        // ！！！绝对不要对 Lorenz 开启这个检查，因为 Lorenz 的 Z 轴正常数值 > 50
        else if (_currentType == AttractorType.halvorsen) {
          if (p.x.abs() > 40 || p.y.abs() > 40 || p.z.abs() > 40) {
            shouldReset = true;
          }
        }

        if (shouldReset) {
          p.x = (Random().nextDouble() - 0.5) * 2.0;
          p.y = (Random().nextDouble() - 0.5) * 2.0;
          p.z = (Random().nextDouble() - 0.5) * 2.0;
        }
      }
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
        scale = 120.0;
        canvas.translate(0, 100);
        break;
      case AttractorType.sprottB:
        particleColor = const Color(0xFFFF4040); // 红色
        scale = 40.0;
        break;
    }

    paint.color = particleColor.withOpacity(0.6);

    final cosA = cos(angle);
    final sinA = sin(angle);

    List<Offset> points = [];
    for (var p in particles) {
      // 旋转公式 (绕 Y 轴)
      double rotX = p.x * cosA - p.z * sinA;
      double rotZ = p.x * sinA + p.z * cosA;
      double rotY = p.y;

      // 透视/正交投影
      double screenX = rotX * scale;
      double screenY = rotY * scale;

      // Aizawa 特殊处理
      if (type == AttractorType.aizawa) {
        screenX = rotX * scale;
        screenY = -p.z * scale;
      }

      // 【核心修复 2】：绘制安全检查
      // 只有当坐标是有效数字（Finite）时才添加。
      // 如果出现 NaN（Not a Number），直接跳过该点，防止 Canvas 报错崩溃。
      if (screenX.isFinite && screenY.isFinite) {
        points.add(Offset(screenX, screenY));
      }
    }

    // 批量绘制点
    canvas.drawPoints(PointMode.points, points, paint);

    // 绘制名字
    TextSpan span = TextSpan(
      style: TextStyle(
        color: particleColor,
        fontSize: 30,
        fontWeight: FontWeight.bold,
        fontFamily: "Courier",
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