import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

void main() {
  runApp(const MaterialApp(home: ParticleMorphingPage()));
}

// 定义形状枚举
enum ParticleShape { sphere, cube, torus, heart }

class ParticleMorphingPage extends StatefulWidget {
  const ParticleMorphingPage({super.key});

  @override
  State<ParticleMorphingPage> createState() => _ParticleMorphingPageState();
}

class _ParticleMorphingPageState extends State<ParticleMorphingPage>
    with SingleTickerProviderStateMixin {
  static const int particleCount = 6000;

  late List<Vector3> _particles;
  late List<List<Vector3>> _shapePositions;
  late Ticker _ticker;
  double _rotationY = 0.0;

  // 【新增】控制分布模式的状态变量
  // false = 随机分布 (Random / Rejection Sampling)
  // true = 有序分布 (Structured / Grid Parametric)
  bool _isStructured = false;

  final PageController _pageController = PageController();
  double _currentPage = 0.0;

  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();
    _particles = List.generate(particleCount, (_) => Vector3(0, 0, 0));

    // 初始化生成所有形状
    _regenerateAllShapes();

    // 初始位置设为球体
    for (int i = 0; i < particleCount; i++) {
      _particles[i] = _shapePositions[0][i];
    }

    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page ?? 0;
      });
    });

    // 3. 启动旋转动画循环
    _ticker = createTicker((elapsed) {
      // 只有当【不在】变形动画时，才更新角度
      // 这样变形过程中，角度会保持不变（暂停）
      if (!_isAnimating) {
        setState(() {
          _rotationY += 0.02;
        });
      }
    });
    _ticker.start();
  }

  // --- 翻页逻辑 ---

  // --- 翻页逻辑 ---

  void _prevPage() {
    if (_currentPage > 0 && !_isAnimating) {
      setState(() {
        _isAnimating = true; // 1. 标记开始变形，暂停自转 (定格在当前角度)
        // 删掉了 _rotationY = 0.0;  <-- 关键！不重置角度
      });

      _pageController
          .previousPage(
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOutCubic,
      )
          .then((_) {
        // 2. 动画结束后，恢复自转
        setState(() {
          _isAnimating = false;
        });
      });
    }
  }

  void _nextPage() {
    if (_currentPage < 3 && !_isAnimating) {
      setState(() {
        _isAnimating = true; // 1. 标记开始变形，暂停自转 (定格在当前角度)
        // 删掉了 _rotationY = 0.0;  <-- 关键！不重置角度
      });

      _pageController
          .nextPage(
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOutCubic,
      )
          .then((_) {
        // 2. 动画结束后，恢复自转
        setState(() {
          _isAnimating = false;
        });
      });
    }
  }

  // 【新增】统一重新生成形状的方法
  void _regenerateAllShapes() {
    _shapePositions = [
      _generateSphere(particleCount),
      _generateCube(particleCount),
      _generateTorus(particleCount),
      _generateHeart(particleCount), // 这里会根据 _isStructured 决定算法
    ];
  }

  // 【新增】切换模式的方法
  void _toggleDistribution() {
    setState(() {
      _isStructured = !_isStructured;
      // 切换后重新计算坐标
      _regenerateAllShapes();
    });
  }

  @override
  void dispose() {
    _ticker.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      // 保持之前的切换分布模式按钮
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _toggleDistribution,
        backgroundColor: Colors.white12,
        // 稍微调暗一点，以免抢视觉
        elevation: 0,
        icon: Icon(
          _isStructured ? Icons.grid_3x3 : Icons.blur_on,
          color: Colors.white,
        ),
        label: Text(
          _isStructured ? "当前: 有序网格" : "当前: 随机分布",
          style: const TextStyle(color: Colors.white),
        ),
      ),

      body: Stack(
        children: [
          // 1. 粒子渲染层 (底层)
          Positioned.fill(
            child: CustomPaint(
              painter: ParticlePainter(
                particles: _shapePositions,
                progress: _currentPage,
                rotationY: _rotationY,
                count: particleCount,
              ),
            ),
          ),

          NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                if (notification is ScrollStartNotification) {
                  // 手指按下去，开始滑动 -> 暂停旋转
                  setState(() {
                    _isAnimating = true;
                  });
                } else if (notification is ScrollEndNotification) {
                  // 手指松开，滑动结束 -> 恢复旋转
                  setState(() {
                    _isAnimating = false;
                  });
                }
                return false;
              },
              child: PageView.builder(
                controller: _pageController,
                // 禁止用户手动划动，强制使用按钮 (可选，看你喜好)
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 4,
                itemBuilder: (context, index) {
                  return Container(
                    alignment: Alignment.bottomCenter,
                    padding: const EdgeInsets.only(bottom: 50),
                    child: Text(
                      _getShapeName(index),
                      style: const TextStyle(
                          color: Colors.white30, // 文字淡一点，更有科技感
                          fontSize: 24,
                          letterSpacing: 4, // 增加字间距
                          fontWeight: FontWeight.w300),
                    ),
                  );
                },
              )),

          // 3. 左侧切换按钮
          Positioned(
            left: 20,
            top: 0,
            bottom: 0,
            child: Center(
              child: IconButton(
                onPressed: _prevPage,
                iconSize: 48,
                icon:
                    const Icon(Icons.arrow_back_ios_new, color: Colors.white24),
                // 鼠标悬停变亮的效果
                style: ButtonStyle(
                  overlayColor: WidgetStateProperty.all(Colors.white10),
                ),
              ),
            ),
          ),

          // 4. 右侧切换按钮
          Positioned(
            right: 20,
            top: 0,
            bottom: 0,
            child: Center(
              child: IconButton(
                onPressed: _nextPage,
                iconSize: 48,
                icon:
                    const Icon(Icons.arrow_forward_ios, color: Colors.white24),
                style: ButtonStyle(
                  overlayColor: WidgetStateProperty.all(Colors.white10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getShapeName(int index) {
    switch (index) {
      case 0:
        return "SPHERE";
      case 1:
        return "CUBE";
      case 2:
        return "TORUS";
      case 3:
        return "HEART";
      default:
        return "";
    }
  }

  // --- 形状生成算法 ---
// 1. 球体 (支持有序/随机切换)
  List<Vector3> _generateSphere(int count) {
    final points = <Vector3>[];

    if (_isStructured) {
      // --- 有序模式：斐波那契螺旋 ---
      // 这里的点是按照黄金分割率排列的，没有任何重叠，
      // 形成非常完美的螺旋纹理，看起来像高科技的护盾。
      final double phi = (sqrt(5) - 1) / 2;
      for (int i = 0; i < count; i++) {
        final double z = (2 * i - (count - 1)) / count;
        final double radius = sqrt(1 - z * z);
        final double theta = 2 * pi * i * phi;
        points.add(Vector3(radius * cos(theta), radius * sin(theta), z));
      }
    } else {
      // --- 随机模式：球面均匀随机采样 ---
      // 这里的点是完全随机的，看起来像一团发光的雾气或磨砂玻璃球。
      // 我们不能直接随机经纬度（那样极点会太密），需要使用正确的数学公式。
      final random = Random();
      for (int i = 0; i < count; i++) {
        // 1. 随机生成 Z 轴高度 (-1 到 1)
        double z = (random.nextDouble() * 2) - 1;

        // 2. 随机生成水平角度 (0 到 2PI)
        double theta = random.nextDouble() * 2 * pi;

        // 3. 根据 Z 计算当前截面的半径 r
        // r = sqrt(1 - z^2)
        double r = sqrt(1 - z * z);

        points.add(Vector3(r * cos(theta), r * sin(theta), z));
      }
    }
    return points;
  }

  List<Vector3> _generateCube(int count) {
    final points = <Vector3>[];

    // 【修改】立方体也支持切换
    if (_isStructured) {
      // 有序：简单的晶格排列
      int side = pow(count, 1 / 3).floor();
      double step = 1.6 / side;
      for (int x = 0; x < side; x++) {
        for (int y = 0; y < side; y++) {
          for (int z = 0; z < side; z++) {
            points.add(Vector3(x * step - 0.8, y * step - 0.8, z * step - 0.8));
          }
        }
      }
      // 补齐剩余点（简单重叠）
      while (points.length < count) {
        points.add(points.last);
      }
    } else {
      // 随机：原来的算法
      final random = Random();
      for (int i = 0; i < count; i++) {
        int face = random.nextInt(6);
        double u = random.nextDouble() * 2 - 1;
        double v = random.nextDouble() * 2 - 1;
        double x = 0, y = 0, z = 0;
        switch (face) {
          case 0:
            x = 1;
            y = u;
            z = v;
            break;
          case 1:
            x = -1;
            y = u;
            z = v;
            break;
          case 2:
            x = u;
            y = 1;
            z = v;
            break;
          case 3:
            x = u;
            y = -1;
            z = v;
            break;
          case 4:
            x = u;
            y = v;
            z = 1;
            break;
          case 5:
            x = u;
            y = v;
            z = -1;
            break;
        }
        points.add(Vector3(x * 0.8, y * 0.8, z * 0.8));
      }
    }
    return points;
  }

// 3. 圆环 (Torus - Seamless/无缝闭合版)
  List<Vector3> _generateTorus(int count) {
    final points = <Vector3>[];
    const double R = 1.0; // 主半径
    const double r = 0.4; // 管半径

    if (_isStructured) {
      // --- 有序模式 ---
      // 关键修复：强制使用能整除 8000 的行列数
      // 这样循环结束时，刚好画完最后一圈，不会因为截断而产生缝隙

      int rings = 100; // 大圈切分 100 份
      int steps = count ~/ rings; // 8000 / 100 = 80 份

      for (int i = 0; i < rings; i++) {
        // v: 沿着大圈的角度 (0 -> 2pi)
        double v = (i / rings) * 2 * pi;

        for (int j = 0; j < steps; j++) {
          // u: 沿着管子截面的角度 (0 -> 2pi)
          double u = (j / steps) * 2 * pi;

          points.add(Vector3((R + r * cos(u)) * cos(v),
              (R + r * cos(u)) * sin(v), r * sin(u)));
        }
      }

      // 理论上不需要补齐，但为了防止 count 被改成奇数导致崩溃，加个保险
      while (points.length < count) {
        points.add(points.last);
      }
    } else {
      // --- 随机模式 ---
      final random = Random();
      for (int i = 0; i < count; i++) {
        double u = random.nextDouble() * 2 * pi;
        double v = random.nextDouble() * 2 * pi;
        points.add(Vector3(
            (R + r * cos(u)) * cos(v), (R + r * cos(u)) * sin(v), r * sin(u)));
      }
    }
    return points;
  }

  // 4. 爱心 (Unified Projection - 统一投影版)
  // 彻底解决了“不规则模式瓣缺失”的问题。
  // 现在，【有序模式】和【随机模式】都使用相同的“射线探测法”来确定形状。
  // 区别仅在于：
  // - 有序模式：射线方向是按斐波那契螺旋排列的 (产生纹理)。
  // - 随机模式：射线方向是球面均匀随机分布的 (产生磨砂感)。
  List<Vector3> _generateHeart(int count) {
    final points = <Vector3>[];

    // --- 形状参数 (保持完全一致) ---
    const double finalScale = 0.55;
    const double stretchX = 1.25;
    const double stretchZ = 0.6;

    final random = Random();
    final double goldenRatio = (1 + sqrt(5)) / 2;

    for (int i = 0; i < count; i++) {
      double theta, phi;

      if (_isStructured) {
        // === 模式 A：有序 (斐波那契) ===
        // 固定的螺旋路径
        double t = 1 - 2 * (i / (count - 1));
        theta = acos(t);
        phi = 2 * pi * i / goldenRatio;
      } else {
        // === 模式 B：无序 (随机球体分布) ===
        // 随机生成方向，但保证在球面上是均匀的，不会聚成一团
        // acos(2*rand - 1) 是标准的球体均匀分布公式
        double t = (random.nextDouble() * 2) - 1;
        theta = acos(t);
        phi = random.nextDouble() * 2 * pi;
      }

      // 1. 计算射线方向
      double dx = sin(theta) * cos(phi);
      double dy = sin(theta) * sin(phi);
      double dz = cos(theta);

      Vector3 dir = Vector3(dx, dz, dy);

      // 2. 核心：用射线去探测爱心表面
      // 因为是主动去“找”表面，所以无论瓣有多薄，都能找到点！
      double r = _solveHeartRadius(dir);

      // 3. 处理随机模式的厚度
      // 如果是随机模式，我们给 radius 加一点点随机扰动，
      // 让它不要全贴在表面，而是像一层厚厚的雾 (0.9 ~ 1.0 之间)
      if (!_isStructured) {
        // 只保留外层 10% 的厚度，保证轮廓清晰
        r *= (0.9 + random.nextDouble() * 0.1);
      }

      double x = dir.x * r;
      double y = dir.y * r;
      double z = dir.z * r;

      points.add(Vector3(x * finalScale * stretchX, -y * finalScale,
          z * finalScale * stretchZ));
    }

    return points;
  }

  // 辅助函数：极限参数调优
  double _solveHeartRadius(Vector3 dir) {
    double minR = 0.0;
    double maxR = 5.0;
    double midR = 0.0;

    for (int k = 0; k < 100; k++) {
      midR = (minR + maxR) / 2;

      double x = dir.x * midR;
      double y = dir.y * midR;
      double z = dir.z * midR;

      double x2 = x * x;
      double y2 = y * y;
      double z2 = z * z;
      double y3 = y2 * y;

      // 【核心修改】

      // 1. 高度拉伸：
      //    将 y^2 的系数从 1.2 降到 0.8。
      //    系数越小，图形在y轴上就越放松、越能长高。
      double group = x2 + (1.2 * z2) + (0.8 * y2) - 1;

      // 2. 深度挖掘：
      //    将 x^2*y^3 的系数从 1.6 直接加到 3.0！
      //    这是极其暴力的挖掘，会让顶部的裂痕深不见底，两边的瓣会高高耸立。
      double value =
          (group * group * group) - (3.0 * x2 * y3) - (0.1 * z2 * y3);

      if (value < 0) {
        minR = midR;
      } else {
        maxR = midR;
      }
    }
    return midR;
  }
}

// 简单的 3D 向量类，避免引入 vector_math 库让代码看起来复杂
class Vector3 {
  final double x, y, z;

  Vector3(this.x, this.y, this.z);

  // 向量线性插值
  static Vector3 lerp(Vector3 a, Vector3 b, double t) {
    return Vector3(
      a.x + (b.x - a.x) * t,
      a.y + (b.y - a.y) * t,
      a.z + (b.z - a.z) * t,
    );
  }
}

class ParticlePainter extends CustomPainter {
  final List<List<Vector3>> particles;
  final double progress;
  final double rotationY;
  final int count;

  ParticlePainter({
    required this.particles,
    required this.progress,
    required this.rotationY,
    required this.count,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final maxRadius = min(size.width, size.height) / 2;

    // 画笔设置：白色，加法混合模式（发光效果关键）
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.6)
      ..blendMode = BlendMode.plus // Additive blending for "glow"
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    // 确定当前的两个形状索引和插值进度
    int firstShapeIndex = progress.floor();
    int secondShapeIndex = (firstShapeIndex + 1).clamp(0, particles.length - 1);
    double t = progress - firstShapeIndex;

    // 防止越界
    if (firstShapeIndex >= particles.length - 1) {
      firstShapeIndex = particles.length - 1;
      secondShapeIndex = particles.length - 1;
      t = 0.0;
    }

    // 缓存 cos/sin 减少重复计算
    final cosY = cos(rotationY);
    final sinY = sin(rotationY);
    final cosX = cos(rotationY * 0.5); // 给一点 X 轴倾斜
    final sinX = sin(rotationY * 0.5);

    // 绘制点
    // 这里使用 drawPoints 会比循环 drawCircle 快得多
    // 但为了处理深度（Z-sorting）或者简单起见，我们直接画
    final List<Offset> pointsToDraw = [];

    for (int i = 0; i < count; i++) {
      // 1. 插值计算当前 3D 位置
      final p1 = particles[firstShapeIndex][i];
      final p2 = particles[secondShapeIndex][i];

      // 手动 Lerp
      double px = p1.x + (p2.x - p1.x) * t;
      double py = p1.y + (p2.y - p1.y) * t;
      double pz = p1.z + (p2.z - p1.z) * t;

      // 2. 旋转 (绕 Y 轴 和 稍微绕 X 轴)
      // 绕 Y 轴旋转公式: x' = x*cos - z*sin, z' = x*sin + z*cos
      double xRot = px * cosY - pz * sinY;
      double zRot = px * sinY + pz * cosY;

      // 绕 X 轴旋转公式 (让它看起来有点俯视感)
      double yRot = py * cosX - zRot * sinX;
      zRot = py * sinX + zRot * cosX;

      // 3. 透视投影 (Perspective Projection)
      // cameraDistance 越大，透视感越弱
      const double cameraDistance = 3.0;
      double factor = cameraDistance / (cameraDistance - zRot); // 简单的透视除法

      double xScreen = xRot * factor * maxRadius * 0.8 + centerX;
      double yScreen = yRot * factor * maxRadius * 0.8 + centerY;

      pointsToDraw.add(Offset(xScreen, yScreen));
    }

    // 批量绘制
    canvas.drawPoints(ui.PointMode.points, pointsToDraw, paint);
  }

  @override
  bool shouldRepaint(covariant ParticlePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.rotationY != rotationY;
  }
}
