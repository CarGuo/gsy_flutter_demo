import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

// --- 1. 向量数学 ---
class _Vec3 {
  double x, y, z;
  _Vec3(this.x, this.y, this.z);
  _Vec3 operator +(_Vec3 v) => _Vec3(x + v.x, y + v.y, z + v.z);
  _Vec3 operator -(_Vec3 v) => _Vec3(x - v.x, y - v.y, z - v.z);
  _Vec3 operator *(double s) => _Vec3(x * s, y * s, z * s);
  double dot(_Vec3 v) => x * v.x + y * v.y + z * v.z;
  _Vec3 normalize() {
    double len = sqrt(x * x + y * y + z * z);
    if (len == 0) return this;
    return _Vec3(x / len, y / len, z / len);
  }
  double distanceTo(_Vec3 v) {
    double dx = x - v.x;
    double dy = y - v.y;
    double dz = z - v.z;
    return sqrt(dx*dx + dy*dy + dz*dz);
  }
}

// --- 2. 数据模型 ---
class _GridTile {
  final List<_Vec3> vertices;
  final _Vec3 centerBase;
  final Color baseColor;

  final _Vec3 noiseDir;
  final _Vec3 tumbleAxis;
  final _Vec3 shimmerNormal;
  final int rowIndex;
  final double randomSeed;

  final double rotationSpeedMultiplier;

  double currentOffset = 0.0;

  _GridTile({
    required this.vertices,
    required this.centerBase,
    required this.baseColor,
    required this.noiseDir,
    required this.tumbleAxis,
    required this.shimmerNormal,
    required this.rowIndex,
    required this.randomSeed,
    required this.rotationSpeedMultiplier,
  });
}

class _RenderQuad {
  final double zDepth;
  final Path path;
  final Color color;
  _RenderQuad(this.zDepth, this.path, this.color);
}

// --- 3. 主页面 ---
class DiscoSphereFinalFusionPage extends StatefulWidget {
  const DiscoSphereFinalFusionPage({super.key});

  @override
  State<DiscoSphereFinalFusionPage> createState() => _DiscoSphereFinalFusionPageState();
}

class _DiscoSphereFinalFusionPageState extends State<DiscoSphereFinalFusionPage>
    with SingleTickerProviderStateMixin {
  late Ticker _ticker;

  final int _latSegments = 32;
  final int _lonSegments = 48;
  final double _radius = 120.0;

  List<_GridTile> _tiles = [];

  double _rotX = 0.25;
  double _baseRotY = 0.0;
  double _time = 0.0;

  // --- 正弦波呼吸系统 ---
  bool _isBreathing = false;
  double _breathProgress = 0.0;
  double _breathSpeed = 0.0;
  _Vec3 _activeBurstCenter = _Vec3(0, 0, 1);
  double _nextBreathTime = 60.0;

  Offset _mousePos = const Offset(-1000, -1000);

  // 模式切换
  bool _isPaperSpreadMode = true;

  @override
  void initState() {
    super.initState();
    _initGrid();

    _ticker = createTicker((elapsed) {
      setState(() {
        _baseRotY += 0.005;
        _time += 0.02;

        // --- 呼吸逻辑 ---
        if (_isBreathing) {
          _breathProgress += _breathSpeed;
          if (_breathProgress >= pi) {
            _breathProgress = 0.0;
            _isBreathing = false;
            _nextBreathTime = 60.0 + Random().nextDouble() * 120.0;
          }
        } else {
          _nextBreathTime -= 1.0;
          if (_nextBreathTime <= 0) {
            _isBreathing = true;
            _breathProgress = 0.0;
            _breathSpeed = 0.02 + Random().nextDouble() * 0.01;

            double theta = Random().nextDouble() * 2 * pi;
            double phi = Random().nextDouble() * pi;
            _activeBurstCenter = _Vec3(
                sin(phi) * cos(theta),
                cos(phi),
                sin(phi) * sin(theta)
            );
          }
        }

        // 鼠标交互衰减
        for (var tile in _tiles) {
          if (tile.currentOffset > 0.5) {
            tile.currentOffset *= 0.92;
          } else {
            tile.currentOffset = 0.0;
          }
        }
      });
    });
    _ticker.start();
  }

  // --- 【修改点 1】初始化网格：增加缝隙缩放 (Scale) 和 新配色 ---
  void _initGrid() {
    _tiles.clear();
    final random = Random();

    List<double> rowSpeeds = List.generate(_latSegments, (rowIndex) {
      double speed = 1.0 + (rowIndex % 2 == 0 ? 0.02 : -0.02);
      bool isFastRow = false;
      if (rowIndex == 7 || rowIndex == 9 || rowIndex == 11) isFastRow = true;
      int fromBottom = (_latSegments - 1) - rowIndex;
      if (fromBottom == 7 || fromBottom == 9 || fromBottom == 11) isFastRow = true;

      if (isFastRow) {
        speed = 1.5 + random.nextDouble() * 0.1;
      }
      return speed;
    });

    for (int y = 0; y < _latSegments; y++) {
      for (int x = 0; x < _lonSegments; x++) {
        double v1 = y / _latSegments;
        double v2 = (y + 1) / _latSegments;
        double u1 = x / _lonSegments;
        double u2 = (x + 1) / _lonSegments;

        _Vec3 p1 = _getSpherePoint(u1, v1);
        _Vec3 p2 = _getSpherePoint(u2, v1);
        _Vec3 p3 = _getSpherePoint(u2, v2);
        _Vec3 p4 = _getSpherePoint(u1, v2);

        _Vec3 center = _Vec3(
          (p1.x + p2.x + p3.x + p4.x) / 4,
          (p1.y + p2.y + p3.y + p4.y) / 4,
          (p1.z + p2.z + p3.z + p4.z) / 4,
        );

        // --- 核心：向中心收缩顶点，制造物理缝隙 ---
        double scale = 0.92; // 缝隙大小控制
        p1 = (p1 - center) * scale + center;
        p2 = (p2 - center) * scale + center;
        p3 = (p3 - center) * scale + center;
        p4 = (p4 - center) * scale + center;

        // --- 核心：金属质感冷色调 ---
        Color color;
        double r = random.nextDouble();
        if (r > 0.70) color = const Color(0xFFF5F5F5); // 亮银
        else if (r > 0.50) color = const Color(0xFFD1C4E9); // 淡紫 (Lavender)
        else if (r > 0.25) color = const Color(0xFF9575CD); // 中紫
        else color = const Color(0xFF673AB7); // 深紫

        _Vec3 noise = _Vec3(
          (random.nextDouble() - 0.5) * 0.8,
          (random.nextDouble() - 0.5) * 0.8,
          (random.nextDouble() - 0.5) * 0.8,
        );

        _Vec3 tumble = _Vec3(
            random.nextDouble(),
            random.nextDouble(),
            random.nextDouble()
        ).normalize();

        // 增加更强的随机法线扰动，让金属反光更碎
        _Vec3 shimmer = _Vec3(
          (random.nextDouble() - 0.5) * 0.9,
          (random.nextDouble() - 0.5) * 0.9,
          (random.nextDouble() - 0.5) * 0.9,
        );

        _tiles.add(_GridTile(
          vertices: [p1, p2, p3, p4],
          centerBase: center,
          baseColor: color,
          noiseDir: noise,
          tumbleAxis: tumble,
          shimmerNormal: shimmer,
          rowIndex: y,
          randomSeed: random.nextDouble() * 100.0,
          rotationSpeedMultiplier: rowSpeeds[y],
        ));
      }
    }
  }

  _Vec3 _getSpherePoint(double u, double v) {
    double theta = u * 2 * pi;
    double phi = v * pi;
    double x = sin(phi) * cos(theta);
    double y = cos(phi);
    double z = sin(phi) * sin(theta);
    return _Vec3(x, y, z);
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
      backgroundColor: const Color(0xFF020205), // 深邃黑背景
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          setState(() {
            _isPaperSpreadMode = !_isPaperSpreadMode;
          });
        },
        backgroundColor: Colors.white.withOpacity(0.15),
        elevation: 0,
        icon: Icon(
            _isPaperSpreadMode ? Icons.layers : Icons.grain,
            color: Colors.white
        ),
        label: Text(
          _isPaperSpreadMode ? "模式: 纸张铺开" : "模式: 随机破碎",
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final center = Offset(constraints.maxWidth / 2, constraints.maxHeight / 2);

          return MouseRegion(
            onHover: (d) => _mousePos = d.localPosition,
            onExit: (_) => _mousePos = const Offset(-1000, -1000),
            child: GestureDetector(
              onPanUpdate: (d) => _mousePos = d.localPosition,
              onPanEnd: (_) => _mousePos = const Offset(-1000, -1000),
              child: CustomPaint(
                size: Size.infinite,
                painter: _BreathingSpherePainter(
                  tiles: _tiles,
                  radius: _radius,
                  rotX: _rotX,
                  baseRotY: _baseRotY,
                  time: _time,
                  breathProgress: _breathProgress,
                  activeBurstCenter: _activeBurstCenter,
                  center: center,
                  mousePos: _mousePos,
                  isPaperSpreadMode: _isPaperSpreadMode,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// --- 4. 渲染器 ---
class _BreathingSpherePainter extends CustomPainter {
  final List<_GridTile> tiles;
  final double radius;
  final double rotX;
  final double baseRotY;
  final double time;

  final double breathProgress;
  final _Vec3 activeBurstCenter;

  final Offset center;
  final Offset mousePos;
  final bool isPaperSpreadMode;

  _BreathingSpherePainter({
    required this.tiles,
    required this.radius,
    required this.rotX,
    required this.baseRotY,
    required this.time,
    required this.breathProgress,
    required this.activeBurstCenter,
    required this.center,
    required this.mousePos,
    required this.isPaperSpreadMode,
  });

  // 噪点函数用于呼吸时的边缘散开
  double _pseudoNoise(double x, double y, double z, double t) {
    double n = sin(x * 5.5 + t) + sin(y * 4.5 + t * 1.2) + cos(z * 5.0 + t * 0.8);
    return (n / 3.0 + 1.0) / 2.0;
  }

  @override
  void paint(Canvas canvas, Size size) {
    const double fov = 500.0;
    final List<_RenderQuad> renderList = [];

    // --- 【修改点 2】光照方向改为上方偏前，制造顶部高光 ---
    final _Vec3 lightDir = _Vec3(0.0, -0.5, -0.8).normalize();
    final _Vec3 viewDir = _Vec3(0.0, 0.0, -1.0);

    final cosX = cos(rotX); final sinX = sin(rotX);

    double currentBreathIntensity = sin(breathProgress);
    if (breathProgress <= 0.001 || breathProgress >= pi - 0.001) {
      currentBreathIntensity = 0.0;
    }

    for (var tile in tiles) {
      double tileRotY = baseRotY * tile.rotationSpeedMultiplier;
      tileRotY += sin(time + tile.rowIndex) * 0.02;

      final cosY = cos(tileRotY);
      final sinY = sin(tileRotY);

      _Vec3 worldCenter = _rotate(tile.centerBase, cosX, sinX, cosY, sinY);

      // --- 位置偏移逻辑 ---
      double totalOffset = tile.currentOffset;
      double globalWobble = 0.0;
      double burstOffset = 0.0;

      if (currentBreathIntensity > 0.0) {
        globalWobble = sin(worldCenter.y * 3.0 + time * 5.0) * 4.0 * currentBreathIntensity;
        double distToGlitch = worldCenter.distanceTo(activeBurstCenter);
        if (distToGlitch < 0.7) {
          double distFactor = (0.7 - distToGlitch) / 0.7;
          double noise = _pseudoNoise(worldCenter.x, worldCenter.y, worldCenter.z, 0.0);
          burstOffset = distFactor * noise * 35.0 * currentBreathIntensity;
        }
      }

      double currentRadius = radius + globalWobble;
      totalOffset += burstOffset;

      // 交互
      if (worldCenter.z < 0.3) {
        double zC = worldCenter.z * currentRadius;
        double scaleC = fov / (fov + zC + currentRadius * 3.5);
        double cx = worldCenter.x * currentRadius * scaleC + center.dx;
        double cy = worldCenter.y * currentRadius * scaleC + center.dy;

        double dist = (Offset(cx, cy) - mousePos).distance;
        if (dist < 85.0) {
          double force = (85.0 - dist) / 85.0;
          tile.currentOffset += force * 15.0;
          tile.currentOffset = min(tile.currentOffset, 160.0);
        }
      }

      // --- 几何形态 ---
      _Vec3 finalCenterPos;
      List<_Vec3> finalVertices = [];
      _Vec3 basePos = worldCenter * currentRadius;

      if (isPaperSpreadMode) {
        _Vec3 flyDir = (worldCenter + tile.noiseDir * 0.2).normalize();
        finalCenterPos = basePos + flyDir * totalOffset;
        for (var vBase in tile.vertices) {
          _Vec3 vRot = _rotate(vBase, cosX, sinX, cosY, sinY);
          _Vec3 vLocal = (vRot - worldCenter) * radius;
          finalVertices.add(finalCenterPos + vLocal);
        }
      } else {
        _Vec3 flyDir = (worldCenter + tile.noiseDir).normalize();
        finalCenterPos = basePos + flyDir * totalOffset;
        double tumbleAngle = totalOffset * 0.08;
        bool shouldTumble = totalOffset > 1.0;
        double cT = 1, sT = 0, one_cT = 0, ux=0, uy=0, uz=0;
        if (shouldTumble) {
          cT = cos(tumbleAngle); sT = sin(tumbleAngle); one_cT = 1 - cT;
          ux = tile.tumbleAxis.x; uy = tile.tumbleAxis.y; uz = tile.tumbleAxis.z;
        }
        for (var vBase in tile.vertices) {
          _Vec3 vRot = _rotate(vBase, cosX, sinX, cosY, sinY);
          _Vec3 vLocal = (vRot - worldCenter) * radius;
          if (shouldTumble) {
            double dot = vLocal.x * ux + vLocal.y * uy + vLocal.z * uz;
            double rx = ux * dot * one_cT + vLocal.x * cT + (uy * vLocal.z - uz * vLocal.y) * sT;
            double ry = uy * dot * one_cT + vLocal.y * cT + (uz * vLocal.x - ux * vLocal.z) * sT;
            double rz = uz * dot * one_cT + vLocal.z * cT + (ux * vLocal.y - uy * vLocal.x) * sT;
            vLocal = _Vec3(rx, ry, rz);
          }
          finalVertices.add(finalCenterPos + vLocal);
        }
      }

      // --- 投影 ---
      Path path = Path();
      bool first = true;
      for (var v in finalVertices) {
        double depth = v.z + radius * 3.5;
        if (depth < 1.0) depth = 1.0;
        double scale = fov / depth;
        double px = v.x * scale + center.dx;
        double py = v.y * scale + center.dy;
        if (first) { path.moveTo(px, py); first = false; } else { path.lineTo(px, py); }
      }
      path.close();

      // --- 【修改点 3】PBR 金属光照计算 ---

      // 法线与朝向
      _Vec3 rotShimmer = _rotate(tile.shimmerNormal, cosX, sinX, cosY, sinY);
      _Vec3 normal = (worldCenter + rotShimmer * 0.3).normalize();

      // 1. 漫反射 (Diffuse)
      double dotL = normal.dot(lightDir);
      double diffuse = max(0.0, -dotL);

      // 2. 镜面反射 (Specular) - 锐利高光
      _Vec3 halfDir = (viewDir - lightDir).normalize();
      double specAngle = max(0.0, normal.dot(halfDir));
      double specular = pow(specAngle, 32.0).toDouble(); // 32.0 使高光更锐利

      // 3. 亮度计算
      double brightness = 0.2 + diffuse * 0.6 + specular * 0.8;

      // 呼吸增强
      if (burstOffset > 2.0) {
        brightness += 0.5 * currentBreathIntensity;
        specular += 0.5 * currentBreathIntensity;
      }

      // 4. 颜色混合
      Color base = tile.baseColor;
      Color shaded = Color.fromARGB(
          255,
          (base.red * brightness).clamp(0, 255).toInt(),
          (base.green * brightness).clamp(0, 255).toInt(),
          (base.blue * brightness).clamp(0, 255).toInt()
      );

      Color finalColor;
      // 叠加白色镜面光
      if (specular > 0.1) {
        finalColor = Color.lerp(shaded, Colors.white, min(specular, 1.0))!;
      } else {
        finalColor = shaded;
      }

      renderList.add(_RenderQuad(finalCenterPos.z, path, finalColor));
    }

    renderList.sort((a, b) => b.zDepth.compareTo(a.zDepth));

    Paint paint = Paint()..style = PaintingStyle.fill;
    // 使用微弱的深色描边增强立体分割感
    Paint stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5
      ..color = Colors.black.withOpacity(0.3)
      ..strokeJoin = StrokeJoin.bevel;

    for (var quad in renderList) {
      paint.color = quad.color;
      canvas.drawPath(quad.path, paint);
      if (quad.zDepth < 0.5) {
        canvas.drawPath(quad.path, stroke);
      }
    }
  }

  _Vec3 _rotate(_Vec3 v, double cosX, double sinX, double cosY, double sinY) {
    double x1 = v.x * cosY - v.z * sinY;
    double z1 = v.z * cosY + v.x * sinY;
    double y1 = v.y;
    double y2 = y1 * cosX - z1 * sinX;
    double z2 = z1 * cosX + y1 * sinX;
    double x2 = x1;
    return _Vec3(x2, y2, z2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}