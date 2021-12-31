import 'package:flutter/material.dart';

class GradientTextDemoPage extends StatelessWidget {
  const GradientTextDemoPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("GradientTextDemoPage"),
      ),
      body: Container(
        child: Center(
          child: Stack(
            children: [
              Text(
                '8',
                style: TextStyle(
                    fontSize: 100,
                    foreground: Paint()
                      ..style = PaintingStyle.fill
                      ..strokeWidth = 3
                      ..shader = LinearGradient(
                              begin: Alignment.bottomLeft,
                              end: Alignment.topRight,
                              colors: [Colors.yellow, Colors.black])
                          .createShader(Rect.fromLTWH(0, 0, 200, 100))),
              ),
              Text(
                '8',
                style: TextStyle(
                    fontSize: 100,
                    foreground: Paint()
                      ..style = PaintingStyle.stroke
                      ..strokeWidth = 2
                      ..shader = LinearGradient(
                              begin: Alignment.bottomLeft,
                              end: Alignment.topRight,
                              colors: [Colors.limeAccent, Colors.cyanAccent])
                          .createShader(Rect.fromLTWH(0, 0, 200, 100))),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
