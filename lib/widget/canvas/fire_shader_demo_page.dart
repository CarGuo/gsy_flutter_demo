import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class FireShaderDemoPage extends StatefulWidget {
  const FireShaderDemoPage({super.key});

  @override
  State<FireShaderDemoPage> createState() => _FireShaderDemoPageState();
}

class _FireShaderDemoPageState extends State<FireShaderDemoPage>
    with SingleTickerProviderStateMixin {
  FragmentShader? shader;
  late Ticker ticker;
  double elapsedSeconds = 0;

  @override
  void initState() {
    super.initState();
    FragmentProgram.fromAsset('shaders/fire.frag').then((program) {
      setState(() {
        shader = program.fragmentShader();
      });
    });

    ticker = createTicker((elapsed) {
      setState(() {
        elapsedSeconds = elapsed.inMilliseconds / 1000.0;
      });
    });
    ticker.start();
  }

  @override
  void dispose() {
    ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (shader == null) return const Scaffold(backgroundColor: Colors.black);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Fire Shader'),
      ),
      body: CustomPaint(
        painter: _FireShaderPainter(shader!, elapsedSeconds),
        size: Size.infinite,
      ),
    );
  }
}

class _FireShaderPainter extends CustomPainter {
  final FragmentShader shader;
  final double time;

  _FireShaderPainter(this.shader, this.time);

  @override
  void paint(Canvas canvas, Size size) {
    shader.setFloat(0, size.width);
    shader.setFloat(1, size.height);
    shader.setFloat(2, time);

    final paint = Paint()..shader = shader;
    canvas.drawRect(Offset.zero & size, paint);
  }

  @override
  bool shouldRepaint(covariant _FireShaderPainter oldDelegate) =>
      oldDelegate.time != time;
}
