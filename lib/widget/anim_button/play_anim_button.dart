import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

class PlayAnimButton extends StatefulWidget {
  @override
  _PlayAnimButtonState createState() => _PlayAnimButtonState();
}

class _PlayAnimButtonState extends State<PlayAnimButton>
    with SingleTickerProviderStateMixin {
  late AnimationController playerButtonController;
  late Animation playerAnimation;

  @override
  void initState() {
    super.initState();
    playerButtonController = new AnimationController(vsync: this)
      ..duration = Duration(milliseconds: 1000);
    this.playerAnimation = CurvedAnimation(
      parent: playerButtonController,
      curve: Curves.bounceInOut,
    )..addListener(updateState);
  }

  @override
  void dispose() {
    playerAnimation.removeListener(updateState);
    playerButtonController.stop();
    super.dispose();
  }

  updateState() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (playerButtonController.isCompleted) {
          playerButtonController.reverse();
        } else {
          playerButtonController.forward();
        }
      },
      child: CustomPaint(
        painter: new PlayButtonPainter(fraction: playerAnimation.value),
      ),
    );
  }
}

class PlayButtonPainter extends CustomPainter {
  final double fraction;

  late double width;

  late double height;

  late double circleRadius;

  late double centerX;
  late double centerY;
  late Rect rect;
  late Rect bgRect;

  PlayButtonPainter({this.fraction = 1});

  late Paint painter;
  late Paint bgPainter;
  Path path = Path();
  Path dstPath = Path();
  late PathMetric pathMetric;

  initPaint() {
    init(Paint painter) {
      painter.color = Colors.white;
      painter.strokeCap = StrokeCap.round;
      painter.strokeWidth = 4;
      painter.style = PaintingStyle.stroke;
      painter.isAntiAlias = true;
    }

    painter = new Paint();
    init(painter);
    bgPainter = new Paint();
    init(bgPainter);
  }

  initSizeAndPath(Size size) {
    double w = size.width;
    double h = size.height;
    width = w * 9 / 10;
    height = h * 9 / 10;
    circleRadius = width / 8;
    centerX = w / 2;
    centerY = h / 2;
    rect = new Rect.fromLTRB(
        centerX - circleRadius,
        centerY + 0.6 * circleRadius,
        centerX + circleRadius,
        centerY + 2.6 * circleRadius);
    bgRect = new Rect.fromLTRB(centerX - width / 2, centerY - height / 2,
        centerX + width / 2, centerY + height / 2);
    path.moveTo(centerX - circleRadius, centerY + 1.8 * circleRadius);
    path.lineTo(centerX - circleRadius, centerY - 1.8 * circleRadius);
    path.lineTo(centerX + circleRadius, centerY);
    path.close();
    pathMetric = path.computeMetrics(forceClosed: false).first;
  }

  void draw(Canvas canvas) {
    double pathLength = pathMetric.length;

    canvas.drawCircle(Offset(centerX, centerY), width / 2, bgPainter);

    if (fraction < 0) {
      canvas.drawLine(
          Offset(centerX + circleRadius,
              centerY - 1.6 * circleRadius + 10 * circleRadius * fraction),
          Offset(centerX + circleRadius,
              centerY + 1.6 * circleRadius + 10 * circleRadius * fraction),
          painter);
      canvas.drawLine(
          Offset(centerX - circleRadius, centerY - 1.6 * circleRadius),
          Offset(centerX - circleRadius, centerY + 1.6 * circleRadius),
          painter);

      canvas.drawArc(bgRect, -105 / 180 * pi, 2 * pi, false, painter);
    } else if (fraction <= 0.3) {
      canvas.drawLine(
          Offset(
              centerX + circleRadius,
              centerY -
                  1.6 * circleRadius +
                  circleRadius * 3.2 / 0.3 * fraction),
          Offset(centerX + circleRadius, centerY + 1.6 * circleRadius),
          painter);

      canvas.drawLine(
          Offset(centerX - circleRadius, centerY - 1.6 * circleRadius),
          Offset(centerX - circleRadius, centerY + 1.6 * circleRadius),
          painter);

      if (fraction != 0)
        canvas.drawArc(rect, 0, pi / 0.3 * fraction, false, painter);

      canvas.drawArc(bgRect, -105 / 180 * pi + 2 * pi * fraction,
          2 * pi * (1 - fraction), false, painter);
    } else if (fraction <= 0.6) {
      canvas.drawArc(rect, pi / 0.3 * (fraction - 0.3),
          pi - pi / 0.3 * (fraction - 0.3), false, painter);
      dstPath.reset();

      var extractPath = pathMetric.extractPath(0.02 * pathLength,
          0.38 * pathLength + 0.42 * pathLength / 0.3 * (fraction - 0.3),
          startWithMoveTo: true);
      dstPath.addPath(extractPath, Offset(0, 0));
      canvas.drawPath(dstPath, painter);

      canvas.drawArc(bgRect, -105 / 180 * pi + 2 * pi * fraction,
          2 * pi * (1 - fraction), false, painter);
    } else if (fraction <= 0.8) {
      dstPath.reset();

      var extractPath = pathMetric.extractPath(
          0.02 * pathLength + 0.2 * pathLength / 0.2 * (fraction - 0.6),
          0.8 * pathLength + 0.2 * pathLength / 0.2 * (fraction - 0.6),
          startWithMoveTo: true);
      dstPath.addPath(extractPath, Offset(0, 0));
      canvas.drawPath(dstPath, painter);

      canvas.drawArc(bgRect, -105 / 180 * pi + 2 * pi * fraction,
          2 * pi * (1 - fraction), false, painter);
    } else {
      dstPath.reset();

      var extractPath = pathMetric.extractPath(
          10 * circleRadius * (fraction - 1), pathLength,
          startWithMoveTo: true);
      dstPath.addPath(extractPath, Offset(0, 0));
      canvas.drawPath(dstPath, painter);
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    initPaint();
    initSizeAndPath(size);
    draw(canvas);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
