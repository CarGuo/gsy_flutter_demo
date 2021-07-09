import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

class AnimaDemoPage2 extends StatefulWidget {
  @override
  _AnimaDemoPageState2 createState() => _AnimaDemoPageState2();
}

class _AnimaDemoPageState2 extends State<AnimaDemoPage2>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  Animation? animation;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );

    animation = CurvedAnimation(
      parent: controller,
      curve: Curves.easeInSine,
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("AnimaDemoPage2"),
      ),
      body: Container(
        color: Colors.blueAccent,
        child: CRAnimation(
          minR: 0,
          maxR: 250,
          offset: Offset(MediaQuery.of(context).size.width / 2,
              MediaQuery.of(context).size.height / 2),
          animation: animation as Animation<double>?,
          child: Center(
            child: Container(
              alignment: Alignment.center,
              height: 250,
              width: 250,
              color: Colors.greenAccent,
              child: new Text("我我我我我我我我我我我说"),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (controller.status == AnimationStatus.completed ||
              controller.status == AnimationStatus.forward) {
            controller.reverse();
          } else {
            controller.forward();
          }
        },
        child: new Text("点我"),
      ),
    );
  }
}

class CRAnimation extends StatelessWidget {
  final Offset? offset;

  final double? minR;

  final double? maxR;

  final Widget child;

  final Animation<double>? animation;

  CRAnimation({
    required this.child,
    required this.animation,
    this.offset,
    this.minR,
    this.maxR,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation!,
      builder: (_, __) {
        return ClipPath(
          clipper: AnimationClipper(
            value: animation!.value,
            minR: minR,
            maxR: maxR,
            offset: offset,
          ),
          child: this.child,
        );
      },
    );
  }
}

class AnimationClipper extends CustomClipper<Path> {
  final double? value;

  final double? minR;

  final double? maxR;

  final Offset? offset;

  AnimationClipper({
    this.value,
    this.offset,
    this.minR,
    this.maxR,
  });

  @override
  bool shouldReclip(old) => true;

  @override
  Path getClip(Size size) {
    var path = Path();
    var offset = this.offset ?? Offset(size.width / 2, size.height / 2);

    var maxRadius = minR ?? radiusSize(size, offset);

    var minRadius = maxR ?? 0;

    var radius = lerpDouble(minRadius, maxRadius, value!)!;
    var rect = Rect.fromCircle(
      radius: radius,
      center: offset,
    );

    path.addOval(rect);
    return path;
  }

  double radiusSize(Size size, Offset offset) {
    final height = max(offset.dy, size.height - offset.dy);
    final width = max(offset.dx, size.width - offset.dx);
    return sqrt(width * width + height * height);
  }
}
