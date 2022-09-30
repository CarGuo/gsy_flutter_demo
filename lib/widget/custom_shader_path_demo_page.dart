import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class CustomShaderPathDemoPage extends StatefulWidget {
  const CustomShaderPathDemoPage({Key? key}) : super(key: key);

  @override
  State<CustomShaderPathDemoPage> createState() =>
      _CustomShaderPathDemoPageState();
}

class _CustomShaderPathDemoPageState extends State<CustomShaderPathDemoPage> {
  Future<ui.Image> _loadAssetImage() {
    Completer<ui.Image> completer = new Completer<ui.Image>();

    AssetImage("static/gsy_cat.png")
        .resolve(new ImageConfiguration())
        .addListener(
            ImageStreamListener((ImageInfo image, bool synchronousCall) {
      ui.Image img;
      img = image.image;
      completer.complete(img);
    }));

    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: new Text("CustomShaderPathDemoPage"),
        ),
        body: new Container(
          child: Center(
            child: FutureBuilder<ui.Image>(
              future: _loadAssetImage(),
              builder: (c, s) {
                if (s.data == null) {
                  return Container();
                }
                return new Container(
                  height: 200,
                  width: 200,
                  color: Colors.greenAccent,
                  child: CustomPaint(
                    ///直接使用值做动画
                    foregroundPainter: _AnimationPainter(s.data!),
                  ),
                );
              },
            ),
          ),
        ));
  }
}

class _AnimationPainter extends CustomPainter {
  final Paint _paint = new Paint();

  final ui.Image img;
  static const double CIRCLE_ANGLE = 360;

  _AnimationPainter(this.img);

  @override
  void paint(Canvas canvas, Size size) {

    var y1 = sin(50);
    var y2 = sin(50 + pi / 2);
    var y3 = sin(50 + pi);

    final startPointY = size.height * (0.5 + 0.4 * y1);
    final controlPointY = size.height * (0.5 + 0.4 * y2);
    final endPointY = size.height * (0.5 + 0.4 * y3);
    var path = Path();
    path.moveTo(size.width * 0, startPointY);
    path.quadraticBezierTo(
        size.width * 0.5, controlPointY, size.width, endPointY);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    canvas.drawPath(
        path,
        _paint
          ..shader = ImageShader(img, TileMode.repeated, TileMode.repeated,
              Matrix4.identity().scaled(0.2).storage)
          ..strokeWidth = 20
          ..style = PaintingStyle.stroke);



    ///网格
    var step = 1;
    var b = path.getBounds();
    canvas.save();
    canvas.clipPath(path);
    for (int i = step; i < b.width; i = i + step)
      canvas.drawLine(
          Offset(b.left + i, b.top), Offset(b.left + i, b.bottom), Paint());

    for (int i = step; i < b.height; i = i + step)
      canvas.drawLine(
          Offset(b.left, b.top + i), Offset(b.right, b.top + i), Paint());

    canvas.restore();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
