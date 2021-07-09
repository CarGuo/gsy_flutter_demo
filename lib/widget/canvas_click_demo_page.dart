import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

class CanvasClickDemoPage extends StatefulWidget {
  @override
  _CanvasClickDemoPageState createState() => _CanvasClickDemoPageState();
}

class _CanvasClickDemoPageState extends State<CanvasClickDemoPage>
    with SingleTickerProviderStateMixin {
  late Timer timer;

  late AnimationController controller;

  late Animation animation;

  @override
  void initState() {
    timer = Timer.periodic(Duration(milliseconds: 800), (_) {
      setState(() {});
    });
    controller = new AnimationController(
        vsync: this, duration: Duration(milliseconds: 100));
    animation = Tween(begin: 0.0, end: 0.0).animate(controller);
    super.initState();
  }

  @override
  void dispose() {
    timer.cancel();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var time = DateTime.now();
    return Scaffold(
        appBar: AppBar(
          title: new Text("CanvasClickDemoPage"),
        ),
        body: Container(
          child: Center(
            child: DebounceButton(
              onTap: () {
                if (controller.isAnimating) {
                  animation = Tween(begin: 0.0, end: 0.0).animate(controller);
                  controller.stop();
                  setState(() {});
                } else {
                  CurvedAnimation curvedAnimation = CurvedAnimation(
                      parent: controller, curve: Curves.bounceInOut);
                  animation = Tween(begin: -0.01 * pi, end: 0.01 * pi)
                      .animate(curvedAnimation);
                  controller.repeat(reverse: true);
                }
              },
              child: RotationTransition(
                turns: animation as Animation<double>,
                child: SizedBox(
                  width: 300,
                  height: 300,
                  child: CustomPaint(
                    painter: ClockPainter(
                      hour: time.hour,
                      minute: time.minute,
                      second: time.second,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ));
  }
}

class ClockPainter extends CustomPainter {
  final int? hour, minute, second;

  ClockPainter({this.hour, this.minute, this.second});

  static const Color DEFAULT_EDGE_COLOR = Colors.blueAccent;
  static const Color DEFAULT_EAR_AND_FOOT_COLOR = Colors.amber;
  static const Color DEFAULT_HEAD_COLOR = Colors.orange;
  static const Color DEFAULT_SCALE_AND_HANDS_COLOR = Colors.black;
  static const Color DEFAULT_SECOND_HAND_COLOR = Colors.red;

  static const double ARC_LENGTH = pi * 2;
  static const double SCALE_ARC_LENGTH_OFFSET = ARC_LENGTH / 12;

  static const double CLOCK_HOUR_HAND_ARC_LENGTH = SCALE_ARC_LENGTH_OFFSET;
  static const double CLOCK_MINUTE_HAND_ARC_LENGTH = ARC_LENGTH / 60;
  static const double CLOCK_SECOND_HAND_ARC_LENGTH =
      CLOCK_MINUTE_HAND_ARC_LENGTH;

  static const double CLOCK_START_ARC = 90 * pi / 180;

  Color edgeColor = DEFAULT_EDGE_COLOR;
  Color earColor = DEFAULT_EAR_AND_FOOT_COLOR;
  Color footColor = DEFAULT_EAR_AND_FOOT_COLOR;
  Color headColor = DEFAULT_HEAD_COLOR;
  Color scaleColor = DEFAULT_SCALE_AND_HANDS_COLOR;
  Color centerPointColor = DEFAULT_EAR_AND_FOOT_COLOR;
  Color hourHandColor = DEFAULT_SCALE_AND_HANDS_COLOR;
  Color minuteHandColor = DEFAULT_SCALE_AND_HANDS_COLOR;
  Color secondHandColor = DEFAULT_SECOND_HAND_COLOR;

  late Paint clockCirclePaint,
      earPaint,
      footPaint,
      headLinePaint,
      headCirclePaint,
      scalePaint,
      centerCirclePaint,
      hourHandPaint,
      minHandPaint,
      secondHandPaint;

  late Rect earRectF;
  late Path earPath, earPath2;

  late Offset footRightStartPointF,
      footRightEndPointF,
      footLeftStartPointF,
      footLeftEndPointF,
      earRightEndPointF,
      earLeftEndPointF;

  late double startScaleLength;
  late double stopScaleLength;

  late double stopHeadLength;

  late double stopHourHandLength;
  late double stopMinHandLength;
  late double stopSecondHandLength;

  late double scaleStartX, scaleStartY, scaleStopX, scaleStopY;

  double? centerX,
      centerY,
      clockStrokeWidth,
      clockRadius,
      clockEarRadius,
      headCircleRadius,
      centerCircleRadius,
      footCalculateRadius,
      earRightAngel,
      earLeftAngel,
      footRightAngel,
      footLeftAngel;

  void init() {
    clockCirclePaint = new Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.stroke
      ..color = edgeColor;

    earPaint = new Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.fill
      ..color = earColor;

    footPaint = new Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = footColor;

    scalePaint = new Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = scaleColor;

    headLinePaint = new Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.stroke
      ..color = headColor;

    headCirclePaint = new Paint()
      ..style = PaintingStyle.fill
      ..color = headColor;

    centerCirclePaint = new Paint()
      ..style = PaintingStyle.fill
      ..color = centerPointColor;

    hourHandPaint = new Paint()
      ..isAntiAlias = true
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.fill
      ..color = hourHandColor;

    minHandPaint = new Paint()
      ..isAntiAlias = true
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round
      ..color = minuteHandColor;

    secondHandPaint = new Paint()
      ..isAntiAlias = true
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round
      ..color = secondHandColor;

    earPath = new Path();
    earPath2 = new Path();

    footRightStartPointF = new Offset(0, 0);
    footRightEndPointF = new Offset(0, 0);
    footLeftStartPointF = new Offset(0, 0);
    footLeftEndPointF = new Offset(0, 0);
    earRightEndPointF = new Offset(0, 0);
    earLeftEndPointF = new Offset(0, 0);

    earRightAngel = 300 * pi / 180;
    earLeftAngel = 240 * pi / 180;

    footRightAngel = (60 * pi / 180);
    footLeftAngel = (120 * pi / 180);
  }

  void intiSize(int w, int h) {
    centerX = w / 2;
    centerY = h / 2;

    int minSize = min(w, h);

    clockRadius = minSize / 3;
    clockStrokeWidth = clockRadius! / 7;

    clockCirclePaint.strokeWidth =
        clockCirclePaint.strokeWidth = clockStrokeWidth!;
    clockEarRadius = clockRadius! / 3;
    earRectF = Rect.fromLTRB(centerX! - clockEarRadius!, centerY! - clockEarRadius!,
        centerX! + clockEarRadius!, centerY! + clockEarRadius!);

    earPath.reset();
    earPath2.reset();
    earPath.addArc(earRectF, pi, pi);
    earPath2.addArc(earRectF, pi, pi);

    footCalculateRadius = clockRadius! + (minSize - clockRadius!) / 4;
    footPaint.strokeWidth = clockStrokeWidth! * 2 / 3;
    scalePaint.strokeWidth = clockStrokeWidth! / 3;

    hourHandPaint.strokeWidth = clockStrokeWidth! / 3;
    minHandPaint.strokeWidth = hourHandPaint.strokeWidth;
    secondHandPaint.strokeWidth = hourHandPaint.strokeWidth / 2;
    headLinePaint.strokeWidth = footPaint.strokeWidth;
    headCircleRadius = clockStrokeWidth! / 2;
    centerCircleRadius = headCircleRadius;

    stopHeadLength = centerY! - clockRadius! - clockStrokeWidth! * 1.5;

    startScaleLength = clockRadius! * 5.2 / 7;
    stopScaleLength = clockRadius! * 5.6 / 7;

    stopHourHandLength = clockRadius! * 3.2 / 7;
    stopMinHandLength = clockRadius! * 4.2 / 7;
    stopSecondHandLength = clockRadius! * 4.2 / 7;

    initCoordinates();
  }

  void initCoordinates() {
    double earRightEndX =
        ((clockRadius! + clockStrokeWidth!) * cos(earRightAngel!) + centerX!);
    double earRightEndY =
        ((clockRadius! + clockStrokeWidth!) * sin(earRightAngel!) + centerY!);
    earRightEndPointF = Offset(earRightEndX, earRightEndY);

    double earLeftEndX =
        ((clockRadius! + clockStrokeWidth!) * cos(earLeftAngel!) + centerX!);
    double earLeftEndY =
        ((clockRadius! + clockStrokeWidth!) * sin(earLeftAngel!) + centerY!);
    earLeftEndPointF = Offset(earLeftEndX, earLeftEndY);

    double footRightStartX =
        ((clockRadius! + clockStrokeWidth! / 2) * cos(footRightAngel!) + centerX!);
    double footRightStartY =
        ((clockRadius! + clockStrokeWidth! / 2) * sin(footRightAngel!) + centerY!);

    footRightStartPointF = Offset(footRightStartX, footRightStartY);

    double footRightEndX =
        (footCalculateRadius! * cos(footRightAngel!) + centerX!);
    double footRightEndY =
        (footCalculateRadius! * sin(footRightAngel!) + centerY!);

    footRightEndPointF = Offset(footRightEndX, footRightEndY);

    double footLeftStartX =
        ((clockRadius! + clockStrokeWidth! / 2) * cos(footLeftAngel!) + centerX!);
    double footLeftStartY =
        ((clockRadius! + clockStrokeWidth! / 2) * sin(footLeftAngel!) + centerY!);
    footLeftStartPointF = Offset(footLeftStartX, footLeftStartY);

    double footLeftEndX = (footCalculateRadius! * cos(footLeftAngel!) + centerX!);
    double footLeftEndY = (footCalculateRadius! * sin(footLeftAngel!) + centerY!);

    footLeftEndPointF = Offset(footLeftEndX, footLeftEndY);
  }

  void drawClock(Canvas canvas) {
    canvas.drawCircle(Offset(centerX!, centerY!), clockRadius!, clockCirclePaint);

    for (var a = 0.0; a <= ARC_LENGTH; a += SCALE_ARC_LENGTH_OFFSET) {
      scaleStartX = startScaleLength * cos(a) + centerX!;
      scaleStartY = startScaleLength * sin(a) + centerY!;

      scaleStopX = stopScaleLength * cos(a) + centerX!;
      scaleStopY = stopScaleLength * sin(a) + centerY!;

      canvas.drawLine(Offset(scaleStartX, scaleStartY),
          Offset(scaleStopX, scaleStopY), scalePaint);
    }

    drawHour(canvas);
    drawMinute(canvas);
    drawSecond(canvas);
    canvas.drawCircle(
        Offset(centerX!, centerY!), centerCircleRadius!, centerCirclePaint);
  }

  void drawHour(Canvas canvas) {
    double angle = ((hour! % 12 + minute! / 60) * CLOCK_HOUR_HAND_ARC_LENGTH -
        CLOCK_START_ARC);

    double hourEndX = (stopHourHandLength * cos(angle) + centerX!);
    double hourEndY = (stopHourHandLength * sin(angle) + centerY!);

    canvas.drawLine(
        Offset(centerX!, centerY!), Offset(hourEndX, hourEndY), hourHandPaint);
  }

  void drawMinute(Canvas canvas) {
    double angle = (minute! * CLOCK_MINUTE_HAND_ARC_LENGTH - CLOCK_START_ARC);

    double minEndX = (stopMinHandLength * cos(angle) + centerX!);
    double minEndY = (stopMinHandLength * sin(angle) + centerY!);

    canvas.drawLine(
        Offset(centerX!, centerY!), Offset(minEndX, minEndY), minHandPaint);
  }

  void drawSecond(Canvas canvas) {
    double angle = (second! * CLOCK_SECOND_HAND_ARC_LENGTH - CLOCK_START_ARC);

    double secondEndX = (stopSecondHandLength * cos(angle) + centerX!);
    double secondEndY = (stopSecondHandLength * sin(angle) + centerY!);

    canvas.drawLine(Offset(centerX!, centerY!), Offset(secondEndX, secondEndY),
        secondHandPaint);
  }

  void drawHead(Canvas canvas) {
    canvas.drawLine(Offset(centerX!, centerY! - clockRadius!),
        Offset(centerX!, stopHeadLength), headLinePaint);

    canvas.drawCircle(
        Offset(centerX!, stopHeadLength), headCircleRadius!, headCirclePaint);
  }

  void drawEars(Canvas canvas, Size size) {
    canvas.saveLayer(Offset.zero & size, new Paint());
    canvas.translate(centerX!, centerY!);
    canvas.rotate(-atan2(centerX!, centerY!));
    canvas.translate(-centerX!, -centerY!);
    canvas.drawPath(
        earPath.transform(
            Matrix4.translationValues(10, -(centerX! - 20), 1).storage),
        earPaint);
    canvas.restore();

    canvas.save();
    canvas.translate(centerX!, centerY!);
    canvas.rotate(atan2(centerX!, centerY!));
    canvas.translate(-centerX!, -centerY!);
    canvas.drawPath(
        earPath2.transform(
            Matrix4.translationValues(-10, -(centerX! - 20), 1).storage),
        earPaint);
    canvas.restore();
  }

  void drawFoots(Canvas canvas) {
    canvas.drawLine(Offset(footRightStartPointF.dx, footRightStartPointF.dy),
        Offset(footRightEndPointF.dx, footRightEndPointF.dy), footPaint);
    canvas.drawLine(Offset(footLeftStartPointF.dx, footLeftStartPointF.dy),
        Offset(footLeftEndPointF.dx, footLeftEndPointF.dy), footPaint);
  }

  @override
  void paint(Canvas canvas, Size size) {
    init();
    intiSize(size.width.toInt(), size.height.toInt());

    drawHead(canvas);
    drawFoots(canvas);
    drawClock(canvas);
    drawEars(canvas, size);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

class DebounceButton extends StatefulWidget {
  final Widget? child;
  final GestureTapCallback? onTap;
  final double radius;

  DebounceButton({this.child, this.onTap, this.radius = 0});

  @override
  _DebounceButtonState createState() => _DebounceButtonState();
}

class _DebounceButtonState extends State<DebounceButton> {
  Duration durationTime = Duration(milliseconds: 500);
  Timer? timer;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      radius: widget.radius,
      borderRadius: BorderRadius.circular(widget.radius),
      onTap: () {
        setState(() {
          if (timer == null) {
            widget.onTap?.call();
            timer = new Timer(durationTime, () {
              timer = null;
            });
          }
        });
      },
      child: widget.child,
    );
  }
}
