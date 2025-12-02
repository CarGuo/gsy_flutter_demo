import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class BoomParticlePage extends StatefulWidget {
  const BoomParticlePage({super.key});

  @override
  State<BoomParticlePage> createState() => _BoomParticlePageState();
}

class _BoomParticlePageState extends State<BoomParticlePage>
    with SingleTickerProviderStateMixin {
  late Ticker _ticker;

  // 粒子数量：在手机 CPU 上，建议 5000-10000 个以保持 60FPS。
  // WebGPU 可以跑 10万+，但在 Dart CPU 上我们需要克制一下。
  static const int particleCount = 8000;

  // 使用 Float32List 存储数据，性能远高于 List<Object>
  // layout: [x, y, x, y, ...]
  late Float32List positions;
  late Float32List velocities;
  late Float32List life; // 用于颜色或闪烁效果

  // 交互状态
  Offset _touchPosition = Offset.zero;
  bool _isTouching = false;

  // 物理参数 (模拟 TSL Shader 中的 uniform)
  double speed = 1.0;
  double damping = 0.95; // 阻力，模拟空气摩擦
  double attractionStrength = 0.5; // 吸引力强度

  Size _screenSize = Size.zero;

  @override
  void initState() {
    super.initState();
    _initParticles();

    _ticker = createTicker((Duration elapsed) {
      _updatePhysics();
    });
    _ticker.start();
  }

  void _initParticles() {
    positions = Float32List(particleCount * 2);
    velocities = Float32List(particleCount * 2);
    life = Float32List(particleCount);

    final random = Random();
    // 初始化在屏幕中心附近
    for (int i = 0; i < particleCount; i++) {
      positions[i * 2] = (random.nextDouble() - 0.5) * 500; // x
      positions[i * 2 + 1] = (random.nextDouble() - 0.5) * 500; // y
      life[i] = random.nextDouble();
    }
  }

  void _updatePhysics() {
    if (_screenSize == Size.zero) return;

    final centerX = _screenSize.width / 2;
    final centerY = _screenSize.height / 2;

    // 目标点：如果触摸则为触摸点，否则为屏幕中心
    final targetX = _isTouching ? _touchPosition.dx : centerX;
    final targetY = _isTouching ? _touchPosition.dy : centerY;

    // 核心物理循环 (对应 Compute Shader 逻辑)
    for (int i = 0; i < particleCount; i++) {
      final idx = i * 2;
      double px = positions[idx];
      double py = positions[idx + 1];
      double vx = velocities[idx];
      double vy = velocities[idx + 1];

      // 1. 计算到目标的向量
      double dx = targetX - px;
      double dy = targetY - py;

      // 2. 计算距离 (避免除以0)
      double distSq = dx * dx + dy * dy;
      double dist = sqrt(distSq);
      if (dist < 1.0) dist = 1.0;

      // 3. 计算吸引力 (TSL 逻辑移植)
      // TSL: force = direction * strength / (distance * falloff + 1)
      // 稍微简化的物理模型：
      double force = attractionStrength * 2.0;

      // 如果没有触摸，给一个类似 "orbit" (轨道) 的旋转力
      if (!_isTouching) {
        // 添加切向力产生旋转效果
        double orbitForce = 0.05;
        vx += -dy / dist * orbitForce;
        vy += dx / dist * orbitForce;
        force *= 0.1; // 待机状态吸引力减弱
      } else {
        // 触摸状态强力吸引
        force *= 2.0;
      }

      // 归一化方向并应用力
      double dirX = dx / dist;
      double dirY = dy / dist;

      vx += dirX * force;
      vy += dirY * force;

      // 4. 应用阻力 (Damping)
      vx *= damping;
      vy *= damping;

      // 5. 更新位置
      px += vx * speed;
      py += vy * speed;

      // 保存回数组
      velocities[idx] = vx;
      velocities[idx + 1] = vy;
      positions[idx] = px;
      positions[idx + 1] = py;
    }

    setState(() {}); // 触发重绘
  }

  // 模拟爆炸效果
  void _explode() {
    final random = Random();
    for (int i = 0; i < particleCount; i++) {
      final idx = i * 2;
      // 给每个粒子一个随机的强力冲击
      double angle = random.nextDouble() * 2 * pi;
      double force = 20.0 + random.nextDouble() * 30.0;

      velocities[idx] += cos(angle) * force;
      velocities[idx + 1] += sin(angle) * force;
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(),
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          const Center(
            child: Text(
              "点击，拖拽",
              style: TextStyle(fontSize: 50, color: Colors.white),
            ),
          ),
          GestureDetector(
            onPanStart: (details) {
              _isTouching = true;
              _touchPosition = details.localPosition;
            },
            onPanUpdate: (details) {
              _touchPosition = details.localPosition;
            },
            onPanEnd: (_) {
              _isTouching = false;
            },
            onTap: _explode,
            // 点击产生爆炸
            child: CustomPaint(
              painter: ParticlePainter(positions, particleCount),
              size: Size.infinite,
            ),
          )
        ],
      ),
    );
  }
}

class ParticlePainter extends CustomPainter {
  final Float32List positions;
  final int count;

  ParticlePainter(this.positions, this.count);

  @override
  void paint(Canvas canvas, Size size) {
    // 批量绘制点，这是 Flutter 中绘制大量同色粒子最高效的方法
    // RawPointsMode.points 绘制单个像素点
    // 也可以试试 pointsFromPolygon 如果需要更大的点

    final Paint paint = Paint()
      ..color = Colors.cyanAccent.withValues(alpha: 0.6)
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..blendMode = BlendMode.screen; // 混合模式产生发光叠加效果

    // 将 Float32List 转换为 Offset 列表供 drawRawPoints 使用会产生大量 GC
    // 所以我们直接使用 drawRawPoints 接受 Float32List
    canvas.drawRawPoints(ui.PointMode.points, positions, paint);
  }

  @override
  bool shouldRepaint(covariant ParticlePainter oldDelegate) {
    return true; // 每一帧都必须重绘
  }
}
