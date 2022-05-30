import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

class ShaderCanvasDemoPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: new Text("ShaderCanvasDemoPage"),
      ),
      extendBody: true,
      body: Column(
        children: [
          ///增加 CustomWidget
          CanvasWidgetA(),
          new SizedBox(
            height: 5,
          ),
          CanvasWidgetB(),
        ],
      ),
    );
  }
}

class CanvasWidgetA extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Container(
          height: 100,
          width: constraints.biggest.width,
          child: CustomPaint(
            foregroundPainter: CurvePainterA(50),
          ));
    });
  }
}

class CurvePainterA extends CustomPainter {
  final double value;

  CurvePainterA(this.value);

  @override
  void paint(Canvas canvas, Size size) {
    final shader = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 5.0);

    final paint = Paint()..color = Colors.blue.withAlpha(60);

    var radientColors = [Color(0x01333333), Color(0x44333333)]; //渐变颜色数组

    ui.Gradient gradient = ui.Gradient.linear(
        Offset(0, 0), Offset(size.width, size.height), radientColors);
    shader.shader = gradient;

    final path = Path();

    final y1 = sin(value);
    final y2 = sin(value + pi / 2);
    final y3 = sin(value + pi);

    final startPointY = size.height * (0.5 + 0.4 * y1);
    final controlPointY = size.height * (0.5 + 0.4 * y2);
    final endPointY = size.height * (0.5 + 0.4 * y3);

    path.moveTo(size.width * 0, startPointY);
    path.quadraticBezierTo(
        size.width * 0.5, controlPointY, size.width, endPointY);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    canvas.drawPath(path, shader);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class CanvasWidgetB extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Container(
          height: 100,
          width: constraints.biggest.width,
          child: CustomPaint(
            foregroundPainter: CurvePainterB(50),
          ));
    });
  }
}

class CurvePainterB extends CustomPainter {
  final double value;

  CurvePainterB(this.value);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withAlpha(60)
      ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 2.0);

    final path = Path();

    final y1 = sin(value);
    final y2 = sin(value + pi / 2);
    final y3 = sin(value + pi);

    final startPointY = size.height * (0.5 + 0.4 * y1);
    final controlPointY = size.height * (0.5 + 0.4 * y2);
    final endPointY = size.height * (0.5 + 0.4 * y3);

    path.moveTo(size.width * 0, startPointY);
    path.quadraticBezierTo(
        size.width * 0.5, controlPointY, size.width, endPointY);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
