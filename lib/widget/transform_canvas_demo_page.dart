import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';

class TransformCanvasDemoPage extends StatefulWidget {
  @override
  _TransformCanvasDemoPageState createState() =>
      _TransformCanvasDemoPageState();
}

class _TransformCanvasDemoPageState extends State<TransformCanvasDemoPage> {
  late Timer timer;
  var angle = 0.0;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(Duration(milliseconds: 300), (_) {
      setState(() {
        angle = angle + math.pi / 10;
      });
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: new Text("TransformCanvasDemoPage"),
      ),
      body: new Container(
        alignment: Alignment.center,
        child: Center(
          child: new Container(
            height: 200,
            width: 200,
            child: CustomPaint(
              foregroundPainter: _AnimationPainter(angle),
            ),
          ),
        ),
      ),
    );
  }
}

class _AnimationPainter extends CustomPainter {
  Paint _paint = new Paint();
  double angle;

  _AnimationPainter(this.angle);

  /// 绕 xy 轴对 canvas 进行旋转
  // renderPath(double angleX, double angleY, Canvas canvas,
  //     [double positionX = 0, double positionY = 0]) {
  //   var t = Matrix4.identity()
  //     ..rotateX(angleX)
  //     ..rotateY(angleY);
  //   t.leftTranslate(positionX, positionY);
  //   t.translate(0.0 - positionX, -positionY);
  //   Path path = Path();
  //   canvas.save();
  //   canvas.transform(t.storage);
  //   path.moveTo(-30.0 + positionX, positionY);
  //   path.lineTo(30.0 + positionX, positionY);
  //   canvas.drawPath(path, _paint);
  //   canvas.restore();
  // }
  //
  // @override
  // void paint(Canvas canvas, Size size) {
  //   _paint
  //     ..color = Colors.redAccent
  //     ..strokeWidth = 30
  //     ..style = PaintingStyle.stroke
  //     ..isAntiAlias = true
  //     ..strokeCap = StrokeCap.round
  //     ..strokeJoin = StrokeJoin.round;
  //   renderPath(0, 0, canvas, 0, -100);
  //   renderPath(0, math.pi / 2, canvas, 0, 0);
  //   renderPath(math.pi / 4, math.pi / 4, canvas, 100, 0);
  //   renderPath(math.pi / 2, math.pi / 2, canvas, 200, 0);
  // }



  ///绕 z 轴的旋转
  // renderPath(double angleZ, Canvas canvas,
  //     [double positionX = 0, double positionY = 0]) {
  //   var t = Matrix4.identity()..rotateZ(angleZ);
  //   t.leftTranslate(positionX, positionY);
  //   t.translate(-positionX, -positionY);
  //   Path path = Path();
  //   canvas.save();
  //   canvas.transform(t.storage);
  //   path.moveTo(-30.0 + positionX, positionY);
  //   path.lineTo(30.0 + positionX, positionY);
  //   canvas.drawPath(path, _paint);
  //   canvas.restore();
  // }
  //
  // @override
  // void paint(Canvas canvas, Size size) {
  //   _paint
  //     ..color = Colors.redAccent
  //     ..strokeWidth = 30
  //     ..style = PaintingStyle.stroke
  //     ..isAntiAlias = true
  //     ..strokeCap = StrokeCap.round
  //     ..strokeJoin = StrokeJoin.round;
  //
  //   renderPath(0, canvas, 0, 0);
  //   renderPath(0, canvas, 80, 0);
  //   renderPath(0, canvas, 160, 0);
  //   renderPath(0, canvas, 240, 0);
  // }



  renderPath(double angleX, double angleY, Canvas canvas,
      [double positionX = 0, double positionY = 0]) {
    Path path = new Path();
    var t = Matrix4.identity()..rotateX(angleX)..rotateY(angleY);
    t.leftTranslate(positionX, positionY);
    t.translate(-positionX, -positionY);
    path.moveTo(-30.0 + positionX, positionY);
    path.lineTo(30.0 + positionX, positionY);
    path = path.transform(t.storage);
    canvas.drawPath(path, _paint);
  }

  @override
  void paint(Canvas canvas, Size size) {
    _paint
      ..color = Colors.redAccent..strokeWidth = 30
      ..style = PaintingStyle.stroke..isAntiAlias = true
      ..strokeCap = StrokeCap.round..strokeJoin = StrokeJoin.round;
    renderPath(0, 0, canvas, 0, -100);
    renderPath(0, angle, canvas, 0, 0);
    renderPath(angle, 0, canvas, 100, 0);
    renderPath(angle, angle, canvas, 200, 0);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
