import 'dart:io';
import 'dart:math' as Math;
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

class AnimScanDemoPage extends StatefulWidget {
  @override
  _AnimScanDemoPageState createState() => _AnimScanDemoPageState();
}

class _AnimScanDemoPageState extends State<AnimScanDemoPage>
    with TickerProviderStateMixin {
  List<RippleCircle> rippleCircles = [];

  late AnimationController animController;
  Animation? animAnimation;
  int _sweepProgress = 0;

  late AnimationController imgAnimController;
  late Animation imgAnimation;

  int get sweepProgress => _sweepProgress;

  set sweepProgress(int value) {
    if (value >= 360) {
      _sweepProgress = 0;
    } else {
      _sweepProgress = value;
    }
  }

  @override
  void initState() {
    super.initState();

    animController = new AnimationController(vsync: this)
      ..duration = Duration(milliseconds: 1000);
    this.animAnimation = CurvedAnimation(
      parent: animController,
      curve: Curves.linear,
    )..addListener(() {
        sweepProgress++;
        updateState();
      });
    animController.repeat(reverse: true);

    imgAnimController = new AnimationController(vsync: this);
    imgAnimation =
        imgAnimController.drive<double>(new Tween(begin: 0.8, end: 1.0));
    startImgAnim();
  }

  @override
  void dispose() {
    animController.stop();
    imgAnimController.stop();
    super.dispose();
  }

  updateState() {
    setState(() {});
  }

  void startRipple(double width, double height) {
    var rippleCircle = RippleCircle();
    rippleCircle.cx = width / 2;
    rippleCircle.cx = height / 2;
    var maxRadius = Math.min(width, height) / 2;
    rippleCircle.startRadius = maxRadius / 3;
    rippleCircle.endRadius = maxRadius;
    rippleCircles.add(rippleCircle);
  }

  void startImgAnim() {
    const spring = SpringDescription(
      mass: 20,
      stiffness: 1,
      damping: 1,
    );
    final simulation = SpringSimulation(spring, 0, 0.8, -10);
    imgAnimController.animateWith(simulation);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("AnimScanDemoPage"),
        ),
        body: Container(
            child: Center(
                child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            new SizedBox(
              width: 300,
              height: 300,
              child: CustomPaint(
                painter: AnimScanPainter(
                    rippleCircles: rippleCircles, sweepProgress: sweepProgress),
              ),
            ),
            DebounceButton(
              onTap: () {
                startRipple(300, 300);
                startImgAnim();
              },
              radius: 70,
              child: ScaleTransition(
                scale: imgAnimation as Animation<double>,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(70),
                  child: new Image.asset(
                    "static/gsy_cat.png",
                    fit: BoxFit.cover,
                    width: 140,
                    height: 140,
                  ),
                ),
              ),
            )
          ],
        ))));
  }
}

class AnimScanPainter extends CustomPainter {
  final List<RippleCircle>? rippleCircles;
  final int? sweepProgress;

  AnimScanPainter({this.rippleCircles, this.sweepProgress});

  @override
  void paint(Canvas canvas, Size size) {
    var width = size.width;
    var height = size.height;

    var maxRadius = Math.min(width, height) / 2.0;
    var radius = maxRadius;

    var ripplePaint = Paint();
    ripplePaint.style = PaintingStyle.stroke;
    ripplePaint.strokeWidth = 1;
    ripplePaint.color = Colors.blue.withAlpha(200);
    ripplePaint.isAntiAlias = true;

    var backPaint = Paint();
    backPaint.style = PaintingStyle.fill;
    backPaint.isAntiAlias = true;
    backPaint.strokeWidth = 1;

    var colors = [
      Colors.blueAccent[700],
      Colors.blue,
      Color(0xFFFFF6F6),
      Colors.white,
    ];

    var sweepGradient =
        SweepGradient(colors: colors as List<Color>, stops: [0, 0.001, 0.9, 1]);

    /// shader 暂不支持 web
    if (Platform.isAndroid == true || Platform.isIOS == true) {
      backPaint.shader = sweepGradient.createShader(Offset.zero & size);
    }

    canvas.translate(width / 2, height / 2);
    double iDeg = 2 * Math.pi / 360 * sweepProgress!.toDouble();
    canvas.rotate(iDeg);
    canvas.translate(-width / 2, -height / 2);

    var rect = Rect.fromLTRB(width / 2.0 - radius, height / 2.0 - radius,
        width / 2.0 + radius, height / 2.0 + radius);
    canvas.saveLayer(rect, backPaint);

    canvas.drawCircle(Offset(width / 2, height / 2), radius, backPaint);

    backPaint.shader = SweepGradient(colors: [
      Color(0xFFFFF6F6).withAlpha(0),
      Color(0xFFFFF6F6).withAlpha(10),
      Colors.white.withAlpha(0),
      Color(0xFFFFF6F6).withAlpha(10),
      Colors.blue,
    ], stops: [
      0,
      0.001,
      0.001,
      0.9,
      1,
    ]).createShader(Offset.zero & size);

    canvas.drawArc(Rect.fromLTWH(0, 0, width, size.height), -0.3 * Math.pi,
        0.6 * Math.pi, true, backPaint);

    backPaint.shader = null;

    backPaint.blendMode = BlendMode.dstOut;
    canvas.drawCircle(Offset(width / 2, height / 2), radius / 2, backPaint);

    backPaint.blendMode = BlendMode.srcOver;

    canvas.translate(0, height / 2);
    if (rippleCircles != null) {
      for (int i = 0; i < rippleCircles!.length; i++) {
        var item = rippleCircles![i];
        bool result = item.draw(canvas, ripplePaint, rippleCircles);
        if (!result) {
          i--;
        }
      }
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

class RippleCircle {
  final int slice = 150;
  var startRadius = 0.0;
  var endRadius = 0.0;
  var cx = 0.0;
  var cy = 0.0;

  var progress = 0;

  bool draw(Canvas canvas, Paint paint, List? rippleCircles) {
    if (progress >= slice) {
      rippleCircles!.remove(this);
      return false;
    }
    progress++;

    paint.color =
        paint.color.withAlpha(((1 - progress / (slice * 1.0) * 255)).toInt());
    var radis = startRadius + (endRadius - startRadius) / slice * progress;
    canvas.drawCircle(Offset(cx, cy), radis, paint);
    return true;
  }
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
