import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:matrix_gesture_detector/matrix_gesture_detector.dart';

class MatrixCustomPainterDemo extends StatefulWidget {
  @override
  _MatrixCustomPainterDemoState createState() => _MatrixCustomPainterDemoState();
}

class _MatrixCustomPainterDemoState extends State<MatrixCustomPainterDemo> {
  Matrix4 matrix = Matrix4.identity();
  ValueNotifier<Matrix4> notifier;

  @override
  void initState() {
    super.initState();
    notifier = ValueNotifier(matrix);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('MatrixCustomPainterDemo Demo'),
      ),
      body: MatrixGestureDetector(
        onMatrixUpdate: (m, tm, sm, rm) => notifier.value = m,
        child: CustomPaint(
          foregroundPainter: TestCustomPainter(context, notifier),
          child: Container(
            color: Colors.blueGrey,
          ),
        ),
      ),
    );
  }
}

class TestCustomPainter extends CustomPainter {
  ValueNotifier<Matrix4> notifier;
  Paint shapesPaint = Paint();
  Paint backgroundPaint = Paint();
  Path path;
  ui.Paragraph paragraph;
  Size currentSize = Size.zero;

  TestCustomPainter(BuildContext context, this.notifier)
      : super(repaint: notifier) {
    var _ = MediaQuery.of(context).size.shortestSide / 40;
    shapesPaint.strokeWidth = _;
    shapesPaint.style = PaintingStyle.stroke;
    ui.ParagraphBuilder builder = ui.ParagraphBuilder(ui.ParagraphStyle(
      textAlign: TextAlign.center,
      fontSize: Theme.of(context).textTheme.display2.fontSize *
          MediaQuery.of(context).textScaleFactor,
    ))
      ..pushStyle(ui.TextStyle(
        color: Colors.white,
        shadows: [
          ui.Shadow(
              color: Colors.grey, blurRadius: _ / 8, offset: Offset(0, _ / 4)),
        ],
      ))
      ..addText('use your two fingers to translate / rotate / scale ...')
      ..pop();
    paragraph = builder.build();
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (size != currentSize) {
      currentSize = size;
      RRect rr = RRect.fromLTRBR(size.width * 0.2, 100, size.width * 0.8,
          100 + size.height / 3, Radius.circular(shapesPaint.strokeWidth * 2));
      Offset offset = Offset(0, 100 + size.height / 3);
      path = Path();
      for (int i = 0; i < 3; i++) {
        path.addRRect(rr.shift(offset * i.toDouble()));
      }
      backgroundPaint.shader = LinearGradient(
        colors: [
          Color(0xff000044),
          Color(0xff000022),
        ],
        stops: [0.5, 1.0],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Offset.zero & size);
    }

    canvas.drawPaint(backgroundPaint);

    shapesPaint.color = Color(0xff880000);
    canvas.drawPath(path, shapesPaint);

    shapesPaint.color = Color(0xffbb6600);
    Matrix4 inverted = Matrix4.zero();
    inverted.copyInverse(notifier.value);
    canvas.save();
    canvas.transform(inverted.storage);
    canvas.drawPath(path, shapesPaint);
    canvas.restore();

    shapesPaint.color = Color(0xff008800);
    canvas.drawPath(path.transform(notifier.value.storage), shapesPaint);

    paragraph.layout(ui.ParagraphConstraints(width: size.width - 64));
    canvas.drawParagraph(paragraph, Offset(32, size.height * 0.3));
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}