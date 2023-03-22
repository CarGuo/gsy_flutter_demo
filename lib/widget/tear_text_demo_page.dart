import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:polygon/polygon.dart';

///类似 https://codepen.io/mattgrosswork/pen/VwprebG
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
    timer = Timer.periodic(Duration(milliseconds: 400), (timer) {
      tearFunction();
    });
    timer2 = Timer.periodic(Duration(milliseconds: 600), (timer) {
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
      Future.delayed(Duration(milliseconds: 150), () {
        setState(() {
          tear = false;
        });
      });
    }
  }

  double randomPosition(position) {
    return Random().nextInt(position).toDouble() *
        (Random().nextBool() ? -1 : 1);
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
              ..strokeWidth = 5
              ..color = Colors.white,
            shadows: [
              Shadow(
                blurRadius: 10,
                color: Colors.white,
                offset: Offset(0, 0),
              ),
              Shadow(
                blurRadius: 20,
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

  renderTearText1(CustomClipper<Path>? clipper) {
    return ShaderMask(
      blendMode: BlendMode.srcATop,
      shaderCallback: (bounds) {
        return LinearGradient(
          colors: [Colors.blue, Colors.green, Colors.red],
          stops: [0.0, 0.5, 1.0],
        ).createShader(bounds);
      },
      child: Container(
        alignment: Alignment.center,
        transform:
            Matrix4.translationValues(randomPosition(4), randomPosition(4), 0),
        child: ClipPath(
          child: ClipRect(
            clipper: SizeClipper(top: 30, bottomAspectRatio: 1.5),
            child: Text(
              widget.text,
              style: TextStyle(
                fontSize: 48,
                foreground: Paint()
                  ..style = PaintingStyle.stroke
                  ..strokeWidth = 5
                  ..color = Colors.white70,
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
      ),
    );
  }

  renderTearText2(CustomClipper<Path>? clipper) {
    return ClipPath(
      child: Container(
        alignment: Alignment.center,
        transform: Matrix4.translationValues(
            randomPosition(10), randomPosition(10), 0),
        padding: EdgeInsets.only(top: 10),
        child: ClipRect(
          clipper: SizeClipper(top: 20, bottomAspectRatio: 2),
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
      ),
      clipper: clipper,
    );
  }

  @override
  Widget build(BuildContext context) {
    var status = Random().nextInt(3);
    return Stack(
      children: [
        //renderTearText1(RandomTearingClipper(tear))
        if (tear && (status == 1)) renderTearText1(RandomTearingClipper(tear)),
        if (!tear || (tear && status != 2))
          renderMainText(RandomTearingClipper(tear)),
        if (tear && status == 2) renderTearText2(RandomTearingClipper(tear)),
      ],
    );
  }
}

class RandomTearingClipper extends CustomClipper<Path> {
  bool tear;

  RandomTearingClipper(this.tear);

  List<Offset> generatePoint() {
    List<Offset> points = [];
    var x = -1.0;
    var y = -1.0;
    for (var i = 0; i < 60; i++) {
      if (i % 2 != 0) {
        x = Random().nextDouble() * (Random().nextBool() ? -1 : 1);
      } else {
        y = Random().nextDouble() * (Random().nextBool() ? -1 : 1);
      }
      points.add(Offset(x, y));
    }
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

class SizeClipper extends CustomClipper<Rect> {
  final double top;
  final double bottomAspectRatio;

  SizeClipper({required this.top, required this.bottomAspectRatio});

  @override
  Rect getClip(Size size) {
    return new Rect.fromLTWH(
        0.0, top, size.width, size.height / bottomAspectRatio);
  }

  @override
  bool shouldReclip(CustomClipper<Rect> oldClipper) {
    return false;
  }
}
