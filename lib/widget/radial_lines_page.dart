import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:vector_math/vector_math_64.dart' as vector;



///
/// 代码解析
/// RadialLinesPage:
///
/// 这是一个 StatefulWidget，使用 Ticker 来模拟 update 循环。
///
/// _noiseStep 变量控制动画的时间维度，每一帧减少 0.005，这与原文 this->noise_step -= 0.005 对应。
///
/// _noiseSeed 用于在不同轴上采样不同的噪声空间，保持结构一致性。
///
/// RadialLinesPainter:
///
/// 主循环：从 size=20 到 3000，步长 10。这模拟了原文中从小立方体到大立方体的扩展。
///
/// 噪声映射：
///
/// 使用 _perlin.noise 获取 0.0-1.0 的值。
///
/// mapDeg 函数复刻了 C++ 代码中的逻辑：如果噪声值小于 0.5，映射到 -270°~0°；如果大于 0.5，映射到 0°~270°。这种非线性的映射创造了那种"突然转向"或"直角折线"的机械感。
///
/// 旋转矩阵：
///
/// 构建 rotX, rotY, rotZ 并组合。注意 Flutter vector_math 库的矩阵操作通常是左乘（M * v），代码中顺序调整为 Rz * Ry * Rx 以匹配原文逻辑。
///
/// 绘制：
///
/// 计算出当前层 8 个顶点的 3D 坐标。
///
/// _project 函数将 3D 坐标 (x, y, z) 转换为 2D 屏幕坐标 (x, y)。
///
/// 连接当前层顶点与上一层顶点 (beforeVertices)，形成连续的触须状线条。
///
/// 颜色根据大小从白色 (239) 渐变到深灰 (39)。
///
/// PerlinNoise:
///
/// 这是一个标准的、自包含的 Ken Perlin 改进版噪声算法实现。它不依赖外部包，确保你可以直接运行代码。它将原本 -1.0 ~ 1.0 的输出归一化到了 0.0 ~ 1.0 以匹配 openFrameworks 的 ofNoise 行为。
///
///
class RadialLinesPage extends StatefulWidget {
  const RadialLinesPage({super.key});

  @override
  State<RadialLinesPage> createState() => _RadialLinesPageState();
}

class _RadialLinesPageState extends State<RadialLinesPage>
    with SingleTickerProviderStateMixin {
  late Ticker _ticker;
  double _noiseStep = 0.0;
  int _frameNum = 0;
  // 固定随机种子，模拟原文中的 ofSeedRandom(39) 导致每一帧 noise_seed 相同
  final vector.Vector3 _noiseSeed = vector.Vector3(
    math.Random(39).nextDouble() * 1000,
    math.Random(39 + 1).nextDouble() * 1000,
    math.Random(39 + 2).nextDouble() * 1000,
  );

  @override
  void initState() {
    super.initState();
    _noiseStep = math.Random().nextDouble() * 1000; // setup 中的随机初始化
    _ticker = createTicker((elapsed) {
      setState(() {
        // update 逻辑
        _noiseStep -= 0.005;
        _frameNum++;
      });
    });
    _ticker.start();
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
      backgroundColor: const Color.fromARGB(255, 39, 39, 39),
      body: CustomPaint(
        painter: RadialLinesPainter(
          noiseStep: _noiseStep,
          frameNum: _frameNum,
          noiseSeed: _noiseSeed,
        ),
        child: Container(),
      ),
    );
  }
}

class RadialLinesPainter extends CustomPainter {
  final double noiseStep;
  final int frameNum;
  final vector.Vector3 noiseSeed;

  RadialLinesPainter({
    required this.noiseStep,
    required this.frameNum,
    required this.noiseSeed,
  });

  // 简易 Perlin Noise 实例
  final _perlin = PerlinNoise();

  @override
  void paint(Canvas canvas, Size size) {
    // 屏幕中心
    final center = vector.Vector2(size.width / 2, size.height / 2);

    // 全局旋转 (ofRotateY(ofGetFrameNum() * 0.72))
    final globalRotationY = frameNum * 0.72 * vector.degrees2Radians;
    final globalRotMat = vector.Matrix4.rotationY(globalRotationY);

    // 存储上一层的顶点，用于连线
    List<vector.Vector3> beforeVertices = [];

    // 循环逻辑: for (int size = 20; size < 3000; size += 10)
    for (int boxSize = 20; boxSize < 3000; boxSize += 10) {
      // 计算噪声值 (ofNoise)
      // 注意：ofNoise 返回 0.0-1.0，这里的 PerlinNoise 实现也归一化到 0-1
      double xValue = _perlin.noise(noiseSeed.x, boxSize * 0.00015 + noiseStep);
      double yValue = _perlin.noise(noiseSeed.y, boxSize * 0.00015 + noiseStep);
      double zValue = _perlin.noise(noiseSeed.z, boxSize * 0.00015 + noiseStep);

      // 角度映射逻辑
      double mapDeg(double val) {
        if (val < 0.5) {
          // map(val, 0, 0.5, -270, 0)
          return -270 + (val / 0.5) * 270;
        } else if (val > 0.5) {
          // map(val, 0.5, 1, 0, 270)
          return 0 + ((val - 0.5) / 0.5) * 270;
        }
        return 0;
      }

      double xDeg = mapDeg(xValue);
      double yDeg = mapDeg(yValue);
      double zDeg = mapDeg(zValue);

      // 构建旋转矩阵
      // 原文顺序: vertex * rotation_z * rotation_y * rotation_x (行向量右乘)
      // 等价于列向量左乘: Rx * Ry * Rz * v ???
      // 实际上 C++ GLM 中 vec4 * mat4 是行向量乘法。
      // v_new = v * M = v * (Rz * Ry * Rx) -> 意味着先应用 Rx，再 Ry，再 Rz。
      // 在 Dart vector_math 中，applyMatrix4 是左乘 v = M * v。
      // 所以我们要构建 M = Rz * Ry * Rx，并计算 v = M * v。

      var rotX = vector.Matrix4.rotationX(xDeg * vector.degrees2Radians);
      var rotY = vector.Matrix4.rotationY(yDeg * vector.degrees2Radians);
      var rotZ = vector.Matrix4.rotationZ(zDeg * vector.degrees2Radians);

      // 复合旋转矩阵 M = Rz * Ry * Rx
      var combinedRot = rotZ.clone();
      combinedRot.multiply(rotY);
      combinedRot.multiply(rotX);

      // 生成当前尺寸的立方体 8 个顶点
      double s = boxSize * 0.5;
      List<vector.Vector3> currentVertices = [
        vector.Vector3(s, s, s),
        vector.Vector3(s, -s, s),
        vector.Vector3(-s, s, s),
        vector.Vector3(-s, -s, s),
        vector.Vector3(s, s, -s),
        vector.Vector3(s, -s, -s),
        vector.Vector3(-s, s, -s),
        vector.Vector3(-s, -s, -s),
      ];

      // 对每个顶点应用局部旋转和全局旋转
      for (var v in currentVertices) {
        // 1. 局部噪声旋转
        v.applyMatrix4(combinedRot);
        // 2. 全局 Y 轴自转
        v.applyMatrix4(globalRotMat);
      }

      // 颜色映射 ofMap(size, 30, 3000, 239, 39)
      // 239 (near white) -> 39 (dark grey)
      double t = (boxSize - 30) / (3000 - 30);
      t = t.clamp(0.0, 1.0);
      int colorVal = (239 * (1 - t) + 39 * t).toInt();
      Paint linePaint = Paint()
        ..color = Color.fromARGB(255, colorVal, colorVal, colorVal)
        ..strokeWidth = 1.0
        ..style = PaintingStyle.stroke;

      // 绘制连线
      if (beforeVertices.isNotEmpty) {
        for (int i = 0; i < 8; i++) {
          // 简单的透视投影
          Offset p1 = _project(currentVertices[i], center);
          Offset p2 = _project(beforeVertices[i], center);
          canvas.drawLine(p1, p2, linePaint);
        }
      }

      beforeVertices = currentVertices;
    }
  }

  // 简单的透视投影函数
  Offset _project(vector.Vector3 v, vector.Vector2 center) {
    // 模拟相机距离
    double fov = 300.0;
    double distance = 800.0; // 相机距离物体的距离

    // 透视除法
    // 坐标系: Flutter Y 向下, OpenFrameworks Y 向下 (2D) / 向上 (3D)
    // 这里的 3D Y 轴在旋转时表现一致即可
    double scale = fov / (distance + v.z);

    return Offset(
      center.x + v.x * scale,
      center.y + v.y * scale, // 如果觉得方向反了可以 - v.y
    );
  }

  @override
  bool shouldRepaint(covariant RadialLinesPainter oldDelegate) {
    return oldDelegate.frameNum != frameNum;
  }
}

/// 一个简单的 2D Perlin Noise 实现 (简化版，仅用于本效果)
class PerlinNoise {
  final List<int> p = List.generate(512, (index) => 0);

  PerlinNoise() {
    var permutation = [
      151,160,137,91,90,15,131,13,201,95,96,53,194,233,7,225,140,36,103,30,69,142,
      8,99,37,240,21,10,23,190,6,148,247,120,234,75,0,26,197,62,94,252,219,203,117,
      35,11,32,57,177,33,88,237,149,56,87,174,20,125,136,171,168,68,175,74,165,71,
      134,139,48,27,166,77,146,158,231,83,111,229,122,60,211,133,230,220,105,92,41,
      55,46,245,40,244,102,143,54,65,25,63,161,1,216,80,73,209,76,132,187,208,89,
      18,169,200,196,135,130,116,188,159,86,164,100,109,198,173,186,3,64,52,217,226,
      250,124,123,5,202,38,147,118,126,255,82,85,212,207,206,59,227,47,16,58,17,182,
      189,28,42,223,183,170,213,119,248,152,2,44,154,163,70,221,153,101,155,167,43,
      172,9,129,22,39,253,19,98,108,110,79,113,224,232,178,185,112,104,218,246,97,
      228,251,34,242,193,238,210,144,12,191,179,162,241,81,51,145,235,249,14,239,
      107,49,192,214,31,181,199,106,157,184,84,204,176,115,121,50,45,127,4,150,254,
      138,236,205,93,222,114,67,29,24,72,243,141,128,195,78,66,215,61,156,180
    ];
    for (int i = 0; i < 256; i++) {
      p[i] = permutation[i];
      p[256 + i] = permutation[i];
    }
  }

  double fade(double t) => t * t * t * (t * (t * 6 - 15) + 10);
  double lerp(double t, double a, double b) => a + t * (b - a);
  double grad(int hash, double x, double y, double z) {
    int h = hash & 15;
    double u = h < 8 ? x : y;
    double v = h < 4 ? y : h == 12 || h == 14 ? x : z;
    return ((h & 1) == 0 ? u : -u) + ((h & 2) == 0 ? v : -v);
  }

  // 标准 3D Noise，此处为了适配 ofNoise(x, y) 使用 z=0 或简单 2D 变体
  // openFrameworks 的 ofNoise 实际上是 Perlin Noise
  double noise(double x, double y, [double z = 0]) {
    int X = x.floor() & 255;
    int Y = y.floor() & 255;
    int Z = z.floor() & 255;
    x -= x.floor();
    y -= y.floor();
    z -= z.floor();
    double u = fade(x);
    double v = fade(y);
    double w = fade(z);
    // ignore: non_constant_identifier_names
    int A = p[X] + Y, AA = p[A] + Z, AB = p[A + 1] + Z;
    // ignore: non_constant_identifier_names
    int B = p[X + 1] + Y, BA = p[B] + Z, BB = p[B + 1] + Z;

    double res = lerp(w, lerp(v, lerp(u, grad(p[AA], x, y, z), grad(p[BA], x - 1, y, z)),
        lerp(u, grad(p[AB], x, y - 1, z), grad(p[BB], x - 1, y - 1, z))),
        lerp(v, lerp(u, grad(p[AA + 1], x, y, z - 1), grad(p[BA + 1], x - 1, y, z - 1)),
            lerp(u, grad(p[AB + 1], x, y - 1, z - 1), grad(p[BB + 1], x - 1, y - 1, z - 1))));

    // 归一化到 0.0 - 1.0 (Perlin 原生约为 -1 到 1)
    return (res + 1.0) / 2.0;
  }
}