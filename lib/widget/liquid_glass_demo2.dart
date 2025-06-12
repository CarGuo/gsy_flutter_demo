import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LiquidGlassShaderView2 extends StatefulWidget {
  const LiquidGlassShaderView2({super.key});

  @override
  State<LiquidGlassShaderView2> createState() => _LiquidGlassShaderViewState2();
}

class _LiquidGlassShaderViewState2 extends State<LiquidGlassShaderView2> {
  ui.FragmentProgram? _program;
  ui.Image? _texture;

  final _pointerPosition = ValueNotifier<Offset>(const Offset(-100, -100));
  bool _isPointerDown = false;

  @override
  void initState() {
    super.initState();
    _loadShaderAndTexture();
  }

  @override
  void dispose() {
    _pointerPosition.dispose();
    super.dispose();
  }

  Future<void> _loadShaderAndTexture() async {
    final program =
        await ui.FragmentProgram.fromAsset('shaders/liquid_glass2.frag');
    final byteData = await rootBundle.load('static/person.jpg');
    final codec = await ui.instantiateImageCodec(byteData.buffer.asUint8List());
    final frame = await codec.getNextFrame();

    setState(() {
      _program = program;
      _texture = frame.image;
    });
  }

  // 更新指针位置和按下状态，并触发重绘
  void _updatePointerState(Offset position, bool isDown) {
    _pointerPosition.value = position;
    if (_isPointerDown != isDown) {
      setState(() {
        _isPointerDown = isDown;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_program == null || _texture == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return Scaffold(
      appBar: AppBar(),
      body: GestureDetector(
        onPanStart: (details) =>
            _updatePointerState(details.localPosition, true),
        onPanUpdate: (details) =>
            _updatePointerState(details.localPosition, true),
        onPanEnd: (details) =>
            _updatePointerState(_pointerPosition.value, false),
        onTapDown: (details) =>
            _updatePointerState(details.localPosition, true),
        onTapUp: (details) => _updatePointerState(details.localPosition, false),
        child: SizedBox.expand(
          child: ValueListenableBuilder<Offset>(
            valueListenable: _pointerPosition,
            builder: (context, position, child) {
              return CustomPaint(
                painter: LiquidGlassPainter(
                  program: _program!,
                  texture: _texture!,
                  pointerPosition: position,
                  isPointerDown: _isPointerDown,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

// Painter (稍作调整以适应新的 Widget 结构)
class LiquidGlassPainter extends CustomPainter {
  LiquidGlassPainter({
    required this.program,
    required this.texture,
    required this.pointerPosition,
    required this.isPointerDown,
  });

  final ui.FragmentProgram program;
  final ui.Image texture;
  final Offset pointerPosition;
  final bool isPointerDown;

  @override
  void paint(Canvas canvas, Size size) {
    final shader = program.fragmentShader();

    // 设置 uniforms (与之前完全相同)
    shader.setFloat(0, size.width);
    shader.setFloat(1, size.height);
    shader.setFloat(2, pointerPosition.dx);
    shader.setFloat(3, pointerPosition.dy);
    shader.setFloat(4, isPointerDown ? 1.0 : 0.0);
    shader.setFloat(5, 0.0);
    shader.setImageSampler(0, texture);

    final paint = Paint()..shader = shader;
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      paint,
    );
  }

  @override
  bool shouldRepaint(LiquidGlassPainter oldDelegate) {
    // 当任何一个影响绘制的属性改变时，都应该重绘
    return oldDelegate.pointerPosition != pointerPosition ||
        oldDelegate.isPointerDown != isPointerDown ||
        oldDelegate.program != program ||
        oldDelegate.texture != texture;
  }
}
