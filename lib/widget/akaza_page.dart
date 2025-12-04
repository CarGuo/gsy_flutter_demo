import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class AkazaCompassPage extends StatelessWidget {
  const AkazaCompassPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF020008),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: AspectRatio(
            aspectRatio: 1, // 保持容器为正方形
            child: AkazaCompassWidget(),
          ),
        ),
      ),
    );
  }
}

class AkazaCompassWidget extends StatefulWidget {
  const AkazaCompassWidget({super.key});

  @override
  State<AkazaCompassWidget> createState() => _AkazaCompassWidgetState();
}

class _AkazaCompassWidgetState extends State<AkazaCompassWidget>
    with TickerProviderStateMixin {
  late AnimationController _drawController;
  late AnimationController _rotateController;
  late AnimationController _tiltController;
  late AnimationController _characterController; // 新增：控制角色显示

  late Animation<double> _centerCircleAnim;
  late Animation<double> _innerLineAnim;
  late Animation<double> _componentsAnim;
  late Animation<double> _outerLineAnim;

  late Animation<double> _tiltAnim;
  late Animation<double> _bloomAnim;
  late Animation<double> _charOpacityAnim; // 角色透明度

  bool _isDrawingComplete = false;
  bool _isRotationComplete = false;

  @override
  void initState() {
    super.initState();

    // 1. 绘制 (4秒)
    _drawController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    );

    // 2. 旋转 (3秒)
    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    // 3. 倾斜倒地 + 亮度爆发 (1.5秒)
    _tiltController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    // 4. 角色显现 (1秒)
    _characterController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    // --- 动画曲线定义 ---
    _centerCircleAnim = CurvedAnimation(
        parent: _drawController,
        curve: const Interval(0.0, 0.2, curve: Curves.easeOut));
    _innerLineAnim = CurvedAnimation(
        parent: _drawController,
        curve: const Interval(0.2, 0.5, curve: Curves.easeInOut));
    _componentsAnim = CurvedAnimation(
        parent: _drawController,
        curve: const Interval(0.5, 0.75, curve: Curves.easeOut));
    _outerLineAnim = CurvedAnimation(
        parent: _drawController,
        curve: const Interval(0.75, 1.0, curve: Curves.easeInOut));

    _tiltAnim = Tween<double>(begin: 0.0, end: -80 * math.pi / 180).animate(
      CurvedAnimation(parent: _tiltController, curve: Curves.easeInOutCubic),
    );

    _bloomAnim = CurvedAnimation(parent: _tiltController, curve: Curves.easeIn);

    // 角色渐变出现
    _charOpacityAnim =
        CurvedAnimation(parent: _characterController, curve: Curves.easeIn);

    // --- 状态监听链 ---
    _drawController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _isDrawingComplete = true;
        });
        _rotateController.forward();
      }
    });

    _rotateController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _isRotationComplete = true;
        });
        _tiltController.forward();
      }
    });

    _tiltController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // 阵法倒地完成后，让角色显示
        _characterController.forward();
      }
    });

    // 启动动画
    _drawController.forward();
  }

  @override
  void dispose() {
    _drawController.dispose();
    _rotateController.dispose();
    _tiltController.dispose();
    _characterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 图片原始比例
    const double imgWidth = 606;
    const double imgHeight = 1043;
    const double aspectRatio = imgWidth / imgHeight;
    // 定义发光颜色，与阵法的青蓝色光晕一致 (参考了 Painter 中的 cCyanGlow)
    const Color charGlowColor = Color(0xFF6FF3F2);

    return AnimatedBuilder(
      animation: Listenable.merge([
        _drawController,
        _rotateController,
        _tiltController,
        _characterController
      ]),
      builder: (context, child) {
        // 计算旋转
        double rotationAngle = 0;
        if (_isDrawingComplete && !_isRotationComplete) {
          rotationAngle =
              Curves.easeIn.transform(_rotateController.value) * 2 * math.pi;
        }

        // 计算3D矩阵 (仅用于阵法)
        Matrix4 transformMatrix = Matrix4.identity();
        transformMatrix.setEntry(3, 2, 0.002); // 透视

        if (_tiltController.value > 0) {
          transformMatrix.rotateX(_tiltAnim.value);
          double scale = 1.0 - (_tiltController.value * 0.2);
          transformMatrix.scale(scale);
        }

        return Stack(
          alignment: Alignment.center,
          children: [
            // --- 底层：3D 阵法 ---
            Transform(
              transform: transformMatrix,
              alignment: Alignment.center,
              child: Transform.rotate(
                angle: rotationAngle,
                child: CustomPaint(
                  painter: CompassPainterV52(
                    centerProgress: _centerCircleAnim.value,
                    innerLineProgress: _innerLineAnim.value,
                    componentProgress: _componentsAnim.value,
                    outerLineProgress: _outerLineAnim.value,
                    bloomValue: _bloomAnim.value,
                  ),
                  size: Size.infinite,
                ),
              ),
            ),

            // --- 顶层：角色图片 (带发光效果) ---
            // 只有当倾斜动画开始或完成时才准备渲染(避免前期干扰)，这里使用透明度控制显隐
            IgnorePointer(
              // 避免图片阻挡手势
              child: Opacity(
                opacity: _charOpacityAnim.value, // 0.0 -> 1.0 控制整体显隐
                child: LayoutBuilder(builder: (context, constraints) {
                  // 动态计算大小：稍微调大了一点比例，让人物更突出
                  double targetHeight = constraints.maxHeight * 0.15;
                  double targetWidth = targetHeight * aspectRatio;

                  return Container(
                    width: targetWidth,
                    height: targetHeight,
                    // 使用 Transform 稍微向上偏移一点，对齐脚底
                    transform:
                        Matrix4.translationValues(0, -targetHeight * 0.42, 0),
                    // 【核心修改】使用 Stack 叠加发光层和原图层
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // 1. 发光层 (在底下)
                        // 使用 ImageFiltered 进行高斯模糊
                        ImageFiltered(
                          imageFilter:
                              ui.ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0),
                          // 使用 ColorFiltered 将图片变成纯粹的发光色剪影
                          child: ColorFiltered(
                            colorFilter: const ColorFilter.mode(
                                charGlowColor, BlendMode.srcIn),
                            child: Image.asset(
                              "static/akaza.png",
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        // 2. 清晰原图层 (在上面)
                        Image.asset(
                          "static/akaza.png",
                          fit: BoxFit.contain,
                          errorBuilder: (ctx, err, stack) => const Icon(
                              Icons.person,
                              size: 100,
                              color: Colors.cyanAccent),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),
          ],
        );
      },
    );
  }
}

class CompassPainterV52 extends CustomPainter {
  final double centerProgress;
  final double innerLineProgress;
  final double componentProgress;
  final double outerLineProgress;
  final double bloomValue;

  CompassPainterV52({
    required this.centerProgress,
    required this.innerLineProgress,
    required this.componentProgress,
    required this.outerLineProgress,
    required this.bloomValue,
  });

  // --- 色彩定义 ---
  final Color cWhiteBright = const Color(0xFF71FFFD);
  final Color cWhiteGlow = const Color(0xFFC0F3F2);
  final Color cCyanGlow = const Color(0xFF6FF3F2);
  final Color cDimPurple = const Color(0xFF9E7CB0);
  final Color textColor = const Color(0xFF22DDDD);

  final List<String> kanjiList = [
    "拾弐",
    "壱",
    "弐",
    "参",
    "肆",
    "伍",
    "陆",
    "漆",
    "捌",
    "玖",
    "拾",
    "拾壱"
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = math.min(size.width, size.height) / 2;

    final double bloomWidthFactor = 1.0 + (bloomValue * 2.0);
    final double bloomOpacityBoost = bloomValue * 0.4;

    final double r1Centercirclefull = maxRadius * 0.07;
    final double rShortHex = maxRadius * 0.48;
    const double distIncrease = 20.0;
    final double rShortEnd = (maxRadius * 0.63) + distIncrease;
    final double rLongHex = maxRadius * 0.70;
    final double rLongEnd = (maxRadius * 0.85) + distIncrease;

    final double baseSize = maxRadius * 0.09;
    final double hexSize = baseSize * 0.85;
    final double endCircleSize = maxRadius * 0.025;
    final double strokeWidth = maxRadius * 0.015;

    final double currentCenterRadius = r1Centercirclefull * centerProgress;

    for (int i = 0; i < 12; i++) {
      final bool isLongBranch = (i % 2 == 0);
      final double angle = (i * 30 - 90) * (math.pi / 180);

      final double currentHexRadius = isLongBranch ? rLongHex : rShortHex;
      final double currentEndRadius = isLongBranch ? rLongEnd : rShortEnd;
      final double hexVerticalHalfSize = hexSize + 3.0;

      Offset start =
          _polarToOffset(center, currentCenterRadius + strokeWidth / 2, angle);
      Offset hexInnerTarget =
          _polarToOffset(center, currentHexRadius - hexVerticalHalfSize, angle);
      Offset hexOuter =
          _polarToOffset(center, currentHexRadius + hexVerticalHalfSize, angle);
      Offset endInnerTarget = _polarToOffset(
          center, currentEndRadius - endCircleSize - strokeWidth / 2, angle);

      double currentLineThickness =
          isLongBranch ? strokeWidth * 1.5 : strokeWidth;

      if (innerLineProgress > 0) {
        Offset currentHexInner =
            Offset.lerp(start, hexInnerTarget, innerLineProgress)!;
        _drawBrightNeonLine(
            canvas,
            start,
            currentHexInner,
            currentLineThickness,
            cWhiteGlow,
            cWhiteBright,
            bloomWidthFactor,
            bloomOpacityBoost);
      }

      if (componentProgress > 0) {
        double opacity = componentProgress;
        const double moveDownOffset = 15.0;
        double widthSmall = isLongBranch ? strokeWidth + 1.0 : strokeWidth;
        double widthLarge =
            isLongBranch ? strokeWidth + 2.0 : strokeWidth + 1.0;

        final double forkSmallRadius =
            (currentHexRadius - hexVerticalHalfSize * 1.8) - moveDownOffset;
        final double spanSmall = baseSize * 0.7 + 5.0;
        _drawHighlightNeonFork(
            canvas,
            center,
            forkSmallRadius,
            angle,
            spanSmall,
            widthSmall,
            cWhiteGlow,
            cWhiteBright,
            opacity,
            bloomWidthFactor,
            bloomOpacityBoost);

        final double forkLargeRadius = forkSmallRadius - baseSize * 0.4 - 10.0;
        final double spanLarge = baseSize * 1.1 + 10.0;
        _drawHighlightNeonFork(
            canvas,
            center,
            forkLargeRadius,
            angle,
            spanLarge,
            widthLarge,
            cWhiteGlow,
            cWhiteBright,
            opacity,
            bloomWidthFactor,
            bloomOpacityBoost);

        _drawBrightNeonHexagon(
            canvas,
            center,
            currentHexRadius,
            angle,
            hexSize,
            3.0,
            strokeWidth,
            cWhiteGlow,
            cWhiteBright,
            textColor,
            kanjiList[i],
            opacity,
            bloomWidthFactor,
            bloomOpacityBoost);
      }

      if (outerLineProgress > 0 && componentProgress >= 1.0) {
        Offset currentEndInner =
            Offset.lerp(hexOuter, endInnerTarget, outerLineProgress)!;
        _drawDimmingGradientLine(canvas, hexOuter, currentEndInner,
            currentLineThickness, cWhiteBright, cDimPurple, bloomWidthFactor);

        Offset endCenter = _polarToOffset(center, currentEndRadius, angle);
        _drawDimCircle(canvas, endCenter, endCircleSize, strokeWidth,
            cDimPurple.withValues(alpha: outerLineProgress));
      }
    }

    if (centerProgress > 0) {
      _drawCenterHollowRing(
          canvas,
          center,
          currentCenterRadius,
          strokeWidth * 2.0,
          cWhiteGlow,
          cWhiteBright,
          bloomWidthFactor,
          bloomOpacityBoost);
    }
  }

  // ================= 绘图方法 =================

  Offset _polarToOffset(Offset center, double radius, double angle) {
    return Offset(
      center.dx + radius * math.cos(angle),
      center.dy + radius * math.sin(angle),
    );
  }

  void _drawBrightNeonLine(
      Canvas canvas,
      Offset p1,
      Offset p2,
      double width,
      Color glowColor,
      Color brightColor,
      double bloomWidth,
      double bloomAlpha) {
    if ((p1 - p2).distance < 1.0) return;
    double glowOpacity = (0.5 + bloomAlpha).clamp(0.0, 1.0);
    canvas.drawLine(
        p1,
        p2,
        Paint()
          ..color = glowColor.withValues(alpha: glowOpacity)
          ..strokeWidth = width * 5 * bloomWidth
          ..strokeCap = StrokeCap.round
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, 12 * bloomWidth));
    canvas.drawLine(
        p1,
        p2,
        Paint()
          ..color = brightColor
          ..strokeWidth = width
          ..strokeCap = StrokeCap.round);
  }

  void _drawDimmingGradientLine(Canvas canvas, Offset p1, Offset p2,
      double width, Color startColor, Color endColor, double bloomWidth) {
    if ((p1 - p2).distance < 1.0) return;
    final glowGradient = ui.Gradient.linear(p1, p2,
        [startColor.withValues(alpha: 0.5), endColor.withValues(alpha: 0.05)]);
    final baseGradient = ui.Gradient.linear(p1, p2, [startColor, endColor]);
    canvas.drawLine(
        p1,
        p2,
        Paint()
          ..shader = glowGradient
          ..strokeWidth = width * 4 * (1 + (bloomWidth - 1) * 0.5)
          ..strokeCap = StrokeCap.round
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12));
    canvas.drawLine(
        p1,
        p2,
        Paint()
          ..shader = baseGradient
          ..strokeWidth = width
          ..strokeCap = StrokeCap.round);
  }

  void _drawCenterHollowRing(
      Canvas canvas,
      Offset center,
      double radius,
      double width,
      Color glowColor,
      Color brightColor,
      double bloomWidth,
      double bloomAlpha) {
    if (radius < 1.0) return;
    double glowOpacity = (0.6 + bloomAlpha).clamp(0.0, 1.0);
    canvas.drawCircle(
        center,
        radius,
        Paint()
          ..color = glowColor.withValues(alpha: glowOpacity)
          ..style = PaintingStyle.stroke
          ..strokeWidth = width * 4 * bloomWidth
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, 10 * bloomWidth));
    canvas.drawCircle(
        center,
        radius,
        Paint()
          ..color = brightColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = width);
  }

  void _drawDimCircle(
      Canvas canvas, Offset center, double radius, double width, Color color) {
    canvas.drawCircle(
        center,
        radius,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = width * 0.9);
  }

  void _drawHighlightNeonFork(
      Canvas canvas,
      Offset center,
      double vertexRadius,
      double angle,
      double horizontalSpan,
      double thickness,
      Color glowColor,
      Color brightColor,
      double opacity,
      double bloomWidth,
      double bloomAlpha) {
    final Offset vertex = _polarToOffset(center, vertexRadius, angle);
    canvas.save();
    canvas.translate(vertex.dx, vertex.dy);
    canvas.rotate(angle + math.pi / 2);
    final double verticalThickOffset = thickness * 1.414;
    final Path path = Path();
    path.moveTo(0, 0);
    path.lineTo(horizontalSpan, -horizontalSpan);
    path.lineTo(horizontalSpan, -horizontalSpan + verticalThickOffset);
    path.lineTo(0, verticalThickOffset);
    path.lineTo(-horizontalSpan, -horizontalSpan + verticalThickOffset);
    path.lineTo(-horizontalSpan, -horizontalSpan);
    path.close();
    double glowOpacity = (0.8 + bloomAlpha).clamp(0.0, 1.0) * opacity;
    canvas.drawPath(
        path,
        Paint()
          ..color = glowColor.withValues(alpha: glowOpacity)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, 15 * bloomWidth)
          ..style = PaintingStyle.fill);
    canvas.drawPath(
        path,
        Paint()
          ..color = brightColor.withValues(alpha: opacity)
          ..style = PaintingStyle.fill);
    canvas.restore();
  }

  void _drawBrightNeonHexagon(
      Canvas canvas,
      Offset center,
      double radius,
      double angle,
      double size,
      double extraHeight,
      double width,
      Color glowColor,
      Color brightColor,
      Color textColor,
      String text,
      double opacity,
      double bloomWidth,
      double bloomAlpha) {
    final Offset hexCenter = _polarToOffset(center, radius, angle);
    canvas.save();
    canvas.translate(hexCenter.dx, hexCenter.dy);
    canvas.rotate(angle + math.pi / 2);
    final double w = size * 0.75;
    final double hBase = size * 0.5;
    final double sideY = hBase + extraHeight;
    final double tipY = size + extraHeight;
    final Path path = Path();
    path.moveTo(0, tipY);
    path.lineTo(w, sideY);
    path.lineTo(w, -sideY);
    path.lineTo(0, -tipY);
    path.lineTo(-w, -sideY);
    path.lineTo(-w, sideY);
    path.close();
    double glowOpacity = (0.6 + bloomAlpha).clamp(0.0, 1.0) * opacity;
    canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = width * 3 * bloomWidth
          ..strokeCap = StrokeCap.butt
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, 10 * bloomWidth)
          ..color = glowColor.withValues(alpha: glowOpacity));
    canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = width
          ..strokeCap = StrokeCap.butt
          ..color = brightColor.withValues(alpha: opacity));
    double calculatedSize = text.length > 1 ? size * 0.75 : size * 0.9;
    double fontSize = calculatedSize - 5.0;
    TextStyle style = TextStyle(
        color: textColor.withValues(alpha: opacity),
        fontSize: fontSize,
        fontWeight: FontWeight.normal,
        fontFamily: "Serif",
        height: 1.0,
        shadows: const []);
    if (text.length == 1) {
      final textPainter = TextPainter(
          text: TextSpan(text: text, style: style),
          textDirection: ui.TextDirection.ltr,
          textAlign: TextAlign.center);
      textPainter.layout();
      textPainter.paint(
          canvas, Offset(-textPainter.width / 2, -textPainter.height / 2));
    } else {
      final String charTop = text[0];
      final String charBottom = text[1];
      final tpTop = TextPainter(
          text: TextSpan(text: charTop, style: style),
          textDirection: ui.TextDirection.ltr);
      tpTop.layout();
      final tpBottom = TextPainter(
          text: TextSpan(text: charBottom, style: style),
          textDirection: ui.TextDirection.ltr);
      tpBottom.layout();
      double offsetFix = fontSize * 0.1;
      tpTop.paint(canvas, Offset(-tpTop.width / 2, -tpTop.height + offsetFix));
      tpBottom.paint(canvas, Offset(-tpBottom.width / 2, -offsetFix));
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CompassPainterV52 oldDelegate) {
    return oldDelegate.centerProgress != centerProgress ||
        oldDelegate.innerLineProgress != innerLineProgress ||
        oldDelegate.componentProgress != componentProgress ||
        oldDelegate.outerLineProgress != outerLineProgress ||
        oldDelegate.bloomValue != bloomValue;
  }
}
