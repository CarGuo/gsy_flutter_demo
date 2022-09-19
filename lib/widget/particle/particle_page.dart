import 'package:flutter/material.dart';
import 'package:gsy_flutter_demo/widget/particle/particle_widget.dart';
import 'package:simple_animations/simple_animations.dart';
import 'package:supercharged/supercharged.dart';

enum _ColorTween { color1, color2 }

class ParticlePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        title: new Text("ParticlePage"),
      ),
      backgroundColor: Colors.black,
      body: Stack(children: <Widget>[
        Positioned.fill(child: AnimatedBackground()),
        Positioned.fill(child: ParticlesWidget(30)),
        Positioned.fill(
          child: new Center(
            child: new Text(
              "GSY Flutter Demo",
              style: new TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
          ),
        ),
      ]),
    );
  }
}

class AnimatedBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final tween = MovieTween()
      ..tween(
        _ColorTween.color1,
        Color(0xffD38312).tweenTo(Colors.lightBlue.shade900),
        duration: 3.seconds,
      )
      ..tween(
        _ColorTween.color2,
        Color(0xffA83279).tweenTo(Colors.blue.shade600),
        duration: 3.seconds,
      );

    return MirrorAnimationBuilder<Movie>(
      tween: tween,
      duration: tween.duration,
      builder: (context, value, child) {
        return Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    value.get<Color>(_ColorTween.color1),
                    value.get<Color>(_ColorTween.color2)
                  ])),
        );
      },
    );
  }
}