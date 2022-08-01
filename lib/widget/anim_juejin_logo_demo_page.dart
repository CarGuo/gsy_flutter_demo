import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

class AnimJueJinLogoDemoPage extends StatefulWidget {
  const AnimJueJinLogoDemoPage({Key? key}) : super(key: key);

  @override
  State<AnimJueJinLogoDemoPage> createState() => _AnimJueJinLogoDemoPageState();
}

class _AnimJueJinLogoDemoPageState extends State<AnimJueJinLogoDemoPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("AnimJueJinLogoDemoPage"),
      ),
      body: Container(
        child: RiveAnimation.asset(
          'static/juejin.riv',
        ),
      ),
    );
  }
}
