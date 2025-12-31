import 'dart:math';
import 'package:flutter/material.dart';

class _LightBeam {
  bool isHorizontal;
  int index;
  double position;
  double speed;
  double length;
  Color color;

  _LightBeam({
    required this.isHorizontal,
    required this.index,
    required this.position,
    required this.speed,
    required this.length,
    required this.color,
  });
}

class SpatialGridPage extends StatefulWidget {
  const SpatialGridPage({super.key});

  @override
  State<SpatialGridPage> createState() => _SpatialGridPageState();
}

class _SpatialGridPageState extends State<SpatialGridPage>
    with SingleTickerProviderStateMixin {

  Offset _mousePoint = const Offset(0, 0);
  Offset _dragLagPoint = const Offset(0, 0);

  bool _isActive = false;
  bool _isCyberpunkMode = false;

  // [新增 1] 用于驱动连续流动的全局时间变量
  double _time = 0.0;

  late AnimationController _controller;
  final List<_LightBeam> _beams = [];
  final Random _rng = Random();

  final List<Color> _neonColors = [
    Colors.cyanAccent,
    Colors.purpleAccent,
    const Color(0xFF00FF00),
    Colors.white,
    const Color(0xFF00F7FF),
  ];

  @override
  void initState() {
    super.initState();
    _initBeams();
    // controller 只作为一个 tick 驱动器
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..addListener(_onTick)..repeat();
  }

  void _initBeams() {
    _beams.clear();
    for (int i = 0; i < 50; i++) {
      _beams.add(_createRandomBeam());
    }
  }

  _LightBeam _createRandomBeam() {
    bool isHorz = _rng.nextBool();
    int idx = _rng.nextInt(_GridPainter.rows);
    Color color = _neonColors[_rng.nextInt(_neonColors.length)];
    double speed = (2.0 + _rng.nextDouble() * 3.0) * (_rng.nextBool() ? 1 : -1);
    double length = 0.1 + _rng.nextDouble() * 0.2;

    return _LightBeam(
      isHorizontal: isHorz,
      index: idx,
      position: _rng.nextDouble(),
      speed: speed / 100.0,
      length: length,
      color: color,
    );
  }

  void _onTick() {
    // [新增 2] 累加时间
    _time += 0.016; // 大约每帧增加的时间 (60fps)

    if (_isActive) {
      double damping = 0.1;
      double dx = _dragLagPoint.dx + (_mousePoint.dx - _dragLagPoint.dx) * damping;
      double dy = _dragLagPoint.dy + (_mousePoint.dy - _dragLagPoint.dy) * damping;
      _dragLagPoint = Offset(dx, dy);
    }

    if (_isCyberpunkMode) {
      for (var beam in _beams) {
        beam.position += beam.speed;
        if (beam.position > 1.0 + beam.length) {
          beam.position = -beam.length;
        } else if (beam.position < -beam.length) {
          beam.position = 1.0 + beam.length;
        }
      }
    }
    // 确保每帧都重绘以显示动态光效
    setState(() {});
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _updateTouch(Offset localPosition, Size size) {
    final dx = (localPosition.dx / size.width) * 2 - 1;
    final dy = (localPosition.dy / size.height) * 2 - 1;

    _mousePoint = Offset(dx, dy);

    if (!_isActive) {
      _isActive = true;
      _dragLagPoint = _mousePoint;
    }
  }

  void _onPanEnd() {}

  void _toggleTheme() {
    setState(() {
      _isCyberpunkMode = !_isCyberpunkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      backgroundColor: _isCyberpunkMode ? Colors.black : Colors.white,
      floatingActionButton: FloatingActionButton(
        onPressed: _toggleTheme,
        backgroundColor: _isCyberpunkMode ? Colors.grey[900] : Colors.black,
        foregroundColor: _isCyberpunkMode ? Colors.cyanAccent : Colors.white,
        child: Icon(_isCyberpunkMode ? Icons.bolt : Icons.dark_mode),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final size = Size(constraints.maxWidth, constraints.maxHeight);
          return MouseRegion(
            onHover: (event) => _updateTouch(event.localPosition, size),
            onExit: (_) => _onPanEnd(),
            child: GestureDetector(
              onPanUpdate: (details) => _updateTouch(details.localPosition, size),
              onPanDown: (details) => _updateTouch(details.localPosition, size),
              onPanEnd: (_) => _onPanEnd(),
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return CustomPaint(
                    size: Size.infinite,
                    painter: _GridPainter(
                      mousePoint: _mousePoint,
                      lagPoint: _dragLagPoint,
                      isActive: _isActive,
                      isCyberpunkMode: _isCyberpunkMode,
                      beams: _beams,
                      time: _time, // [新增 3] 传入时间
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  final Offset mousePoint;
  final Offset lagPoint;
  final bool isActive;
  final bool isCyberpunkMode;
  final List<_LightBeam> beams;
  final double time; // [新增] 接收时间

  _GridPainter({
    required this.mousePoint,
    required this.lagPoint,
    required this.isActive,
    required this.isCyberpunkMode,
    required this.beams,
    required this.time,
  });

  static const int rows = 60;
  static const int cols = 60;
  static const double spacing = 0.1;

  Offset _project3D(double x, double y, double z, Offset center, Size size) {
    double angleX = pi / 3.5;
    double ry = y * cos(angleX) - z * sin(angleX);
    double rz = y * sin(angleX) + z * cos(angleX);
    double cameraDist = 4.0;
    double perspective = 1.0 / (cameraDist - rz * 0.6);
    return Offset(
        center.dx + x * size.width * 0.45 * perspective,
        center.dy + ry * size.width * 0.45 * perspective
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // 基础画笔配置
    Paint gridCorePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;
    Paint gridGlowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;

    // 预计算一些常量
    final double centerX = mousePoint.dx * 3.0;
    final double centerY = mousePoint.dy * 3.0 * 1.5;
    final double radius = 1.3;
    double tiltX = (mousePoint.dx - lagPoint.dx) * 2.0;
    double tiltY = (mousePoint.dy - lagPoint.dy) * 2.0;

    // --- 1. 计算网格点 (几何计算保持不变) ---
    List<List<Offset>> gridPoints = List.generate(rows, (i) => List.filled(cols, Offset.zero));
    // 用于存储原始未投影坐标，用于后续计算距离
    List<List<Offset>> rawPoints = List.generate(rows, (i) => List.filled(cols, Offset.zero));

    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < cols; j++) {
        double xBase = (j - cols / 2) * spacing;
        double yBase = (i - rows / 2) * spacing;

        double xFinal = xBase;
        double yFinal = yBase;
        double z = 0.0;

        if (isActive) {
          double dx = xBase - centerX;
          double dy = yBase - centerY;
          double dist = sqrt(dx * dx + dy * dy);

          if (dist < radius) {
            double t = dist / radius;
            // Z轴隆起 + 倾斜
            double bulgeHeight = 1.1;
            double baseZ = (1.0 + cos(t * pi)) / 2.0 * bulgeHeight;
            double shear = (dx * tiltX + dy * tiltY) * 1.5 * (1.0 - t);
            z = baseZ + shear;

            // XY轴坍缩
            double smoothT = (1.0 - cos(t * pi)) / 2.0;
            double contraction = 0.35 + (1.0 - 0.35) * smoothT;
            xFinal = centerX + dx * contraction;
            yFinal = centerY + dy * contraction;
          }
        }
        rawPoints[i][j] = Offset(xFinal, yFinal); // 存储原始 2D 坐标
        gridPoints[i][j] = _project3D(xFinal, yFinal, z, center, size);
      }
    }

    // --- 2. 绘制网格 (核心修改：动态能量脉冲) ---
    if (!isCyberpunkMode) {
      // 普通模式简单绘制
      gridCorePaint..color = Colors.black.withOpacity(0.8)..strokeWidth = 1.0;
      for (int i = 0; i < rows; i++) {
        for (int j = 0; j < cols; j++) {
          if (j < cols - 1) canvas.drawLine(gridPoints[i][j], gridPoints[i][j+1], gridCorePaint);
          if (i < rows - 1) canvas.drawLine(gridPoints[i][j], gridPoints[i+1][j], gridCorePaint);
        }
      }
    } else {
      // [赛博朋克模式：动态能量脉冲]
      Color baseNeon = Colors.cyanAccent;

      for (int i = 0; i < rows; i++) {
        for (int j = 0; j < cols; j++) {
          // --- 处理横线 ---
          if (j < cols - 1) {
            _drawDynamicLine(canvas, gridPoints[i][j], gridPoints[i][j+1],
                rawPoints[i][j], rawPoints[i][j+1],
                centerX, centerY, radius, baseNeon, gridGlowPaint, gridCorePaint);
          }
          // --- 处理竖线 ---
          if (i < rows - 1) {
            _drawDynamicLine(canvas, gridPoints[i][j], gridPoints[i+1][j],
                rawPoints[i][j], rawPoints[i+1][j],
                centerX, centerY, radius, baseNeon, gridGlowPaint, gridCorePaint);
          }
        }
      }
    }

    // --- 3. 绘制光带 (保持不变) ---
    if (isCyberpunkMode) {
      Paint tailPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 4.0;
      Paint headPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..color = Colors.white
        ..strokeWidth = 2.0;

      for (var beam in beams) {
        if (beam.position > 1.0 || beam.position + beam.length < 0.0) continue;
        double fullStartT = max(0.0, beam.position);
        double fullEndT = min(1.0, beam.position + beam.length);
        if (fullStartT >= fullEndT) continue;

        Path tailPath = _generatePath(beam, fullStartT, fullEndT, gridPoints);
        double headLengthT = beam.length * 0.25;
        double headStartT, headEndT;
        if (beam.speed > 0) {
          headEndT = fullEndT;
          headStartT = max(fullStartT, fullEndT - headLengthT);
        } else {
          headStartT = fullStartT;
          headEndT = min(fullEndT, fullStartT + headLengthT);
        }
        Path headPath = _generatePath(beam, headStartT, headEndT, gridPoints);

        tailPaint.color = beam.color.withOpacity(0.6);
        canvas.drawPath(tailPath, tailPaint);
        canvas.drawPath(headPath, headPaint);
      }
    }
  }

  // [新增辅助方法] 绘制带有动态能量脉冲的线条
  void _drawDynamicLine(
      Canvas canvas, Offset p1, Offset p2, // 屏幕坐标
      Offset rawP1, Offset rawP2,          // 原始空间坐标
      double centerX, double centerY, double radius,
      Color baseColor, Paint glowPaint, Paint corePaint
      ) {
    // 计算线段中点距离引力中心的距离
    Offset midRaw = (rawP1 + rawP2) / 2.0;
    double dx = midRaw.dx - centerX;
    double dy = midRaw.dy - centerY;
    double dist = sqrt(dx * dx + dy * dy);

    double glowOpacity = 0.15;
    double coreOpacity = 0.5;
    double glowWidth = 3.5;
    double coreWidth = 1.0;

    // 如果在引力影响范围内，应用动态脉冲
    if (isActive && dist < radius * 1.5) {
      // [核心逻辑] 创建向中心汇聚的能量波
      // dist * 5.0: 空间频率，决定波的密集程度
      // time * 8.0: 时间频率，决定波的移动速度 (正号表示向中心移动)
      double wave = sin(dist * 5.0 + time * 8.0);
      // 将波形范围从 [-1, 1] 映射到 [0, 1] 的能量强度因子
      double energyFactor = (wave + 1.0) / 2.0;

      // 距离衰减：越靠近中心，能量感越强
      double proximityFactor = 1.0 - (dist / (radius * 1.5)).clamp(0.0, 1.0);
      // 使用平方让衰减更自然
      proximityFactor = proximityFactor * proximityFactor;

      // 综合计算最终增强因子
      double boost = energyFactor * proximityFactor;

      // 动态调整亮度和宽度
      glowOpacity = 0.15 + boost * 0.3; // 最高到 0.45
      coreOpacity = 0.5 + boost * 0.5;  // 最高到 1.0 (纯白)
      glowWidth = 3.5 + boost * 2.5;    // 变宽
      coreWidth = 1.0 + boost * 1.5;    // 变宽
    }

    // 应用样式并绘制
    glowPaint
      ..color = baseColor.withOpacity(glowOpacity)
      ..strokeWidth = glowWidth;
    canvas.drawLine(p1, p2, glowPaint);

    corePaint
      ..color = baseColor.withOpacity(coreOpacity)
      ..strokeWidth = coreWidth;
    canvas.drawLine(p1, p2, corePaint);
  }

  Path _generatePath(_LightBeam beam, double startT, double endT, List<List<Offset>> gridPoints) {
    double startIdxRaw = startT * (beam.isHorizontal ? (cols - 1) : (rows - 1));
    double endIdxRaw = endT * (beam.isHorizontal ? (cols - 1) : (rows - 1));
    Path path = Path();
    bool isFirst = true;
    double step = 0.2;
    if (startIdxRaw <= endIdxRaw) {
      for (double k = startIdxRaw; k <= endIdxRaw; k += step) {
        Offset p = _getPointAt(beam, k, gridPoints);
        if (isFirst) { path.moveTo(p.dx, p.dy); isFirst = false; }
        else { path.lineTo(p.dx, p.dy); }
      }
    } else {
      for (double k = startIdxRaw; k >= endIdxRaw; k -= step) {
        Offset p = _getPointAt(beam, k, gridPoints);
        if (isFirst) { path.moveTo(p.dx, p.dy); isFirst = false; }
        else { path.lineTo(p.dx, p.dy); }
      }
    }
    Offset pEnd = _getPointAt(beam, endIdxRaw, gridPoints);
    if (isFirst) { path.moveTo(pEnd.dx, pEnd.dy); }
    else { path.lineTo(pEnd.dx, pEnd.dy); }
    return path;
  }

  Offset _getPointAt(_LightBeam beam, double rawIdx, List<List<Offset>> gridPoints) {
    int idxA = rawIdx.floor();
    int idxB = idxA + 1;
    double t = rawIdx - idxA;
    Offset pA, pB;
    if (beam.isHorizontal) {
      int row = beam.index;
      idxA = idxA.clamp(0, cols - 2);
      idxB = idxB.clamp(1, cols - 1);
      pA = gridPoints[row][idxA];
      pB = gridPoints[row][idxB];
    } else {
      int col = beam.index;
      idxA = idxA.clamp(0, rows - 2);
      idxB = idxB.clamp(1, rows - 1);
      pA = gridPoints[idxA][col];
      pB = gridPoints[idxB][col];
    }
    return Offset(
      pA.dx + (pB.dx - pA.dx) * t,
      pA.dy + (pB.dy - pA.dy) * t,
    );
  }

  @override
  bool shouldRepaint(covariant _GridPainter oldDelegate) {
    return true;
  }
}