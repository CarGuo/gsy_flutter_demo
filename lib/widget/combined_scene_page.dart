import 'dart:math';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' as v;

// --- 粒子類 ---
class Particle {
  final int index;
  final double orbitRadius;
  double currentAngle;
  final double rotationSpeed;
  final double size;
  final double opacity;
  final ParticleType type;

  Particle({
    required this.index,
    required this.orbitRadius,
    required this.currentAngle,
    required this.rotationSpeed,
    required this.size,
    required this.opacity,
    required this.type,
  });
}

enum ParticleType { treeGreen, spearWhite }

class CombinedScenePage extends StatelessWidget {
  const CombinedScenePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      backgroundColor: Colors.black,
      body: const CombinedSceneWidget(),
    );
  }
}

class CombinedSceneWidget extends StatefulWidget {
  const CombinedSceneWidget({super.key});

  @override
  State<CombinedSceneWidget> createState() => _CombinedSceneWidgetState();
}

class _CombinedSceneWidgetState extends State<CombinedSceneWidget>
    with TickerProviderStateMixin {
  late AnimationController _rotateController;
  late AnimationController _shakeController;

  final List<Particle> _particles = [];
  final int _treeSteps = 1000;
  final int _spearSteps = 1200;

  @override
  void initState() {
    super.initState();

    // 旋轉動畫
    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat();

    // 抖動動畫
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _generateParticles();

    _rotateController.addListener(() {
      setState(() {
        for (var p in _particles) {
          p.currentAngle += p.rotationSpeed * 0.05;
          if (p.currentAngle > 2 * pi) p.currentAngle -= 2 * pi;
        }
      });
    });

    _shakeController.addListener(() {
      setState(() {});
    });
  }

  void _generateParticles() {
    final random = Random();
    // 樹的綠點
    for (int i = 0; i < 180; i++) {
      int randomIndex = random.nextInt(_treeSteps - 60) + 30;
      _particles.add(Particle(
        index: randomIndex,
        orbitRadius: random.nextDouble() * 25 + 10,
        currentAngle: random.nextDouble() * 2 * pi,
        rotationSpeed: (random.nextDouble() - 0.5) * 4.0,
        size: random.nextDouble() * 3 + 2,
        opacity: random.nextDouble() * 0.4 + 0.6,
        type: ParticleType.treeGreen,
      ));
    }
    // 槍的白點
    for (int i = 0; i < 100; i++) {
      int randomIndex = random.nextInt(_spearSteps);
      _particles.add(Particle(
        index: randomIndex,
        orbitRadius: random.nextDouble() * 15 + 5,
        currentAngle: random.nextDouble() * 2 * pi,
        rotationSpeed: (random.nextDouble() - 0.5) * 5.0,
        size: random.nextDouble() * 1.5 + 1,
        opacity: random.nextDouble() * 0.5 + 0.3,
        type: ParticleType.spearWhite,
      ));
    }
  }

  void _handleTap() {
    _shakeController.forward(from: 0);
  }

  @override
  void dispose() {
    _rotateController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: Stack(
        children: [
          // 2. 左上角公式展示層 (HUD風格)
          Positioned(
            top: 40,
            left: 20,
            child: Container(
              padding: const EdgeInsets.all(16),
              // 限制最大寬度，防止遮擋太多
              constraints: const BoxConstraints(maxWidth: 320),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 紅線公式
                  _buildSectionTitle(
                      "RED SPEAR (Double Helix)", Colors.redAccent),
                  _buildFancyFormula("r(t) = base_w · (1 - t^0.8)"),
                  _buildFancyFormula("θ(t) = t · 9π + {0, π}"),

                  const SizedBox(height: 8),
                  // 黃線公式
                  _buildSectionTitle(
                      "GOLD RIBBON (Conical Spiral)", Colors.amberAccent),
                  _buildFancyFormula("x = [(h-z)/h] · r · cos(2πnz/h)"),
                  _buildFancyFormula("y = z  (Height)"),
                  _buildFancyFormula("z_coord = [(h-z)/h] · r · sin(2πnz/h)"),

                  const SizedBox(height: 8),
                  // 綠點公式
                  _buildSectionTitle(
                      "GREEN PARTICLES (Orbital)", Colors.greenAccent),
                  _buildFancyFormula("Pos = P_ribbon + P_local_orbit"),
                  _buildFancyFormula("P_local = [R·cos(α), R·sin(α)]_normal"),
                ],
              ),
            ),
          ),
          // 1. 核心繪圖層 (佔滿全屏)
          Positioned.fill(
            child: AnimatedBuilder(
              animation:
                  Listenable.merge([_rotateController, _shakeController]),
              builder: (context, child) {
                return LayoutBuilder(builder: (context, constraints) {
                  return CustomPaint(
                    size: Size(constraints.maxWidth, constraints.maxHeight),
                    painter: CombinedPainter(
                      rotation: _rotateController.value * 2 * pi,
                      shakeProgress: _shakeController.value,
                      particles: _particles,
                      treeSteps: _treeSteps,
                      spearSteps: _spearSteps,
                    ),
                  );
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  // 構建小標題
  Widget _buildSectionTitle(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4, top: 4),
      child: Row(
        children: [
          Icon(Icons.label_important, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            title,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              fontFamily: 'Roboto Mono',
            ),
          ),
        ],
      ),
    );
  }

  // 構建帶有代碼高亮效果的公式文本
  Widget _buildFancyFormula(String formula) {
    // 簡單的解析器，用於給不同類型的字符上色
    List<TextSpan> spans = [];
    RegExp exp =
        RegExp(r"([a-zA-Z_]+[0-9]*)|([0-9]+\.?[0-9]*)|([+\-*/=^·\[\]{\}(),])");

    formula.splitMapJoin(exp, onMatch: (m) {
      String text = m.group(0)!;
      Color color = Colors.white70; // 默認符號顏色

      if (RegExp(r"^[a-zA-Z_]").hasMatch(text)) {
        // 變量名 (如 r, t, h, cos)
        color = Colors.lightBlueAccent;
      } else if (RegExp(r"^[0-9]").hasMatch(text)) {
        // 數字
        color = Colors.orangeAccent;
      }

      spans.add(TextSpan(text: text, style: TextStyle(color: color)));
      return text;
    }, onNonMatch: (text) {
      // 空格等其他字符
      spans.add(TextSpan(text: text));
      return text;
    });

    return Padding(
      padding: const EdgeInsets.only(left: 18, bottom: 2),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(
            fontFamily: 'Roboto Mono', // 使用等寬字體
            fontSize: 11,
            height: 1.3,
          ),
          children: spans,
        ),
      ),
    );
  }
}

// --- 以下為原有的 Painter 代碼 (保持不變) ---
class CombinedPainter extends CustomPainter {
  final double rotation;
  final double shakeProgress;
  final List<Particle> particles;
  final int treeSteps;
  final int spearSteps;

  final double _fov = 900;
  final double _baseDepth = 200;
  final double _maxWidth = 600.0;
  final double _maxHeight = 900.0;

  CombinedPainter({
    required this.rotation,
    required this.shakeProgress,
    required this.particles,
    required this.treeSteps,
    required this.spearSteps,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double centerX = size.width / 2;
    final double centerY = size.height / 2;

    final double effectiveW = min(size.width, _maxWidth);
    final double effectiveH = min(size.height, _maxHeight);

    final double h = effectiveH * 0.8;
    final double yOffset = h / 2;

    final double rTree = effectiveW * 0.4;
    const double nTree = 7.0;
    final double spearBaseW = effectiveW * 0.06;

    double shakeIntensity = 0;
    if (shakeProgress > 0 && shakeProgress < 1) {
      shakeIntensity = sin(shakeProgress * pi) * (1 - shakeProgress * 0.5);
    }

    List<v.Vector3> tree3DPoints = [];
    List<v.Vector3> spear1_3DPoints = [];
    List<v.Vector3> spear2_3DPoints = [];

    // 1. 金樹
    for (int i = 0; i <= treeSteps; i++) {
      double progress = i / treeSteps;
      v.Vector3 rawPos =
          _calculateTreePos(progress, h, rTree, nTree, shakeIntensity);
      tree3DPoints.add(v.Vector3(rawPos.x, rawPos.y - yOffset, rawPos.z));
    }

    // 2. 紅槍
    for (int i = 0; i <= spearSteps; i++) {
      double progress = i / spearSteps;
      v.Vector3 rawPos1 =
          _calculateSpearPos(progress, 0, spearBaseW, h, shakeIntensity);
      v.Vector3 rawPos2 =
          _calculateSpearPos(progress, 1, spearBaseW, h, shakeIntensity);

      spear1_3DPoints.add(v.Vector3(rawPos1.x, rawPos1.y - yOffset, rawPos1.z));
      spear2_3DPoints.add(v.Vector3(rawPos2.x, rawPos2.y - yOffset, rawPos2.z));
    }

    // 3. 繪製
    _paintSpear(canvas, spear1_3DPoints, spear2_3DPoints, centerX, centerY);
    _paintTreeRibbon(canvas, tree3DPoints, centerX, centerY, size);
    _paintParticles(
        canvas, h, rTree, nTree, centerX, centerY, yOffset, shakeIntensity);

    if (tree3DPoints.isNotEmpty) {
      Offset top = _project3DVector(tree3DPoints.last, centerX, centerY);
      _drawStar(canvas, top, 20, Colors.white);
    }
  }

  v.Vector3 _calculateTreePos(
      double progress, double h, double r, double n, double shakeIntensity) {
    double currentY = progress * h;
    double scaleFactor = (h - currentY) / h;
    double angle = (2 * pi * n * currentY) / h;

    double wave = 0;
    if (shakeIntensity > 0) {
      wave = sin(angle * 6.0 - shakeProgress * 40.0) * 8.0 * shakeIntensity;
    }

    double finalR = scaleFactor * r + wave;

    return v.Vector3(finalR * cos(angle), currentY, finalR * sin(angle));
  }

  v.Vector3 _calculateSpearPos(double progress, int strandIndex, double baseW,
      double h, double shakeIntensity) {
    const double forkEnd = 0.22;
    const double twistStart = 0.28;

    double r;
    double angle;
    if (progress < forkEnd) {
      r = baseW;
    } else {
      double t = (progress - forkEnd) / (1.0 - forkEnd);
      r = baseW * (1 - pow(t, 0.8));
      if (r < 0) r = 0;
    }

    double baseAngleOffset = (strandIndex == 0) ? 0 : pi;
    if (progress < twistStart) {
      angle = baseAngleOffset;
    } else {
      double twistProgress = (progress - twistStart) / (1.0 - twistStart);
      angle = baseAngleOffset + twistProgress * 4.5 * 2 * pi;
    }

    if (shakeIntensity > 0) {
      double jitter =
          sin(progress * 100 + shakeProgress * 50) * 5 * shakeIntensity;
      r += jitter;
    }

    return v.Vector3(r * cos(angle), progress * h, r * sin(angle));
  }

  void _paintParticles(Canvas canvas, double h, double rTree, double nTree,
      double cx, double cy, double yOffset, double shakeIntensity) {
    Paint greenGlow = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    Paint greenCore = Paint()..style = PaintingStyle.fill;
    Paint whitePaint = Paint()..style = PaintingStyle.fill;

    for (var p in particles) {
      v.Vector3 pos3D;

      if (p.type == ParticleType.treeGreen) {
        double progress = p.index / treeSteps;
        v.Vector3 base =
            _calculateTreePos(progress, h, rTree, nTree, shakeIntensity);

        double dist = sqrt(base.x * base.x + base.z * base.z);
        if (dist < 0.001) dist = 0.001;

        double nx = base.x / dist;
        double nz = base.z / dist;

        double offsetRadial = p.orbitRadius * cos(p.currentAngle);
        double offsetVertical = p.orbitRadius * sin(p.currentAngle);

        if (shakeIntensity > 0) {
          offsetRadial += (Random().nextDouble() - 0.5) * 5 * shakeIntensity;
        }

        pos3D = v.Vector3(base.x + offsetRadial * nx,
            (base.y - yOffset) + offsetVertical, base.z + offsetRadial * nz);

        Offset pos2D = _project3DVector(pos3D, cx, cy);
        canvas.drawCircle(
            pos2D,
            p.size * 1.5,
            greenGlow
              ..color = Colors.greenAccent.withValues(alpha: p.opacity * 0.5));
        canvas.drawCircle(
            pos2D,
            p.size * 0.6,
            greenCore
              ..color = Colors.lightGreenAccent.withValues(alpha: p.opacity));
      } else {
        double progress = p.index / spearSteps;
        double yRaw = progress * h;
        double currentOrbitR =
            p.orbitRadius * (progress > 0.5 ? (1.5 - progress) : 1.0);

        if (shakeIntensity > 0) {
          currentOrbitR += sin(shakeProgress * pi * 8) * 15.0 * shakeIntensity;
        }

        double lx = currentOrbitR * cos(p.currentAngle);
        double lz = currentOrbitR * sin(p.currentAngle);
        pos3D = v.Vector3(lx, yRaw - yOffset, lz);

        Offset pos2D = _project3DVector(pos3D, cx, cy);
        canvas.drawCircle(
            pos2D,
            p.size,
            whitePaint
              ..color = Colors.white.withValues(alpha: p.opacity * 0.8));
      }
    }
  }

  void _paintSpear(Canvas canvas, List<v.Vector3> p1, List<v.Vector3> p2,
      double cx, double cy) {
    double extraGlow = shakeProgress > 0 ? 6.0 * sin(shakeProgress * pi) : 0.0;

    Path path1 =
        _createPath(p1.map((p) => _project3DVector(p, cx, cy)).toList());
    Path path2 =
        _createPath(p2.map((p) => _project3DVector(p, cx, cy)).toList());

    Paint glowPaint = Paint()
      ..color = Colors.redAccent.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0 + extraGlow
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 10 + extraGlow);

    Paint corePaint = Paint()
      ..color = const Color(0xFF880000)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;
    Paint lightPaint = Paint()
      ..color = const Color(0xFFFF5555)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    canvas.drawPath(path1, glowPaint);
    canvas.drawPath(path2, glowPaint);
    canvas.drawPath(path1, corePaint);
    canvas.drawPath(path2, corePaint);
    canvas.drawPath(path1, lightPaint);
    canvas.drawPath(path2, lightPaint);
  }

  void _paintTreeRibbon(Canvas canvas, List<v.Vector3> points3D, double cx,
      double cy, Size size) {
    Path path =
        _createPath(points3D.map((p) => _project3DVector(p, cx, cy)).toList());

    Paint glowPaint = Paint()
      ..color = Colors.orange.shade300.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

    Paint corePaint = Paint()
      ..shader = const LinearGradient(
        colors: [Colors.orange, Colors.amberAccent, Colors.white],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawPath(path, glowPaint);
    canvas.drawPath(path, corePaint);
  }

  Offset _project3DVector(v.Vector3 point3D, double centerX, double centerY) {
    double rotatedX = point3D.x * cos(rotation) - point3D.z * sin(rotation);
    double rotatedZ = point3D.x * sin(rotation) + point3D.z * cos(rotation);
    double rotatedY = point3D.y;

    double depthScale = _fov / (_fov + rotatedZ + _baseDepth);

    double screenX = centerX + rotatedX * depthScale;
    double screenY = centerY - rotatedY * depthScale;

    return Offset(screenX, screenY);
  }

  Path _createPath(List<Offset> points) {
    Path path = Path();
    if (points.isNotEmpty) {
      path.moveTo(points[0].dx, points[0].dy);
      for (int i = 1; i < points.length; i++) {
        path.lineTo(points[i].dx, points[i].dy);
      }
    }
    return path;
  }

  void _drawStar(Canvas canvas, Offset center, double size, Color color) {
    double extraSize = shakeProgress > 0 ? 10 * sin(shakeProgress * pi) : 0;

    Paint starGlow = Paint()
      ..color = color.withValues(alpha: 0.8)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);
    canvas.drawCircle(center, (size + extraSize) / 1.5, starGlow);
    canvas.drawCircle(center, size / 4, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant CombinedPainter oldDelegate) => true;
}
