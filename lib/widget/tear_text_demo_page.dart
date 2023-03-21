import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:polygon/polygon.dart';

class TearTextDemoPage extends StatelessWidget {
  const TearTextDemoPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("TearTextDemoPage"),
      ),
      backgroundColor: Colors.black,
      body: Center(
        child: TearingText(text: "Hello Flutter"),
      ),
    );
  }
}

class TearingText extends StatefulWidget {
  final String text;

  TearingText({required this.text});

  @override
  _TearingTextState createState() => _TearingTextState();
}

class _TearingTextState extends State<TearingText> {
  late Timer timer;
  late Timer timer2;
  int count = 0;
  bool tear = false;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(Duration(milliseconds: 500), (timer) {
      tearFunction();
    });
    timer2 = Timer.periodic(Duration(milliseconds: 800), (timer) {
      tearFunction();
    });
  }

  @override
  void dispose() {
    timer.cancel();
    timer2.cancel();
    super.dispose();
  }

  tearFunction() {
    count++;
    tear = count % 2 == 0;
    if (tear == true) {
      setState(() {});
      Future.delayed(Duration(milliseconds: 200), () {
        setState(() {
          tear = false;
        });
      });
    }
  }

  renderMainText(CustomClipper<Path>? clipper) {
    return ClipPath(
      child: Center(
        child: Text(
          widget.text,
          style: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            foreground: Paint()
              ..style = PaintingStyle.fill
              ..strokeWidth = 10
              ..color = Colors.white,
          ),
        ),
      ),
      clipper: clipper,
    );
  }

  renderTearText1(CustomClipper<Path>? clipper) {
    return ShaderMask(
      blendMode: BlendMode.srcATop,
      shaderCallback: (bounds) {
        return LinearGradient(
          colors: [Colors.blue, Colors.green, Colors.red],
          stops: [0.0, 0.5, 1.0],
        ).createShader(bounds);
      },
      child: ClipPath(
        child: Align(
          child: Text(
            widget.text,
            style: TextStyle(
              fontSize: 48,
              foreground: Paint()
                ..style = PaintingStyle.stroke
                ..strokeWidth = 5
                ..color = Colors.white30,
              shadows: [
                Shadow(
                  blurRadius: 10,
                  color: Colors.white30,
                  offset: Offset(0, 0),
                ),
                Shadow(
                  blurRadius: 30,
                  color: Colors.white30,
                  offset: Offset(0, 0),
                ),
              ],
            ),
          ),
        ),
        clipper: clipper,
      ),
    );
  }

  renderTearText2(CustomClipper<Path>? clipper) {
    return ClipPath(
      child: Container(
        alignment: Alignment.center,
        margin: EdgeInsets.only(
            top: Random().nextInt(10).toDouble(),
            left: Random().nextInt(20).toDouble()),
        child: Text(
          widget.text,
          style: TextStyle(
            fontSize: 48,
            fontStyle: FontStyle.italic,
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 5
              ..color = Colors.white30,
            shadows: [
              Shadow(
                blurRadius: 10,
                color: Colors.white30,
                offset: Offset(0, 0),
              ),
              Shadow(
                blurRadius: 30,
                color: Colors.white30,
                offset: Offset(0, 0),
              ),
            ],
          ),
        ),
      ),
      clipper: clipper,
    );
  }

  @override
  Widget build(BuildContext context) {
    var status = Random().nextBool();
    var clipper = RandomTearingClipper(tear);
    return Stack(
      children: [
        renderMainText(clipper),
        if (tear && status) renderTearText1(clipper),
        if (tear && !status) renderTearText2(clipper),
      ],
    );
  }
}

class RandomTearingClipper extends CustomClipper<Path> {
  bool tear;

  RandomTearingClipper(this.tear);

  List<Offset> generatePoint() {
    List<Offset> points = [];
    var x = .0;
    var y = .0;
    for (var i = 0; i < 60; i++) {
      if (i % 2 != 0) {
        x = Random().nextDouble() * (Random().nextBool() ? -1 : 1);
      } else {
        y = Random().nextDouble() * (Random().nextBool() ? -1 : 1);
      }

      points.add(Offset(x, y));
    }
    print(points);
    return points;
  }

  @override
  Path getClip(Size size) {
    var points = generatePoint();
    var polygon = Polygon(points);
    if (tear)
      return polygon.computePath(rect: Offset.zero & size);
    else
      return Path()..addRect(Offset.zero & size);
  }

  @override
  bool shouldReclip(RandomTearingClipper oldClipper) => true;
}
