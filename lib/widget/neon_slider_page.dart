import 'package:flutter/material.dart';

class NeonSliderPage extends StatefulWidget {
  const NeonSliderPage({super.key});

  @override
  State<NeonSliderPage> createState() => _NeonSliderPageState();
}

class _NeonSliderPageState extends State<NeonSliderPage>
    with SingleTickerProviderStateMixin {
  double _progress = 0.34;
  late AnimationController _flashController;
  late Animation<double> _flashAnimation;

  // 增加一个状态标记，用于实现“迟滞”逻辑
  bool _hasTriggeredFlash = false;

  @override
  void initState() {
    super.initState();
    _flashController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    // 使用 easeOutCubic 让爆发更有力
    _flashAnimation = CurvedAnimation(
      parent: _flashController,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _flashController.dispose();
    super.dispose();
  }

  void _updateProgress(double value) {
    setState(() {
      _progress = value;
    });

    // --- 核心修复 1: 迟滞逻辑 (Hysteresis) ---
    // 只有当进度 >= 0.99 且之前没触发过时，才触发
    if (value >= 0.99) {
      if (!_hasTriggeredFlash) {
        _hasTriggeredFlash = true;
        _flashController.forward(from: 0.0);
      }
    }
    // 只有当进度掉回到 0.90 以下时，才重置标记
    // 这样在 0.90 - 1.0 之间随意抖动，都不会导致动画重置和频闪
    else if (value < 0.90) {
      if (_hasTriggeredFlash) {
        _hasTriggeredFlash = false;
        _flashController.reset();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // 纯黑背景
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: AnimatedBuilder(
              animation: _flashAnimation,
              builder: (context, child) {
                return NeonSlider(
                  value: _progress,
                  height: 56,
                  flashValue: _flashAnimation.value,
                  onChanged: _updateProgress,
                );
              }),
        ),
      ),
    );
  }
}

class NeonSlider extends StatelessWidget {
  final double value;
  final double height;
  final double flashValue;
  final ValueChanged<double> onChanged;

  const NeonSlider({
    super.key,
    required this.value,
    required this.height,
    required this.flashValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final int displayValue = (value * 100).round();

        // 限制文字位置
        double textWidth = width * value;
        textWidth = textWidth < height ? height : textWidth;
        textWidth = textWidth > width ? width : textWidth;

        return GestureDetector(
          onHorizontalDragUpdate: (details) {
            double newValue =
                (details.localPosition.dx / width).clamp(0.0, 1.0);
            onChanged(newValue);
          },
          onTapDown: (details) {
            double newValue =
                (details.localPosition.dx / width).clamp(0.0, 1.0);
            onChanged(newValue);
          },
          child: SizedBox(
            height: height,
            width: width,
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                CustomPaint(
                  size: Size(width, height),
                  painter: _NeonPainter(
                    progress: value,
                    sliderHeight: height,
                    flashValue: flashValue,
                  ),
                ),
                if (value > 0.05)
                  Positioned(
                    left: 0,
                    width: textWidth,
                    height: height,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: EdgeInsets.only(right: height * 0.35),
                        child: Text(
                          "$displayValue",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: height * 0.32,
                            fontWeight: FontWeight.w600,
                            fontFamily: "monospace",
                            // 文字也跟随闪烁一点点，但不加 Blur 防止模糊
                            shadows: flashValue > 0.1
                                ? [
                                    Shadow(
                                        blurRadius: 10 * flashValue,
                                        color:
                                            Colors.white.withValues(alpha: 0.5))
                                  ]
                                : null,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _NeonPainter extends CustomPainter {
  final double progress;
  final double sliderHeight;
  final double flashValue;

  _NeonPainter({
    required this.progress,
    required this.sliderHeight,
    required this.flashValue,
  });

  final List<Color> _neonColors = const [
    Color(0xFFFF5F6D),
    Color(0xFFFFC371),
    Color(0xFF25D366),
    Color(0xFF00C6FF),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final double halfHeight = sliderHeight / 2;
    final Rect fullRect = Rect.fromLTWH(0, 0, size.width, sliderHeight);
    final RRect fullRRect =
        RRect.fromRectAndRadius(fullRect, Radius.circular(halfHeight));

    // 1. 底板背景 (深灰色)
    final Paint bgFillPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(0xFF151515);
    canvas.drawRRect(fullRRect, bgFillPaint);

    // 1.1 底板边框
    final Paint bgBorderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..color = Colors.white.withValues(alpha: 0.1);
    canvas.drawRRect(fullRRect, bgBorderPaint);

    // --- 准备激活区域 ---
    double activeWidth = size.width * progress;
    activeWidth = activeWidth < sliderHeight ? sliderHeight : activeWidth;
    final Rect activeRectBounds =
        Rect.fromLTWH(0, 0, activeWidth, sliderHeight);
    final RRect activeRRect =
        RRect.fromRectAndRadius(activeRectBounds, Radius.circular(halfHeight));

    // 压缩渐变 Shader
    final Shader activeGradientShader = LinearGradient(
      colors: _neonColors,
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    ).createShader(activeRectBounds);

    // --- 核心修复 2: 移除 BlendMode.plus，改用双重绘制增强亮度 ---
    // 这样上层的黑色遮罩就能 100% 遮住它，不会有光透出来。

    // 计算光晕参数
    double glowStrokeWidth = 8.0 + (18.0 * flashValue); // 宽度动态增加
    double glowBlurRadius = 8.0 + (16.0 * flashValue); // 模糊动态增加

    final Paint glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = glowStrokeWidth
      ..shader = activeGradientShader
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, glowBlurRadius);

    // 第一次绘制光晕：基础层
    // 使用 withOpacity 降低一点透明度，让光晕柔和
    glowPaint.color = Colors.white.withValues(alpha: 0.6);
    canvas.drawRRect(activeRRect, glowPaint);

    // 第二次绘制光晕：核心亮层 (仅在闪光较强时叠加)
    // 这种叠加方式比 BlendMode.plus 安全，不会穿透遮罩
    if (flashValue > 0.1) {
      final Paint glowHighLightPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = glowStrokeWidth * 0.8 // 稍微细一点
        ..shader = activeGradientShader
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, glowBlurRadius * 0.8);

      // 这里加一点白色滤镜来提亮，而不是用 BlendMode
      glowHighLightPaint.colorFilter = ColorFilter.mode(
          Colors.white.withValues(alpha: 0.5 * flashValue), BlendMode.srcATop);

      canvas.drawRRect(activeRRect, glowHighLightPaint);
    }

    // --- 3. 遮罩层 (Occlusion) ---
    // 纯黑遮挡，确保中间是黑的
    final Paint occlusionPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(0xFF151515);

    // 技巧：为了防止微小的抗锯齿缝隙漏光，我们把遮挡层极其微小地向外扩充 0.5 像素
    // 或者保持原样，因为去掉了 BlendMode.plus，普通遮挡通常就足够了。
    canvas.drawRRect(activeRRect, occlusionPaint);

    // --- 4. 顶层清晰边框 ---
    final Paint activeBorderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..shader = activeGradientShader;

    // 闪光时，实体边框也加白提亮，营造“过曝”感
    if (flashValue > 0) {
      activeBorderPaint.colorFilter = ColorFilter.mode(
          Colors.white.withValues(alpha: 0.4 * flashValue), BlendMode.srcATop);
    }

    canvas.drawRRect(activeRRect, activeBorderPaint);
  }

  @override
  bool shouldRepaint(covariant _NeonPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.flashValue != flashValue;
  }
}
