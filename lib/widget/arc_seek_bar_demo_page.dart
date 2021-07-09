import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

class ArcSeekBarDemoPage extends StatefulWidget {
  @override
  _ArcSeekBarDemoPageState createState() => _ArcSeekBarDemoPageState();
}

class _ArcSeekBarDemoPageState extends State<ArcSeekBarDemoPage>
    with SingleTickerProviderStateMixin {
  double progress = 0;
  final double rotateAngle = 90;
  final double openAngle = 120;
  final Size size = Size(300, 300);

  onTouch(DragUpdateDetails d) {
    var x = d.localPosition.dx;
    var y = d.localPosition.dy;
    double tempProgressPresent = getCurrentProgress(x, y);
    // 允许突变 或者非突变
    setState(() {
      progress = tempProgressPresent;
    });
  }

  double getCurrentProgress(double px, double py) {
    double diffAngle = getDiffAngle(px, py);
    double progress = diffAngle / (ArcSeekBarPainter.CIRCLE_ANGLE - openAngle);
    if (progress < 0) progress = 0;
    if (progress > 1) progress = 1;
    return progress;
  }

  double getDiffAngle(double px, double py) {
    double angle = getAngle(px, py);
    double diffAngle;
    diffAngle = angle - rotateAngle;
    if (diffAngle < 0) {
      diffAngle = (diffAngle + ArcSeekBarPainter.CIRCLE_ANGLE) %
          ArcSeekBarPainter.CIRCLE_ANGLE;
    }
    diffAngle = diffAngle - openAngle / 2;
    return diffAngle;
  }

  double getAngle(double px, double py) {
    double angle =
        atan2(py - size.height / 2, px - size.width / 2) * 180 / 3.14;
    if (angle < 0) {
      angle += 360;
    }
    return angle;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("ArcSeekBarDemoPage"),
      ),
      body: Container(
        child: Center(
          child: GestureDetector(
            onPanUpdate: onTouch,
            child: SizedBox(
              height: size.width,
              width: size.height,
              child: CustomPaint(
                painter: new ArcSeekBarPainter(
                    progress: progress,
                    rotateAngle: rotateAngle,
                    openAngle: openAngle),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ArcSeekBarPainter extends CustomPainter {
  static const double CIRCLE_ANGLE = 360;

  final double progress;
  final double rotateAngle;

  final double openAngle;

  ArcSeekBarPainter({
    this.progress = 0,
    this.rotateAngle = 90,
    this.openAngle = 120,
  });

  late Path seekPath;
  late Path borderPath;
  late Paint arcPaint;
  late Paint thumbPaint;
  late Paint borderPaint;
  late Paint shadowPaint;
  late Rect content;
  late double startAngle;
  late double sweepAngle;
  Offset tempPos = Offset(0, 0);
  Offset tempTan = Offset(0, 0);

  PathMetric? seekPathMeasure;

  double arcWidth = 40;
  double borderWidth = 2;
  double shadowRadius = 0;
  double thumbShadowRadius = 2;
  double thumbRadius = 15;

  late double thumbX;
  late double thumbY;

  late double centerX;
  late double centerY;

  late List<Color> arcColors;

  void initData() {
    seekPath = new Path();
    borderPath = new Path();
    arcColors = [Colors.blueAccent, Colors.pinkAccent, Colors.amberAccent];
  }

  void initPaint() {
    initArcPaint();
    initThumbPaint();
    initBorderPaint();
    initShadowPaint();
  }

  void initArcPaint() {
    arcPaint = new Paint();
    arcPaint.isAntiAlias = true;
    arcPaint.strokeWidth = 40;
    arcPaint.style = PaintingStyle.stroke;
    arcPaint.strokeCap = StrokeCap.round;
  }

  void initThumbPaint() {
    thumbPaint = new Paint();
    thumbPaint.isAntiAlias = true;
    thumbPaint.color = Colors.white;
    thumbPaint.strokeWidth = borderWidth;
    thumbPaint.strokeCap = StrokeCap.round;
    thumbPaint.style = PaintingStyle.fill;
  }

  void initBorderPaint() {
    borderPaint = new Paint();
    borderPaint.isAntiAlias = true;
    borderPaint.color = Colors.white;
    borderPaint.strokeWidth = 0;
    borderPaint.style = PaintingStyle.stroke;
  }

  void initShadowPaint() {
    shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.3)
      ..strokeWidth = arcPaint.strokeWidth + 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, thumbShadowRadius);
  }

  void initSize(Size size) {
    double w = size.width;
    double h = size.height;
    var safeW = w;
    var safeH = h;
    double edgeLength, startX, startY;
    double fix = arcWidth / 2 + borderWidth + shadowRadius * 2; // 修正距离,画笔宽度的修正
    if (safeW < safeH) {
      edgeLength = safeW - fix;
      startX = 0;
      startY = (safeH - safeW) / 2.0;
    } else {
      edgeLength = safeH - fix;
      startX = (safeW - safeH) / 2.0;
      startY = 0;
    }

    content = new Rect.fromLTRB(
        startX + fix, startY + fix, startX + edgeLength, startY + edgeLength);
    centerX = content.center.dx;
    centerY = content.center.dy;

    seekPath.reset();
    startAngle = (openAngle / 2) / 360 * 2 * pi;
    sweepAngle = (CIRCLE_ANGLE - openAngle) / 360 * 2 * pi;
    seekPath.addArc(content, startAngle, sweepAngle);
    seekPathMeasure = seekPath.computeMetrics(forceClosed: false).first;

    borderPath.extendWithPath(seekPath, Offset.zero);

    computeThumbPos(progress);
    resetShaderColor(size);

    borderPath.close();
  }

  void computeThumbPos(double present) {
    if (present < 0) present = 0;
    if (present > 1) present = 1;
    if (null == seekPathMeasure) return;
    double distance = seekPathMeasure!.length * present;
    var tangent = seekPathMeasure!.getTangentForOffset(distance)!;
    tempPos = tangent.position;
    tempTan = tangent.vector;
    thumbX = tempPos.dx;
    thumbY = tempPos.dy;
  }

  void resetShaderColor(Size size) {
    // 计算渐变数组
    double startPos = (openAngle / 2) / CIRCLE_ANGLE;
    double stopPos = (CIRCLE_ANGLE - (openAngle / 2)) / CIRCLE_ANGLE;
    int len = arcColors.length - 1;
    double distance = (stopPos - startPos) / len;
    var pos = List.filled(arcColors.length, 0.0);
    for (int i = 0; i < arcColors.length; i++) {
      pos[i] = startPos + (distance * i);
    }
    var sweepGradient = SweepGradient(colors: arcColors, stops: pos);
    try {
      if (Platform.isIOS == true || Platform.isAndroid == true)
        arcPaint.shader = sweepGradient.createShader(Offset.zero & size);
    } catch (e) {}
  }

  void draw(Canvas canvas) {
    canvas.save();
    canvas.translate(centerX, centerY);
    canvas.rotate(2 * pi * rotateAngle / 360);
    canvas.translate(-centerX, -centerY);

    ///阴影
    canvas.drawArc(content, startAngle, sweepAngle, false, shadowPaint);

    canvas.drawPath(seekPath, arcPaint);

    if (thumbShadowRadius > 0) {
      Path oval = Path()
        ..addOval(Rect.fromCircle(
            center: Offset(thumbX, thumbY), radius: thumbRadius + 3));
      Paint shadowPaint = Paint()
        ..color = Colors.black.withOpacity(0.3)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, thumbShadowRadius);
      canvas.drawPath(oval, shadowPaint);
    }

    canvas.drawCircle(Offset(thumbX, thumbY), thumbRadius, thumbPaint);
    canvas.restore();
  }

  @override
  void paint(Canvas canvas, Size size) {
    initData();
    initPaint();
    initSize(size);
    draw(canvas);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
