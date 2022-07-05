import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_swiper_view/flutter_swiper_view.dart';
import 'package:flutter_swiper_view/src/transformer_page_view.dart';

class BottomAnimNavPage extends StatefulWidget {
  @override
  _BottomAnimNavPageState createState() => _BottomAnimNavPageState();
}

class _BottomAnimNavPageState extends State<BottomAnimNavPage>
    with SingleTickerProviderStateMixin {
  int index = 0;

  late AnimationController controller;

  late Animation animation;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(vsync: this)
      ..duration = Duration(milliseconds: 500);
    animation = Tween(begin: 0.0, end: 1.0).animate(controller);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColorDark,
      appBar: AppBar(
        title: new Text("ViewPagerDemoPage"),
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          Navigator.of(context).pop();
        },
        child: Container(
          alignment: Alignment.bottomCenter,
          margin: EdgeInsets.only(bottom: 50),
          child: Builder(
            builder: (context) {
              return TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                onPressed: () {
                  index = 0;
                  showBottomSheet(
                      context: context,
                      backgroundColor: Colors.transparent,
                      builder: (context) {
                        return new Container(
                          height: 300,
                          child: Stack(
                            children: <Widget>[
                              SizedBox.expand(
                                child: CustomPaint(
                                  painter: _RadiusPainter(
                                    width: MediaQuery.of(context).size.width,
                                    color: Colors.redAccent.withAlpha(190),
                                  ),
                                ),
                              ),
                              Swiper(
                                onIndexChanged: (index) {
                                  setState(() {
                                    this.index = index;
                                  });
                                },
                                itemBuilder: (BuildContext context, int index) {
                                  return ScaleTransition(
                                    scale: animation as Animation<double>,
                                    child: new Container(
                                      decoration: BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                          border:
                                              Border.all(color: Colors.white)),
                                      margin: EdgeInsets.symmetric(
                                          horizontal:
                                              (index == this.index) ? 5 : 10),
                                      child: InkWell(
                                        onTap: () {
                                          print("##### $index");
                                        },
                                        focusColor: Colors.transparent,
                                        hoverColor: Colors.transparent,
                                        highlightColor: Colors.transparent,
                                        splashColor: Colors.transparent,
                                        child: new Center(
                                          child: new Text(
                                            "$index",
                                            style: new TextStyle(
                                                fontSize: 20.0,
                                                color: Colors.white),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                                transformer: AngleTransformer(),
                                itemCount: 18,
                                itemWidth: 50,
                                viewportFraction: 0.16,
                              )
                            ],
                          ),
                        );
                      });
                  controller.reset();
                  controller.forward();
                },
                child: new Text(
                  "Show",
                  style: TextStyle(fontSize: 22, color: Colors.white),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class AngleTransformer extends PageTransformer {
  final double _fade;
  final double _radius;
  final double _horizontalOffset = 20;

  AngleTransformer({double fade: 1, double radius = 140})
      : _fade = fade,
        _radius = radius;

  @override
  Widget transform(Widget item, TransformInfo info) {
    double position = info.position!;
    Widget child = item;

    var dx = _horizontalOffset * (position.abs() * 10);
    var dy;
    if (dx <= _radius) {
      dy = _radius - math.sqrt((_radius * _radius) - (dx * dx));
    } else {
      dy = _radius;
    }

    dx = 0;

    double fadeFactor = (1 - position.abs()) * (1 - _fade);
    double opacity = _fade + fadeFactor;
    child = new Opacity(
      opacity: opacity,
      child: child,
    );

    child = new Transform.translate(
      offset: Offset(position.isNegative ? -dx : dx, dy),
      child: child,
    );

    return child;
  }
}

class _RadiusPainter extends CustomPainter {
  final double width;
  final Color? color;

  _RadiusPainter({required this.width, this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color ?? Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width < width ? size.width : width;
    canvas.drawArc(Rect.fromLTWH(0, size.height, width, size.height), 0.0,
        2 * math.pi, false, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
