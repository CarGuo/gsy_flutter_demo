import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MosaicScannerPage extends StatefulWidget {
  const MosaicScannerPage({super.key});

  @override
  State<MosaicScannerPage> createState() => _MosaicScannerPageState();
}

class _MosaicScannerPageState extends State<MosaicScannerPage>
    with SingleTickerProviderStateMixin {
  ui.FragmentProgram? _program;
  ui.Image? _image;
  late AnimationController _controller;

  // 新增：使用 CurvedAnimation 来实现非匀速效果
  late Animation<double> _animation;
  double _time = 0.0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    // --- 1. 设置动画控制器 ---
    // 将单次扫描时长设置为 2.5秒
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    // --- 2. 设置动画曲线 (关键修改) ---
    // 使用 easeInOutQuint 曲线。这种曲线两头非常平缓，中间非常陡峭。
    // 完美模拟了“慢启动 -> 快速扫描通过 -> 慢结束”的质感。
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    // --- 3. 自定义带停顿的循环逻辑 (关键修改) ---
    // 监听动画状态，在到达终点或起点时暂停一下，再反向执行。
    _controller.addStatusListener((status) async {
      if (status == AnimationStatus.completed) {
        // 变成全马赛克了，停顿 1 秒
        await Future.delayed(const Duration(milliseconds: 1000));
        if (mounted) _controller.reverse(); // 然后反向（变清晰）
      } else if (status == AnimationStatus.dismissed) {
        // 变成全清晰了，停顿 1 秒
        await Future.delayed(const Duration(milliseconds: 1000));
        if (mounted) _controller.forward(); // 然后正向（变马赛克）
      }
    });

    // 启动动画循环
    _controller.forward();

    // 4. 加载资源
    _loadAssets();

    // 5. 启动波浪计时器 (保持不变)
    _timer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      if (mounted) {
        setState(() {
          _time += 0.016;
        });
      }
    });
  }

  Future<void> _loadAssets() async {
    final program =
        await ui.FragmentProgram.fromAsset('shaders/mosaic_wave.frag');
    // 请确保这里替换成了你自己的图片路径
    final image = await _loadImage('static/gsy_cat.png');

    setState(() {
      _program = program;
      _image = image;
    });
  }

  Future<ui.Image> _loadImage(String assetPath) async {
    final data = await rootBundle.load(assetPath);
    final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    final frame = await codec.getNextFrame();
    return frame.image;
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.only(top: 30),
            child: Text("当前效果不支持 Web ，请在 App 查看"),
          ),
        ),
      );
    }
    if (_program == null || _image == null) {
      return Scaffold(
        appBar: AppBar(),
        backgroundColor: Colors.black,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: AspectRatio(
          aspectRatio: _image!.width / _image!.height,
          // 注意：这里监听的是 _animation 而不是 _controller
          child: AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return CustomPaint(
                painter: _MosaicShaderPainter(
                  program: _program!,
                  image: _image!,
                  // 注意：这里传入的是经过曲线计算后的值 _animation.value
                  progress: _animation.value,
                  time: _time,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

// Painter 部分保持不变
class _MosaicShaderPainter extends CustomPainter {
  final ui.FragmentProgram program;
  final ui.Image image;
  final double progress;
  final double time;

  _MosaicShaderPainter({
    required this.program,
    required this.image,
    required this.progress,
    required this.time,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final shader = program.fragmentShader();
    shader.setFloat(0, size.width);
    shader.setFloat(1, size.height);
    shader.setFloat(2, time);
    shader.setFloat(3, progress);
    shader.setImageSampler(0, image);

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..shader = shader,
    );
  }

  @override
  bool shouldRepaint(covariant _MosaicShaderPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.time != time;
  }
}
