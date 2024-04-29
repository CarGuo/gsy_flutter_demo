import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

class AnimJueJinLogoDemoPage extends StatefulWidget {
  const AnimJueJinLogoDemoPage({super.key});

  @override
  State<AnimJueJinLogoDemoPage> createState() => _AnimJueJinLogoDemoPageState();
}

class _AnimJueJinLogoDemoPageState extends State<AnimJueJinLogoDemoPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("AnimJueJinLogoDemoPage"),
      ),
      body: const RiveAnimation.asset(
        'static/juejin.riv',
      ),
    );
  }
}
