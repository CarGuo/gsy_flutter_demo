import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// 来自国外友人 codepen 上的杰作，这里主要提供阅读参考
/// https://codepen.io/rx-labz/pen/xxwdGaM?__cf_chl_jschl_tk__=830b2fd03dd1ccb9ac8d7c1fdbdee39e71fc2e7c-1587971334-0-AQ6h_JKRflUPLJcJhlH7eT841oCDgD5EttuC0cq9I50PQHwBtecDMdA9H-_a9FitSk4HQwlPO3dvvYn83act0FI6ufSlRL7MCB-gJVkKQov2i-AVA92X3KFwD93JOfog1LMy9yTdUyNb1zr43ZgC2X-cg0IsMGPr6U54kAb40AQgoK-KbYc9-KYWUIFqFy8pShOZIfn23-0lInSjKlJ3p8rnLXp84p7rhdTNrQU0pWPKNiDkuuthEaqzi9THfk4-iTrZ3CJ6wU0t81T9GyKwIT5VthFlnuPyNqIKseggtyxBxgZJ4W4ec6FmQoFp7bYAQF9rFb3D5L_3juEL-262JH_TP20ojcgjb30pvNnHyTfh

class AnimBubbleGumDemoPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("AnimBubbleGumDemoPage"),
      ),
      body: Container(color: Colors.pink[200], child: AnimBubbleGum()),
    );
  }
}

final size = ui.window.physicalSize / ui.window.devicePixelRatio;

const frequency = Duration(milliseconds: 50);

const numCircles = 299;

final red = Paint()..color = Colors.red;
final redStroke = Paint()
  ..color = Colors.red
  ..style = PaintingStyle.stroke;

final black = Paint()..color = Colors.black;

class Circle {
  final Offset? offset;
  final double radius;
  final Color color;

  const Circle({this.offset, this.color = Colors.white, this.radius = 10});
}

class AnimBubbleGum extends StatefulWidget {
  @override
  _AnimBubbleGumState createState() => _AnimBubbleGumState();
}

class _AnimBubbleGumState extends State<AnimBubbleGum> {
  late Timer timer;

  final circles = <Circle>[];

  Offset force = Offset(1, 1);

  HSLColor hslColor = HSLColor.fromColor(Colors.pink[100]!);

  final StreamController<List<Circle>> _circleStreamer =
      StreamController<List<Circle>>.broadcast();

  Stream<List<Circle>> get _circle$ => _circleStreamer.stream;

  Color get color => hslColor.toColor();

  Offset get randomPoint => size.topLeft(Offset.zero) * Random().nextDouble();

  @override
  void initState() {
    timer = Timer.periodic(
      frequency,
      (t) {
        if (circles.isEmpty)
          _circleStreamer.add(
            circles
              ..add(
                Circle(
                  offset: randomPoint,
                  radius: 1,
                  color: hslColor.toColor(),
                ),
              ),
          );
        int count = 0;
        while (count < 29) {
          final p = // newPoint
              size.bottomRight(Offset.zero) * 0.5 +
                  (size.bottomRight(Offset.zero) * 0.1).scale(
                    cos(circles.length / 59),
                    cos(circles.length / 99),
                  );

          hslColor = hslColor.withHue((hslColor.hue + 0.2) % 360).withLightness(
              min(1.0, .1 + sin(circles.length / 49).abs() / 10));

          final r = // radius
              size.width / 10 +
                  (size.height / 20 * sin(circles.length / 79 / 6));

          _circleStreamer
              .add(circles..add(Circle(offset: p, radius: r, color: color)));

          count++;
        }
      },
    );
    super.initState();
  }

  @override
  void dispose() {
    timer.cancel();
    _circleStreamer.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Stack(
        children: [
          StreamBuilder<List<Circle>>(
            initialData: [],
            stream: _circle$.map(
              (event) => event.length > numCircles
                  ? event
                      .getRange(event.length - numCircles, event.length)
                      .toList()
                  : event,
            ),
            builder: (context, snapshot) => CustomPaint(
              size: size,
              painter: Painter(circles: snapshot.data),
            ),
          ),
        ],
      );
}

class Painter extends CustomPainter {
  List<Circle>? circles;

  Painter({this.circles});

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < circles!.length - 1; i++) {
      final c = circles![i];
      final hsl = HSLColor.fromColor(c.color);
      final paint = Paint()
        ..color = c.color
        ..shader = ui.Gradient.linear(
          c.offset!,
          c.offset! + Offset(0, c.radius),
          [
            hsl.withLightness(max(0, min(1, hsl.lightness + 0.7))).toColor(),
            c.color,
          ],
        );
      var light = Paint();
      try {
        if (Platform.isAndroid  == true|| Platform.isIOS == true) {
          light = Paint()
            ..color = c.color
            ..shader = ui.Gradient.radial(
              c.offset! - Offset(0, c.radius),
              c.radius,
              [
                Color(0x53ffffff),
                Colors.transparent,
              ],
            );
        }
      } catch (e) {}
      //too heavy for mobile web rendering

      canvas
        ..drawCircle(c.offset!, c.radius, paint)
        ..drawCircle(c.offset!, c.radius, light)
        ..rotate(pi / 10800);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
