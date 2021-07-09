import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

class LoadingAnimButton extends StatefulWidget {
  final LoadingState? loadingState;
  final int loadingSpeed;

  LoadingAnimButton({this.loadingState, this.loadingSpeed = 2});

  @override
  _LoadingAnimButtonState createState() => _LoadingAnimButtonState();
}

class _LoadingAnimButtonState extends State<LoadingAnimButton>
    with SingleTickerProviderStateMixin {
  double currentRippleX = 0;

  late AnimationController loadingButtonController;
  late Animation loadingAnimation;

  LoadingState loadingState = LoadingState.STATE_PRE;

  @override
  void initState() {
    super.initState();
    loadingButtonController = new AnimationController(vsync: this)
      ..duration = Duration(milliseconds: 1000);
    this.loadingAnimation = CurvedAnimation(
      parent: loadingButtonController,
      curve: Curves.decelerate,
    )..addListener(updateState);
    loadingButtonController.repeat();
  }

  @override
  void dispose() {
    loadingAnimation.removeListener(updateState);
    loadingButtonController.stop();
    super.dispose();
  }

  updateState() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: LoadingButtonPainter(
          fraction: 1 - loadingAnimation.value as double,
          currentState: widget.loadingState,
          currentRippleX: currentRippleX,
          loadingSpeed: widget.loadingSpeed,
          currentRippleXCallback: (result) {
            currentRippleX = result;
          }),
    );
  }
}

enum LoadingState { STATE_PRE, STATE_DOWNLOADING, STATE_END, STATE_COMPLETE }

class LoadingButtonPainter extends CustomPainter {
  final double fraction;

  final LoadingState? currentState;
  final ValueChanged? currentRippleXCallback;
  final int loadingSpeed;

  late double width;

  late double height;

  late double circleRadius;

  late double centerX;
  late double centerY;
  late double baseLength;
  late double baseRippleLength;
  double currentRippleX;
  late Rect rect;
  late Rect clipRect;

  LoadingButtonPainter(
      {this.fraction = 1,
      this.currentState = LoadingState.STATE_PRE,
      this.currentRippleX = 0,
      this.loadingSpeed = 2,
      this.currentRippleXCallback});

  late Paint painter;
  late Paint bgPainter;
  Path path = Path();
  Path dstPath = Path();
  PathMetric? pathMetric;

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
    width = w;
    height = h;
    circleRadius = width * 5 / 12;
    baseLength = circleRadius / 3;
    baseRippleLength = 4.4 * baseLength / 12;
    centerX = w / 2;
    centerY = h / 2;
    currentRippleX = centerX - baseRippleLength * 10;
    rect = new Rect.fromLTRB(
        centerX - circleRadius,
        centerY + 0.6 * circleRadius,
        centerX + circleRadius,
        centerY + 2.6 * circleRadius);
    rect = Rect.fromLTRB(centerX - circleRadius, centerY - circleRadius,
        centerX + circleRadius, centerY + circleRadius);
    clipRect = Rect.fromLTRB(centerX - 6 * baseRippleLength, 0,
        centerX + 6 * baseRippleLength, height);
  }

  void draw(Canvas canvas) {
    switch (currentState) {
      case LoadingState.STATE_PRE:
        if (fraction <= 0.4) {
          canvas.drawCircle(Offset(centerX, centerY), circleRadius, bgPainter);
          canvas.drawLine(Offset(centerX - baseLength, centerY),
              Offset(centerX, centerY + baseLength), painter);
          canvas.drawLine(Offset(centerX, centerY + baseLength),
              Offset(centerX + baseLength, centerY), painter);
          canvas.drawLine(
              Offset(centerX,
                  centerY + baseLength - 1.3 * baseLength / 0.4 * fraction),
              Offset(
                  centerX,
                  centerY -
                      1.6 * baseLength +
                      1.3 * baseLength / 0.4 * fraction),
              painter);
        } else if (fraction <= 0.6) {
          canvas.drawCircle(Offset(centerX, centerY), circleRadius, bgPainter);
          canvas.drawCircle(
              Offset(centerX, centerY - 0.3 * baseLength), 2, painter);
          canvas.drawLine(
              Offset(
                  centerX -
                      baseLength -
                      baseLength * 1.2 / 0.2 * (fraction - 0.4),
                  centerY),
              Offset(centerX,
                  centerY + baseLength - baseLength / 0.2 * (fraction - 0.4)),
              painter);
          canvas.drawLine(
              Offset(centerX,
                  centerY + baseLength - baseLength / 0.2 * (fraction - 0.4)),
              Offset(
                  centerX +
                      baseLength +
                      baseLength * 1.2 / 0.2 * (fraction - 0.4),
                  centerY),
              painter);
        } else if (fraction <= 1) {
          canvas.drawCircle(Offset(centerX, centerY), circleRadius, bgPainter);
          canvas.drawCircle(
              Offset(
                  centerX,
                  centerY -
                      0.3 * baseLength -
                      (circleRadius - 0.3 * baseLength) /
                          0.4 *
                          (fraction - 0.6)),
              2,
              painter);
          canvas.drawLine(Offset(centerX - baseLength * 2.2, centerY),
              Offset(centerX + baseLength * 2.2, centerY), painter);
        } else {
          canvas.drawCircle(Offset(centerX, centerY), circleRadius, bgPainter);
          canvas.drawCircle(
              Offset(centerX,
                  centerY - circleRadius - baseLength * 3 * (fraction - 1)),
              3,
              painter);
          canvas.drawLine(Offset(centerX - baseLength * 2.2, centerY),
              Offset(centerX + baseLength * 2.2, centerY), painter);
        }
        break;
      case LoadingState.STATE_DOWNLOADING:
        canvas.drawCircle(Offset(centerX, centerY), circleRadius, bgPainter);
        canvas.drawArc(
            rect, -0.5 * pi, 359.99 / 180 * pi * fraction, false, painter);
        path.reset();
        currentRippleX += loadingSpeed;
        if (currentRippleX > centerX - baseRippleLength * 6)
          currentRippleX = centerX - baseRippleLength * 10;
        currentRippleXCallback?.call(currentRippleX);
        path.moveTo(currentRippleX, centerY);
        for (int i = 0; i < 4; i++) {
          path.relativeQuadraticBezierTo(baseRippleLength,
              -(1 - fraction) * baseRippleLength, baseRippleLength * 2, 0);
          path.relativeQuadraticBezierTo(baseRippleLength,
              (1 - fraction) * baseRippleLength, baseRippleLength * 2, 0);
        }
        canvas.save();
        canvas.clipRect(clipRect);
        canvas.drawPath(path, painter);
        canvas.restore();
        break;
      case LoadingState.STATE_END:
        canvas.drawCircle(Offset(centerX, centerY), circleRadius, painter);

        canvas.drawLine(
            Offset(centerX - baseLength * 2.2 + baseLength * 1.2 * fraction,
                centerY),
            Offset(centerX - baseLength * 0.5,
                centerY + baseLength * 0.5 * fraction * 1.3),
            painter);
        canvas.drawLine(
            Offset(centerX - baseLength * 0.5,
                centerY + baseLength * 0.5 * fraction * 1.3),
            Offset(centerX + baseLength * 2.2 - baseLength * fraction,
                centerY - baseLength * fraction * 1.3),
            painter);
        break;
      case LoadingState.STATE_COMPLETE:
      default:
        canvas.drawCircle(Offset(centerX, centerY), circleRadius, bgPainter);
        canvas.drawLine(
            Offset(centerX - baseLength, centerY),
            Offset(centerX - baseLength * 0.5 + baseLength * 0.5 * fraction,
                centerY + baseLength * 0.65 + baseLength * 0.35 * fraction),
            painter);
        canvas.drawLine(
            Offset(centerX - baseLength * 0.5 + baseLength * 0.5 * fraction,
                centerY + baseLength * 0.65 + baseLength * 0.35 * fraction),
            Offset(centerX + baseLength * 1.2 - baseLength * 0.2 * fraction,
                centerY - 1.3 * baseLength + 1.3 * baseLength * fraction),
            painter);
        canvas.drawLine(
            Offset(centerX - baseLength * 0.5 + baseLength * 0.5 * fraction,
                centerY + baseLength * 0.65 + baseLength * 0.35 * fraction),
            Offset(centerX - baseLength * 0.5 + baseLength * 0.5 * fraction,
                centerY + baseLength * 0.65 - baseLength * 2.25 * fraction),
            painter);
        break;
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
